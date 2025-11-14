# HDA Translation Platform - Product Requirements Document (PRD) v2.1

**Status**: Active Development - Story 1.4 Complete, Story 1.5 Next
**Date**: 2025-10-03
**Version**: 2.1 (Parallel Worker Architecture)

**Related Documents**:
- `TECHNICAL_ARCHITECTURE.md` - Complete implementation guide with API specs, database schemas, and worker logic
- `ARCHITECTURE_DECISIONS.md` - Architectural decisions and rationale
- `FRONTEND_BACKEND_GAP_ANALYSIS.md` - Detailed frontend integration requirements

---

## Executive Summary

This PRD defines a **simplified, production-ready architecture** for the HDA Translation Platform. We are rebuilding the backend from scratch while preserving the existing frontend. The new architecture eliminates unnecessary complexity by using **Supabase Cloud as our complete backend platform**.

**For detailed technical specifications**, see `TECHNICAL_ARCHITECTURE.md`.



## Goals and Background Context

### Goals
- Launch a multi-tenant SaaS platform for enterprise translation and document text extraction
- Generate revenue through white-label licensing and SaaS subscriptions
- Process PDFs/e-books with text extraction using Vertex AI Gemini 2.5 Pro as the MVP deliverable for HDA (flagship client)
- Deliver enterprise-grade text extraction capabilities for scanned documents, manuscripts, and image-based text content
- Support 6 initial languages (English, Hindi, Marathi, Bengali, Gujarati, German) with unlimited expansion capability
- Enable AI provider flexibility through marketplace model with 20-30% markup revenue stream

### Background Context

Organizations worldwide struggle with massive content repositories trapped in single languages and locked in non-digital formats. The Hare Krishna Mandir's 2TB archive exemplifies this challenge, containing both digital text and scanned manuscripts requiring text extraction before transformation into multilingual resources. This platform addresses the complete content processing pipeline: text extraction for digitization and translation for global accessibility.

### Change Log
| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2025-09-23 | 1.0 | Initial PRD with complex multi-service architecture | John (PM) |
| 2025-10-02 | 2.0 | Simplified Supabase-first architecture, backend rebuild | John (PM) |
| 2025-10-03 | 2.1 | Added Story 1.5 (Parallel Workers), moved Translation to 1.6 | Claude + John |

---

## Technical Architecture

### Core Platform Decision

We are using **Supabase Cloud (Free Tier)** as our complete backend platform. This single decision eliminates the need for Redis, Celery, S3, Socket.io, and complex Docker orchestration.

### Why Supabase Cloud?

1. **Complete Backend in One Service**
   - PostgreSQL database with pgmq extension (message queuing)
   - Supabase Storage (file storage with CDN)
   - Supabase Realtime (WebSocket for live updates)
   - Supabase Auth (user authentication - ready when needed)
   - PostgREST (auto-generated REST APIs)

2. **Free Tier is Sufficient for MVP**
   - 500MB database storage
   - 1GB file storage
   - 2GB bandwidth
   - pgmq, Realtime, Auth all included
   - No credit card required

3. **No IPv4/IPv6 Issues**
   - Cloud endpoints work everywhere
   - No local networking workarounds
   - Direct connection from any dev environment

4. **Easy Scaling Path**
   - Start free
   - $25/month when you need more
   - Same architecture, just bigger limits

### Technology Stack (Final)

| Layer | Technology | Version | Rationale |
|-------|------------|---------|-----------|
| **Database** | Supabase (PostgreSQL) | 15+ | Complete backend platform with pgmq, Realtime, Storage |
| **Queue** | pgmq | Latest | Built into PostgreSQL, no separate service needed |
| **Storage** | Supabase Storage | Latest | Integrated CDN, automatic optimization |
| **Real-time** | Supabase Realtime | Latest | WebSocket built into Supabase |
| **Auth** | Supabase Auth | Latest | JWT-based, ready when needed |
| **Backend API** | FastAPI | 0.117+ | Custom business logic only (Vertex AI, PDF processing) |
| **Backend Language** | Python | 3.13+ | Strong AI/ML ecosystem |
| **Frontend** | React + Vite | 18.3+ | Already built (Lovable), no changes needed |
| **AI Service** | Vertex AI Gemini 2.5 Pro | Latest | Google Cloud, 1M input / 65K output tokens |


