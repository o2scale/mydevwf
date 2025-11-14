# Comprehensive Playwright Testing Report - HDA v2
**Date**: 2025-10-04
**Testing Tool**: Playwright MCP Browser Automation
**Environment**: Local Development (Frontend: http://localhost:8080, Backend: http://localhost:8000)
**Tested After**: Story 1.9 Database Migration (completed)
**Purpose**: Identify UI gaps and issues before implementing Story 1.10

---

## Executive Summary

Completed comprehensive automated testing of all major application pages after Story 1.9 database schema migration. Found **15 issues** ranging from critical blockers to minor UI polish needs.

**Key Findings**:
- ✅ **Application loads without crashing**
- ✅ **Core UI components render correctly**
- ❌ **3 Critical blockers** preventing data display
- ❌ **5 High-priority issues** affecting user experience
- ⚠️ **7 Medium/Low priority issues** for polish

**Recommendation**: Fix Phase 0 (database investigation) and Phase 1 (queue display) issues BEFORE proceeding with Story 1.10 implementation.

---

## Issues by Priority

### 🔴 Critical Issues (Blockers) - 3 issues

#### Issue #1: PGRST201 Foreign Key Ambiguity
**Severity**: CRITICAL
**Location**: Queue page - Translation pipeline
**Error**: `PGRST201: Could not embed because more than one relationship was found for 'translation_results' and 'documents'`

**Impact**:
- Translation jobs cannot be loaded from database
- Frontend stuck in infinite retry loop
- Queue page completely broken for translation pipeline

**Root Cause**:
Multiple foreign keys from `translation_results` table pointing to `documents` table. PostgREST cannot determine which relationship to use.

**Evidence**:
```javascript
// Console output (repeats continuously)
Translation jobs query result: {data: null, error: Object}
Error fetching tasks: {
  code: PGRST201,
  hint: "Try changing 'documents' to one of the following..."
}
```

**Fix Required**:
```typescript
// frontend/src/store/queue-store.ts (line ~403)
// BEFORE (broken)
.from('translation_results')
.select(`
  *,
  documents!inner(*)  // ❌ Ambiguous
`)

// AFTER (fixed)
.from('translation_results')
.select(`
  *,
  documents!translation_results_document_id_fkey(*)  // ✅ Explicit FK name
`)
```

**Also add error handling**:
```typescript
if (translationError && translationError.code === 'PGRST201') {
  console.warn('Foreign key ambiguity detected. Stopping retry loop.');
  return; // Prevent infinite retries
}
```

---

#### Issue #2: Extraction Jobs Not Displaying
**Severity**: CRITICAL
**Location**: Queue page - Text Extraction pipeline
**Observation**: 7 extraction jobs exist in database, 0 shown in UI

**Impact**:
- Users cannot see completed extraction jobs
- Cannot navigate to editor to review extracted text
- Workflow completely blocked

**Evidence**:
```javascript
// Console shows successful query
Extraction jobs query result: {data: Array(7), error: null}

// But UI shows 0 in all columns
Queued: 0 | Processing: 0 | In Review: 0 | Completed: 0
```

**Root Causes** (investigation needed):
1. Status mismatch: Jobs have `status='completed'` but UI expects `status='in-review'`
2. Missing pipeline field: Jobs missing `pipeline='extraction'` in documents table
3. Data transformation bug: Store fails to map DB rows to UI `DocumentTask` type
4. Filter logic bug: Jobs filtered out by status/owner/priority logic

**Fix Required**:
1. **Database investigation** (Phase 0):
   ```sql
   -- Check actual status values
   SELECT id, document_id, status, created_at
   FROM text_extraction_results
   ORDER BY created_at DESC;

   -- Check pipeline tracking in documents table
   SELECT id, filename, current_pipeline, extraction_status
   FROM documents
   WHERE id IN (SELECT document_id FROM text_extraction_results);
   ```

2. **Frontend fix** (queue-store.ts):
   ```typescript
   // Add status normalization
   const normalizeStatus = (status: string): ProcessingStatus => {
     const statusMap: Record<string, ProcessingStatus> = {
       'completed': 'in-review',  // Map old values to new schema
       'text-processing': 'processing',
       'queued_manual': 'queued',
       // ... etc
     };
     return statusMap[status] || status as ProcessingStatus;
   };

   // Ensure pipeline is set
   const task: DocumentTask = {
     ...job,
     pipeline: 'extraction',  // Explicitly set
     status: normalizeStatus(job.status)
   };
   ```

---

#### Issue #3: CORS Error on Translation Results Endpoint
**Severity**: CRITICAL
**Location**: Editor page
**Error**: `Access to XMLHttpRequest at 'http://localhost:8000/api/translations/results/{id}' has been blocked by CORS policy`

**Impact**:
- Cannot load translation results in editor
- Translation workflow broken

**Root Cause**:
Backend CORS not configured for `/api/translations/results/` endpoint, or endpoint doesn't exist.

**Fix Required**:
```python
# backend/api/main.py
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080"],  # Add frontend origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

### 🟠 High Priority Issues - 5 issues

#### Issue #4: Editor Navbar Link Broken (404)
**Severity**: HIGH
**Location**: Global navbar
**Error**: Clicking "Editor" in navbar navigates to `/editor` which shows 404

**Root Cause**:
Editor route requires document ID: `/editor/:documentId` (App.tsx:27)
Navbar link goes to `/editor` (no ID)

**Fix Options**:
1. Remove "Editor" from navbar
2. Change link to redirect to `/queue` (where users select documents)
3. Show "Select a document" page instead of 404

**Recommended Fix**:
```typescript
// Option 2: Redirect to queue
<Link to="/queue">Editor</Link>

// OR Option 3: Create /editor landing page
<Route path="/editor" element={<EditorLanding />} />
```

---

#### Issue #5: Language Mismatch Between Queue and Editor
**Severity**: HIGH
**Location**: Queue page vs Editor language selection dialog

**Mismatch**:
- **Queue page languages**: Hindi, Bengali, Tamil, Telugu, Kannada, Malayalam
- **Editor dialog languages**: Hindi, Marathi, Bengali, Gujarati, German, English

**Missing in editor**: Tamil, Telugu, Kannada, Malayalam
**Extra in editor**: Marathi, Gujarati, German, English

**Impact**:
- Inconsistent language configuration across application
- Users confused about which languages are supported
- May cause translation jobs to fail if unsupported languages selected

**Fix Required**:
Align language lists in both components. Determine canonical language list from requirements.

```typescript
// Shared constant for all language selectors
export const SUPPORTED_LANGUAGES = [
  'Hindi', 'Bengali', 'Tamil', 'Telugu', 'Kannada', 'Malayalam'
];
```

---

#### Issue #6: Worker Metrics Fetch Failure
**Severity**: HIGH
**Location**: Dashboard page
**Error**: `Error fetching worker metrics: TypeError: Failed to fetch` (appears twice)

**Impact**:
- Worker status unavailable on dashboard
- Cannot monitor system health

**Root Cause**:
`/api/workers/status` endpoint not responding or not implemented

**Fix Required**:
Implement backend endpoint or remove UI element if workers not ready.

---

#### Issue #7: Recent Documents Not Showing
**Severity**: HIGH
**Location**: Dashboard page
**Observation**: Shows "No documents yet" despite 7 documents in database

**Impact**:
- Users cannot see their recent work
- Must navigate to queue to find documents

**Root Cause**:
Dashboard query issue or filtering problem (similar to queue page Issue #2)

**Fix Required**:
Check dashboard query and data transformation logic.

---

#### Issue #8: Active Processing Not Showing
**Severity**: HIGH
**Location**: Dashboard page
**Observation**: Shows "No active processing jobs" despite 7 extraction jobs in database

**Impact**:
- Dashboard provides no value
- Users must navigate to queue for all information

**Root Cause**:
Same as Issue #2 (extraction jobs not loading)

---

### 🟡 Medium Priority Issues - 4 issues

#### Issue #9: API Services Showing Offline
**Severity**: MEDIUM
**Location**: Dashboard - System Health panel

**Observation**:
All services showing "offline":
- Gemini AI: offline
- OpenAI: offline
- Supabase: offline

**Impact**:
User thinks system is down when it's actually working

**Fix Required**:
Either implement real health checks or remove panel if not ready.

---

#### Issue #10: Incomplete Features in Navbar
**Severity**: MEDIUM
**Location**: Global navbar

**Observation**:
Buttons exist but no routes/functionality:
- Review button
- Analytics button
- Settings button

**Impact**:
User confusion when clicking non-functional buttons

**Fix Required**:
Either remove buttons or add placeholder pages.

---

#### Issue #11: Status Indicator Shows "Disconnected"
**Severity**: MEDIUM
**Location**: Queue page header

**Observation**:
Red "Disconnected" indicator showing

**Impact**:
Unclear what this refers to (WebSocket? Worker pool?)

**Fix Required**:
Clarify what connection this monitors or remove if not applicable.

---

#### Issue #12: React Key Prop Warning
**Severity**: MEDIUM
**Location**: Glossary page
**Error**: `Warning: Each child in a list should have a unique "key" prop`

**Impact**:
React console warning, no functional impact

**Fix Required**:
Add unique keys to glossary term list items.

---

### 🟢 Low Priority Issues - 3 issues

#### Issue #13: Progress Bar Unclear (0/4)
**Severity**: LOW
**Location**: Queue page header

**Observation**:
Shows "0/4" but unclear what this represents

**Fix Required**:
Add tooltip or label explaining this metric.

---

#### Issue #14: Search Bar Functionality Unclear
**Severity**: LOW
**Location**: Global top bar

**Observation**:
Search bar present on all pages but behavior unknown

**Fix Required**:
Clarify what it searches (documents? glossary? both?)

---

#### Issue #15: Dialog Accessibility Warning
**Severity**: LOW
**Location**: Editor language selection dialog
**Error**: `Warning: Missing Description or aria-describedby={undefined} for {DialogContent}`

**Impact**:
Accessibility issue for screen readers

**Fix Required**:
Add aria-describedby to dialog component.

---

## Pages Tested

### 1. Dashboard (/) ✅
**URL**: http://localhost:8080/

**Working**:
- Upload section renders
- Status cards display (Pending, Processing, Completed)
- Quality metrics section visible
- System health panel visible

**Issues**:
- Worker metrics fetch failure (Issue #6)
- API services offline (Issue #9)
- Recent documents empty (Issue #7)
- Active processing empty (Issue #8)

**Screenshot**: `dashboard-initial.png`

---

### 2. Upload/Documents (/upload) ✅
**URL**: http://localhost:8080/upload

**Working**:
- ✅ Upload drop zone functional
- ✅ File type indicators (PDF, Images, DOCX)
- ✅ Configuration panel (language, pages, translation options)
- ✅ Cost & time estimate section
- ✅ Priority selection
- ✅ Process Now / Add to Queue buttons

**Issues**: None - this page works perfectly!

**Screenshot**: `test-upload-page.png`

---

### 3. Processing Queue (/queue) ❌
**URL**: http://localhost:8080/queue

**Working**:
- ✅ Pipeline dropdown (Text Extraction / Translation)
- ✅ Language filter (appears for Translation)
- ✅ Kanban view (4 columns)
- ✅ Filter tabs (All, My Documents, Urgent, Failed)
- ✅ View toggle (Kanban/List)

**Issues**:
- PGRST201 error on translation query (Issue #1)
- 0 extraction jobs shown (Issue #2)
- 0 translation jobs shown (Issue #1)
- "Disconnected" status (Issue #11)

**Screenshots**:
- `queue-page-extraction-initial.png`
- `queue-page-translation-with-language-filter.png`

---

### 4. Editor (/editor/:documentId) ⚠️
**URL**: http://localhost:8080/editor/018208b0-6b17-483f-bb9d-ce99b30b5ab4

**Working**:
- ✅ PDF viewer (10 pages, zoom, navigation)
- ✅ Source text editor (5 lines with confidence scores)
- ✅ Step indicator (Source Text → Translation → Complete)
- ✅ Scroll sync toggle
- ✅ Statistics panel (character/word/line count)
- ✅ Language selection dialog
- ✅ Glossary integration (2 terms)
- ✅ Connection status indicator

**Issues**:
- Editor navbar link 404 (Issue #4)
- CORS error on translation endpoint (Issue #3)
- Language mismatch (Issue #5)
- Accessibility warning (Issue #15)

**Screenshots**:
- `editor-page-404-error.png`
- `editor-page-source-text-review.png`
- `editor-language-selection-dialog.png`

---

### 5. Glossary (/glossary) ✅
**URL**: http://localhost:8080/glossary

**Working**:
- ✅ 3 glossary terms displayed correctly
- ✅ Category tabs (Religious, Technical, etc.)
- ✅ Search bar
- ✅ Data table with all columns
- ✅ Actions (History, Export, Import, Add Term)

**Issues**:
- React key warning (Issue #12)

**Screenshot**: `glossary-page.png`

---

## Test Environment Details

**Frontend**:
- Port: 8080
- Framework: React + Vite
- Running instances: 2 (cf4edb, 916217)

**Backend**:
- Port: 8000
- Framework: FastAPI
- Running instances: 2 (7c9aed, a0c037)

**Database**:
- Platform: Supabase (PostgreSQL)
- State after Story 1.9:
  - 7 documents
  - 7 text_extraction_results (status='completed')
  - 5 translation_results

**Browser**:
- Playwright automated browser
- Screenshots: 8 images in `.playwright-mcp/`

---

## Recommended Action Plan for Story 1.10

Based on testing findings, update Story 1.10 with the following phases:

### Phase 0: Database Investigation (CRITICAL - Do First!)
**Duration**: 30 minutes
**Tasks**:
1. Run SQL to check foreign keys on `translation_results` table
2. Fix foreign key ambiguity (use explicit FK names or drop extra FK)
3. Check actual status values in `text_extraction_results`
4. Update jobs with `status='completed'` to `status='in-review'` if needed
5. Verify `documents.current_pipeline` and `documents.extraction_status` populated

### Phase 1: Queue Page Data Display (HIGH)
**Duration**: 2 hours
**Tasks**:
1. Fix PGRST201 error with explicit FK name in translation query
2. Add status normalization function for old status values
3. Ensure `pipeline` field set correctly for all tasks
4. Add error handling to prevent infinite retry loops
5. Test both Text Extraction and Translation views

### Phase 2: Navigation & Routing (HIGH)
**Duration**: 1 hour
**Tasks**:
1. Fix or remove "Editor" navbar link
2. Decide on Review/Analytics/Settings buttons (remove or add routes)
3. Add proper 404 handling

### Phase 3: Language Configuration (MEDIUM)
**Duration**: 1 hour
**Tasks**:
1. Define canonical list of supported languages
2. Update queue page language filter
3. Update editor language selection dialog
4. Ensure consistency across all components

### Phase 4: Dashboard Fixes (HIGH)
**Duration**: 2 hours
**Tasks**:
1. Fix recent documents query
2. Fix active processing query (depends on Phase 1 fix)
3. Implement worker metrics endpoint or remove UI
4. Implement API health checks or remove panel

### Phase 5: UI Polish (LOW)
**Duration**: 1 hour
**Tasks**:
1. Add React keys to glossary list
2. Fix accessibility warnings
3. Add tooltips for unclear UI elements
4. Clarify search bar functionality

**Total Estimated Time**: 7.5 hours

---

## Testing Artifacts

**Documentation Created**:
1. `playwright-test-session.md` - Running test notes
2. `playwright-comprehensive-test-report.md` - This report (summary)
3. `1.10-ui-gaps-analysis.md` - Initial findings (already exists)

**Screenshots Captured** (8 files in `.playwright-mcp/`):
1. dashboard-initial.png
2. test-upload-page.png
3. queue-page-extraction-initial.png
4. queue-page-translation-with-language-filter.png
5. editor-page-404-error.png
6. editor-page-source-text-review.png
7. editor-language-selection-dialog.png
8. glossary-page.png

**Console Logs Analyzed**:
- All pages checked for errors and warnings
- Key errors documented with file/line numbers
- Error patterns identified (e.g., PGRST201 infinite retry)

---

## Conclusion

Comprehensive Playwright testing revealed **15 issues** across the application after Story 1.9 database migration. While the application loads and core UI components work, **3 critical blockers** prevent users from seeing or working with data.

**Critical Path**:
1. Fix database schema issues (Phase 0)
2. Fix queue page display (Phase 1)
3. Fix navigation issues (Phase 2)

Once these are resolved, the application will be functional for end-to-end testing of the text extraction and translation workflows.

**Next Step**: User should review this report and approve proceeding with Story 1.10 implementation focusing on the prioritized phases.

---

**Testing Completed**: 2025-10-04
**Total Testing Duration**: ~45 minutes
**Pages Tested**: 5/5
**Issues Found**: 15
**Recommendations**: Ready for Story 1.10 implementation
