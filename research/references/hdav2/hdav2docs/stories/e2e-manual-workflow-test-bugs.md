# E2E Manual Workflow Testing - Critical Bugs Found

**Date**: 2025-10-05
**Test Session**: Manual Translation Workflow (NOT Auto-Translate)
**Test File**: The Beggar Princess.pdf (150 pages, selected pages 1-23)

---

## Test Scenario

**Objective**: Test the complete MANUAL translation workflow:
1. Upload PDF with page selection (23 of 150 pages)
2. Disable auto-translate checkbox
3. Extract text → Review in Editor → Verify/Approve
4. Manually proceed to translation (Hindi + Marathi)
5. Monitor translation queue and processing

---

## ✅ Features Working Correctly

### 1. Upload & Page Selection
- ✅ File upload successful (The Beggar Princess.pdf, 1.43 MB, 150 pages)
- ✅ Page selection via Quick Page Range "1-23" worked (after second attempt)
- ✅ Cost calculation: ₹13.20 for 23 pages (correct)
- ✅ Auto-translate checkbox can be disabled
- ✅ "Add to Queue" button works

### 2. Text Extraction
- ✅ Worker processed correctly: 3 batches, 23 pages, 7641 tokens, 156 seconds
- ✅ All page markers correct: `# [Page 1]`, `# [Page 2]`, etc.
- ✅ Extraction quality: 95% confidence
- ✅ Text quality excellent

### 3. Editor Access
- ✅ Can access editor despite wrong status (workaround works)
- ✅ PDF preview loads correctly
- ✅ Source text displays with proper formatting
- ✅ Page navigation works (Page 1/23, Page 2/23, etc.)
- ✅ Stats display: 29,909 characters, 5,444 words, 636 lines

### 4. Translation Job Creation
- ✅ Language selection dialog appears
- ✅ Can select multiple languages (Hindi + Marathi)
- ✅ Alert shows "Added 2 language(s) to translation queue"
- ✅ API endpoint called: `POST /api/translations/start/{document_id}`

---

## ❌ Critical Bugs Found

### Bug #1: Worker Status - "completed" Instead of "in-review" (HIGH PRIORITY)

**Issue**: Text extraction worker sets status to "completed" instead of "in-review" when extraction finishes, regardless of auto-translate flag.

**Evidence**:
- Worker logs: `[DONE] COMPLETED: 23 pages, 7641 tokens, 156s`
- Frontend logs: `Status normalization: "completed" -> "completed"`
- Queue UI: Job appears in "Completed" column instead of "In Review"

**Expected Behavior**:
- For manual workflow (auto_translate = false): Status should be "in-review"
- User should review/verify extraction before proceeding to translation

**Impact**: BLOCKS manual review workflow - users cannot review and approve extractions

**Location**: `backend/workers/text_extraction_worker.py` (status setting logic)

**Screenshots**:
- `.playwright-mcp/e2e-queue-completed-status-bug.png`

**Same Bug As**: First test with test-10-pages.pdf showed identical issue

---

### ~~Bug #2: Translation Jobs - Only 1 Created Instead of 2~~ ✅ NOT A BUG - Correct Design

**Status**: ✅ **RESOLVED - This is the correct implementation**

**Initial Misunderstanding**:
I thought each language should create a separate job in the queue, but the actual design is smarter.

**Actual Design Pattern** (Verified in code):
1. **One Job Record** in `translation_results` table with all target languages
2. **Multiple PGMQ Messages** (one per language) for parallel worker processing
3. **Progressive Updates** as workers complete each language:
   - `translations`: `{"hi": "...", "mr": "..."}`
   - `completed_languages`: `["hi"]` → `["hi", "mr"]`
   - `progress`: `0%` → `50%` → `100%`

**Benefits of This Design**:
- ✅ Single job ID for all languages (clean, not confusing)
- ✅ Parallel processing (workers process different languages simultaneously)
- ✅ Progressive tracking (can see which languages are complete vs pending)
- ✅ No queue clutter (1 job card instead of N cards per document)

**Code Evidence**:
- `backend/api/routers/translations.py:130-143` - Loop creates one PGMQ message per language
- `backend/workers/translation_worker.py:149-158` - Worker updates shared job with language-specific results

**UI Enhancement Opportunity**:
Queue card could show more detail like "Hindi, Marathi (1/2 complete)" but the backend logic is correct.

---

### Bug #3: Editor Shows Dummy Translation Content (MEDIUM PRIORITY)

**Issue**: After clicking "Add to Queue" for translation, editor automatically navigates to Translation step (step 2) and shows dummy/placeholder content about "Ganesh Chaturthi" instead of waiting for actual translation.