---

## System Architecture

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     FRONTEND (React)                         │
│  - Lovable UI (already built)                               │
│  - Direct Supabase connection via @supabase/supabase-js     │
│  - Real-time updates via Supabase Realtime                  │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ├──────────────► Supabase Cloud (Free Tier)
                 │                ├─ PostgreSQL + pgmq
                 │                ├─ Supabase Storage (files)
                 │                ├─ Realtime (WebSocket)
                 │                └─ Auth (for later)
                 │
                 └──────────────► FastAPI Backend
                                  ├─ Vertex AI integration
                                  ├─ PDF processing
                                  ├─ Translation logic
                                  └─ pgmq workers
```

### Data Flow

**Upload Flow:**
1. User uploads PDF via frontend
2. Frontend → Supabase Storage (direct upload)
3. Frontend → FastAPI (trigger processing)
4. FastAPI → pgmq (queue text extraction job)
5. pgmq worker → Vertex AI (extract text)
6. Worker → Supabase DB (save results)
7. Supabase Realtime → Frontend (live progress updates)

**Translation Flow:**
1. User clicks "Translate"
2. Frontend → FastAPI (start translation)
3. FastAPI → pgmq (queue translation job)
4. pgmq worker → Vertex AI (translate text)
5. Worker → Supabase DB (save translation)
6. Supabase Realtime → Frontend (live updates)

---

## Requirements

### Functional Requirements

**FR1:** Multi-tenant architecture with complete data isolation between organizations
**FR2:** Text extraction from PDFs using Vertex AI Gemini 2.5 Pro (1M input / 65K output tokens)
**FR3:** Translation between 6 languages (English, Hindi, Marathi, Bengali, Gujarati, German)
**FR4:** File upload via drag-and-drop (PDF, JPG, PNG, DOCX up to 100MB)
**FR5:** Two-stage workflow: Source Text Editor → Translation Editor with approval gates
**FR6:** Side-by-side editor for reviewing extracted text and translations
**FR7:** Translation glossaries with version control and import/export (CSV, TMX)
**FR8:** Background job processing with real-time progress updates
**FR9:** Export to PDF, DOCX, TXT with structure preservation
**FR10:** Batch processing with template system for repeated operations

### Non-Functional Requirements

**NFR1:** Quality over speed: >95% accuracy for printed text, >85% for handwritten content, 100% for Sanskrit/religious terminology. Preserve document structure (indentation, line breaks, paragraph spacing). Processing times of 30-60s per page acceptable.

**NFR2:** Real-time progress updates via Supabase Realtime subscriptions

**NFR3:** Graceful handling of long-running operations with pgmq background processing

**NFR4:** Platform must scale to support 1000+ concurrent users across all tenants

**NFR5:** All data encrypted at rest (Supabase handles this) and in transit (TLS 1.3)

**NFR6:** Supabase Cloud infrastructure provides:
- PostgreSQL with pgmq extension for message queuing
- Supabase Realtime for WebSocket communications
- Supabase Storage for file management
- Supabase Auth (GoTrue) for authentication
- PostgREST for auto-generated REST APIs
- Row Level Security (RLS) for multi-tenant data isolation

---

## Queue Architecture & Processing Pipeline

### Using pgmq (PostgreSQL Message Queue)

**Why pgmq?**
- Built into PostgreSQL (no separate service)
- ACID guarantees with database operations
- Transactional consistency
- Exactly-once delivery
- Simple to use, reliable

### Queue Structure

**Two Queues:**

1. **`text_extraction_queue`** - For PDF text extraction jobs
   ```sql
   CREATE EXTENSION IF NOT EXISTS pgmq;
   SELECT pgmq.create('text_extraction_queue');
   ```

2. **`translation_queue`** - For translation jobs
   ```sql
   SELECT pgmq.create('translation_queue');
   ```

### Job Processing Flow

**Text Extraction:**
```python
# Send job to queue
await pgmq.send(
    queue_name='text_extraction_queue',
    message={
        'document_id': doc_id,
        'pages': [1, 2, 3, 4, 5],
        'priority': 8
    }
)

