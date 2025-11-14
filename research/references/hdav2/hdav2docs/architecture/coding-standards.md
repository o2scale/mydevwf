# Coding Standards & Tech Stack

**Version**: 2.0
**Last Updated**: 2025-10-02
**Purpose**: Development standards, tech stack, and best practices for HDA Translation Platform v2.0

---

## Technology Stack

### Backend

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Runtime | Python | 3.13+ | Backend language |
| API Framework | FastAPI | 0.117+ | REST API endpoints |
| Server | Uvicorn | 0.34+ | ASGI server |
| Database Client | psycopg2 | 2.9+ | Direct PostgreSQL access |
| Supabase SDK | supabase-py | 2.13+ | Supabase client |
| Queue | pgmq | 0.11+ | Message queue |
| AI SDK | vertexai | 1.75+ | Google Vertex AI |
| PDF Processing | PyPDF2 | 3.0+ | Page count extraction |
| Image Conversion | pdf2image | 1.17+ | PDF to images for Vertex AI |
| Image Library | Pillow | 11.0+ | Image manipulation |
| Environment | python-dotenv | 1.0+ | Environment variables |

### Frontend (Already Built)

| Component | Technology | Version |
|-----------|------------|---------|
| Framework | React | 18.3+ |
| Build Tool | Vite | 5.0+ |
| Supabase Client | @supabase/supabase-js | 2.x |

### Infrastructure

| Component | Service | Plan |
|-----------|---------|------|
| Database | Supabase PostgreSQL | Free Tier |
| Storage | Supabase Storage | Free Tier |
| Realtime | Supabase Realtime | Free Tier |
| AI | Google Vertex AI | Pay-as-you-go |

---

## Directory Structure

```
backend/
├── api/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app entry point
│   ├── config.py               # Environment configuration
│   ├── routers/
│   │   ├── __init__.py
│   │   ├── documents.py        # Document upload endpoints
│   │   └── text_extraction.py # Extraction endpoints
│   ├── services/
│   │   ├── __init__.py
│   │   ├── supabase.py         # Supabase client setup
│   │   ├── vertex_ai.py        # Vertex AI integration
│   │   └── batch_processor.py  # Batch calculation logic
│   └── utils/
│       ├── __init__.py
│       ├── token_estimator.py
│       └── page_markers.py
├── workers/
│   ├── __init__.py
│   ├── text_extraction_worker.py
│   └── translation_worker.py    # Future
├── tests/
│   ├── __init__.py
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── requirements.txt
├── .env.example
└── README.md
```

---

## Python Coding Standards

### Style Guide

Follow **PEP 8** with these specifics:

**Line Length**: 100 characters (not 79)
**Indentation**: 4 spaces (no tabs)
**Quotes**: Double quotes for strings
**Imports**: Grouped and sorted (stdlib, third-party, local)

**Example**:
```python
import os
from datetime import datetime
from typing import Optional, List

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from supabase import create_client

from api.services.batch_processor import calculate_batches
```

### Type Hints

Use type hints for all function signatures:

```python
async def process_extraction(
    document_id: str,
    selected_pages: Optional[List[int]] = None
) -> Dict[str, Any]:
    """
    Process text extraction for a document

    Args:
        document_id: UUID of the document
        selected_pages: Optional list of page numbers

    Returns:
        Job information dictionary
    """
    # Implementation...
```

### Error Handling

Use specific exception types:

```python
try:
    result = await vertex_ai.extract_text(pdf_bytes)
except VertexAIRateLimitError as e:
    raise HTTPException(status_code=429, detail="AI service rate limit exceeded")
except VertexAIAuthError as e:
    raise HTTPException(status_code=500, detail="AI service authentication failed")
except Exception as e:
    logger.error(f"Unexpected error: {e}")
    raise HTTPException(status_code=500, detail="Internal server error")
```

### Async/Await

Use async for I/O-bound operations:

```python
# Good
async def upload_to_storage(file_bytes: bytes, path: str):
    await supabase.storage.from_("documents").upload(path, file_bytes)

# Bad (blocking)
def upload_to_storage(file_bytes: bytes, path: str):
    supabase.storage.from_("documents").upload(path, file_bytes)  # Blocks
```

---

## API Design Patterns

### Endpoint Naming

- Use lowercase with hyphens
- Resource-based URLs
- Version in path (future)

```python
# Good
POST /api/documents/upload
GET /api/text-extraction/status/{job_id}

# Bad
POST /api/UploadDocument
GET /api/getExtractionStatus
```

### Response Format

Consistent response structure:

```python
# Success response
{
  "data": {...},
  "message": "Success message",
  "timestamp": "2025-10-02T10:00:00Z"
}

# Error response
{
  "detail": "Error message",
  "error_code": "INVALID_FILE_TYPE",
  "timestamp": "2025-10-02T10:00:00Z"
}
```

### Request Validation

Use Pydantic models:

```python
from pydantic import BaseModel, Field

class ExtractionRequest(BaseModel):
    auto_translate: bool = Field(default=False, description="Auto-start translation")
    target_languages: List[str] = Field(default=[], max_length=10)
    selected_pages: Optional[List[int]] = Field(default=None, min_length=1)

@router.post("/extract/{document_id}")
async def start_extraction(
    document_id: str,
    request: ExtractionRequest
):
    # Request is automatically validated
    ...
```

---

## Database Standards

### Naming Conventions

- Tables: `snake_case`, plural (e.g., `documents`, `text_extraction_results`)
- Columns: `snake_case` (e.g., `file_name`, `created_at`)
- Indexes: `idx_{table}_{column}` (e.g., `idx_documents_status`)

### Timestamps

All tables must have:
```sql
created_at TIMESTAMPTZ DEFAULT NOW(),
updated_at TIMESTAMPTZ DEFAULT NOW()
```

### Foreign Keys

Always use `ON DELETE CASCADE` or `ON DELETE SET NULL`:
```sql
document_id UUID REFERENCES documents(id) ON DELETE CASCADE
```

---

## Environment Variables

### Required Variables

```bash
# Supabase
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_KEY=eyJ...
DATABASE_URL=postgresql://...

# Vertex AI
GOOGLE_CLOUD_PROJECT=project-id
VERTEX_AI_LOCATION=us-central1
VERTEX_AI_MODEL=gemini-2.0-flash-exp
GOOGLE_APPLICATION_CREDENTIALS=./credentials.json

# Backend API
API_HOST=0.0.0.0
API_PORT=8000
ENVIRONMENT=development
DEBUG=true

# Frontend
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
```

### Loading Environment Variables

```python
from dotenv import load_dotenv
import os

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
if not SUPABASE_URL:
    raise ValueError("SUPABASE_URL not set")
```

---

## Logging

### Log Format

```python
import logging
import structlog

# Configure structured logging
logging.basicConfig(level=logging.INFO)
logger = structlog.get_logger()

# Log with context
logger.info(
    "extraction_started",
    job_id=job_id,
    document_id=document_id,
    page_count=page_count
)

logger.error(
    "extraction_failed",
    job_id=job_id,
    error=str(e),
    retry_count=retry_count
)
```

### Log Levels

- `DEBUG`: Detailed diagnostic information
- `INFO`: General informational messages
- `WARNING`: Warning messages
- `ERROR`: Error messages
- `CRITICAL`: Critical failures

---

## Testing Standards

### Test Structure

```
tests/
├── unit/
│   ├── test_token_estimator.py
│   ├── test_batch_processor.py
│   └── test_page_markers.py
├── integration/
│   ├── test_upload_api.py
│   ├── test_extraction_api.py
│   └── test_full_flow.py
└── e2e/
    └── test_user_journey.py
```

### Test Naming

