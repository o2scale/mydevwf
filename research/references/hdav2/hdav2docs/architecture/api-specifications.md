# API Specifications

**Version**: 2.0
**Last Updated**: 2025-10-02
**Purpose**: Complete REST API endpoint specifications for HDA Translation Platform v2.0

---

## Base URL

```
Development: http://localhost:8000
Production: TBD
```

---

## 1. Document Upload API

### POST /api/documents/upload

Upload PDF to Supabase Storage and create database record.

**Request**:
```http
POST /api/documents/upload?source_language=en&target_language=es&tenant_id=xxx HTTP/1.1
Content-Type: multipart/form-data

file: [binary PDF data]
```

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| source_language | string | No | 'en' | ISO 639-1 code |
| target_language | string | No | null | Target language code |
| tenant_id | UUID | No | auto-generated | Tenant ID |

**Response** (200 OK):
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "file_name": "1730544000000-document.pdf",
  "original_name": "document.pdf",
  "status": "uploaded",
  "storage_path": "tenant-uuid/1730544000000-document.pdf",
  "page_count": 150,
  "file_size": 5242880,
  "message": "Document uploaded successfully"
}
```

**Error Responses**:
- `400 Bad Request` - Invalid file type or corrupt PDF
- `413 Payload Too Large` - File > 500MB
- `500 Internal Server Error` - Storage or database failure

---

## 2. Text Extraction API

### POST /api/text-extraction/extract-with-batching/{document_id}

Start text extraction job with intelligent batching for large PDFs.

**Request**:
```http
POST /api/text-extraction/extract-with-batching/550e8400-e29b-41d4-a716-446655440000 HTTP/1.1
Content-Type: application/json

{
  "auto_translate": false,
  "target_languages": ["es", "hi"],
  "selected_pages": [1, 2, 3, 5, 10]
}
```

**Request Body**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| auto_translate | boolean | No | Start translation after extraction |
| target_languages | string[] | No | Languages to translate to |
| selected_pages | number[] | No | Specific pages (null = all) |

**Response** (200 OK):
```json
{
  "job_id": "660e8400-e29b-41d4-a716-446655440000",
  "document_id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "queued",
  "message": "Text extraction job queued successfully",
  "estimated_time": 120,
  "batch_info": {
    "total_pages": 150,
    "selected_pages": 150,
    "total_batches": 3,
    "estimated_tokens": 450000,
    "batch_strategy": "token-based"
  }
}
```

---

### GET /api/text-extraction/status/{job_id}

Get extraction job status and progress.

**Request**:
```http
GET /api/text-extraction/status/660e8400-e29b-41d4-a716-446655440000 HTTP/1.1
```

**Response (Processing)**:
```json
{
  "job_id": "660e8400-e29b-41d4-a716-446655440000",
  "document_id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "processing",
  "progress": 67,
  "current_batch": 2,
  "total_batches": 3,
  "current_page": 100,
  "total_pages": 150,
  "estimated_completion": "2025-10-02T15:30:00Z",
  "message": "Processing batch 2 of 3"
}
```

**Response (Completed)**:
```json
{
  "job_id": "660e8400-e29b-41d4-a716-446655440000",
  "document_id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "completed",
  "progress": 100,
  "total_pages": 150,
  "total_batches": 3,
  "token_count": 450000,
  "processing_time": 180,
  "confidence_score": 95.5,
  "completed_at": "2025-10-02T15:25:00Z",
  "message": "Text extraction completed successfully"
}
```

**Response (Failed)**:
```json
{
  "job_id": "660e8400-e29b-41d4-a716-446655440000",
  "status": "failed",
  "progress": 34,
  "error_message": "Vertex AI API rate limit exceeded",
  "failed_at": "2025-10-02T15:20:00Z",
  "retry_count": 2
}
```

---

## 3. Translation API (Future)

### GET /api/translation/status/{document_id}

Get all translation jobs for a document.

**Request**:
```http
GET /api/translation/status/550e8400-e29b-41d4-a716-446655440000 HTTP/1.1
```

**Response** (200 OK):
```json
{
  "document_id": "550e8400-e29b-41d4-a716-446655440000",
  "translations": [
    {
      "id": "770e8400-e29b-41d4-a716-446655440000",
      "target_language": "es",
      "status": "completed",
      "progress": 100,
      "confidence_score": 92.5,
      "created_at": "2025-10-02T15:00:00Z",
      "completed_at": "2025-10-02T15:10:00Z"
    },
    {
      "id": "880e8400-e29b-41d4-a716-446655440000",
      "target_language": "hi",
      "status": "processing",
      "progress": 65,
      "queue_position": 2,
      "created_at": "2025-10-02T15:05:00Z"
    }
  ]
}
```

---

## 4. Health Check API

### GET /health

System health check with database connectivity test.

**Response**:
```json
{
  "status": "healthy",
  "database": "connected",
  "pgmq_queues": 2,
  "db_time": "2025-10-02 10:00:00.123456+00:00"
}
```

---

## Error Handling

All endpoints return errors in this format:

```json
{
  "detail": "Error message here"
}
```

**Common HTTP Status Codes**:
- `200 OK` - Success
- `400 Bad Request` - Invalid input
- `404 Not Found` - Resource not found
- `413 Payload Too Large` - File too large
- `500 Internal Server Error` - Server error

---

## CORS Configuration

**Allowed Origins**:
- `http://localhost:5173` (frontend dev)
- `http://localhost:3000` (alternative port)

**Allowed Methods**: `GET`, `POST`, `PUT`, `DELETE`, `OPTIONS`
**Allowed Headers**: `*`
**Credentials**: `true`

---

## Rate Limiting (Future)

Not implemented in MVP. Future consideration:
- 100 requests per minute per IP
- 1000 requests per hour per tenant

---

## Authentication (Future - Story 1.7)

Currently using `anonymous-user` placeholder. Future implementation will use:
- Supabase Auth JWT tokens
- Bearer token in Authorization header
- Row Level Security (RLS) based on user_id

---

**Reference**: See `docs/stories/1.2-upload-api.md` and `docs/stories/1.3-text-extraction.md` for detailed implementations.