# Worker picks up job
job = await pgmq.read('text_extraction_queue', vt=30)

# Process with Vertex AI
result = await vertex_ai.extract_text(job['document_id'])

# Save to database
await db.save_extraction_result(result)

# Delete from queue (job complete)
await pgmq.delete('text_extraction_queue', job['msg_id'])

# Notify frontend via Supabase Realtime
await supabase.channel('document_updates').send({
    'event': 'extraction_complete',
    'document_id': doc_id
})
```

### Priority System

- **High Priority (8-10)**: Small documents, urgent requests
- **Medium Priority (5-7)**: Regular processing
- **Low Priority (1-4)**: Large batch jobs

Jobs processed in priority order within each queue.

### Worker Architecture

```python
# Simple pgmq worker
async def text_extraction_worker():
    while True:
        # Read job from queue (30 second visibility timeout)
        job = await pgmq.read('text_extraction_queue', vt=30)

        if job:
            try:
                # Process the job
                await process_extraction(job['message'])

                # Delete from queue (success)
                await pgmq.delete('text_extraction_queue', job['msg_id'])
            except Exception as e:
                # Job will automatically return to queue after 30s
                logger.error(f"Job failed: {e}")
        else:
            # No jobs, wait 5 seconds
            await asyncio.sleep(5)
```



## Epic 1: Core Translation System (Simplified)

**Objective:** Build a working PDF translation system with text extraction and translation capabilities. Backend will be rebuilt from scratch using Supabase Cloud.

### Story 1.1: Supabase Cloud Setup & Direct Database Connection

**As a** Developer
**I want** to establish direct PostgreSQL connection to Supabase (NOT via REST API)
**So that** I can use pgmq, run custom SQL, and have full database access from the backend

**Critical Issue to Solve:**
Previous attempts were blocked from direct PostgreSQL access and forced to use PostgREST APIs only. This story MUST solve the direct connection problem.

**Acceptance Criteria:**
1. Supabase Cloud project created (free tier)
2. **DIRECT PostgreSQL connection working from backend (NOT PostgREST)**
3. Backend can execute raw SQL queries without REST API
4. pgmq extension installed and accessible via direct connection
5. Core tables created via direct SQL execution
6. Connection pooler configured correctly (if needed)
7. IPv4/IPv6 networking issues resolved
8. Test pgmq operations (send/read/delete) working

**Tasks:**
- Sign up for Supabase Cloud (free tier)
- Create new project and get all connection strings
- **Test DIRECT connection methods:**
  - Connection string: `postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres`
  - Transaction pooler: `postgresql://postgres:[PASSWORD]@[PROJECT-REF].pooler.supabase.com:6543/postgres`
  - Session pooler: `postgresql://postgres:[PASSWORD]@[PROJECT-REF].pooler.supabase.com:5432/postgres`
- Debug and resolve any IPv4/IPv6 connection issues
- Install pgmq extension via SQL editor: `CREATE EXTENSION IF NOT EXISTS pgmq;`
- Test pgmq functions directly: `SELECT pgmq.create('test_queue');`
- Run schema creation SQL script via direct connection
- Verify backend can execute custom SQL (not just REST API)
- Document the working connection method for future reference

**Success Criteria:**
✅ Backend has direct PostgreSQL access
✅ pgmq operations work without REST API wrapper
✅ Can run any SQL query from Python backend
✅ No forced dependency on PostgREST for database operations

