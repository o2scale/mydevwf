# Frontend-Backend Gap Analysis

**Last Updated**: 2025-10-02
**Purpose**: Document the gaps between frontend implementation and backend requirements for the HDA v2.0 rebuild

---

## Executive Summary

The frontend (React + Vite, from Lovable.dev) is fully built and expects specific backend API endpoints, database structures, and Supabase Realtime channels. This document identifies all integration points and gaps that need to be addressed during backend development.

**Critical Finding**: Frontend uses a hybrid approach - some operations go through FastAPI backend, others directly query Supabase. The backend needs to accommodate both patterns.

---

## 1. API Endpoints Required by Frontend

### 1.1 Document Management Endpoints

#### **POST /api/documents/upload**
- **Used by**: `upload-store.ts:216`, `documents.ts:56`
- **Request**: `multipart/form-data` with file + query params
  - Query params: `source_language`, `target_language`, `tenant_id`
- **Expected Response**:
  ```typescript
  {
    id: string;           // UUID from Supabase documents table
    file_name: string;
    status: string;
    message?: string;
  }
  ```
- **Backend Action**: Upload file to Supabase Storage, create `documents` table record
- **Gap**: Backend endpoint doesn't exist yet

#### **GET /api/documents/{id}**
- **Used by**: `documents.ts:128`
- **Expected Response**: Full document object
  ```typescript
  {
    id: string;
    file_name: string;
    original_name: string;
    file_extension: string;
    mime_type: string;
    file_size: number;
    status: 'uploaded' | 'processing' | 'completed' | 'failed';
    storage_path: string;
    tenant_id: string;
    created_at: string;
    updated_at: string;
    source_language?: string;
    target_language?: string;
    user_id?: string;
  }
  ```
- **Fallback**: Frontend falls back to direct Supabase query if FastAPI unavailable
- **Gap**: Backend endpoint doesn't exist yet

#### **GET /api/documents/{id}/download**
- **Used by**: `documents.ts:240`
- **Purpose**: Return signed URL or direct file download
- **Expected Response**: File stream or signed URL
- **Gap**: Backend endpoint doesn't exist yet

---

### 1.2 Text Extraction Endpoints

#### **POST /api/text-extraction/extract-with-batching/{documentId}**
- **Used by**: `upload-store.ts:352`
- **Request Body**:
  ```typescript
  {
    auto_translate: boolean;
    target_languages: string[];
    selected_pages: number[];
  }
  ```
- **Expected Response**:
  ```typescript
  {
    job_id: string;      // UUID for extraction job
    status: string;
    message?: string;
  }
  ```
- **Backend Action**:
  - Create job in `text_extraction_results` table
  - Send message to pgmq `text_extraction_queue`
  - Start batch processing for large PDFs
- **Gap**: **CRITICAL** - This is the main extraction trigger endpoint, doesn't exist yet

#### **GET /api/text-extraction/status/{job_id}**
- **Used by**: `upload-store.ts:381`
- **Purpose**: Poll extraction job status
- **Expected Response**:
  ```typescript
  {
    job_id: string;
    status: 'queued' | 'processing' | 'completed' | 'failed';
    progress?: number;      // 0-100
    error_message?: string;
    current_page?: number;
    total_pages?: number;
  }
  ```
- **Polling Frequency**: Every 2 seconds, max 300 attempts (10 minutes)
- **Gap**: Backend endpoint doesn't exist yet

#### **POST /api/text-extraction/start/{documentId}**
- **Used by**: `text-extraction.ts:40`
- **Request Body**:
  ```typescript
  {
    auto_translate: boolean;
    target_languages: string[];
    selected_pages: number[];
  }
  ```
- **Expected Response**: TextExtractionJob object
- **Gap**: Backend endpoint doesn't exist yet

#### **GET /api/text-extraction/result/{documentId}**
- **Used by**: `text-extraction.ts:90`
- **Expected Response**: Array of extraction results (or single result)
- **Fallback**: Frontend queries Supabase `text_extraction_results` table directly
- **Gap**: Backend endpoint doesn't exist yet (but frontend has fallback)

#### **POST /api/text-extraction/process/{jobId}**
- **Used by**: `text-extraction.ts:218`
- **Purpose**: Retry failed extraction job
- **Expected Response**: Success/failure status
- **Gap**: Backend endpoint doesn't exist yet