```python
def test_upload_valid_pdf_should_return_document_id():
    """Test that uploading a valid PDF returns document ID"""
    ...

def test_upload_invalid_file_type_should_return_400():
    """Test that uploading non-PDF returns 400 error"""
    ...
```

### Test Coverage

Minimum coverage targets:
- Unit tests: 80%
- Integration tests: 60%
- Critical paths: 100%

---

## Security Standards

### Secrets Management

- NEVER commit secrets to git
- Use `.env` for local development
- Use environment variables in production
- Rotate keys regularly

### Input Validation

```python
# Validate file type
if file.content_type != "application/pdf":
    raise HTTPException(400, "Invalid file type")

# Validate file size
MAX_FILE_SIZE = 500 * 1024 * 1024  # 500MB
if file_size > MAX_FILE_SIZE:
    raise HTTPException(413, "File too large")

# Sanitize filenames
import re
safe_filename = re.sub(r'[^a-zA-Z0-9._-]', '', filename)
```

### SQL Injection Prevention

Use parameterized queries:

```python
# Good
cursor.execute("SELECT * FROM documents WHERE id = %s", (document_id,))

# Bad
cursor.execute(f"SELECT * FROM documents WHERE id = '{document_id}'")
```

---

## Performance Standards

### Response Time Targets

| Endpoint | Target | Max |
|----------|--------|-----|
| Upload | <2s | 5s |
| Start Extraction | <500ms | 1s |
| Status Check | <100ms | 500ms |

### Caching Strategy

```python
from functools import lru_cache

@lru_cache(maxsize=100)
def estimate_tokens(page_count: int, document_type: str) -> int:
    """Cached token estimation"""
    ...
```

---

## Git Workflow

### Branch Naming

- `feature/story-1.1-supabase-setup`
- `bugfix/fix-page-marker-format`
- `hotfix/critical-vertex-ai-error`

### Commit Messages

```
feat(extraction): Add batch processing for large PDFs

- Implement token-based batch splitting
- Add batch coordination table
- Update worker to process sequentially

Closes #123
```

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guide
- [ ] Documentation updated
- [ ] No new warnings
```

---

## Documentation Standards

### Code Comments

```python
# Good - explains WHY
# Use token-based batching to stay within Vertex AI 1M token limit
batch_size = calculate_batch_size(total_pages, estimated_tokens)

# Bad - explains WHAT (obvious from code)
# Calculate batch size
batch_size = calculate_batch_size(total_pages, estimated_tokens)
```

### Function Docstrings

```python
def calculate_batches(
    document_id: str,
    job_id: str,
    total_pages: int,
    selected_pages: List[int]
) -> Dict:
    """
    Create batch records for a document based on token limits

    Splits large PDFs into batches to stay within Vertex AI's
    1M input token limit. Uses token estimation to determine
    optimal batch size.

    Args:
        document_id: UUID of the document
        job_id: UUID of the extraction job
        total_pages: Total pages in document
        selected_pages: Pages to process (may be subset)

    Returns:
        Dictionary with batch information:
        {
            "total_batches": 3,
            "estimated_tokens": 450000,
            "batch_strategy": "token-based"
        }

    Raises:
        ValueError: If selected_pages is empty
        DatabaseError: If batch creation fails

    Example:
        >>> batch_info = calculate_batches("doc-123", "job-456", 500, [1,2,3])
        >>> batch_info["total_batches"]
        1
    """
    ...
```

---

## Critical Implementation Notes

### Page Marker Format (BLOCKING ISSUE)

**MUST use exact format**: `# [Page N]`

```python
# Good
combined_text.append(f"# [Page {page_num}]")

# Bad - will break editor
combined_text.append(f"Page {page_num}")
combined_text.append(f"## [Page {page_num}]")
combined_text.append(f"# Page {page_num}")
```

**Regex Used by Frontend**: `/^#\s*\[Page\s+(\d+)\]$/i`

---

**Reference**: See individual story files for detailed implementation examples.