---

### Story 1.2: Backend API Foundation

**As a** Developer
**I want** a FastAPI application with Supabase integration
**So that** I can build custom business logic

**Acceptance Criteria:**
1. FastAPI application with health check endpoint
2. Supabase client initialized and working
3. CORS configured for frontend (port 5173)
4. Environment variables loaded from .env
5. Basic error handling and logging
6. API documentation available at /docs

**Tasks:**
- Create FastAPI app structure
- Install dependencies (fastapi, uvicorn, supabase-py)
- Configure Supabase client
- Add health check endpoint
- Test from frontend
- Add logging configuration

---

### Story 1.2: PDF Upload and Storage System

**As a** User
**I want** to upload PDFs and have them stored securely
**So that** I can process them for text extraction

**Acceptance Criteria:**
1. Backend API endpoint: `POST /api/documents/upload`
2. Files uploaded to Supabase Storage bucket: `documents`
3. Document metadata saved to `documents` table with exact schema (see TECHNICAL_ARCHITECTURE.md Section 2.1)
4. SHA-256 hash calculated for deduplication
5. File validation: PDF only, max 500MB
6. Response includes document ID, storage_path, page_count
7. Frontend receives proper response format (see FRONTEND_BACKEND_GAP_ANALYSIS.md Section 3.1)

**Critical Requirements:**
- **Response format MUST match frontend expectations** (see FRONTEND_BACKEND_GAP_ANALYSIS.md Section 3.1)
- Database schema MUST match exactly (file_name, original_name, storage_path, etc.)
- Storage path format: `{tenant_id}/{timestamp}-{filename}`

**Tasks:**
- Create Supabase Storage bucket (`documents`) with private RLS
- Implement `POST /api/documents/upload` endpoint
- Add SHA-256 hash calculation for deduplication
- Extract page count using PyPDF2
- Save document metadata to database
- Test with 500+ page PDFs
- Validate frontend integration

**Reference:** TECHNICAL_ARCHITECTURE.md Section 3.1 for complete API specification

---

### Story 1.3: Text Extraction with Vertex AI and Batch Processing

**As a** User
**I want** AI-powered text extraction from my PDFs with progress updates
**So that** I can access the content for translation

**Acceptance Criteria:**
1. Backend API endpoint: `POST /api/text-extraction/extract-with-batching/{document_id}`
2. Backend API endpoint: `GET /api/text-extraction/status/{job_id}`
3. Extraction job queued via pgmq `text_extraction_queue`
4. Worker processes jobs with intelligent batching (see ARCHITECTURE_DECISIONS.md Decision 7)
5. PDF sent to Vertex AI Gemini 2.5 Pro in batches (50-100 pages for digital, 20-30 for scanned)
6. **Extracted text MUST include page markers in format: `# [Page N]`** (CRITICAL - see FRONTEND_BACKEND_GAP_ANALYSIS.md Section 5.3)
7. Results saved to `text_extraction_results` table with exact schema
8. Real-time progress updates via Supabase Realtime
9. Frontend polling receives status updates every 2 seconds
10. Editor successfully loads and parses extracted text

**Critical Requirements:**
- **Page Marker Format**: MUST use `# [Page N]` (regex: `/^#\s*\[Page\s+(\d+)\]$/i`)
- **Token-Based Batching**: Use algorithm from TECHNICAL_ARCHITECTURE.md Section 7.1
- **Batch Coordination**: Track batches in `processing_batches` table
- **Selected Pages Support**: Process only user-selected pages (virtual references, no physical splitting)
- **Response Formats**: Must match frontend expectations (FRONTEND_BACKEND_GAP_ANALYSIS.md Section 3.2)

