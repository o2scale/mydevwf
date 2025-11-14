# Development Roadmap - HDA Translation Platform v2.0

**Last Updated**: October 3, 2025, 3:11 AM IST
**Current Status**: Story 1.1 Complete ✅

---

## Overview

This roadmap tracks the development progress of the HDA Translation Platform v2.0 backend rebuild. The platform enables text extraction and translation from PDF documents using Google Vertex AI.

---

## Epic 1: Core Translation System

**Goal**: Build complete backend with text extraction and translation capabilities
**Duration**: ~2-3 weeks
**Status**: In Progress (2/4 stories complete)

### Story 1.1: Supabase Cloud Setup ✅ COMPLETE

**Status**: ✅ **COMPLETED** - October 3, 2025
**Duration**: 2 hours
**Priority**: P0 (Blocker)

**Achievements**:
- ✅ Direct PostgreSQL connection via Session Pooler
- ✅ pgmq v1.4.4 installed and working
- ✅ 5 database tables deployed
- ✅ 2 message queues created
- ✅ Health check endpoint implemented

**Critical Learnings**:
- Must use Session Pooler (Port 5432) for pgmq
- IPv6-only for direct connection, use pooler instead
- Connection string format documented

**Deliverables**:
- Working backend API with health check
- Complete database schema
- Environment configuration
- Connection testing utilities

---

### Story 1.2: Document Upload API ✅ COMPLETE

**Status**: ✅ **COMPLETED** - October 3, 2025
**Duration**: 15 minutes
**Priority**: P0 (Blocker)
**Dependencies**: Story 1.1 ✅

**User Story**:
```
As a user
I want to upload PDF documents to the system
So that I can extract text and translate them
```

**Achievements**:
- ✅ `POST /api/documents/upload` endpoint implemented
- ✅ File validation (PDF only, max 500MB)
- ✅ Supabase Storage bucket created (`documents`)
- ✅ File uploaded to Supabase Storage
- ✅ PDF page count extracted (PyPDF2)
- ✅ Database record created in `documents` table
- ✅ Returns document ID and metadata
- ✅ SHA-256 hash for deduplication
- ✅ Duplicate detection working
- ✅ Error handling with rollback

**Critical Learnings**:
- Supabase Storage bucket created via Dashboard
- SHA-256 hash deduplication prevents duplicate uploads
- Storage path format: `{tenant_id}/{timestamp}-{filename}`
- PyPDF2 accurately extracts page count
- Rollback mechanism prevents orphaned files

**Deliverables**:
- `backend/api/routers/documents.py` - Upload endpoint (183 lines)
- `create_test_pdf.py` - Test PDF generator
- `test-sample.pdf` - 3-page test document
- API documentation at `/docs`

**Test Results**:
- ✅ Valid PDF upload: 3-page PDF uploaded successfully
- ✅ Duplicate detection: Hash matching prevents re-upload
- ✅ Invalid file type: 400 error for non-PDFs
- ✅ Response format: Matches frontend contract
- ✅ Storage integration: File accessible in Supabase Storage
- ✅ Database record: All fields populated correctly

---

### Story 1.3: Text Extraction Workflow 📅 PLANNED

**Status**: ⏳ **PLANNED**
**Estimated Duration**: 1 week
**Priority**: P0 (Blocker)
**Dependencies**: Story 1.2

**User Story**:
```
As a user
I want to extract text from uploaded PDFs
So that I can review and edit the extracted content
```

**Acceptance Criteria**:
- [ ] `POST /api/text-extraction/start/{document_id}` endpoint
- [ ] `GET /api/text-extraction/status/{job_id}` endpoint
- [ ] Batch processing logic for large PDFs (>100 pages)
- [ ] Token estimation and batch calculation
- [ ] pgmq job queuing working
- [ ] Background worker processing jobs
- [ ] Vertex AI integration for text extraction
- [ ] **Page markers inserted** (`# [Page N]` format)
- [ ] Results stored in `text_extraction_results` table
- [ ] Realtime progress updates via Supabase
- [ ] Selected pages support (extract only specific pages)

**Technical Components**:
1. **API Endpoints**:
   - Start extraction endpoint
   - Status polling endpoint
   - Cancel extraction endpoint

2. **Batch Processing**:
   - Token estimation algorithm
   - Batch calculation (max 1M tokens per batch)
   - Batch coordination via `processing_batches` table
   - Sequential batch processing

3. **Worker**:
   - pgmq polling worker
   - Vertex AI API integration
   - PDF to image conversion (pdf2image)
   - Page marker insertion
   - Error handling and retries

4. **Vertex AI Integration**:
   - Service account authentication
   - Gemini 2.0 Flash model usage
   - Multimodal input (PDF pages as images)
   - Response parsing and cleaning

**Critical Requirements**:
- **Page Marker Format**: MUST be `# [Page N]` (exact format, no variations)
- **Regex Match**: `/^#\s*\[Page\s+(\d+)\]$/i` (frontend dependency)
- **Token Limit**: 1M input tokens max per Vertex AI call
- **Batch Strategy**: Split large PDFs into sequential batches

**Files to Create**:
- `backend/api/routers/text_extraction.py` - Extraction endpoints
- `backend/api/services/vertex_ai.py` - Vertex AI integration
- `backend/api/services/batch_processor.py` - Batch calculation
- `backend/api/utils/token_estimator.py` - Token estimation
- `backend/api/utils/page_markers.py` - Page marker insertion
- `backend/workers/text_extraction_worker.py` - Background worker
- `backend/tests/test_extraction.py` - Extraction tests

**Test Scenarios**:
1. Small PDF (10 pages) - Single batch
2. Medium PDF (100 pages) - Single batch
3. Large PDF (500 pages) - Multiple batches
4. Selected pages extraction (pages 1-10 only)
5. Error handling (Vertex AI rate limit, timeout)
6. Realtime updates verification

