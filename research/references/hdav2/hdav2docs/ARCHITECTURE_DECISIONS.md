# HDA Translation Platform - Architecture Decisions Document

**Status**: Finalized for v2.0 Clean Slate
**Date**: 2025-10-02
**Version**: 2.0
**Purpose**: Supporting document for PRD and Architecture - defines key architectural decisions for queue management, batch processing, workflow state, and database design

---

## Document Purpose

This document consolidates all architectural decisions extracted from previous implementation learnings, adapted for the **Supabase Cloud-only** architecture. It serves as a reference for:

1. Database schema design
2. Queue architecture and job processing
3. Batch processing for large documents
4. Workflow state management
5. Multi-language translation support

**Note**: All references to SQLite, hybrid storage, and dual-database approaches have been removed. This is a **Supabase-first** architecture.

---

## Table of Contents

1. [Storage & File Management](#storage--file-management)
2. [Queue Architecture](#queue-architecture)
3. [Batch Processing](#batch-processing)
4. [Multi-Language Support](#multi-language-support)
5. [Workflow State Management](#workflow-state-management)
6. [Database Schema Decisions](#database-schema-decisions)
7. [API Design Patterns](#api-design-patterns)

---

## Storage & File Management

### Decision 1: Virtual Page References (No Physical Page Splitting) ✅

**Problem**: Large PDFs need page extraction for processing

**Decision**: Store **only the original PDF** in Supabase Storage. Extract pages on-demand in worker memory.

**Implementation**:
```python
# Document storage metadata
document = {
    "id": "doc_123",
    "storage_path": "documents/tenant_abc/document_123.pdf",  # ONE file only
    "page_count": 418,
    "selected_pages": [1, 2, 3, 4, 5, 6, 7]  # Metadata in JSONB
}

# Worker extracts pages on-demand
class ExtractionWorker:
    async def process_job(self, job):
        # 1. Download original PDF once
        pdf_bytes = await self.download_from_supabase_storage(job.document_id)

        # 2. Extract selected pages IN-MEMORY
        selected_pages = self.extract_pages_in_memory(pdf_bytes, job.selected_pages)

        # 3. Send directly to Vertex AI
        results = await self.send_to_vertex_ai(selected_pages)

        # 4. Save only TEXT results to Supabase DB
        await self.save_extraction_result(job.id, results)
```

**Benefits**:
- ✅ 50% storage savings (no redundant page PDFs)
- ✅ Simpler state management (no "which pages extracted?" tracking)
- ✅ Clean Supabase Storage (1 file per document)
- ✅ No race conditions between workers

**Rejected Alternative**: Physically split PDFs into individual page files
**Reason**: Storage redundancy, slower processing, complex cleanup

---

### Decision 2: Worker-Side PDF Caching (Optional - Phase 2) ✅

**Problem**: Same document processed multiple times wastes bandwidth

**Decision**: Implement in-memory LRU cache on workers (optional optimization)

**Configuration**:
```python
WORKER_CACHE_CONFIG = {
    'max_cache_size': 500_000_000,  # 500MB per worker
    'cache_ttl': 3600,               # 1 hour
    'eviction_policy': 'LRU'
}
```

**Performance Impact**:
- First job for doc_123: Downloads PDF (2 sec)
- Second job for doc_123: Uses cache (0.1 sec) - **20x faster**
- Reduces Supabase Storage bandwidth

**Priority**: Phase 2 (nice-to-have, not MVP critical)

---

## Queue Architecture

### Decision 3: Dual-Queue System with pgmq ✅

**Problem**: Need separate processing for extraction vs translation

**Decision**: Two pgmq queues with independent workers

**Queue Structure**:
1. **`text_extraction_queue`** - PDF text extraction jobs
2. **`translation_queue`** - Translation jobs (one per language)

**Benefits**:
- Independent scaling (more extraction workers if needed)
- Clear separation of concerns
- Prioritize extraction (faster user feedback)
- Different retry logic per job type

**Implementation**:
```sql
-- Create queues
CREATE EXTENSION IF NOT EXISTS pgmq;
SELECT pgmq.create('text_extraction_queue');
SELECT pgmq.create('translation_queue');
```

---

### Decision 4: Job Structure & Priority System ✅

**Extraction Job**:
```json
{
    "job_id": "uuid",
    "job_type": "text_extraction",
    "document_id": "doc_123",
    "selected_pages": [1, 2, 3, 4, 5],
    "priority": 8,
    "created_at": "2025-10-02T10:00:00Z",
    "timeout_seconds": 1800
}
```

**Translation Job** (one per language):
```json
{
    "job_id": "uuid",
    "job_type": "translation",
    "document_id": "doc_123",
    "extraction_id": "extraction_456",
    "target_language": "hi",
    "glossary_id": "glossary_789",
    "priority": 7,
    "created_at": "2025-10-02T10:15:00Z"
}
```

**Priority Calculation**:
```python
def calculate_extraction_priority(page_count):
    if page_count <= 10:
        return 8  # High priority (small docs)
    elif page_count <= 50:
        return 5  # Medium priority
    else:
        return 3  # Low priority (large batches)

# Translation gets slightly lower priority
def calculate_translation_priority(page_count):
    return calculate_extraction_priority(page_count) - 1
```

**Reasoning**: Small jobs complete faster → better user experience

---

### Decision 5: Failure Handling & Retries ✅

**Decision**: All-or-nothing - if any page fails, entire job fails

**Implementation**:
```python
async def process_extraction_job(job):
    results = []
    try:
        for page_num in job.selected_pages:
            result = await vertex_ai.extract_text(page_num)
            results.append(result)
    except Exception as e:
        # Mark job as failed
        await db.update_job_status(job.id, 'failed', error=str(e))

        # Move to dead letter queue after max retries
        if job.retry_count >= 3:
            await pgmq.send('dead_letter_queue', job)

        return None

    # All pages succeeded - save results
    await db.save_extraction_results(job.document_id, results)
    await db.update_job_status(job.id, 'completed')
```

**Retry Logic**: Max 3 attempts with exponential backoff (1s, 2s, 4s)

**Rejected Alternative**: Partial success (save what worked)
**Reason**: Too complex, inconsistent UX, hard to track state

---

### Decision 6: Timeout Configuration ✅

**Problem**: Jobs can hang indefinitely

**Decision**: Conservative timeouts with auto-recovery

**Timeouts**:
- **Extraction**: 30 minutes max (5 min per page)
- **Translation**: 1 hour max (10 min per page)

**Implementation**:
```python
TIMEOUTS = {
    'text_extraction': 1800,  # 30 minutes
    'translation': 3600       # 1 hour
}

# pgmq visibility timeout ensures stuck jobs return to queue
job = await pgmq.read('text_extraction_queue', vt=TIMEOUTS['text_extraction'])
```

---

## Batch Processing

### Decision 7: Token-Based Batch Splitting ✅

**Problem**: Gemini API has 1M input / 65K output token limits

**Decision**: Split large PDFs into batches based on token estimation

**Batch Rules**:
```python
MAX_TOKENS_PER_BATCH = 800_000  # 80% of 1M limit (safety margin)
MAX_PAGES_PER_BATCH = 50        # For digital PDFs
MAX_PAGES_SCANNED = 30          # For scanned PDFs (more tokens)

def estimate_tokens(pdf_page):
    # Digital text: ~500-1000 tokens per page
    # Scanned image: ~2000-5000 tokens per page
    return calculate_tiktoken_estimate(pdf_page)

def split_into_batches(document, selected_pages):
    batches = []
    current_batch = []
    current_tokens = 0

    for page in selected_pages:
        page_tokens = estimate_tokens(document.get_page(page))

        if current_tokens + page_tokens > MAX_TOKENS_PER_BATCH:
            # Start new batch
            batches.append(current_batch)
            current_batch = [page]
            current_tokens = page_tokens
        else:
            current_batch.append(page)
            current_tokens += page_tokens

    if current_batch:
        batches.append(current_batch)

    return batches
```

**Example**: 448-page PDF → 15 batches (30 pages each)

---

### Decision 8: Batch Processing & Stitching ✅

**Problem**: Need to reassemble text from multiple batches

**Decision**: Sequential batch processing with text stitching

**Workflow**:
```
PDF (448 pages) → Split into 15 batches
  ↓
Batch 1 (pages 1-30)   → Vertex AI → Text 1
Batch 2 (pages 31-60)  → Vertex AI → Text 2
Batch 3 (pages 61-90)  → Vertex AI → Text 3
  ...
  ↓
Text Stitcher → Combines all batches → Complete document text
```

**Implementation**:
```python
async def process_large_document(document_id, selected_pages):
    # 1. Split into batches
    batches = split_into_batches(document, selected_pages)

    # 2. Process each batch
    batch_results = []
    for i, batch in enumerate(batches):
        result = await vertex_ai.extract_text(
            batch,
            context=f"Batch {i+1} of {len(batches)}"
        )
        batch_results.append(result)

        # Real-time progress update
        await supabase.realtime.send({
            'event': 'batch_progress',
            'batch': i+1,
            'total': len(batches),
            'progress': ((i+1) / len(batches)) * 100
        })

    # 3. Stitch results
    complete_text = stitch_batch_texts(batch_results)

    # 4. Save to database
    await db.save_extraction_result(document_id, complete_text)
```

**Database Tracking**:
```sql
CREATE TABLE extraction_batches (
    id UUID PRIMARY KEY,
    document_id UUID REFERENCES documents(id),
    batch_number INTEGER NOT NULL,
    start_page INTEGER,
    end_page INTEGER,
    estimated_tokens INTEGER,
    extracted_text TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    processed_at TIMESTAMPTZ
);
```

---

## Multi-Language Support

### Decision 9: Independent Language Jobs ✅

**Problem**: User wants to translate to multiple languages

**Decision**: Each language creates **separate independent job** in translation queue

**User Flow**:
1. User reviews extracted text
2. Clicks "Proceed to Translation"
3. Selects languages: ☑ Hindi, ☑ Marathi, ☑ Bengali
4. System creates 3 separate translation jobs

**Implementation**:
```python
# User selects multiple languages
selected_languages = ['hi', 'mr', 'bn']

# Create independent job for each
for lang in selected_languages:
    job = {
        "job_type": "translation",
        "document_id": doc_id,
        "extraction_id": extraction_id,
        "target_language": lang,
        "priority": calculate_translation_priority(page_count)
    }
    await pgmq.send('translation_queue', job)
```

**Result**: 3 independent jobs, can process simultaneously

---

### Decision 10: Per-Language Status Tracking ✅

**Problem**: Need to track translation status per language

**Decision**: Document has aggregate status, `translations` table has per-language status

**Document-Level Status** (aggregate):
```python
document = {
    "id": "doc_123",
    "status": "translation_processing",  # ANY translation active
    "extraction_completed_at": "2025-10-02T10:10:00Z"
}
```

**Per-Language Status** (`translations` table):
```python
translations = [
    {"document_id": "doc_123", "target_language": "hi", "status": "completed"},
    {"document_id": "doc_123", "target_language": "mr", "status": "processing"},
    {"document_id": "doc_123", "target_language": "bn", "status": "queued"}
]
```

**Language Job Independence**:
- If Hindi fails, Marathi/Bengali continue
- User can retry individual languages
- Each language has own verification status

---

## Workflow State Management

### Decision 11: Document Journey & Job Versioning ✅

**Problem**: Same document uploaded multiple times with different page selections

**Decision**: One document → Many jobs (each with unique page ranges)

**Model**:
```
DOCUMENT (1) → JOBS (Many) → Each job tracks specific pages
```

**Example**:
- Upload document.pdf
- Job #1: Pages 1-7 (extraction → translation → complete)
- Later: Upload same document
- Job #2: Pages 8-15 (new job, independent tracking)

**Database Structure**:
```sql
-- One document
CREATE TABLE documents (
    id UUID PRIMARY KEY,
    file_hash VARCHAR(64) UNIQUE,  -- SHA-256 for duplicate detection
    file_name TEXT,
    storage_path TEXT,             -- Supabase Storage path
    page_count INTEGER
);

-- Many jobs per document
CREATE TABLE document_jobs (
    id UUID PRIMARY KEY,
    document_id UUID REFERENCES documents(id),
    selected_pages JSONB,          -- [1,2,3,4,5]
    current_stage VARCHAR(50),     -- Workflow stage
    created_at TIMESTAMPTZ,
    last_accessed_at TIMESTAMPTZ
);
```

---

### Decision 12: Workflow Stages ✅

**Problem**: Need to track document through multi-step workflow

**Decision**: Defined workflow stages with clear transitions

**Stages**:
```python
class WorkflowStage(Enum):
    # Initial
    UPLOADED = "uploaded"
    EXTRACTION_QUEUED = "extraction_queued"
    EXTRACTION_PROCESSING = "extraction_processing"
    EXTRACTION_COMPLETE = "extraction_complete"

    # Review
    EXTRACTION_REVIEW = "extraction_review"
    EXTRACTION_APPROVED = "extraction_approved"

    # Translation
    TRANSLATION_QUEUED = "translation_queued"
    TRANSLATION_PROCESSING = "translation_processing"
    TRANSLATION_COMPLETE = "translation_complete"
    TRANSLATION_REVIEW = "translation_review"

    # Final
    VERIFIED = "verified"

    # Error
    FAILED = "failed"
    CANCELLED = "cancelled"
```

**Stage Transition**:
```python
async def transition_stage(job_id, new_stage, stage_data=None):
    job = await db.get_job(job_id)

    # Validate transition
    if not is_valid_transition(job.current_stage, new_stage):
        raise InvalidTransitionError()

    # Update job
    job.previous_stage = job.current_stage
    job.current_stage = new_stage
    job.stage_updated_at = datetime.utcnow()

    # Save stage history
    await db.save_stage_history(job_id, {
        "from": job.previous_stage,
        "to": new_stage,
        "timestamp": datetime.utcnow(),
        "data": stage_data
    })

    return job
```

---

### Decision 13: Duplicate Detection & Page Overlap ✅

**Problem**: User uploads same document again

**Decision**: Detect duplicates via file hash, check for page overlaps

**Implementation**:
```python
async def handle_upload(file, selected_pages):
    # 1. Calculate file hash
    file_hash = calculate_sha256(file)

    # 2. Check for existing document
    existing_doc = await db.find_document_by_hash(file_hash)

    if existing_doc:
        # 3. Get all jobs for this document
        existing_jobs = await db.get_jobs(existing_doc.id)

        # 4. Check for page overlaps
        overlaps = find_page_overlaps(selected_pages, existing_jobs)

        if overlaps:
            return {
                "status": "duplicate_with_overlap",
                "document_id": existing_doc.id,
                "overlapping_jobs": overlaps,
                "options": [
                    {"label": "Reuse existing extraction", "action": "reuse"},
                    {"label": "Re-process these pages", "action": "new_job"},
                    {"label": "View existing results", "action": "view"}
                ]
            }
        else:
            # No overlap - create new job
            new_job = await db.create_job(existing_doc.id, selected_pages)
            return {"status": "new_job", "job_id": new_job.id}
    else:
        # Brand new document
        new_doc = await db.create_document(file, file_hash)
        new_job = await db.create_job(new_doc.id, selected_pages)
        return {"status": "new_document", "job_id": new_job.id}
```

---

## Database Schema Decisions

### Decision 14: Enhanced Schema for v2.0 ✅

**Complete Database Schema**:

```sql
-- Documents table
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    file_name TEXT NOT NULL,
    file_hash VARCHAR(64) UNIQUE,
    file_size BIGINT,
    storage_path TEXT NOT NULL,  -- Supabase Storage path
    page_count INTEGER,
    status TEXT DEFAULT 'uploaded',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Text extraction results
CREATE TABLE text_extraction_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
    extracted_text TEXT,
    confidence_score FLOAT,
    page_count INTEGER,
    token_count INTEGER,
    processing_time FLOAT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Translations (one per language)
CREATE TABLE translations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
    extraction_id UUID REFERENCES text_extraction_results(id),
    source_language VARCHAR(10),
    target_language VARCHAR(10),
    translated_text TEXT,
    confidence_score FLOAT,
    status TEXT DEFAULT 'queued',
    glossary_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    verified_at TIMESTAMPTZ,

    -- Constraint: One translation per document per language
    UNIQUE(document_id, target_language)
);

-- Queue jobs tracking
CREATE TABLE queue_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_type TEXT NOT NULL,  -- 'text_extraction' or 'translation'
    document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
    extraction_id UUID REFERENCES text_extraction_results(id),
    translation_id UUID REFERENCES translations(id),

    -- Job configuration
    selected_pages JSONB,  -- [1,2,3,4,5]
    job_config JSONB,      -- Additional config

    -- Queue management
    queue_name TEXT,
    status TEXT DEFAULT 'queued',
    priority INTEGER DEFAULT 5,

    -- Timing
    queued_at TIMESTAMPTZ DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,

    -- Error handling
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,

    -- Indexes
    INDEX idx_queue_jobs_document (document_id),
    INDEX idx_queue_jobs_status (status),
    INDEX idx_queue_jobs_queue (queue_name)
);

-- Extraction batches (for large documents)
CREATE TABLE extraction_batches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
    batch_number INTEGER,
    start_page INTEGER,
    end_page INTEGER,
    estimated_tokens INTEGER,
    extracted_text TEXT,
    status TEXT DEFAULT 'pending',
    processed_at TIMESTAMPTZ,

    INDEX idx_batches_document (document_id, batch_number)
);

-- Glossaries
CREATE TABLE glossaries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    name VARCHAR(255),
    source_language VARCHAR(10),
    target_language VARCHAR(10),
    terms JSONB,  -- Array of {source, target, notes}
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## API Design Patterns

### Decision 15: RESTful Endpoints ✅

**Translation Endpoints**:
```python
# Start translation for multiple languages
POST /api/translation/start/{document_id}
Body: {
    "target_languages": ["hi", "mr"],
    "glossary_id": "uuid",
    "pages": [1,2,3,4,5]
}
Response: {
    "jobs": [
        {"job_id": "uuid_1", "target_language": "hi"},
        {"job_id": "uuid_2", "target_language": "mr"}
    ]
}

# Get translation status
GET /api/translation/status/{document_id}/{language}
Response: {
    "status": "processing",
    "progress": 45,
    "current_batch": 2,
    "total_batches": 3
}

# Get translation result
GET /api/translation/result/{document_id}/{language}
Response: {
    "translated_text": "...",
    "confidence_score": 0.92,
    "status": "pending_review"
}
```

**Job Management Endpoints**:
```python
# Create new job
POST /api/jobs/create
Body: {
    "document_id": "uuid",
    "selected_pages": [1,2,3],
    "job_type": "text_extraction"
}

# Get job status
GET /api/jobs/{job_id}/status

# Resume job
POST /api/jobs/{job_id}/resume
```

---

## Summary of Key Decisions

### Storage ✅
1. Virtual page references (no physical splitting)
2. Worker-side LRU caching (optional)
3. Supabase Storage for all files

### Queue Architecture ✅
4. Dual-queue system (extraction + translation)
5. Priority-based job scheduling
6. All-or-nothing failure handling
7. Conservative timeout configuration

### Batch Processing ✅
8. Token-based batch splitting
9. Sequential processing with stitching

### Multi-Language ✅
10. Independent language jobs
11. Per-language status tracking

### Workflow ✅
12. Document journey with job versioning
13. Defined workflow stages
14. Duplicate detection & overlap handling

### Database ✅
15. Enhanced schema with proper relationships
16. RESTful API patterns

---

**This document serves as the foundation for the Architecture Document and implementation guides.**

---

*Document Version: 2.0*
*Last Updated: October 2, 2025*
*Status: Ready for Implementation*