**Tasks:**
- Implement `POST /api/text-extraction/extract-with-batching/{document_id}`
- Implement `GET /api/text-extraction/status/{job_id}`
- Create token estimation algorithm
- Create batch splitting logic
- Implement text extraction worker with pgmq
- **Implement page marker insertion** (CRITICAL for editor)
- Configure Vertex AI Gemini 2.5 Pro client
- Test with 500+ page PDFs
- Enable Supabase Realtime on `text_extraction_results` table
- Test polling and Realtime notifications
- Validate extracted_text format in editor

**Reference:**
- TECHNICAL_ARCHITECTURE.md Sections 3.2, 7, 8 for complete specifications
- FRONTEND_BACKEND_GAP_ANALYSIS.md Section 5.3 for page marker format requirements

---

### Story 1.4: Frontend-Backend Integration & End-to-End Testing

**As a** User
**I want** the existing frontend to work seamlessly with the new backend
**So that** I have a complete working upload → extraction → editor flow

**Acceptance Criteria:**
1. Frontend successfully uploads PDFs via `POST /api/documents/upload`
2. Frontend triggers extraction via `POST /api/text-extraction/extract-with-batching/{document_id}`
3. Frontend polls status endpoint and receives progress updates
4. Supabase Realtime subscriptions working for live updates
5. Editor loads extraction results and parses page markers correctly
6. Upload → Extract → Editor flow works end-to-end
7. No console errors, clean user experience
8. All 12 integration test scenarios pass (see FRONTEND_BACKEND_GAP_ANALYSIS.md Section 13.1)

**Critical Integration Points:**
- **API Response Formats**: Must match exactly (FRONTEND_BACKEND_GAP_ANALYSIS.md Section 3)
- **Database Schemas**: Must match exactly (FRONTEND_BACKEND_GAP_ANALYSIS.md Section 2)
- **Page Markers**: Must be parseable by frontend regex
- **Realtime Channels**: Must be subscribed correctly (FRONTEND_BACKEND_GAP_ANALYSIS.md Section 6)

**Tasks:**
- Verify all API endpoints return expected formats
- Test upload flow with 10-page, 100-page, and 500-page PDFs
- Test selected pages extraction (pages 1, 5, 10 only)
- Verify Realtime subscriptions trigger UI updates
- Test polling as fallback when Realtime unavailable
- Validate editor parses extracted_text correctly
- Test page navigation in editor
- Run complete integration test suite
- Document any frontend adjustments needed

**Reference:**
- FRONTEND_BACKEND_GAP_ANALYSIS.md Sections 5, 9 for complete data flows
- TECHNICAL_ARCHITECTURE.md Section 13 for testing scenarios

---

### Story 1.5: Parallel Worker Architecture (HIGH PRIORITY)

**As a** Developer
**I want** multiple text extraction workers running concurrently
**So that** 3-4 jobs can process simultaneously instead of waiting in a sequential queue

**Strategic Rationale:**
- Current sequential processing is a production bottleneck (users wait 15+ minutes for multiple documents)
- Translation queue will need the same parallel architecture
- Solve once, apply twice (text extraction + translation)
- Better to document the pattern now and reuse it later

**Acceptance Criteria:**
1. Worker pool manager spawns 3-4 concurrent worker processes
2. Each worker polls pgmq independently (pgmq handles locking)
3. 4 text extraction jobs process simultaneously
4. No race conditions or database conflicts
5. Worker health monitoring and auto-restart on failure
6. Backend API endpoints for worker status (`/api/workers/status`, `/api/workers/health`)
7. Queue monitoring page shows active worker count
8. Documentation created for parallel worker pattern (architecture diagram, deployment guide)

**Technical Approach:**
- Create `backend/workers/worker_pool_manager.py` to spawn worker processes
- Refactor `text_extraction_worker.py` to be concurrency-safe
- Add worker ID logging for debugging
- Implement health checks and graceful shutdown
- Configure via environment variable: `WORKER_POOL_SIZE=4`