**Evidence**:
- Translation text: "Ganesh Chaturthi is a major festival of Hinduism..."
- This content is completely unrelated to "The Beggar Princess" document
- Translation step shows "Translation: 88%" (fake metric)
- Status shows "Unsaved changes"

**Expected Behavior**:
- Editor should NOT auto-navigate to translation step
- Translation step should wait for actual translation jobs to complete
- Should display actual translated content, not mock data

**Impact**: Confusing UX - user sees fake translation content

**Location**:
- Frontend editor component (auto-navigation logic)
- Translation data loading (using mock/dummy data instead of real results)

**Screenshots**:
- `.playwright-mcp/e2e-translation-editor-dummy-content.png`

---

### Bug #4: Quick Page Range Feature Intermittent (LOW PRIORITY)

**Issue**: Quick Page Range input "1-23" didn't work on first attempt. Required clicking "Select None" first, then second attempt worked.

**Evidence**:
- First attempt: Typed "1-23", clicked Apply → No change (remained 150/150)
- Clicked "Select None" → 0/150
- Second attempt: Typed "1-23", clicked Apply → Success (23/150)

**Expected Behavior**:
- Quick Page Range should work consistently on first attempt

**Impact**: Minor UX annoyance, workaround available

---

### Bug #5: Performance - Page Selection Triggers 150+ Console Logs (LOW PRIORITY)

**Issue**: Clicking "Select None" button triggers 150+ console logs of "Current file: {...}"

**Evidence**: Browser console flooded with repeated logs when deselecting pages

**Expected Behavior**: Batch update without excessive logging

**Impact**: Potential performance issue, clutters console

---

### Bug #6: Translation Queue Card Missing Target Language (MEDIUM PRIORITY)

**Issue**: Translation queue job card shows "English" as source language but doesn't display target language(s).

**Evidence**: Queue card shows "150 pages, English" but no indication of target language

**Expected Behavior**: Should show "English → Hindi" or "English → Hindi, Marathi"

**Impact**: User cannot see what language(s) are being translated to

**Screenshots**:
- `.playwright-mcp/e2e-translation-queue-1job-expected2.png`

---

## 🔄 Testing Status

### Manual Workflow Testing Progress:
- ✅ Upload with page selection
- ✅ Disable auto-translate
- ✅ Text extraction processing
- ✅ Editor access and review
- ✅ Translation job creation dialog
- ⚠️ Translation queue verification (found bugs)
- ⏸️ Translation processing (blocked by bugs)
- ⏸️ Deduplication testing (pending)

---

## 📝 Next Steps

### High Priority Fixes Required:

1. **Fix Worker Status Bug** (Bug #1)
   - Modify `text_extraction_worker.py` to set "in-review" status for manual workflow
   - Check `auto_translate` flag from job metadata
   - Only set "completed" if auto-translate is enabled AND translation jobs created successfully

2. **Fix Translation Job Creation** (Bug #2)
   - Debug `POST /api/translations/start/{document_id}` endpoint
   - Ensure loop creates one job per selected language
   - Verify PGMQ receives all jobs

3. **Fix Editor Mock Data** (Bug #3)
   - Remove dummy/placeholder translation content
   - Implement proper loading state while waiting for translation
   - Only show translation step when actual results available

### Medium Priority:
- Bug #6: Add target language display to queue cards

### Low Priority:
- Bug #4: Fix Quick Page Range intermittent issue
- Bug #5: Optimize page selection performance

---

## 📸 Test Artifacts

All screenshots saved in `.playwright-mcp/` directory:
- `e2e-queue-completed-status-bug.png` - Bug #1
- `e2e-editor-page1-source-text.png` - Editor working
- `e2e-editor-page2-with-marker.png` - Page markers verified
- `e2e-translation-language-dialog.png` - Language selection
- `e2e-translation-dialog-2languages-selected.png` - 2 languages selected
- `e2e-translation-editor-dummy-content.png` - Bug #3
- `e2e-translation-queue-1job-expected2.png` - Bug #2

---

## 🎯 Test Summary

**Main Achievement**: Discovered 6 critical bugs in manual translation workflow through systematic E2E testing.

**Critical Blockers**:
- Bug #1 prevents manual review workflow
- Bug #2 breaks multi-language translation
- Bug #3 shows fake data to users

**Overall Assessment**: Manual workflow is severely broken. High-priority fixes required before this feature is usable.

**Testing Approach**: Iterative E2E testing with Playwright MCP proves highly effective at discovering integration issues that unit tests would miss.
