# HDA Translation Platform - Technical Architecture Document

**Version**: 2.0
**Last Updated**: 2025-10-02
**Status**: Implementation Ready
**Related Documents**:
- `NEW-PRD.md` - Product requirements and business goals
- `ARCHITECTURE_DECISIONS.md` - Architectural decisions and rationale
- `FRONTEND_BACKEND_GAP_ANALYSIS.md` - Frontend integration requirements

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Database Architecture](#2-database-architecture)
3. [API Specifications](#3-api-specifications)
4. [Queue Architecture](#4-queue-architecture)
5. [Storage Architecture](#5-storage-architecture)
6. [Realtime Architecture](#6-realtime-architecture)
7. [Batch Processing System](#7-batch-processing-system)
8. [Worker Architecture](#8-worker-architecture)
9. [Data Flow Specifications](#9-data-flow-specifications)
10. [Development Setup](#10-development-setup)
11. [Security & RLS Policies](#11-security--rls-policies)
12. [Monitoring & Observability](#12-monitoring--observability)

---

## 1. System Overview

### 1.1 Architecture Principles

1. **Supabase-First**: Use Supabase Cloud for all infrastructure (database, storage, auth, realtime)
2. **FastAPI for AI Only**: Backend API only handles Vertex AI operations and queue management
3. **Direct Frontend Queries**: Frontend queries Supabase directly for CRUD operations
4. **Realtime by Default**: Use Supabase Realtime for live updates, polling as fallback
5. **Virtual Pages**: No physical PDF splitting, only virtual page references
6. **Token-Based Batching**: Split large PDFs into batches based on token limits (not page count)

### 1.2 Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        FRONTEND (React + Vite)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Upload Store │  │ Editor Store │  │Dashboard Store│          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                  │                  │                   │
│         │ Direct Queries   │                  │                   │
│         ├──────────────────┼──────────────────┤                   │
│         │                  │                  │                   │
│         │  API Calls (AI)  │                  │                   │
│         ▼                  ▼                  ▼                   │
└─────────┼──────────────────┼──────────────────┼───────────────────┘
          │                  │                  │
          │                  │                  │
    ┌─────▼──────────────────▼──────────────────▼─────┐
    │         SUPABASE CLOUD (Free Tier)               │
    │  ┌────────────────────────────────────────────┐  │
    │  │  PostgreSQL 15+ with Extensions            │  │
    │  │  • pgmq (message queue)                    │  │
    │  │  • uuid-ossp (UUID generation)             │  │
    │  │  • Realtime (postgres_changes)             │  │
    │  └────────────────────────────────────────────┘  │
    │  ┌────────────────────────────────────────────┐  │
    │  │  Supabase Storage                          │  │
    │  │  • documents bucket (private)              │  │
    │  │  • RLS policies for multi-tenancy          │  │
    │  └────────────────────────────────────────────┘  │
    │  ┌────────────────────────────────────────────┐  │
    │  │  Supabase Realtime                         │  │
    │  │  • postgres_changes subscriptions          │  │
    │  │  • WebSocket connections                   │  │
    │  └────────────────────────────────────────────┘  │
    └──────────────────────────────────────────────────┘
                    │
                    │ Queue polling
                    │
    ┌───────────────▼──────────────────┐
    │   FASTAPI BACKEND (Python 3.13+) │
    │  ┌─────────────────────────────┐ │
    │  │  API Endpoints              │ │
    │  │  • /api/documents/upload    │ │
    │  │  • /api/text-extraction/*   │ │
    │  │  • /api/translation/*       │ │
    │  └─────────────────────────────┘ │
    │  ┌─────────────────────────────┐ │
    │  │  Background Workers         │ │
    │  │  • Text Extraction Worker   │ │
    │  │  • Translation Worker       │ │
    │  └─────────────────────────────┘ │
    └──────────────┬───────────────────┘
                   │
                   │ API calls
                   │
    ┌──────────────▼───────────────────┐
    │  VERTEX AI (Google Cloud)        │
    │  • Gemini 2.5 Pro (gemini-2.0)   │
    │  • 1M input / 65K output tokens  │
    │  • Multimodal (text + images)    │
    └──────────────────────────────────┘
```

### 1.3 Request Flow Types

**Type 1: CRUD Operations (Frontend → Supabase)**
```
Frontend → Supabase Client Library → PostgreSQL
Example: List documents, get extraction status
```

**Type 2: AI Operations (Frontend → FastAPI → Vertex AI)**
```
Frontend → FastAPI → Vertex AI → PostgreSQL (results) → Supabase Realtime → Frontend
Example: Start extraction, start translation
```

**Type 3: Background Processing (Worker → Vertex AI)**
```
Worker polls pgmq → Process job → Call Vertex AI → Update PostgreSQL → Realtime notifies frontend
Example: Text extraction worker processing queue
```

---

## 2. Database Architecture

### 2.1 Complete Schema

```sql
-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgmq";

-- ============================================================================
-- DOCUMENTS TABLE
-- Core document metadata and storage references
-- ============================================================================
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- File information
    file_name TEXT NOT NULL,              -- Generated filename (timestamp-based)
    original_name TEXT NOT NULL,          -- User's original filename
    file_extension TEXT,                  -- pdf, docx, etc.
    mime_type TEXT,                       -- application/pdf, etc.
    file_size BIGINT,                     -- Size in bytes
    file_hash VARCHAR(64),                -- SHA-256 for deduplication

    -- Storage reference
    storage_path TEXT NOT NULL,           -- Supabase Storage path: {tenant_id}/{file_name}

    -- Processing metadata
    page_count INTEGER,                   -- Total pages in document
    status TEXT DEFAULT 'uploaded',       -- 'uploaded' | 'processing' | 'completed' | 'failed'

    -- Language settings
    source_language TEXT,                 -- ISO 639-1 code (en, hi, es, etc.)
    target_language TEXT,                 -- Target language for translation

    -- Multi-tenancy
    tenant_id UUID NOT NULL,              -- Tenant/organization ID
    user_id TEXT DEFAULT 'anonymous-user',-- User who uploaded (Supabase Auth user_id)

    -- Additional metadata
    metadata JSONB,                       -- Flexible metadata storage
                                          -- Example: {"selected_pages": [1,2,5], "extraction_quality": "balanced"}

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Indexes
    CONSTRAINT unique_file_hash UNIQUE (file_hash)
);

-- Indexes for common queries
CREATE INDEX idx_documents_tenant_id ON documents(tenant_id);
CREATE INDEX idx_documents_user_id ON documents(user_id);
CREATE INDEX idx_documents_status ON documents(status);
CREATE INDEX idx_documents_created_at ON documents(created_at DESC);
CREATE INDEX idx_documents_file_hash ON documents(file_hash);

-- ============================================================================
-- TEXT_EXTRACTION_RESULTS TABLE
-- Stores text extraction job status and results
-- ============================================================================
CREATE TABLE text_extraction_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Document reference
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,

    -- Job status
    status TEXT DEFAULT 'queued',         -- 'queued' | 'processing' | 'completed' | 'failed'
    progress INTEGER DEFAULT 0,           -- 0-100 percentage

    -- Service information
    service_used TEXT,                    -- 'vertex-ai-gemini-2.5-pro'
    model_version TEXT,                   -- Exact model version used

    -- Extraction results
    extracted_text TEXT,                  -- Full extracted text with page markers
                                          -- Format: "# [Page 1]\nLine 1\nLine 2\n\n# [Page 2]\n..."
    confidence_score NUMERIC(5,2),        -- Overall confidence (0-100)

    -- Processing metadata
    page_count INTEGER,                   -- Pages processed
    token_count INTEGER,                  -- Total tokens used
    processing_time INTEGER,              -- Seconds taken
    batch_info JSONB,                     -- Batch processing details
                                          -- Example: {"total_batches": 3, "batch_size": 100, "batches": [...]}

    -- Selected pages (virtual page references)
    selected_pages INTEGER[],             -- Array of page numbers processed
                                          -- NULL means all pages

    -- Error handling
    error_message TEXT,                   -- Error details if failed
    retry_count INTEGER DEFAULT 0,        -- Number of retries attempted

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,

    -- Quality metrics
    low_confidence_pages INTEGER[],       -- Pages with confidence < 80%
    quality_metadata JSONB                -- Detailed quality metrics per page
);

-- Indexes
CREATE INDEX idx_extraction_document_id ON text_extraction_results(document_id);
CREATE INDEX idx_extraction_status ON text_extraction_results(status);
CREATE INDEX idx_extraction_created_at ON text_extraction_results(created_at DESC);

-- ============================================================================
-- TRANSLATIONS TABLE
-- Stores translation job status and results
-- ============================================================================
CREATE TABLE translations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Document reference
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    source_extraction_id UUID REFERENCES text_extraction_results(id) ON DELETE SET NULL,

    -- Language settings
    target_language TEXT NOT NULL,        -- ISO 639-1 code
    source_language TEXT,                 -- Detected or specified

    -- Job status
    status TEXT DEFAULT 'queued',         -- 'queued' | 'processing' | 'completed' | 'failed'
    progress INTEGER DEFAULT 0,           -- 0-100 percentage
    queue_position INTEGER,               -- Position in translation queue

    -- Service information
    service_used TEXT,                    -- 'vertex-ai-gemini-2.5-pro'
    model_version TEXT,

    -- Translation results
    translated_text TEXT,                 -- Full translated text with page markers
                                          -- Same format as extracted_text
    confidence_score NUMERIC(5,2),

    -- Processing metadata
    token_count INTEGER,
    processing_time INTEGER,
    batch_info JSONB,

    -- Glossary application
    glossary_id UUID,                     -- Reference to glossary used (future)
    glossary_matches INTEGER DEFAULT 0,   -- Number of glossary terms applied

    -- Selected pages
    selected_pages INTEGER[],             -- Pages to translate (virtual references)

    -- Error handling
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,

    -- Quality metrics
    quality_metadata JSONB
);

-- Indexes
CREATE INDEX idx_translations_document_id ON translations(document_id);
CREATE INDEX idx_translations_status ON translations(status);
CREATE INDEX idx_translations_target_language ON translations(target_language);
CREATE INDEX idx_translations_created_at ON translations(created_at DESC);

-- ============================================================================
-- DOCUMENT_PAGES TABLE
-- Virtual page references for batch processing coordination
-- ============================================================================
CREATE TABLE document_pages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- References
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    extraction_job_id UUID REFERENCES text_extraction_results(id) ON DELETE CASCADE,

    -- Page information
    page_number INTEGER NOT NULL,         -- 1-based page number
    batch_number INTEGER,                 -- Which batch this page belongs to

    -- Processing status
    status TEXT DEFAULT 'pending',        -- 'pending' | 'processing' | 'completed' | 'failed'

    -- Results
    extracted_text TEXT,                  -- Text for this page only
    confidence_score NUMERIC(5,2),
    token_count INTEGER,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,

    -- Unique constraint
    CONSTRAINT unique_doc_page UNIQUE (document_id, extraction_job_id, page_number)
);

-- Indexes
CREATE INDEX idx_doc_pages_extraction_job ON document_pages(extraction_job_id);
CREATE INDEX idx_doc_pages_batch_number ON document_pages(batch_number);
CREATE INDEX idx_doc_pages_status ON document_pages(status);

-- ============================================================================
-- PROCESSING_BATCHES TABLE
-- Tracks batch processing for large documents
-- ============================================================================
CREATE TABLE processing_batches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- References
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    extraction_job_id UUID REFERENCES text_extraction_results(id) ON DELETE CASCADE,

    -- Batch information
    batch_number INTEGER NOT NULL,        -- 1-based batch number
    total_batches INTEGER NOT NULL,       -- Total number of batches

    -- Page range
    start_page INTEGER NOT NULL,
    end_page INTEGER NOT NULL,
    page_count INTEGER NOT NULL,

    -- Token estimation
    estimated_tokens INTEGER,
    actual_tokens INTEGER,

    -- Status
    status TEXT DEFAULT 'pending',        -- 'pending' | 'processing' | 'completed' | 'failed'

    -- Results
    extracted_text TEXT,                  -- Combined text for this batch
    confidence_score NUMERIC(5,2),

    -- Processing metadata
    processing_time INTEGER,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,

    -- Unique constraint
    CONSTRAINT unique_extraction_batch UNIQUE (extraction_job_id, batch_number)
);

-- Indexes
CREATE INDEX idx_batches_extraction_job ON processing_batches(extraction_job_id);
CREATE INDEX idx_batches_status ON processing_batches(status);
CREATE INDEX idx_batches_batch_number ON processing_batches(batch_number);

-- ============================================================================
-- AUTO-UPDATE TRIGGERS
-- Automatically update updated_at timestamps
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables
CREATE TRIGGER update_documents_updated_at
    BEFORE UPDATE ON documents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_text_extraction_results_updated_at
    BEFORE UPDATE ON text_extraction_results
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_translations_updated_at
    BEFORE UPDATE ON translations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_document_pages_updated_at
    BEFORE UPDATE ON document_pages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_processing_batches_updated_at
    BEFORE UPDATE ON processing_batches
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

### 2.2 Database Schema Diagram

```
documents (1) ────┬──────> (*) text_extraction_results
   │              │              │
   │              │              └──────> (*) document_pages
   │              │              │
   │              │              └──────> (*) processing_batches
   │              │
   │              └──────> (*) translations
   │
   └── storage_path references Supabase Storage bucket
```

### 2.3 Critical Schema Notes

1. **Page Markers in extracted_text**: Must use format `# [Page N]` (regex: `/^#\s*\[Page\s+(\d+)\]$/i`)
2. **Virtual Pages**: No physical PDF files stored per page, only references in `document_pages`
3. **Batch Coordination**: `processing_batches` tracks which pages are in which batch
4. **Cascade Deletes**: Deleting a document cascades to all related records
5. **Token Counts**: Store both estimated and actual tokens for cost tracking

---

## 3. API Specifications

### 3.1 Document Upload API

#### **POST /api/documents/upload**

**Purpose**: Upload PDF to Supabase Storage and create database record

**Request**:
```http
POST /api/documents/upload?source_language=en&target_language=es&tenant_id=xxx HTTP/1.1
Content-Type: multipart/form-data

file: [binary PDF data]
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| source_language | string | No | ISO 639-1 code (default: 'en') |
| target_language | string | No | Target language code |
| tenant_id | UUID | No | Tenant ID (auto-generated if not provided) |

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

**Response** (400 Bad Request):
```json
{
  "detail": "Invalid file type. Only PDF files are supported."
}
```

**Response** (413 Payload Too Large):
```json
{
  "detail": "File size exceeds maximum limit of 500MB"
}
```

**Implementation Steps**:
1. Validate file type (must be application/pdf)
2. Generate unique filename: `{timestamp}-{original_name}`
3. Calculate SHA-256 hash for deduplication
4. Check if file_hash exists in database
5. Upload to Supabase Storage: `{tenant_id}/{file_name}`
6. Extract page count using PyPDF2 or similar
7. Create database record in `documents` table
8. Return response with document ID

**Backend Code Reference**:
```python
from fastapi import FastAPI, UploadFile, File, Query
from supabase import create_client
import hashlib
from datetime import datetime

@app.post("/api/documents/upload")
async def upload_document(
    file: UploadFile = File(...),
    source_language: str = Query(default="en"),
    target_language: str = Query(default="es"),
    tenant_id: str = Query(default=None)
):
    # Validate file type
    if file.content_type != "application/pdf":
        raise HTTPException(400, "Invalid file type")

    # Generate filename
    timestamp = int(datetime.now().timestamp() * 1000)
    file_name = f"{timestamp}-{file.filename}"

    # Calculate hash
    content = await file.read()
    file_hash = hashlib.sha256(content).hexdigest()

    # Check for duplicate
    existing = supabase.table("documents").select("id").eq("file_hash", file_hash).execute()
    if existing.data:
        return {"id": existing.data[0]["id"], "message": "Document already exists"}

    # Upload to storage
    tenant_id = tenant_id or str(uuid.uuid4())
    storage_path = f"{tenant_id}/{file_name}"
    supabase.storage.from_("documents").upload(storage_path, content)

    # Create database record
    doc = supabase.table("documents").insert({
        "file_name": file_name,
        "original_name": file.filename,
        "storage_path": storage_path,
        "file_size": len(content),
        "file_hash": file_hash,
        "tenant_id": tenant_id,
        "source_language": source_language,
        "target_language": target_language,
        "page_count": get_page_count(content),
        "status": "uploaded"
    }).execute()

    return doc.data[0]
```

---

### 3.2 Text Extraction API

#### **POST /api/text-extraction/extract-with-batching/{document_id}**

**Purpose**: Start text extraction job with intelligent batching for large PDFs

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
| auto_translate | boolean | No | Start translation after extraction (default: false) |
| target_languages | string[] | No | Languages to translate to |
| selected_pages | number[] | No | Specific pages to extract (null = all pages) |

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

**Implementation Steps**:
1. Validate document exists and status is 'uploaded'
2. Create job record in `text_extraction_results` table
3. Estimate token count based on page count and document type
4. Calculate batch strategy:
   - Digital PDFs: 50-100 pages per batch
   - Scanned PDFs: 20-30 pages per batch
   - Token limit: 900K tokens per batch (leaving buffer from 1M limit)
5. Create batch records in `processing_batches` table
6. Send message to pgmq `text_extraction_queue`:
   ```json
   {
     "job_id": "uuid",
     "document_id": "uuid",
     "batch_count": 3,
     "priority": "normal"
   }
   ```
7. Update document status to 'processing'
8. Return job ID and batch info

---

#### **GET /api/text-extraction/status/{job_id}**

**Purpose**: Get extraction job status and progress

**Request**:
```http
GET /api/text-extraction/status/660e8400-e29b-41d4-a716-446655440000 HTTP/1.1
```

**Response** (200 OK - Processing):
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

**Response** (200 OK - Completed):
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

**Response** (200 OK - Failed):
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

**Implementation**:
```python
@app.get("/api/text-extraction/status/{job_id}")
async def get_extraction_status(job_id: str):
    # Query job status
    job = supabase.table("text_extraction_results").select("*").eq("id", job_id).single().execute()

    if not job.data:
        raise HTTPException(404, "Job not found")

    # Get batch progress
    batches = supabase.table("processing_batches").select("*").eq("extraction_job_id", job_id).execute()
    completed_batches = len([b for b in batches.data if b["status"] == "completed"])
    total_batches = len(batches.data)

    # Calculate progress
    progress = int((completed_batches / total_batches) * 100) if total_batches > 0 else 0

    return {
        "job_id": job_id,
        "status": job.data["status"],
        "progress": progress,
        "current_batch": completed_batches + 1 if completed_batches < total_batches else total_batches,
        "total_batches": total_batches,
        # ... other fields
    }
```

---

### 3.3 Translation API

#### **GET /api/translation/status/{document_id}**

**Purpose**: Get all translation jobs for a document

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
      "glossary_matches": 45,
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

## 4. Queue Architecture

### 4.1 pgmq Setup

**Create Queues**:
```sql
-- Text extraction queue
SELECT pgmq.create('text_extraction_queue');

-- Translation queue
SELECT pgmq.create('translation_queue');
```

### 4.2 Queue Message Format

**Text Extraction Message**:
```json
{
  "job_id": "660e8400-e29b-41d4-a716-446655440000",
  "document_id": "550e8400-e29b-41d4-a716-446655440000",
  "batch_count": 3,
  "priority": "normal",
  "selected_pages": [1, 2, 3],
  "extraction_quality": "balanced",
  "timestamp": "2025-10-02T15:00:00Z"
}
```

**Translation Message**:
```json
{
  "translation_id": "770e8400-e29b-41d4-a716-446655440000",
  "document_id": "550e8400-e29b-41d4-a716-446655440000",
  "source_extraction_id": "660e8400-e29b-41d4-a716-446655440000",
  "target_language": "es",
  "priority": "normal",
  "timestamp": "2025-10-02T15:10:00Z"
}
```

### 4.3 Queue Operations

**Send Message**:
```python
from pgmq import PGMQueue
import json

pgmq = PGMQueue(connection_string)

message = {
    "job_id": job_id,
    "document_id": document_id,
    "batch_count": 3
}

msg_id = pgmq.send("text_extraction_queue", message)
```

**Read Message (with visibility timeout)**:
```python
# Read with 30 second visibility timeout
messages = pgmq.read("text_extraction_queue", vt=30, qty=1)

if messages:
    msg = messages[0]
    job_data = msg["message"]
    msg_id = msg["msg_id"]

    # Process job...

    # Archive message when done
    pgmq.archive("text_extraction_queue", msg_id)
```

### 4.4 Priority Queue Logic

```python
# Priority calculation (higher = more urgent)
def calculate_priority_score(message):
    priority_weights = {
        "urgent": 1000,
        "high": 500,
        "normal": 100,
        "low": 10
    }

    base_score = priority_weights.get(message["priority"], 100)

    # Time-based boost (older = higher priority)
    age_minutes = (datetime.now() - message["timestamp"]).total_minutes()
    time_boost = age_minutes * 2

    return base_score + time_boost

# Read messages and sort by priority
messages = pgmq.read("text_extraction_queue", vt=30, qty=10)
sorted_messages = sorted(messages, key=calculate_priority_score, reverse=True)
```

---

## 5. Storage Architecture

### 5.1 Supabase Storage Bucket Configuration

**Bucket Name**: `documents`
**Privacy**: Private (requires authentication)
**File Size Limit**: 500MB per file
**Allowed MIME Types**: `application/pdf`

**Create Bucket (SQL)**:
```sql
-- Create bucket via Supabase dashboard or SQL
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', false);
```

### 5.2 Storage Path Structure

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

### 5.3 Storage Operations

**Upload File**:
```python
storage_path = f"{tenant_id}/{timestamp}-{filename}"
supabase.storage.from_("documents").upload(
    storage_path,
    file_bytes,
    file_options={"content-type": "application/pdf"}
)
```

**Download File**:
```python
# Get signed URL (expires in 1 hour)
signed_url = supabase.storage.from_("documents").create_signed_url(
    storage_path,
    expires_in=3600
)
```

**Delete File**:
```python
supabase.storage.from_("documents").remove([storage_path])
```

---

## 6. Realtime Architecture

### 6.1 Enable Realtime on Tables

```sql
-- Enable realtime for documents table
ALTER PUBLICATION supabase_realtime ADD TABLE documents;

-- Enable realtime for text_extraction_results
ALTER PUBLICATION supabase_realtime ADD TABLE text_extraction_results;

-- Enable realtime for translations
ALTER PUBLICATION supabase_realtime ADD TABLE translations;
```

### 6.2 Realtime Channel Specifications

**Document Status Updates**:
```typescript
supabase
  .channel('document-updates')
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'public',
    table: 'documents',
    filter: `id=eq.${documentId}`
  }, (payload) => {
    console.log('Document updated:', payload.new);
  })
  .subscribe();
```

**Extraction Progress Updates**:
```typescript
supabase
  .channel(`extraction-${jobId}`)
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'public',
    table: 'text_extraction_results',
    filter: `id=eq.${jobId}`
  }, (payload) => {
    const progress = payload.new.progress;
    const status = payload.new.status;
    // Update UI
  })
  .subscribe();
```

**Translation Updates**:
```typescript
supabase
  .channel('translation-updates')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'translations',
    filter: `document_id=eq.${documentId}`
  }, (payload) => {
    if (payload.eventType === 'INSERT') {
      // New translation started
    } else if (payload.eventType === 'UPDATE') {
      // Translation progress
    }
  })
  .subscribe();
```

---

## 7. Batch Processing System

### 7.1 Token Estimation Algorithm

```python
def estimate_tokens(page_count: int, document_type: str) -> int:
    """
    Estimate token count for a PDF document

    Token estimation rules:
    - Digital text PDFs: ~500-800 tokens per page
    - Scanned/image PDFs: ~300-500 tokens per page (OCR generates less text)
    - Add 20% buffer for safety
    """
    if document_type == "digital":
        tokens_per_page = 650  # Average
    else:  # scanned
        tokens_per_page = 400  # Average

    estimated = page_count * tokens_per_page
    buffered = int(estimated * 1.2)  # Add 20% buffer

    return buffered

def calculate_batch_size(total_pages: int, estimated_tokens: int, document_type: str) -> int:
    """
    Calculate optimal batch size based on token limits

    Vertex AI Gemini 2.5 Pro limits:
    - Max input tokens: 1,000,000
    - Safe limit per batch: 900,000 (leaving 100K buffer)
    """
    SAFE_TOKEN_LIMIT = 900_000

    tokens_per_page = estimated_tokens / total_pages
    max_pages_per_batch = int(SAFE_TOKEN_LIMIT / tokens_per_page)

    # Apply document-type specific limits
    if document_type == "digital":
        # Digital PDFs can handle larger batches
        batch_size = min(max_pages_per_batch, 100)
    else:  # scanned
        # Scanned PDFs need smaller batches (more processing intensive)
        batch_size = min(max_pages_per_batch, 30)

    return max(batch_size, 1)  # At least 1 page per batch

def create_batches(document_id: str, job_id: str, total_pages: int, selected_pages: list = None):
    """
    Create batch records for a document
    """
    # Determine document type (simplified - in reality, analyze PDF)
    document_type = "digital"  # or "scanned"

    # Get pages to process
    pages_to_process = selected_pages if selected_pages else list(range(1, total_pages + 1))

    # Estimate tokens
    estimated_tokens = estimate_tokens(len(pages_to_process), document_type)

    # Calculate batch size
    batch_size = calculate_batch_size(len(pages_to_process), estimated_tokens, document_type)

    # Create batches
    batches = []
    for i in range(0, len(pages_to_process), batch_size):
        batch_pages = pages_to_process[i:i + batch_size]
        batch_number = (i // batch_size) + 1

        batch = {
            "document_id": document_id,
            "extraction_job_id": job_id,
            "batch_number": batch_number,
            "total_batches": (len(pages_to_process) + batch_size - 1) // batch_size,
            "start_page": batch_pages[0],
            "end_page": batch_pages[-1],
            "page_count": len(batch_pages),
            "estimated_tokens": int(estimated_tokens * len(batch_pages) / len(pages_to_process)),
            "status": "pending"
        }
        batches.append(batch)

    # Insert into database
    supabase.table("processing_batches").insert(batches).execute()

    return batches
```

### 7.2 Batch Processing Flow

```
1. API receives extraction request
    ↓
2. Create extraction job record (status: 'queued')
    ↓
3. Estimate total tokens
    ↓
4. Calculate batch size and create batch records
    ↓
5. Send message to pgmq queue
    ↓
6. Worker polls queue and receives message
    ↓
7. Worker processes batches sequentially:
    For each batch:
        a. Update batch status to 'processing'
        b. Download PDF from Supabase Storage
        c. Extract pages for this batch (virtual extraction, not physical split)
        d. Call Vertex AI with batch pages
        e. Insert page markers in extracted text
        f. Update batch status to 'completed'
        g. Update extraction job progress
        h. Supabase Realtime notifies frontend
    ↓
8. After all batches complete:
    a. Combine all batch results
    b. Update extraction job status to 'completed'
    c. Store full extracted_text with page markers
    d. Update document status to 'completed'
```

### 7.3 Page Marker Insertion Logic

```python
def insert_page_markers(batch_results: list) -> str:
    """
    Combine batch results and insert page markers

    Input: List of batch results
    [
        {"batch_number": 1, "start_page": 1, "end_page": 50, "extracted_text": "..."},
        {"batch_number": 2, "start_page": 51, "end_page": 100, "extracted_text": "..."},
        ...
    ]

    Output: Combined text with page markers
    # [Page 1]
    Line 1 text
    Line 2 text

    # [Page 2]
    Line 1 text
    ...
    """
    combined_text = []

    for batch in sorted(batch_results, key=lambda x: x["batch_number"]):
        # Parse Vertex AI response to extract page-by-page text
        pages = parse_vertex_response(batch["extracted_text"], batch["start_page"], batch["end_page"])

        for page_num, page_text in pages.items():
            # Insert page marker
            combined_text.append(f"# [Page {page_num}]")
            combined_text.append(page_text.strip())
            combined_text.append("")  # Blank line between pages

    return "\n".join(combined_text)

def parse_vertex_response(vertex_text: str, start_page: int, end_page: int) -> dict:
    """
    Parse Vertex AI response to extract individual pages

    Vertex AI may or may not return page breaks. This function:
    1. Checks if Vertex AI included page markers
    2. If not, estimates page breaks based on content length
    3. Returns dict: {page_number: page_text}
    """
    # Check if Vertex AI included page markers (it sometimes does)
    if "Page " in vertex_text or "[Page" in vertex_text:
        # Parse existing markers
        return parse_existing_markers(vertex_text, start_page)

    # Otherwise, estimate page breaks
    # This is a simplified approach - real implementation should be smarter
    lines = vertex_text.split("\n")
    total_lines = len(lines)
    page_count = end_page - start_page + 1
    lines_per_page = total_lines // page_count

    pages = {}
    for i in range(page_count):
        page_num = start_page + i
        start_line = i * lines_per_page
        end_line = (i + 1) * lines_per_page if i < page_count - 1 else total_lines
        page_text = "\n".join(lines[start_line:end_line])
        pages[page_num] = page_text

    return pages
```

---

## 8. Worker Architecture

### 8.1 Text Extraction Worker

```python
import asyncio
from pgmq import PGMQueue
from supabase import create_client
from vertexai import generative_models
from datetime import datetime

class TextExtractionWorker:
    def __init__(self):
        self.pgmq = PGMQueue(os.getenv("DATABASE_URL"))
        self.supabase = create_client(
            os.getenv("SUPABASE_URL"),
            os.getenv("SUPABASE_KEY")
        )
        self.vertex_client = generative_models.GenerativeModel("gemini-2.0-flash-exp")

    async def run(self):
        """Main worker loop"""
        print("Text Extraction Worker started")

        while True:
            try:
                # Read message from queue
                messages = self.pgmq.read("text_extraction_queue", vt=300, qty=1)

                if not messages:
                    await asyncio.sleep(2)  # Poll every 2 seconds
                    continue

                msg = messages[0]
                job_data = msg["message"]
                msg_id = msg["msg_id"]

                # Process job
                await self.process_extraction_job(job_data)

                # Archive message
                self.pgmq.archive("text_extraction_queue", msg_id)

            except Exception as e:
                print(f"Worker error: {e}")
                await asyncio.sleep(5)

    async def process_extraction_job(self, job_data: dict):
        """Process a single extraction job"""
        job_id = job_data["job_id"]
        document_id = job_data["document_id"]

        try:
            # Update job status to processing
            self.supabase.table("text_extraction_results").update({
                "status": "processing",
                "progress": 0
            }).eq("id", job_id).execute()

            # Get document info
            doc = self.supabase.table("documents").select("*").eq("id", document_id).single().execute()

            # Download PDF from storage
            pdf_bytes = self.supabase.storage.from_("documents").download(doc.data["storage_path"])

            # Get batches for this job
            batches = self.supabase.table("processing_batches").select("*").eq(
                "extraction_job_id", job_id
            ).order("batch_number").execute()

            total_batches = len(batches.data)
            batch_results = []

            # Process each batch
            for i, batch in enumerate(batches.data):
                print(f"Processing batch {batch['batch_number']} of {total_batches}")

                # Update batch status
                self.supabase.table("processing_batches").update({
                    "status": "processing"
                }).eq("id", batch["id"]).execute()

                # Extract text for this batch
                batch_text = await self.extract_batch(
                    pdf_bytes,
                    batch["start_page"],
                    batch["end_page"]
                )

                # Update batch with results
                self.supabase.table("processing_batches").update({
                    "status": "completed",
                    "extracted_text": batch_text,
                    "completed_at": datetime.now().isoformat()
                }).eq("id", batch["id"]).execute()

                batch_results.append({
                    "batch_number": batch["batch_number"],
                    "start_page": batch["start_page"],
                    "end_page": batch["end_page"],
                    "extracted_text": batch_text
                })

                # Update overall progress
                progress = int(((i + 1) / total_batches) * 100)
                self.supabase.table("text_extraction_results").update({
                    "progress": progress
                }).eq("id", job_id).execute()

            # Combine results with page markers
            full_text = insert_page_markers(batch_results)

            # Update job as completed
            self.supabase.table("text_extraction_results").update({
                "status": "completed",
                "progress": 100,
                "extracted_text": full_text,
                "completed_at": datetime.now().isoformat()
            }).eq("id", job_id).execute()

            # Update document status
            self.supabase.table("documents").update({
                "status": "completed"
            }).eq("id", document_id).execute()

            print(f"Job {job_id} completed successfully")

        except Exception as e:
            # Handle failure
            self.supabase.table("text_extraction_results").update({
                "status": "failed",
                "error_message": str(e)
            }).eq("id", job_id).execute()

            print(f"Job {job_id} failed: {e}")

    async def extract_batch(self, pdf_bytes: bytes, start_page: int, end_page: int) -> str:
        """Extract text from a batch of pages using Vertex AI"""
        # Convert PDF pages to images (for Vertex AI multimodal)
        images = pdf_to_images(pdf_bytes, start_page, end_page)

        # Prepare prompt
        prompt = f"""Extract all text from these document pages ({start_page} to {end_page}).

        Requirements:
        - Preserve original text layout and structure
        - Include all text, even if partially visible
        - Maintain paragraph breaks and formatting
        - If text is unclear, provide best-effort transcription

        Return the extracted text only, without any additional commentary."""

        # Call Vertex AI
        response = await self.vertex_client.generate_content_async([prompt] + images)

        return response.text

# Run worker
if __name__ == "__main__":
    worker = TextExtractionWorker()
    asyncio.run(worker.run())
```

### 8.2 Worker Deployment

**Run as Background Process**:
```bash
# Development
python backend/workers/text_extraction_worker.py

# Production (with process manager)
supervisord -c supervisord.conf
```

**Supervisor Configuration** (`supervisord.conf`):
```ini
[program:text_extraction_worker]
command=python backend/workers/text_extraction_worker.py
directory=/app/backend
autostart=true
autorestart=true
stderr_logfile=/var/log/extraction_worker.err.log
stdout_logfile=/var/log/extraction_worker.out.log
```

---

## 9. Data Flow Specifications

### 9.1 Complete Upload → Extraction → Editor Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. USER UPLOADS PDF                                              │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. FRONTEND: upload-store.ts                                     │
│    - Generate thumbnails (first 3 pages)                         │
│    - Create file preview                                         │
│    - Show page count                                             │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ POST /api/documents/upload
             │ FormData: file
             │ Query: source_language, target_language
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. BACKEND: FastAPI Upload Endpoint                             │
│    - Validate file type (PDF only)                              │
│    - Calculate SHA-256 hash                                      │
│    - Check for duplicates                                        │
│    - Generate unique filename: {timestamp}-{original}            │
│    - Extract page count using PyPDF2                             │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. SUPABASE STORAGE                                              │
│    - Upload to bucket: documents/{tenant_id}/{filename}          │
│    - Return storage_path                                         │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. SUPABASE DATABASE                                             │
│    - INSERT into documents table                                 │
│    - Fields: id, file_name, storage_path, page_count, status     │
│    - status = 'uploaded'                                         │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Response: { id, file_name, status: 'uploaded' }
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. FRONTEND: Receives document ID                                │
│    - Store documentId in upload-store                            │
│    - Update file status to 'ready'                               │
│    - Enable "Process" button                                     │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ User clicks "Process"
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 7. FRONTEND: processFiles()                                      │
│    - Collect selected pages                                      │
│    - Get extraction settings (quality, auto_translate)           │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ POST /api/text-extraction/extract-with-batching/{docId}
             │ Body: { auto_translate, target_languages, selected_pages }
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 8. BACKEND: Extraction Endpoint                                  │
│    - Validate document exists                                    │
│    - Estimate total tokens                                       │
│    - Calculate batch strategy                                    │
│    - Create extraction job record (status: 'queued')             │
│    - Create batch records in processing_batches                  │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 9. PGMQ: Send message to text_extraction_queue                   │
│    Message: { job_id, document_id, batch_count, priority }       │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Response: { job_id, status: 'queued', batch_info }
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 10. FRONTEND: Start status polling                               │
│     - Poll GET /api/text-extraction/status/{job_id} every 2s     │
│     - Max 300 attempts (10 minutes)                              │
│     - Update progress bar                                        │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Simultaneously...
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 11. WORKER: Polls pgmq queue                                     │
│     - Read message (visibility timeout: 5 minutes)               │
│     - Get job details from database                              │
│     - Download PDF from Supabase Storage                         │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 12. WORKER: Process batches sequentially                         │
│     For each batch:                                              │
│       - Update batch status to 'processing'                      │
│       - Extract pages (virtual, not physical)                    │
│       - Convert pages to images for Vertex AI                    │
│       - Call Vertex AI Gemini 2.5 Pro                            │
│       - Receive extracted text                                   │
│       - Update batch status to 'completed'                       │
│       - Update job progress (Realtime notifies frontend)         │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 13. WORKER: Combine batch results                                │
│     - Parse Vertex AI responses                                  │
│     - Insert page markers: # [Page N]                            │
│     - Combine into single extracted_text string                  │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 14. DATABASE: Update extraction job                              │
│     UPDATE text_extraction_results SET:                          │
│       - status = 'completed'                                     │
│       - progress = 100                                           │
│       - extracted_text = combined_text                           │
│       - completed_at = NOW()                                     │
│     (Realtime fires UPDATE event)                                │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 15. FRONTEND: Receives status update                             │
│     - Polling returns: { status: 'completed', progress: 100 }    │
│     - OR Realtime subscription triggers callback                 │
│     - Update file status to 'complete'                           │
│     - Navigate to editor: /editor/{documentId}                   │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 16. EDITOR: Load extraction                                      │
│     - Query: SELECT * FROM text_extraction_results               │
│               WHERE document_id = {documentId}                   │
│     - Parse extracted_text:                                      │
│         • Split by '\n'                                          │
│         • Detect page markers: /^#\s*\[Page\s+(\d+)\]$/i         │
│         • Assign page numbers to lines                           │
│         • Create TextLine[] array                                │
│     - Populate sourceText in editor-store                        │
│     - Render editor UI                                           │
└─────────────────────────────────────────────────────────────────┘
```

### 9.2 Critical Integration Points

| Step | Integration Point | Requirement |
|------|------------------|-------------|
| 3 | Upload validation | Only accept `application/pdf` MIME type |
| 5 | Database insert | Exact schema match: `file_name`, `original_name`, `storage_path`, etc. |
| 8 | Batch calculation | Use token estimation algorithm from Section 7.1 |
| 12 | Vertex AI call | Handle 1M token limit, implement retry logic |
| 13 | Page markers | **CRITICAL**: Use exact format `# [Page N]` |
| 14 | Realtime update | Database update triggers Realtime notification |
| 16 | Text parsing | Frontend regex must match backend page marker format |

---

## 10. Development Setup

### 10.1 Supabase Project Setup

**Step 1: Create Supabase Project**
1. Go to https://supabase.com/dashboard
2. Create new project (Free tier)
3. Save credentials:
   - Project URL: `https://xxx.supabase.co`
   - Anon Key: `eyJ...`
   - Service Role Key: `eyJ...` (secret, for backend only)
   - Database Password: (for direct PostgreSQL connection)

**Step 2: Get Database Connection String**
```
postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
```

Test connection:
```bash
psql "postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres"
```

**Step 3: Enable pgmq Extension**
```sql
CREATE EXTENSION IF NOT EXISTS pgmq;
```

**Step 4: Run Schema Migration**
```bash
psql [CONNECTION_STRING] < database_schema.sql
```

**Step 5: Create Storage Bucket**
1. Go to Storage > Create bucket
2. Name: `documents`
3. Public: No (private)
4. Apply RLS policies (Section 11)

**Step 6: Enable Realtime**
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE documents;
ALTER PUBLICATION supabase_realtime ADD TABLE text_extraction_results;
ALTER PUBLICATION supabase_realtime ADD TABLE translations;
```

### 10.2 Backend Setup (FastAPI)

**Directory Structure**:
```
backend/
├── api/
│   ├── __init__.py
│   ├── main.py              # FastAPI app
│   ├── config.py            # Environment config
│   ├── routers/
│   │   ├── __init__.py
│   │   ├── documents.py     # Document upload endpoints
│   │   └── text_extraction.py  # Extraction endpoints
│   ├── services/
│   │   ├── __init__.py
│   │   ├── supabase.py      # Supabase client
│   │   ├── vertex_ai.py     # Vertex AI integration
│   │   └── batch_processor.py
│   └── utils/
│       ├── __init__.py
│       ├── token_estimator.py
│       └── page_markers.py
├── workers/
│   ├── __init__.py
│   ├── text_extraction_worker.py
│   └── translation_worker.py
├── requirements.txt
└── .env
```

**requirements.txt**:
```
fastapi==0.117.0
uvicorn[standard]==0.34.0
python-multipart==0.0.20
supabase==2.13.0
pgmq==0.11.1
vertexai==1.75.0
google-cloud-aiplatform==1.75.0
PyPDF2==3.0.1
Pillow==11.0.0
python-dotenv==1.0.1
```

**.env**:
```bash
# Supabase
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_KEY=eyJ...
DATABASE_URL=postgresql://postgres.[PROJECT-REF]:[PASSWORD]@...

# Vertex AI
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json

# API Settings
API_HOST=0.0.0.0
API_PORT=8000
```

**Run Backend**:
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
```

**Run Worker**:
```bash
python workers/text_extraction_worker.py
```

### 10.3 Frontend Setup

**Already Built** - No setup needed, just ensure environment variables:

**frontend/.env**:
```bash
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
VITE_API_URL=http://localhost:8000
```

### 10.4 Vertex AI Setup

**Step 1: Enable Vertex AI API**
```bash
gcloud services enable aiplatform.googleapis.com
```

**Step 2: Create Service Account**
```bash
gcloud iam service-accounts create hda-vertex-ai \
  --display-name="HDA Vertex AI Service Account"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:hda-vertex-ai@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"
```

**Step 3: Download Key**
```bash
gcloud iam service-accounts keys create service-account-key.json \
  --iam-account=hda-vertex-ai@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

**Step 4: Test Connection**
```python
import vertexai
from vertexai.generative_models import GenerativeModel

vertexai.init(project="YOUR_PROJECT_ID", location="us-central1")
model = GenerativeModel("gemini-2.0-flash-exp")

response = model.generate_content("Hello, test!")
print(response.text)
```

---

## 11. Security & RLS Policies

### 11.1 Row Level Security (RLS) for Documents

```sql
-- Enable RLS on documents table
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own tenant's documents
CREATE POLICY "Users can view own tenant documents"
ON documents FOR SELECT
USING (
  tenant_id = (SELECT auth.jwt() ->> 'tenant_id')::UUID
  OR
  user_id = (SELECT auth.uid())::TEXT
);

-- Policy: Users can insert documents for their tenant
CREATE POLICY "Users can insert own tenant documents"
ON documents FOR INSERT
WITH CHECK (
  tenant_id = (SELECT auth.jwt() ->> 'tenant_id')::UUID
  OR
  user_id = (SELECT auth.uid())::TEXT
);

-- Policy: Users can update their own documents
CREATE POLICY "Users can update own documents"
ON documents FOR UPDATE
USING (
  user_id = (SELECT auth.uid())::TEXT
);

-- Policy: Users can delete their own documents
CREATE POLICY "Users can delete own documents"
ON documents FOR DELETE
USING (
  user_id = (SELECT auth.uid())::TEXT
);
```

### 11.2 Storage Bucket RLS

```sql
-- Storage policy: Users can upload to their tenant folder
CREATE POLICY "Users can upload to own tenant folder"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'documents'
  AND
  (storage.foldername(name))[1] = (SELECT auth.jwt() ->> 'tenant_id')
);

-- Storage policy: Users can read their tenant's files
CREATE POLICY "Users can read own tenant files"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'documents'
  AND
  (storage.foldername(name))[1] = (SELECT auth.jwt() ->> 'tenant_id')
);
```

### 11.3 Service Role Bypass

**Backend uses Service Role Key** - bypasses RLS for background operations:

```python
# Backend uses service_role key
supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)

# Frontend uses anon key (enforces RLS)
supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
```

---

## 12. Monitoring & Observability

### 12.1 Key Metrics to Track

**Database Metrics**:
- Queue depth (pgmq message count)
- Average processing time per document
- Extraction success/failure rate
- Database connection pool usage

**API Metrics**:
- Request latency (p50, p95, p99)
- Error rate by endpoint
- Upload throughput (MB/s)
- Active extraction jobs

**Worker Metrics**:
- Worker health (alive/dead)
- Jobs processed per hour
- Average batch processing time
- Vertex AI API latency

### 12.2 Logging Strategy

```python
import logging
import structlog

# Configure structured logging
logging.basicConfig(level=logging.INFO)
logger = structlog.get_logger()

# Log with context
logger.info("extraction_started",
    job_id=job_id,
    document_id=document_id,
    page_count=page_count,
    batch_count=batch_count
)

logger.error("extraction_failed",
    job_id=job_id,
    error=str(e),
    retry_count=retry_count
)
```

### 12.3 Health Check Endpoints

```python
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "database": check_database_connection(),
        "storage": check_storage_connection(),
        "queue": check_queue_health()
    }

@app.get("/health/worker")
async def worker_health():
    # Check last worker heartbeat
    last_job = supabase.table("text_extraction_results").select("updated_at").order("updated_at", desc=True).limit(1).execute()

    if not last_job.data:
        return {"status": "no_jobs_processed"}

    last_update = datetime.fromisoformat(last_job.data[0]["updated_at"])
    if (datetime.now() - last_update).seconds > 300:  # 5 minutes
        return {"status": "worker_stale", "last_activity": last_update}

    return {"status": "healthy", "last_activity": last_update}
```

---

## 13. Testing Strategy

### 13.1 Integration Test Scenarios

**Test 1: Small PDF (10 pages)**
1. Upload 10-page PDF
2. Verify document record created
3. Start extraction
4. Verify single batch created
5. Wait for completion
6. Verify extracted_text has page markers
7. Load in editor
8. Verify UI renders correctly

**Test 2: Large PDF (500 pages)**
1. Upload 500-page PDF
2. Start extraction
3. Verify multiple batches created (5-10 batches)
4. Monitor progress updates
5. Verify batch processing sequential
6. Verify final text has 500 page markers
7. Load in editor
8. Verify page navigation works

**Test 3: Selected Pages (pages 1, 5, 10)**
1. Upload PDF
2. Select specific pages
3. Start extraction
4. Verify only selected pages processed
5. Verify extracted_text has only 3 page markers

**Test 4: Realtime Updates**
1. Start extraction
2. Subscribe to Realtime channel
3. Verify progress updates received
4. Verify completion event received

### 13.2 Load Testing

```bash
# Use locust or k6 for load testing
# Test 100 concurrent uploads
locust -f load_test.py --host http://localhost:8000 --users 100
```

---

## 14. Deployment Checklist

### 14.1 Pre-Deployment

- [ ] Supabase project created and configured
- [ ] Database schema applied
- [ ] pgmq queues created
- [ ] Storage bucket created with RLS policies
- [ ] Realtime enabled on all tables
- [ ] Vertex AI service account created and tested
- [ ] Environment variables configured
- [ ] Backend dependencies installed
- [ ] Worker tested locally
- [ ] Frontend environment variables set
- [ ] Integration tests passed

### 14.2 Post-Deployment

- [ ] Health check endpoints returning healthy
- [ ] Test document upload
- [ ] Test extraction flow end-to-end
- [ ] Verify Realtime subscriptions working
- [ ] Monitor worker logs
- [ ] Check queue depth
- [ ] Verify storage uploads
- [ ] Test editor loading extraction
- [ ] Monitor error rates
- [ ] Set up alerts

---

## Document Version History

- **2025-10-02**: Initial creation - Complete technical architecture for backend rebuild