**Implementation Details:**
```python
# Worker Pool Manager spawns N processes
class WorkerPoolManager:
    def __init__(self, pool_size: int = 4):
        self.pool_size = pool_size

    def start(self):
        for i in range(self.pool_size):
            worker = Process(target=run_worker, args=(i,))
            worker.start()

# Each worker polls pgmq independently
class TextExtractionWorker:
    def __init__(self, worker_id: int):
        self.worker_id = worker_id

    def run(self):
        while True:
            job = pgmq.read('text_extraction_queue', vt=30)
            if job:
                self.process_job(job)
```

**Queue Monitoring Enhancements:**
- Display active worker count: "3/4 workers running"
- Show which worker is processing which job: "Worker-1 (doc_123), Worker-2 (doc_456)"
- Display queue depth: "5 jobs waiting"

**Documentation to Create:**
1. `docs/architecture/parallel-workers.md` - Architecture diagram, pgmq concurrency guarantees, scaling considerations
2. `docs/deployment/worker-setup.md` - How to start worker pool, environment variables, monitoring
3. `docs/troubleshooting/workers.md` - Common issues, log analysis, performance tuning

**Tasks:**
- Create `backend/workers/worker_pool_manager.py` with multiprocessing
- Refactor `text_extraction_worker.py` to add worker_id logging
- Add concurrency-safe database connection handling
- Implement health check endpoints (`/api/workers/status`, `/api/workers/health`)
- Test with 4 concurrent jobs processing simultaneously
- Update queue monitoring page to show active workers
- Create architecture documentation with diagrams
- Create deployment guide for production
- Create troubleshooting guide

**Success Criteria:**
- ✅ 4 concurrent text extraction jobs process without conflicts
- ✅ Worker failures don't affect other workers
- ✅ Queue page displays active worker count and job assignments
- ✅ Comprehensive documentation for reuse in translation queue
- ✅ Pattern documented and ready to apply to Story 1.6 (Translation)

**Estimated Effort:** 4-6 hours

**Reference:**
- pgmq handles message locking automatically (ACID guarantees)
- Pattern will be reused in Story 1.6 for translation queue

---

### Story 1.6: Translation Pipeline

**As a** User
**I want** to translate extracted text to target languages
**So that** I can share content with global audiences

**Note**: This story will use the parallel worker architecture from Story 1.5, enabling concurrent translation jobs from day one.

**Acceptance Criteria:**
1. Backend API endpoint: `GET /api/translation/status/{document_id}`
2. Translation job queued via pgmq `translation_queue`
3. **Parallel workers process 3-4 translation jobs concurrently** (reusing Story 1.5 pattern)
4. Text sent to Vertex AI for translation
5. Translated text saved to `translations` table with page markers
6. Real-time progress updates working
7. Frontend displays translation results in editor

**Strategic Benefit:**
- Implement with parallel processing from start (no technical debt)
- Copy worker pool pattern from Story 1.5
- Faster implementation with existing reference architecture

**Tasks:**
- Implement `GET /api/translation/status/{document_id}` endpoint
- Create `backend/workers/translation_worker.py` (copy pattern from text_extraction_worker.py)
- Create `backend/workers/translation_pool_manager.py` (copy from worker_pool_manager.py)
- Implement Vertex AI translation API calls
- Add translation job queuing logic
- Save results to `translations` table
- Enable Realtime on `translations` table
- Configure parallel worker pool (env: `TRANSLATION_WORKER_POOL_SIZE=4`)
- Test concurrent translation flow
- Validate translated text displays in editor

**Reference:**
- TECHNICAL_ARCHITECTURE.md Section 3.3 for API specification
- FRONTEND_BACKEND_GAP_ANALYSIS.md Section 3.3 for endpoint requirements
- Story 1.5 documentation for parallel worker pattern

**Estimated Effort:** 8-10 hours (faster due to reusable pattern from Story 1.5)

---

### Story 1.7: Export & Download System (Future - Not MVP)