---

### 1.3 Translation Endpoints

#### **GET /api/translation/status/{documentId}**
- **Used by**: `editor-store.ts:276`
- **Expected Response**:
  ```typescript
  {
    translations: Array<{
      id: string;
      target_language: string;
      status: 'queued' | 'processing' | 'completed' | 'failed';
      progress: number;
      queue_position?: number;
      error_message?: string;
      created_at: string;
      completed_at?: string;
    }>;
  }
  ```
- **Gap**: Backend endpoint doesn't exist yet

---

## 2. Database Tables Expected by Frontend

### 2.1 `documents` Table
**Direct Supabase Queries**: `documents.ts:92-108`, `editor-store.ts:67-73`, `dashboard-store.ts`

**Expected Schema**:
```sql
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    file_name TEXT NOT NULL,
    original_name TEXT NOT NULL,
    file_extension TEXT,
    mime_type TEXT,
    file_size BIGINT,
    status TEXT DEFAULT 'uploaded',  -- 'uploaded' | 'processing' | 'completed' | 'failed'
    storage_path TEXT NOT NULL,
    tenant_id UUID,
    user_id TEXT,
    source_language TEXT,
    target_language TEXT,
    page_count INTEGER,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Frontend Operations**:
- `SELECT *` with filters (status, search, pagination)
- `INSERT` for batch upload (`documents.ts:363-380`)
- `UPDATE` for status changes
- `DELETE` with cascade to storage

**Gap**: Table exists in PRD but needs exact schema match

---

### 2.2 `text_extraction_results` Table
**Direct Supabase Queries**: `text-extraction.ts`, `editor-store.ts:293-364`

**Expected Schema**:
```sql
CREATE TABLE text_extraction_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'queued',  -- 'queued' | 'processing' | 'completed' | 'failed'
    service_used TEXT,             -- 'vertex-ai-gemini-2.5-pro'
    extracted_text TEXT,
    confidence_score NUMERIC(5,2),
    page_count INTEGER,
    token_count INTEGER,
    processing_time INTEGER,       -- seconds
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);
```

**Frontend Operations**:
- `SELECT` by `document_id` (editor loads extraction)
- `SELECT` by `id` (job status polling)
- `UPDATE` status, progress fields (worker updates)

**Critical**: Frontend parses `extracted_text` field:
- Expects plain text with page markers: `# [Page N]`
- Splits by `\n` to create line-by-line editor view
- Uses page markers to assign page numbers to lines (`editor-store.ts:310-322`)

**Gap**: Table schema needs to match exactly, especially `extracted_text` format

---

### 2.3 `translations` Table
**Direct Supabase Queries**: `editor-store.ts:274-286`

**Expected Schema**:
```sql
CREATE TABLE translations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
    source_extraction_id UUID REFERENCES text_extraction_results(id),
    target_language TEXT NOT NULL,
    status TEXT DEFAULT 'queued',
    translated_text TEXT,
    progress INTEGER DEFAULT 0,
    queue_position INTEGER,
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);
```

**Frontend Operations**:
- `SELECT` all translations for a document
- Auto-select first completed translation

**Gap**: Table doesn't exist yet in backend

---

## 3. Supabase Storage Expected by Frontend

### 3.1 `documents` Storage Bucket
**Used by**: `documents.ts:353-359`, `documents.ts:186-194`

**Operations**:
- **Upload**: `supabase.storage.from('documents').upload(storagePath, file)`
  - Path format: `{tenantId}/{timestamp}-{filename}`
  - Content type from file MIME type
- **Delete**: `supabase.storage.from('documents').remove([storage_path])`
- **Signed URL**: `supabase.storage.from('documents').createSignedUrl(path, 3600)`
- **Public URL**: `supabase.storage.from('documents').getPublicUrl(path)`

**Expected Configuration**:
- Bucket name: `documents`
- Privacy: Private (requires RLS for access)
- File size limit: Support multi-GB PDFs

**Gap**: Bucket needs to be created with proper RLS policies

---

## 4. Supabase Realtime Channels

### 4.1 Document Changes Channel
**Used by**: `documents.ts:295-309`, `documents.ts:313-334`

