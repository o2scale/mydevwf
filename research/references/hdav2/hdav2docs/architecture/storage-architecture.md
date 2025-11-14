# Storage Architecture

**Version**: 2.0
**Last Updated**: 2025-10-02
**Purpose**: Supabase Storage configuration and usage for file management

---

## Overview

All files stored in **Supabase Storage** - a scalable object storage solution built on top of S3-compatible storage.

**Storage Type**: Private (requires authentication/RLS)
**File Types**: PDF only for MVP
**Max File Size**: 500MB per file

---

## Storage Bucket Configuration

### Bucket: `documents`

**Privacy**: Private (requires RLS for access)
**File Size Limit**: 500MB
**Allowed MIME Types**: `application/pdf`

**Create Bucket (SQL)**:
```sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', false);
```

**Create Bucket (Dashboard)**:
1. Go to Storage → Create bucket
2. Name: `documents`
3. Public: No
4. File size limit: 500MB

---

## Storage Path Structure

```
documents/
├── {tenant_id_1}/
│   ├── 1730544000000-document1.pdf
│   ├── 1730544001000-document2.pdf
│   └── ...
├── {tenant_id_2}/
│   ├── 1730544002000-document3.pdf
│   └── ...
└── ...
```

**Path Format**: `{tenant_id}/{timestamp}-{original_filename}`

**Example**:
```
documents/550e8400-e29b-41d4-a716-446655440000/1730544000000-my-document.pdf
```

---

## Storage Operations

### Upload File

```python
from supabase import create_client

supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)

# Generate storage path
tenant_id = "uuid"
timestamp = int(datetime.now().timestamp() * 1000)
filename = f"{timestamp}-{original_filename}"
storage_path = f"{tenant_id}/{filename}"

# Upload
supabase.storage.from_("documents").upload(
    storage_path,
    file_bytes,
    file_options={"content-type": "application/pdf"}
)
```

### Download File

```python
# Download file bytes
file_bytes = supabase.storage.from_("documents").download(storage_path)
```

### Get Signed URL (Temporary Access)

```python
# Create signed URL (expires in 1 hour)
signed_url = supabase.storage.from_("documents").create_signed_url(
    storage_path,
    expires_in=3600  # seconds
)

# URL format: https://{project}.supabase.co/storage/v1/object/sign/documents/{path}?token=...
```

### Get Public URL (if bucket is public)

```python
# For private buckets, use signed URLs instead
public_url = supabase.storage.from_("documents").get_public_url(storage_path)
```

### Delete File

```python
# Delete single file
supabase.storage.from_("documents").remove([storage_path])

# Delete multiple files
supabase.storage.from_("documents").remove([
    "tenant1/file1.pdf",
    "tenant1/file2.pdf"
])
```

### List Files in Folder

```python
# List all files for a tenant
files = supabase.storage.from_("documents").list(tenant_id)

# Response:
# [
#   {"name": "1730544000000-doc1.pdf", "id": "uuid", "size": 1024},
#   {"name": "1730544001000-doc2.pdf", "id": "uuid", "size": 2048}
# ]
```

---

## Row Level Security (RLS) Policies

### For MVP (No Auth - Disabled RLS)

```sql
-- Temporarily disable RLS for development
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;
```

### For Production (With Auth)

**Upload Policy**:
```sql
CREATE POLICY "Users can upload to own tenant folder"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'documents'
  AND (storage.foldername(name))[1] = auth.jwt() ->> 'tenant_id'
);
```

**Read Policy**:
```sql
CREATE POLICY "Users can read own tenant files"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'documents'
  AND (storage.foldername(name))[1] = auth.jwt() ->> 'tenant_id'
);
```

**Delete Policy**:
```sql
CREATE POLICY "Users can delete own files"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'documents'
  AND (storage.foldername(name))[1] = auth.jwt() ->> 'tenant_id'
);
```

---

## Storage Limits (Supabase Free Tier)

| Resource | Limit |
|----------|-------|
| Total Storage | 1GB |
| File Size | 50MB per file (configurable to 500MB) |
| Bandwidth | 2GB/month |
| Requests | Unlimited (within reasonable use) |

**Upgrade Path**: Pro tier ($25/month) = 100GB storage + 200GB bandwidth

---

## Integration with Backend

### Upload Flow

1. Frontend sends file to backend API
2. Backend validates file (type, size)
3. Backend calculates SHA-256 hash
4. Backend checks for duplicates in database
5. Backend uploads to Supabase Storage
6. Backend creates database record with `storage_path`
7. Backend returns document ID to frontend

### Worker Download Flow

1. Worker receives job from queue
2. Worker queries database for `storage_path`
3. Worker downloads PDF from Supabase Storage
4. Worker processes PDF (extraction)
5. Worker saves results to database
6. Worker deletes message from queue

---

## Virtual Page References (No Physical Page Splitting)

**Decision**: Store only the original PDF. Extract pages on-demand in worker memory.

**Why**:
- 50% storage savings
- Simpler state management
- No race conditions between workers
- Clean storage (1 file per document)

**Implementation**:
```python
class Worker:
    async def extract_batch(self, pdf_bytes, start_page, end_page):
        # Extract pages IN-MEMORY (not physical files)
        images = pdf2image.convert_from_bytes(
            pdf_bytes,
            first_page=start_page,
            last_page=end_page
        )

        # Send directly to Vertex AI
        result = await vertex_ai.extract_text(images)

        return result
```

---

## Cleanup Strategy (Future)

**Automatic Cleanup** (not implemented in MVP):
- Delete files after 30 days of inactivity
- Archive old documents to cheaper storage
- Implement storage quotas per tenant

**Manual Cleanup**:
```python
# Delete document and storage file
async def delete_document(document_id):
    # Get document
    doc = await db.get_document(document_id)

    # Delete from storage
    supabase.storage.from_("documents").remove([doc.storage_path])

    # Delete from database (cascade to related records)
    await db.delete_document(document_id)
```

---

## Performance Optimization

### Worker-Side Caching (Optional - Phase 2)

```python
from functools import lru_cache

@lru_cache(maxsize=10)  # Cache last 10 PDFs
async def download_pdf(storage_path):
    return supabase.storage.from_("documents").download(storage_path)
```

**Benefits**:
- 20x faster for repeated processing
- Reduces Supabase Storage bandwidth
- Useful for reprocessing same document

---

## Monitoring

### Storage Usage Query

```sql
-- Total storage per tenant
SELECT
    (storage.foldername(name))[1] as tenant_id,
    COUNT(*) as file_count,
    SUM((metadata->>'size')::bigint) as total_bytes
FROM storage.objects
WHERE bucket_id = 'documents'
GROUP BY tenant_id;
```

### Recent Uploads

```sql
SELECT name, created_at, (metadata->>'size')::bigint as size
FROM storage.objects
WHERE bucket_id = 'documents'
ORDER BY created_at DESC
LIMIT 10;
```

---

**Reference**: See `docs/stories/1.2-upload-api.md` for upload implementation details.