**As a** User
**I want** to download extracted/translated text in various formats
**So that** I can use the content in other applications

**Note**: Deferred to post-MVP phase.

---

### Story 1.8: User Management & Authentication (Future - Not MVP)

**As a** User
**I want** secure user authentication and multi-tenancy
**So that** my documents are private and secure

**Note**: Currently using `anonymous-user` placeholder. Deferred to post-MVP phase.

**Reference:** TECHNICAL_ARCHITECTURE.md Section 11 for RLS policies (ready when needed)

---

## Epic 1 Story Summary

### Completed Stories ✅
- **Story 1.1**: Supabase Setup & Database Connection - COMPLETE
- **Story 1.2**: Document Upload API - COMPLETE
- **Story 1.3**: Text Extraction with Vertex AI - COMPLETE
- **Story 1.4**: Frontend Integration & Testing - COMPLETE

### Current Sprint
- **Story 1.5**: Parallel Worker Architecture - **NEXT (HIGH PRIORITY)**
  - Enables 3-4 concurrent text extraction jobs
  - Removes production bottleneck
  - Creates reusable pattern for translation workers
  - Estimated: 4-6 hours

### Upcoming Stories
- **Story 1.6**: Translation Pipeline - After 1.5
  - Will use parallel worker pattern from Story 1.5
  - Concurrent translation jobs from day one
  - Estimated: 8-10 hours (faster due to reusable pattern)

### Future / Post-MVP
- **Story 1.7**: Export & Download System
- **Story 1.8**: User Management & Authentication

**Strategic Decision**: Implementing parallel workers (1.5) before translation (1.6) ensures both queues have proper concurrency from the start, avoiding technical debt and reducing overall development time.

---

## User Interface Design Goals

### Frontend Status

**Current State:** Frontend is **100% complete** (Lovable-generated React app)

**What Exists:**
- Dashboard with active processing widgets
- Upload center with drag-and-drop
- Page selection interface
- Processing queue visualization
- Translation editor (two-panel)
- Glossary management (placeholder)

**What May Be Reduced:**
- Some advanced features not needed for MVP
- Complex workflows can be simplified
- Remove any non-essential UI components

**No Changes Needed For:**
- Core upload flow
- Basic text extraction view
- Simple translation interface
- Document list/grid

---

## Database Schema

### Core Tables

**documents**
```sql
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    file_name TEXT NOT NULL,
    file_size BIGINT,
    storage_path TEXT NOT NULL,  -- Supabase Storage path
    page_count INTEGER,
    selected_pages JSONB,  -- Array of page numbers
    status TEXT DEFAULT 'uploaded',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**text_extraction_results**
```sql
CREATE TABLE text_extraction_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID REFERENCES documents(id),
    extracted_text TEXT,
    confidence_score FLOAT,
    page_count INTEGER,
    token_count INTEGER,
    processing_time FLOAT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**translations**
```sql
CREATE TABLE translations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID REFERENCES documents(id),
    extraction_id UUID REFERENCES text_extraction_results(id),
    source_language TEXT,
    target_language TEXT,
    translated_text TEXT,
    confidence_score FLOAT,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    verified_at TIMESTAMPTZ
);
```

**queue_jobs** (tracking table, pgmq handles actual queuing)
```sql
CREATE TABLE queue_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_type TEXT NOT NULL,  -- 'text_extraction' or 'translation'
    document_id UUID REFERENCES documents(id),
    queue_name TEXT,
    status TEXT DEFAULT 'queued',
    priority INTEGER DEFAULT 5,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    error_message TEXT
);
```

---

## Security & Multi-Tenancy

### Row Level Security (RLS)

Supabase provides built-in Row Level Security. Enable on all tables:

```sql
-- Example for documents table
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own tenant's documents
CREATE POLICY tenant_isolation ON documents
    FOR ALL
    USING (tenant_id = current_setting('app.tenant_id')::UUID);
```

### Authentication