**Channel Setup**:
```typescript
supabase
  .channel('document-{id}')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'documents',
    filter: `id=eq.{id}`
  }, callback)
  .subscribe()
```

**Use Case**: Live updates when document status changes (upload → processing → completed)

**Gap**: Requires Supabase Realtime enabled on `documents` table

---

### 4.2 Extraction Job Updates Channel
**Used by**: `text-extraction.ts:163-180`

**Channel Setup**:
```typescript
supabase
  .channel('extraction-job-{jobId}')
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'public',
    table: 'text_extraction_results',
    filter: `id=eq.{jobId}`
  }, callback)
  .subscribe()
```

**Use Case**: Live progress updates during extraction (avoids polling)

**Gap**: Requires Supabase Realtime enabled on `text_extraction_results` table

---

### 4.3 Translation Updates Channel
**Used by**: `ProgressiveEditor.tsx:108-128`

**Channel Setup**:
```typescript
supabase
  .channel('translation-updates')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'translations',
    filter: `document_id=eq.{documentId}`
  }, callback)
  .subscribe()
```

**Use Case**: Live updates when translation completes

**Gap**: Requires Supabase Realtime enabled on `translations` table

---

### 4.4 Dashboard Updates Channel
**Used by**: `dashboard-store.ts`

**Channel Setup**:
```typescript
supabase
  .channel('dashboard-updates')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'documents'
  }, callback)
  .subscribe()
```

**Use Case**: Dashboard refreshes when any document changes

**Gap**: Needs Realtime on `documents` table

---

## 5. Frontend Data Flow Analysis

### 5.1 Upload Flow (Frontend Perspective)

```
User Drops PDF
    ↓
1. upload-store.ts: Generate thumbnails, create file object
    ↓
2. documentsService.upload() → POST /api/documents/upload
    ↓
3. Backend uploads to Supabase Storage, creates documents record
    ↓
4. Frontend receives { id, file_name, status: 'ready' }
    ↓
5. Store documentId in upload-store
    ↓
6. User clicks "Process" → processFiles()
    ↓
7. POST /api/text-extraction/extract-with-batching/{documentId}
   Body: { auto_translate, target_languages, selected_pages }
    ↓
8. Backend returns { job_id }
    ↓
9. Frontend polls GET /api/text-extraction/status/{job_id} every 2s
    ↓
10. Backend worker updates text_extraction_results table
    ↓
11. Frontend receives { status: 'completed' }
    ↓
12. Redirect to Editor: /editor/{documentId}
```

**Gaps Identified**:
- Step 2: Backend upload endpoint doesn't exist
- Step 7: Batch extraction endpoint doesn't exist
- Step 9: Status polling endpoint doesn't exist
- Step 10: Worker logic doesn't exist

---

### 5.2 Editor Load Flow (Frontend Perspective)

```
User Navigates to /editor/{documentId}
    ↓
1. ProgressiveEditor.tsx useEffect
    ↓
2. Fetch document from Supabase:
   SELECT * FROM documents WHERE id = documentId
    ↓
3. loadExtraction(documentId) → editor-store.ts:291
    ↓
4. SELECT * FROM text_extraction_results
   WHERE document_id = documentId
   ORDER BY created_at DESC LIMIT 1
    ↓
5. Parse extracted_text:
   - Split by '\n'
   - Detect page markers: # [Page N]
   - Create TextLine[] with line numbers, confidence, page numbers
    ↓
6. Populate sourceText in editor-store
    ↓
7. Subscribe to Realtime:
   - postgres_changes on translations table
    ↓
8. fetchTranslations(documentId) → editor-store.ts:274
    ↓
9. GET /api/translation/status/{documentId}
    ↓
10. Render editor with source text + translations
```

**Gaps Identified**:
- Step 4: Requires `text_extraction_results` table with correct schema
- Step 5: `extracted_text` must have page markers in format `# [Page N]`
- Step 7: Realtime must be enabled on `translations` table
- Step 9: Translation status endpoint doesn't exist

---

### 5.3 Page Marker Format (Critical)

Frontend expects this **exact format** in `extracted_text`:

```
# [Page 1]
First line of page 1 text
Second line of page 1 text

# [Page 2]
First line of page 2 text
Second line of page 2 text

# [Page 3]
...
```

