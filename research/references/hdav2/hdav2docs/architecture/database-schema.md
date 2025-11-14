# Database Schema

**Version**: 2.0
**Last Updated**: 2025-10-02
**Purpose**: Complete PostgreSQL database schema for HDA Translation Platform v2.0

---

## Overview

All data is stored in **Supabase PostgreSQL** with the following extensions:
- `uuid-ossp` - UUID generation
- `pgmq` - Message queue (for background jobs)

---

## Complete Schema

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

    -- Constraints
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
-- DOCUMENT_PAGES TABLE (Optional - for detailed page tracking)
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

---

## Schema Relationships

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

---

## Critical Schema Notes

### 1. Page Markers in `extracted_text`
**Format**: Must use `# [Page N]`
**Regex**: `/^#\s*\[Page\s+(\d+)\]$/i`
**Example**:
```
# [Page 1]
First line of page 1
Second line of page 1

# [Page 2]
First line of page 2
```

### 2. Virtual Pages
No physical PDF files stored per page. All page references are virtual (metadata only).

### 3. Batch Coordination
`processing_batches` tracks which pages are in which batch during extraction.

### 4. Cascade Deletes
Deleting a document cascades to all related records (extractions, translations, batches).

### 5. Token Counts
Store both `estimated_tokens` and `actual_tokens` for cost tracking and optimization.

---

## Common Queries

### Get Document with Latest Extraction
```sql
SELECT
    d.*,
    e.extracted_text,
    e.status AS extraction_status,
    e.progress AS extraction_progress
FROM documents d
LEFT JOIN LATERAL (
    SELECT * FROM text_extraction_results
    WHERE document_id = d.id
    ORDER BY created_at DESC
    LIMIT 1
) e ON true
WHERE d.id = 'document-uuid';
```

### Get Batch Progress for Job
```sql
SELECT
    batch_number,
    total_batches,
    status,
    start_page,
    end_page,
    processing_time
FROM processing_batches
WHERE extraction_job_id = 'job-uuid'
ORDER BY batch_number;
```

### Get All Translations for Document
```sql
SELECT
    target_language,
    status,
    progress,
    confidence_score,
    created_at,
    completed_at
FROM translations
WHERE document_id = 'document-uuid'
ORDER BY created_at DESC;
```

---

## Migration Steps

1. Create Supabase project
2. Enable extensions (`uuid-ossp`, `pgmq`)
3. Run complete schema SQL
4. Verify all tables created
5. Test insert/update/delete operations
6. Enable Supabase Realtime on tables

---

**Reference**: See `docs/stories/1.1-supabase-setup.md` for detailed setup instructions.