---

### Story 1.4: Integration Testing & Bug Fixes 📅 PLANNED

**Status**: ⏳ **PLANNED**
**Estimated Duration**: 3-4 days
**Priority**: P0
**Dependencies**: Story 1.3

**User Story**:
```
As a developer
I want comprehensive integration tests
So that the entire upload-to-extraction flow works reliably
```

**Acceptance Criteria**:
- [ ] End-to-end tests for full workflow
- [ ] Performance testing with large PDFs
- [ ] Realtime update verification
- [ ] Frontend integration working
- [ ] All edge cases handled
- [ ] Production-ready error handling
- [ ] Logging and monitoring in place

**Test Coverage**:
1. **Happy Path**:
   - Upload PDF → Extract text → View results
   - Verify page markers present
   - Verify Realtime updates

2. **Edge Cases**:
   - Empty PDF
   - Scanned PDF (image-based)
   - Non-English text
   - Very large PDF (1000+ pages)
   - Corrupted PDF

3. **Error Handling**:
   - Network failures
   - Vertex AI rate limiting
   - Database connection loss
   - Storage failures
   - Worker crashes

4. **Performance**:
   - Upload speed (<5s for 100MB PDF)
   - Extraction speed (~1 page/second)
   - Queue processing latency (<5s)
   - Realtime update latency (<1s)

**Deliverables**:
- Integration test suite
- Performance benchmarks
- Bug fix commits
- Deployment readiness checklist

---

## Future Stories (Epic 2+)

### Story 1.5: Translation API (Optional)
- Translation job creation
- Translation worker with Vertex AI
- Glossary support
- Target language selection

### Story 1.6: Download & Export
- Download extracted text
- Download translations
- Export to multiple formats (TXT, DOCX, PDF)

### Story 1.7: Authentication & Multi-tenancy
- Supabase Auth integration
- Row Level Security (RLS) policies
- User management
- Tenant isolation

---

## Current Sprint Plan

**Sprint Goal**: Complete Upload API (Story 1.2)
**Duration**: 1 day
**Start**: October 3, 2025, 3:11 AM IST

### Today's Tasks (Story 1.2)
1. Create Supabase Storage bucket ⏳
2. Implement upload endpoint ⏳
3. Add file validation ⏳
4. Integrate PyPDF2 for page count ⏳
5. Test with frontend ⏳

### Tomorrow's Tasks
- Continue Story 1.3 (Text Extraction)
- Or break/code review if Story 1.2 needs refinement

---

## Dependencies & Blockers

### External Dependencies
- ✅ Supabase Cloud (working)
- ✅ Google Vertex AI (credentials configured)
- ⏳ Supabase Storage (needs bucket creation)

### Technical Blockers
- None currently

### Team Blockers
- None currently

---

## Success Metrics

### Story 1.1 Metrics
- **Time**: 2 hours ✅
- **Tests**: 8/8 passing ✅
- **Coverage**: 100% acceptance criteria ✅
- **Quality**: Production-ready ✅

### Story 1.2 Metrics
- **Time**: 15 minutes ✅
- **Tests**: 4/4 passing ✅
- **Coverage**: 100% acceptance criteria ✅
- **Quality**: Production-ready ✅

### Overall Progress
- **Stories Complete**: 2/4 (50%)
- **Epic 1 Progress**: 50%
- **Estimated Completion**: October 10, 2025

---

## Risk Assessment

### Low Risk ✅
- Database connectivity (working)
- pgmq operations (working)
- Environment setup (complete)

### Medium Risk ⚠️
- Vertex AI rate limiting (mitigation: retry logic, backoff)
- Large PDF processing (mitigation: batch processing)
- Realtime update delays (mitigation: polling fallback)

### High Risk 🔴
- None identified

---

## Team Capacity

### Current Team
- **Dev Agent (James)**: Full-time development
- **QA Agent (Quinn)**: Available for testing (Playwright MCP)
- **User**: Product owner, manual testing

### Velocity
- Story 1.1: 2 hours
- Estimated Story 1.2: 2-3 hours
- Estimated Story 1.3: 1 week

---

## Definition of Done

For each story to be considered "done":
- [ ] All acceptance criteria met
- [ ] Unit tests written and passing
- [ ] Integration tests passing
- [ ] Code follows coding standards
- [ ] Documentation updated
- [ ] DevNotes updated with learnings
- [ ] Commit with descriptive message
- [ ] Manual testing completed
- [ ] QA review (if applicable)
- [ ] Ready for production deployment

---

## Quick Links

### Documentation
- [PRD](./NEW-PRD.md)
- [Technical Architecture](./TECHNICAL_ARCHITECTURE.md)
- [Coding Standards](./architecture/coding-standards.md)
- [Story 1.1 Summary](./stories/1.1-COMPLETION-SUMMARY.md)

### Code
- [Backend API](../backend/api/)
- [Database Schema](../database/schema.sql)
- [Test Scripts](../scripts/)

### Infrastructure
- [Supabase Dashboard](https://supabase.com/dashboard)
- [Vertex AI Console](https://console.cloud.google.com/vertex-ai)

---

## Notes for Next Session

**When resuming development**:
1. Read `.ai/devnotes.md` for latest context
2. Check Story 1.2 acceptance criteria
3. Create Supabase Storage bucket first
4. Test upload with sample PDF before proceeding

**Remember**:
- Session Pooler (Port 5432) for pgmq
- Page markers: `# [Page N]` (critical!)
- Update devnotes after each major milestone

---

**Last Updated**: 2025-10-03 03:11:00 IST by DEV (James)