**Regex Used**: `/^#\s*\[Page\s+(\d+)\]$/i` (`editor-store.ts:311`)

**Why Critical**: Editor uses page markers to:
- Assign page numbers to each line
- Calculate total page count
- Enable page-based navigation in DocumentPanel
- Sync scroll between PDF viewer and text editor

**Backend Requirement**: Vertex AI extraction must insert page markers, OR backend post-processes extraction to add them.

---

## 6. Authentication & User Management

### 6.1 Current State
**From `documents.ts:342`**:
```typescript
// TEMPORARY: Skip authentication for development
const userId = 'anonymous-user';
```

**From `api.ts:24-37`**: Has auth interceptor for Supabase sessions, but not currently used.

### 6.2 Expected Future State
- Supabase Auth integration
- JWT tokens in API requests
- Row Level Security (RLS) based on `user_id` and `tenant_id`

**Gap**: Auth is mocked out, but infrastructure is ready. Story 1.8 will implement this.

---

## 7. Missing Backend Features

### 7.1 High Priority (Blocking Frontend)

1. **Document Upload API** (`POST /api/documents/upload`)
   - Upload to Supabase Storage
   - Create database record
   - Return document ID

2. **Batch Extraction API** (`POST /api/text-extraction/extract-with-batching/{documentId}`)
   - Queue job in pgmq
   - Create extraction job record
   - Return job ID

3. **Job Status API** (`GET /api/text-extraction/status/{job_id}`)
   - Query job status from database
   - Return progress info

4. **Extraction Worker**
   - Poll pgmq queue
   - Call Vertex AI Gemini 2.5 Pro
   - Handle batch processing for large PDFs
   - Insert page markers in extracted text
   - Update job status in real-time

5. **Database Tables**
   - `documents` (with exact schema match)
   - `text_extraction_results` (with exact schema match)
   - `translations` (for future translation support)

6. **Supabase Storage Bucket**
   - Create `documents` bucket
   - Set RLS policies

7. **Supabase Realtime**
   - Enable on `documents`, `text_extraction_results`, `translations` tables

---

### 7.2 Medium Priority (Frontend has Fallbacks)

1. **Get Document API** (`GET /api/documents/{id}`)
   - Frontend falls back to Supabase query

2. **Translation Status API** (`GET /api/translation/status/{documentId}`)
   - Frontend can query Supabase directly if needed

3. **Extraction Results API** (`GET /api/text-extraction/result/{documentId}`)
   - Frontend already queries Supabase directly

---

### 7.3 Low Priority (Future Features)

1. **Translation Worker** (Story 1.5)
2. **Export/Download System** (Story 1.7)
3. **User Management** (Story 1.8)
4. **Queue Management UI Backend** (Story 1.9)

---

## 8. Data Format Specifications

### 8.1 Upload Metadata
```typescript
{
  source_language: string;      // e.g., 'en', 'hi', 'es'
  target_language: string;      // e.g., 'es', 'en'
  priority: 'low' | 'normal' | 'high' | 'urgent';
  extraction_quality: 'fast' | 'balanced' | 'maximum';
}
```

### 8.2 Extraction Job Response
```typescript
{
  job_id: string;               // UUID
  document_id: string;          // UUID
  status: 'queued' | 'processing' | 'completed' | 'failed';
  progress: number;             // 0-100
  current_page?: number;
  total_pages?: number;
  error_message?: string;
  estimated_completion?: string;  // ISO timestamp
}
```

### 8.3 Extracted Text Format
```
# [Page 1]
Line 1 text here
Line 2 text here

# [Page 2]
Line 1 text here
...
```

**Must use**:
- Exact marker format: `# [Page N]`
- Newline-separated lines
- Blank line between pages (optional but recommended)

---

## 9. Recommendations for Backend Development

### 9.1 Story 1.1 (Supabase Setup)
- Create all tables with exact schemas from this document
- Create `documents` storage bucket
- Enable Realtime on `documents`, `text_extraction_results`, `translations`
- Test direct PostgreSQL connection (critical issue from previous attempt)

### 9.2 Story 1.2 (PDF Upload)
- Implement `POST /api/documents/upload`
- Test with large files (500+ page PDFs)
- Validate storage upload and database record creation
- Return proper response format