**MVP:** No authentication required (single tenant - HDA)

**Future:** Supabase Auth ready when needed
- Email/password authentication
- JWT token management
- Multi-factor authentication
- SSO support

---

## Cost Projections

### Supabase Cloud (Free Tier)
- **Database**: 500MB (sufficient for MVP)
- **Storage**: 1GB (sufficient for testing)
- **Bandwidth**: 2GB/month
- **Cost**: $0/month

### When to Upgrade to Pro ($25/month)
- Database > 500MB (around 100+ documents)
- Need more than 1GB storage
- Exceed bandwidth limits
- Want automatic backups

### Vertex AI Costs (Gemini 2.5 Pro)
- **Input tokens**: $1.25 per 1M tokens (≤200K context)
- **Input tokens**: $2.50 per 1M tokens (>200K context)
- **Output tokens**: $10 per 1M tokens
- **Typical 100-page PDF**: ~$0.56 for extraction + translation
- **Monthly estimate (100 documents)**: ~$56

### Total MVP Cost
- Supabase: **$0/month** (free tier)
- Vertex AI: **~$50-100/month** (depending on usage)
- **Total: $50-100/month**

---

## Development Practices


### Environment Variables

```bash
# .env file
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key

# Vertex AI
GOOGLE_CLOUD_PROJECT_ID=your-project-id
VERTEX_AI_LOCATION=us-central1
VERTEX_AI_MODEL=gemini-2.5-pro
GOOGLE_APPLICATION_CREDENTIALS=./vertex-ai-credentials.json

# Backend
ENVIRONMENT=development
DEBUG=true
```

### Testing Strategy

**Unit Tests:**
- Vertex AI service
- PDF processing logic
- Pydantic schemas

**Integration Tests:**
- API endpoints with mock Supabase
- pgmq job processing
- End-to-end upload flow

**E2E Tests:**
- Frontend → Backend → Vertex AI
- Complete translation pipeline

---

## Success Criteria

**MVP is successful when:**
1. ✅ User can upload a PDF via frontend
2. ✅ PDF is stored in Supabase Storage
3. ✅ Text extraction job processes via pgmq worker
4. ✅ Extracted text displays in frontend
5. ✅ Translation job processes and completes
6. ✅ User can view and download translated text
7. ✅ Real-time progress updates work throughout
8. ✅ No Redis, Celery, or S3 dependencies
9. ✅ Runs entirely on Supabase Cloud free tier + FastAPI

---

## What We Learned

### Why the Original Architecture Failed

1. **Over-Engineering**: Used Redis + Celery when pgmq would suffice
2. **Storage Confusion**: Mixed local, S3, and Supabase Storage references
3. **Self-Hosting Too Early**: IPv4/IPv6 issues, complex Docker setup
4. **Conflicting Documentation**: PRD said "use Supabase" but architecture included Redis/Celery
5. **"Migrate Later" Trap**: Built dual systems instead of committing to one approach

### How This Version Fixes It

1. **Single Source of Truth**: Supabase Cloud for everything
2. **No Migration Strategy**: Start with the right architecture from day 1
3. **Minimal Backend**: FastAPI only for custom business logic
4. **Clear Technology Choices**: One technology per job, no alternatives
5. **Cloud-First**: Avoid infrastructure complexity until scale demands it

---

## Next Steps

1. **Review this PRD** - Make any necessary adjustments
2. **Create Architecture Document** - Detailed technical specs
3. **Write Story Details** - Expand Stories 1.1-1.6 with technical tasks
4. **Set Up Supabase Cloud** - Create project, configure database
5. **Build Backend** - 6 stories, estimated 1-2 weeks of focused work
6. **Connect Frontend** - Update API endpoints, test flows
7. **Deploy MVP** - Launch to HDA for testing

---

**Document Status**: Ready for Review
**Next Review**: Architecture Document
**Author**: John (PM)
**Date**: 2025-10-02