### 9.3 Story 1.3 (Vertex AI Extraction)
- Implement `POST /api/text-extraction/extract-with-batching/{documentId}`
- Implement `GET /api/text-extraction/status/{job_id}`
- Implement extraction worker with pgmq
- **CRITICAL**: Add page marker insertion logic (`# [Page N]`)
- Test batch processing for 500+ page PDFs
- Implement status updates via database (Realtime will auto-notify frontend)

### 9.4 Story 1.4 (Frontend Integration)
- Test full upload → extraction → editor flow
- Verify Realtime subscriptions work
- Test polling as fallback
- Validate data formats match frontend expectations

### 9.5 Story 1.5 (Translation)
- Implement `GET /api/translation/status/{documentId}`
- Implement translation worker
- Store translations in `translations` table
- Frontend already has full translation UI

---

## 10. Testing Checklist

### Backend Must Support:
- [ ] Upload 500+ page PDF
- [ ] Store in Supabase Storage
- [ ] Create document record with all fields
- [ ] Trigger extraction job via pgmq
- [ ] Process extraction in batches (token limits)
- [ ] Insert page markers in correct format
- [ ] Update status in real-time
- [ ] Handle extraction failures gracefully
- [ ] Support selected pages (not just full document)
- [ ] Return job ID immediately
- [ ] Poll status endpoint returns progress
- [ ] Realtime notifications work for status changes

### Frontend Should Receive:
- [ ] Document ID after upload
- [ ] Job ID after extraction request
- [ ] Status updates with progress percentage
- [ ] Extracted text with page markers
- [ ] Confidence scores (if available)
- [ ] Error messages on failure

---

## 11. Critical Architecture Decisions

### 11.1 Hybrid Backend Approach
Frontend uses **both**:
- **FastAPI Backend**: For Vertex AI operations (extraction, translation)
- **Direct Supabase**: For CRUD operations (documents, jobs, status)

**Why**: Reduces backend complexity. FastAPI only handles what Supabase can't (AI operations).

**Backend Implication**:
- Don't build full REST CRUD APIs for everything
- Focus on AI/queue operations
- Let frontend query Supabase directly for reads

### 11.2 Polling vs Realtime
Frontend implements **both**:
- **Polling**: `upload-store.ts:375-409` (every 2s, max 10 minutes)
- **Realtime**: `text-extraction.ts:163-180` (Supabase postgres_changes)

**Why**: Redundancy. Polling as fallback if Realtime fails.

**Backend Implication**: Just update database, frontend will get notified via Realtime OR polling.

### 11.3 Page Marker Format
Frontend **depends** on exact page marker format: `# [Page N]`

**Backend Implication**: Must be part of extraction pipeline, not optional.

---

## 12. Open Questions for PM/Frontend Team

1. **Queue Management**: Does frontend need queue priority changes during processing? (upload-store has priority setting, but no change-priority endpoint)

2. **Translation Trigger**: How does user trigger translation? Frontend has UI (`TranslationOptionsSection.tsx`), but no API call to start translation job.

3. **Batch Configuration**: Frontend has batch naming and configuration UI (`BatchConfigurationSection.tsx`), but no backend endpoints. Is this for future use?

4. **Template System**: Frontend has template selection UI (`TemplateSection.tsx`), but no template storage/retrieval logic. Is this for future use?

5. **Glossary Management**: Editor has full glossary UI (`ProgressiveEditor.tsx:138-192`), but no glossary CRUD endpoints. Priority for Story 1.6?

---

## 13. Immediate Next Steps

### For Backend Team:
1. Read this document thoroughly
2. Review `ARCHITECTURE_DECISIONS.md` for batch processing logic
3. Start with Story 1.1: Solve direct PostgreSQL connection issue
4. Implement tables with **exact schemas** from Section 2
5. Create storage bucket with RLS policies
6. Build extraction API endpoints (Section 1.2)
7. Implement extraction worker with page marker insertion
8. Test with real 500+ page PDFs from the start

### For PM:
1. Review open questions in Section 12
2. Prioritize which "future features" should be in MVP (templates, glossary, queue management)
3. Update Story 1.4 with integration testing scenarios
4. Clarify translation workflow (when/how it's triggered)

---

## Document Revision History
- **2025-10-02**: Initial creation based on frontend code analysis
