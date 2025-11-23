# Handoff Format Templates

**Version**: 3.1 (Document + Snippet + Git Integration)
**Last Updated**: 2025-11-15
**Purpose**: Dual-format handoff system with detailed documents for permanent records and compact snippets for terminal communication in BMad workflow. All handoffs committed to git for audit trail.

---

## Document Creation Protocol

**CRITICAL**: All handoff types create TWO outputs:

### 1. **Detailed Handoff Document** (Markdown file)

- **Location**: `docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-{type}-handoff.md`
- **Format**: Comprehensive markdown with sections, details, context
- **Purpose**:
  - Permanent record for audit trail and debugging
  - Comprehensive reference for agents (QA reads for context)
  - Preserves detailed implementation notes beyond conversation history
- **Created by**: Outputting agent (Dev, QA, Orchestrator)
- **Versioning**: Committed to git immediately after creation/update (git history preserves all versions)
- **CRITICAL**: ALWAYS commit handoff to git after creating/updating (see git commit step in each handoff type)

### 2. **Compact Handoff Snippet** (Terminal output)

- **Format**: 10-15 line copy-paste block with `═══` separators
- **Purpose**: Quick terminal-to-terminal handoff, includes reference to document
- **Output**: Terminal text (NOT a file)
- **Usage**: User copies from source terminal and pastes into target terminal

### File Naming Convention

| Handoff Type | Filename Pattern | Example |
|--------------|------------------|---------|
| Story Handoff | `{epic}.{story}-{slug}-story-handoff.md` | `2.2-transcription-story-handoff.md` |
| QA Handoff | `{epic}.{story}-{slug}-qa-handoff.md` | `2.2-transcription-qa-handoff.md` |
| Test Review Handoff | `{epic}.{story}-{slug}-test-review-handoff.md` | `2.2-transcription-test-review-handoff.md` |
| Developer Handoff | `{epic}.{story}-{slug}-developer-handoff.md` | `2.2-transcription-developer-handoff.md` |
| Completion Handoff | `{epic}.{story}-{slug}-completion-handoff.md` | `2.2-transcription-completion-handoff.md` |
| Story Completion Summary | `{epic}.{story}-{slug}-completion-summary.md` | `2.2-transcription-completion-summary.md` |

### Why Dual Format?

- **Document**: Permanent, comprehensive, agent-readable context
- **Snippet**: Quick, copy-paste, essential info only
- **Together**: Best of both worlds - rich context + fast communication

---

## Overview

Handoffs ensure clean communication between terminals with compact, copy-paste formats (10-15 lines). These templates prevent information loss and maintain traceability across two-terminal and three-terminal workflows.

---

## Six Handoff Types

1. **QA Handoff** (Dev → QA): Story ready for testing
2. **Developer Handoff** (QA → Dev): Issues found, needs fixes
3. **Completion Handoff** (QA → Dev): All tests passed, ready for commit
4. **Story Handoff** (Orchestrator → Dev): Story ready for implementation
5. **Test Review Handoff** (Orchestrator → QA/Dev): Test scenarios vetted
6. **Story Completion Summary** (Dev → Orchestrator): Story complete, context for next story

---

## 1. QA Handoff (Dev → QA)

**When**: Dev completes implementation and is ready for QA review
**From**: Dev Terminal
**To**: QA Terminal
**Format**: Detailed document + Compact snippet

### Document Creation Steps:

1. **Determine paths**:
   - Extract sprint number and epic number from story file
   - Create folder: `docs/handoffs/sprint-{N}/epics/epic-{N}/` (if doesn't exist)

2. **Create detailed document**: `{epic}.{story}-{slug}-qa-handoff.md` with:
   - Implementation summary (what was built, how it works)
   - Background processes (URLs, PIDs, shell IDs, how to verify)
   - Backend restart confirmation (if backend files modified: restart timestamp, new PID, files that triggered restart)
   - Files created/modified (complete list with paths)
   - Test details (Vitest tests written, E2E scenarios locations)
   - Edge cases and focus areas (what QA should pay attention to)
   - Validation checklist (items for QA to verify)
   - Dev notes (any gotchas, workarounds, or technical decisions)

3. **CRITICAL: Commit handoff to git** (IMMEDIATELY after creation):
   ```bash
   git add docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-qa-handoff.md
   git commit -m "handoff({epic}.{story}): Create QA handoff - implementation complete

   Authored by O2Scale"
   ```
   **Why**: Preserves handoff in version control, enables audit trail, allows diff comparison if handoff updated later

4. **Output compact snippet to terminal** (includes document reference)

### Compact Snippet Template:

```
═══ QA HANDOFF ═══
📋 Story: {epic}.{story}-{slug} | docs/stories/{file}
📄 Full Handoff: docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-qa-handoff.md
📅 Handed Off: $(date +%Y-%m-%d\ %H:%M:%S) | 👤 {Dev Agent Name}
✅ Done: {Brief task summary - what was completed}
📁 Check: {Key files for QA to review - comma separated}
🧪 Tests: {N} Vitest ({filename.test.ts if exists}), {N} E2E (docs/qa/e2e/...)
🚀 Running: {URL} (PID: {PID}), {URL} (PID: {PID})
🔄 Backend: {Restarted ✅ at [timestamp] (PID: [new-pid]) | No restart needed ⏭️}
💡 Focus: {Specific areas QA should test - edge cases, integrations}
═══ COPY TO QA TERMINAL ═══
```

### Example (Filled):

```
═══ QA HANDOFF ═══
📋 Story: 2.3-media-validation | docs/stories/2.3.story.md
📄 Full Handoff: docs/handoffs/sprint-2/epics/epic-2/2.3-media-validation-qa-handoff.md
📅 Handed Off: 2025-11-04 12:30:15 | 👤 James (Dev Agent)
✅ Done: File upload validation, error handling for 50MB+ files, progress tracking
📁 Check: frontend/src/components/UploadValidator.tsx, backend/api/routers/media.py
🧪 Tests: 3 Vitest (validation.test.ts), 8 E2E (docs/qa/e2e/sprint-2/epics/epic-2/story-3/)
🚀 Running: http://localhost:5173 (PID: 12345), http://localhost:8000 (PID: 12346)
🔄 Backend: Restarted ✅ at 2025-11-04 12:29:45 (PID: 12346, Modified: backend/api/routers/media.py)
💡 Focus: Error handling for 50MB+ files, network timeout scenarios, progress bar accuracy
═══ COPY TO QA TERMINAL ═══
```

---

## 2. Developer Handoff (QA → Dev)

**When**: QA finds issues during testing
**From**: QA Terminal
**To**: Dev Terminal
**Format**: Detailed document + Compact snippet

### Document Creation Steps:

1. **Determine paths**:
   - Extract sprint number and epic number from story file
   - Create folder: `docs/handoffs/sprint-{N}/epics/epic-{N}/` (if doesn't exist)

2. **Create detailed document**: `{epic}.{story}-{slug}-developer-handoff.md` with:
   - Gate status (FAIL or CONCERNS with rationale)
   - Comprehensive issue list (all failing test cases with full descriptions)
   - Evidence references (screenshots, console logs, network traces)
   - Root cause analysis (QA's assessment of what's wrong)
   - Suggested fixes (prioritized list of what needs to change)
   - Test results breakdown (Vitest pass/fail, E2E pass/fail by test case)
   - Reproduction steps (how Dev can reproduce the issues)

3. **CRITICAL: Commit handoff + gate to git** (IMMEDIATELY after creation):
   ```bash
   git add docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-developer-handoff.md \
           docs/qa/gates/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}.yml
   git commit -m "handoff({epic}.{story}): Create Developer handoff - {brief-issue-summary}

   Authored by O2Scale"
   ```
   **Example**: `git commit -m "handoff(2.3): Create Developer handoff - timeout error boundary missing"`
   **Why**: Preserves QA findings in version control, enables tracking of what issues were found when

4. **Output compact snippet to terminal** (includes document reference)

### Compact Snippet Template:

```
═══ DEVELOPER HANDOFF ═══
📋 Story: {epic}.{story}-{slug} | Gate: {FAIL / CONCERNS}
📄 Full Handoff: docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-developer-handoff.md
📅 Reviewed: $(date +%Y-%m-%d\ %H:%M:%S) | 👤 {QA Agent Name}
📁 Gate: docs/qa/gates/sprint-{N}/epics/epic-{epic}/{epic}.{story}-{slug}.yml
❌ Issues: TC{AC}.{case} - {brief description}, TC{AC}.{case} - {brief description}
📸 Evidence: docs/qa/evidence/sprint-{N}/epics/epic-{epic}/story-{story}/
🔧 Fix: {Primary fix needed - most critical issue}
📊 Summary: Vitest {X}/{N}, E2E {X}/{N} ({Y} failed)
💡 Next: Fix issues above, re-test, output new QA Handoff
═══ COPY TO DEV TERMINAL ═══
```

### Example (Filled):

```
═══ DEVELOPER HANDOFF ═══
📋 Story: 2.3-media-validation | Gate: CONCERNS
📄 Full Handoff: docs/handoffs/sprint-2/epics/epic-2/2.3-media-validation-developer-handoff.md
📅 Reviewed: 2025-11-04 14:15:45 | 👤 Quinn (QA Agent)
📁 Gate: docs/qa/gates/sprint-2/epics/epic-2/2.3-media-validation.yml
❌ Issues: TC2.3 - Timeout handling shows blank screen (expected error modal)
📸 Evidence: docs/qa/evidence/sprint-2/epics/epic-2/story-3/tc2.3-timeout-blank.png
🔧 Fix: Add error boundary to UploadValidator component for timeout scenarios
📊 Summary: Vitest 3/3 ✅, E2E 7/8 (1 failed - TC2.3)
💡 Next: Fix error boundary, re-test TC2.3, output new QA Handoff
═══ COPY TO DEV TERMINAL ═══
```

---

## 3. Completion Handoff (QA → Dev)

**When**: All tests pass, story approved for commit
**From**: QA Terminal
**To**: Dev Terminal
**Format**: Detailed document + Compact snippet

### Document Creation Steps:

1. **Determine paths**:
   - Extract sprint number and epic number from story file
   - Create folder: `docs/handoffs/sprint-{N}/epics/epic-{N}/` (if doesn't exist)

2. **Create detailed document**: `{epic}.{story}-{slug}-completion-handoff.md` with:
   - Gate status (PASS with full approval)
   - Complete test results (all Vitest tests passed, all E2E scenarios passed)
   - Evidence summary (number of screenshots captured, console logs checked)
   - Quality notes (code quality observations, performance notes, security checks)
   - Approval timestamp and QA agent
   - Suggested commit message (conventional commit format)
   - Sign-off notes (any final comments or observations)

3. **CRITICAL: Commit handoff + gate to git** (IMMEDIATELY after creation):
   ```bash
   git add docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-completion-handoff.md \
           docs/qa/gates/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}.yml
   git commit -m "handoff({epic}.{story}): Create Completion handoff - all tests PASS

   Authored by O2Scale"
   ```
   **Why**: Preserves QA approval in version control, enables audit trail of when story was approved

4. **Output compact snippet to terminal** (includes document reference)

### Compact Snippet Template:

```
═══ COMPLETION HANDOFF ═══
📋 Story: {epic}.{story}-{slug} | Gate: PASS ✅
📄 Full Handoff: docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-completion-handoff.md
📅 Approved: $(date +%Y-%m-%d\ %H:%M:%S) | 👤 {QA Agent Name}
📁 Gate: docs/qa/gates/sprint-{N}/epics/epic-{epic}/{epic}.{story}-{slug}.yml
✅ All Tests: Vitest {N}/{N}, E2E {N}/{N} (100%)
📸 Evidence: {N} screenshots, no console errors
🚀 Commit: "{Suggested commit message}"
═══ COPY TO DEV TERMINAL ═══
```

### Example (Filled):

```
═══ COMPLETION HANDOFF ═══
📋 Story: 2.3-media-validation | Gate: PASS ✅
📅 Approved: 2025-11-04 15:45:30 | 👤 Quinn (QA Agent)
📁 Gate: docs/qa/gates/sprint-2/epics/epic-2/2.3-media-validation.yml
✅ All Tests: Vitest 3/3, E2E 8/8 (100%)
📸 Evidence: 12 screenshots, no console errors
🚀 Commit: "feat(upload): Add 50MB+ file validation with error handling"
═══ COPY TO DEV TERMINAL ═══
```

---

## 4. Story Handoff (Orchestrator → Dev)

**When**: Orchestrator completes story creation and planning
**From**: Orchestrator Terminal
**To**: Dev Terminal
**Format**: Detailed document + Compact snippet

### Document Creation Steps:

1. **Determine paths**:
   - Extract sprint number and epic number from story file
   - Create folder: `docs/handoffs/sprint-{N}/epics/epic-{N}/` (if doesn't exist)

2. **Create detailed document**: `{epic}.{story}-{slug}-story-handoff.md` with:
   - Story overview (what needs to be built and why)
   - Context7 research findings (libraries, patterns, best practices discovered)
   - Technical decisions made (architecture choices, technology selections)
   - Acceptance criteria breakdown (detailed explanation of each AC)
   - Expected test scenarios (what E2E tests Dev should write)
   - Dependencies and blockers (other stories, external services, prerequisites)
   - Implementation guidance (suggested approach, patterns to follow, pitfalls to avoid)
   - Knowledge base references (relevant KB entries Dev must USE from previous stories)
   - Knowledge base creation expectations (KB entries Dev must CREATE per story-dod-checklist.md section 10 - integrations, patterns, complex solutions)

3. **CRITICAL: Commit handoff to git** (IMMEDIATELY after creation):
   ```bash
   git add docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-story-handoff.md
   git commit -m "handoff({epic}.{story}): Create Story handoff - ready for development

   Authored by O2Scale"
   ```
   **Why**: Preserves planning decisions in version control, enables tracking of what context Dev received

4. **Output compact snippet to terminal** (includes document reference)

### Compact Snippet Template:

```
═══ STORY HANDOFF ═══
📋 Story: {epic}.{story}-{slug} | docs/stories/{file}
📄 Full Handoff: docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-story-handoff.md
📅 Created: $(date +%Y-%m-%d\ %H:%M:%S) | 👤 {Orchestrator Agent Name}
📊 Scope: {Brief description of what needs to be implemented}
🔍 Research: {Key Context7 findings or tech decisions if applicable}
📚 KB Use: {Existing KB entries to follow if any, or "No KB dependencies"}
📝 KB Create: {Expected KB entries to create, or "No KB creation expected"}
📝 ACs: {N} acceptance criteria → {N} E2E scenarios expected
⚠️ Notes: {Special considerations, dependencies, risks}
💡 Guidance: {Implementation hints, architecture patterns to use}
═══ COPY TO DEV TERMINAL ═══
```

### Example (Filled):

```
═══ STORY HANDOFF ═══
📋 Story: 3.2-pdf-batch-processing | docs/stories/3.2.story.md
📄 Full Handoff: docs/handoffs/sprint-3/epics/epic-3/3.2-pdf-batch-processing-story-handoff.md
📅 Created: 2025-11-04 10:15:00 | 👤 Alex (Orchestrator Agent)
📊 Scope: Implement batch processing for large PDFs (500+ pages) with progress tracking
🔍 Research: Vertex AI has 10MB payload limit, use streaming approach (Context7)
📚 KB Use: backend-patterns/batch-processing.md (token-based batching from Story 2.1)
📝 KB Create: integrations/vertex-ai-streaming.md (large payload handling pattern for Stories 3.3, 4.1)
📝 ACs: 4 acceptance criteria → 8 E2E scenarios expected (batch split, progress, retry)
⚠️ Notes: Depends on pgmq setup (Story 3.1), test with real 800-page PDF
💡 Guidance: Follow batch-processing.md pattern exactly, document Vertex AI streaming approach
═══ COPY TO DEV TERMINAL ═══
```

---

## 5. Test Review Handoff (Orchestrator → QA/Dev)

**When**: Orchestrator vets Dev's test scenarios for completeness
**From**: Orchestrator Terminal
**To**: QA Terminal (if approved) or Dev Terminal (if revisions needed)
**Format**: Detailed document + Compact snippet

### Document Creation Steps:

1. **Determine paths**:
   - Extract sprint number and epic number from story file
   - Create folder: `docs/handoffs/sprint-{N}/epics/epic-{N}/` (if doesn't exist)

2. **Create detailed document**: `{epic}.{story}-{slug}-test-review-handoff.md` with:
   - Review summary (APPROVE or REVISE with detailed rationale)
   - Coverage analysis (which ACs have test scenarios, which are missing)
   - Strengths assessment (what's well-covered, good edge cases identified)
   - Gaps identification (missing test scenarios, uncovered edge cases)
   - Specific recommendations (what needs to be added if REVISE)
   - Test scenario quality notes (are scenarios detailed enough, clear steps, expected outcomes)
   - Risk assessment (high-risk areas that need extra test coverage)

3. **CRITICAL: Commit handoff to git** (IMMEDIATELY after creation):
   ```bash
   git add docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-test-review-handoff.md
   git commit -m "handoff({epic}.{story}): Create Test Review handoff - {APPROVE/REVISE}

   Authored by O2Scale"
   ```
   **Why**: Preserves test vetting decision in version control, enables tracking of test scenario evolution

4. **Output compact snippet to terminal** (includes document reference)

### Compact Snippet Template:

```
═══ TEST REVIEW HANDOFF ═══
📋 Story: {epic}.{story}-{slug}
📄 Full Handoff: docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-test-review-handoff.md
📅 Reviewed: $(date +%Y-%m-%d\ %H:%M:%S) | 👤 {Orchestrator Agent Name}
📊 Coverage: {N}/{N} ACs have test scenarios
✅ Strengths: {What's good about the test scenarios}
❌ Gaps: {Missing scenarios or coverage gaps if any}
🎯 Recommendation: {APPROVE / REVISE}
💡 Next: {QA proceed with testing / Dev add missing scenarios}
═══ COPY TO {QA / DEV} TERMINAL ═══
```

### Example (Approved):

```
═══ TEST REVIEW HANDOFF ═══
📋 Story: 2.3-media-validation
📄 Full Handoff: docs/handoffs/sprint-2/epics/epic-2/2.3-media-validation-test-review-handoff.md
📅 Reviewed: 2025-11-04 12:45:00 | 👤 Alex (Orchestrator Agent)
📊 Coverage: 4/4 ACs have test scenarios (10 total test cases)
✅ Strengths: Edge cases well covered (50MB limit, timeout, network failure)
❌ Gaps: None - comprehensive coverage
🎯 Recommendation: APPROVE ✅
💡 Next: QA proceed with E2E testing using Playwright MCP
═══ COPY TO QA TERMINAL ═══
```

### Example (Needs Revision):

```
═══ TEST REVIEW HANDOFF ═══
📋 Story: 2.3-media-validation
📄 Full Handoff: docs/handoffs/sprint-2/epics/epic-2/2.3-media-validation-test-review-handoff.md
📅 Reviewed: 2025-11-04 12:45:00 | 👤 Alex (Orchestrator Agent)
📊 Coverage: 3/4 ACs have test scenarios (AC3 missing)
✅ Strengths: Happy path and error handling covered
❌ Gaps: AC3 (concurrent uploads) - no test scenario, AC2 (validation) - missing edge case for 0-byte files
🎯 Recommendation: REVISE ❌
💡 Next: Dev add scenarios for AC3 and 0-byte file edge case, then re-submit for review
═══ COPY TO DEV TERMINAL ═══
```

---

## 6. Story Completion Summary (Dev → Orchestrator)

**When**: After QA PASS (Completion Handoff received), before requesting next story creation
**From**: Dev Terminal
**To**: Orchestrator Terminal
**Format**: Detailed document + Compact snippet
**Purpose**: Provide Orchestrator with story outcome context for creating next story

### Document Creation Steps:

1. **Determine paths**:
   - Extract sprint number and epic number from story file
   - Create folder: `docs/handoffs/sprint-{N}/epics/epic-{N}/` (if doesn't exist)

2. **Create detailed document**: `{epic}.{story}-{slug}-completion-summary.md` with:
   - Story overview (user story, AC status)
   - Implementation summary (what was built, key files)
   - Architectural decisions (patterns chosen, rationale, impact on next stories)
   - Knowledge base entries created (paths, purpose, relevant for which stories)
   - Database schema changes (new tables, modified columns, migrations)
   - Dependencies for next stories (what next stories can use/require)
   - QA findings and lessons learned (critical findings, non-blocking observations)
   - Git commits (hashes for 3 commit points + handoff commits)
   - Test results (Vitest pass/fail, E2E pass/fail, quality gate status)
   - Recommendations for next story (Dev Notes suggestions, technical considerations)
   - Handoff document references (all handoffs created during story)
   - Summary for Orchestrator (key takeaways, next story dependencies met)

3. **CRITICAL: Commit completion summary to git** (IMMEDIATELY after creation):
   ```bash
   git add docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-completion-summary.md
   git commit -m "handoff({epic}.{story}): Create Story Completion Summary - story complete

   Authored by O2Scale"
   ```
   **Why**: Preserves complete story outcome in version control, enables Orchestrator to reference historical context

4. **Output compact snippet to terminal** (includes document reference)

### Compact Snippet Template:

```
═══ STORY COMPLETION SUMMARY ═══
📋 Story: {epic}.{story}-{slug} | Epic {N} | Status: COMPLETE ✅
📄 Full Summary: docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-completion-summary.md
📅 Completed: $(date +%Y-%m-%d\ %H:%M:%S) | 👤 {Dev Agent Name}

✅ IMPLEMENTED:
   - {Brief implementation summary - 2-3 key deliverables}

🏗️ ARCHITECTURE DECISIONS:
   - {Key decision 1 and impact}
   - {Key decision 2 and impact}

📚 KB ENTRIES CREATED:
   - {category/entry-name.md} ({purpose})

🗄️ SCHEMA CHANGES:
   - {Table/column changes summary}

🔗 DEPENDENCIES FOR NEXT STORIES:
   - {What next stories can use}
   - {What next stories require}

⚠️ LESSONS LEARNED:
   - {Critical finding 1}
   - {Critical finding 2}

🧪 TESTS: Vitest {X}/{N} | E2E {X}/{N} | Gate: {PASS/CONCERNS/FAIL}

💡 NEXT STORY ({next-story-num}) NOTES:
   - {Dev Notes suggestion 1}
   - {Dev Notes suggestion 2}
   - {Technical consideration}

═══ COPY TO ORCHESTRATOR TERMINAL ═══
```

### Example (Filled):

```
═══ STORY COMPLETION SUMMARY ═══
📋 Story: 2.1-media-upload | Epic 2 | Status: COMPLETE ✅
📄 Full Summary: docs/handoffs/sprint-2/epics/epic-2/2.1-media-upload-completion-summary.md
📅 Completed: 2025-11-15 14:30:00 | 👤 James (Dev Agent)

✅ IMPLEMENTED:
   - File upload API (POST /api/documents/upload) with 50MB limit
   - Frontend drag-and-drop (UploadZone.tsx)
   - Validation layer (file size, PDF format, duplicates)

🏗️ ARCHITECTURE DECISIONS:
   - Token-based batching (not page-based) due to variable page density
   - Supabase Storage naming: {timestamp}-{original_name}.pdf to prevent collisions
   - 50MB file size limit enforced (QA found >50MB causes timeout)

📚 KB ENTRIES CREATED:
   - backend-patterns/batch-processing.md (token estimation, batch coordination)
   - integrations/supabase-storage-upload.md (file upload pattern, error handling)

🗄️ SCHEMA CHANGES:
   - NEW: processing_batches table (batch coordination for AI processing)
   - MODIFIED: documents table (added file_name, original_name, storage_path)

🔗 DEPENDENCIES FOR NEXT STORIES:
   - Story 2.2: Requires processing_batches table ✅
   - Story 2.2: Should reference batch-processing.md pattern
   - All stories: Must maintain 50MB file size limit

⚠️ LESSONS LEARNED:
   - Files >50MB cause backend timeout (enforce 50MB limit in all file ops)
   - Error messages must be user-actionable (generic errors confuse users)
   - Test with realistic file sizes early in development

🧪 TESTS: Vitest 15/15 ✅ | E2E 8/8 ✅ | Gate: PASS ✅

💡 NEXT STORY (2.2) NOTES:
   - Reference batch-processing.md in Dev Notes (token estimation pattern)
   - Reuse processing_batches table for worker coordination
   - Follow Story 2.1 error handling pattern (user-actionable messages)
   - Test at 50MB file boundary (edge case validation)

═══ COPY TO ORCHESTRATOR TERMINAL ═══
```

---

## Usage Guidelines

### Three-Terminal Workflow Pattern

**Orchestrator Terminal**: Planning, story creation, research, test vetting
**Dev Terminal**: Implementation, testing, background processes
**QA Terminal**: Test execution, validation, gate decisions

### Orchestrator Agent - Story Handoff Generation:
1. After creating story with `*create-story`, generate Story Handoff
2. Include Context7 research findings if applicable
3. Provide implementation guidance and architecture patterns
4. Note dependencies, risks, and special considerations
5. Specify expected number of E2E scenarios based on ACs

### Orchestrator Agent - Test Review Handoff Generation:
1. When Dev completes test scenarios, review for coverage
2. Check each AC has corresponding E2E scenarios
3. Identify missing edge cases or gaps
4. Generate Test Review Handoff with APPROVE or REVISE recommendation
5. If APPROVE: Send to QA. If REVISE: Send to Dev with specific gaps to address

### Dev Agent - Reading Story Handoff:
1. Copy Story Handoff from Orchestrator terminal
2. Read story file at specified path
3. Note implementation guidance and research findings
4. Begin development using specified architecture patterns

### Dev Agent - QA Handoff Generation:
1. **CRITICAL**: At end of implementation, ALWAYS generate QA Handoff
2. Include timestamp using: `$(date +%Y-%m-%d\ %H:%M:%S)`
3. List completed tasks briefly
4. Specify key files for QA to review
5. **CRITICAL**: Include ALL background process URLs with PIDs
6. Mention test counts (Vitest + E2E)
7. Highlight areas QA should focus on
8. HALT after outputting handoff (wait for QA)

### Dev Agent - Reading Test Review Handoff:
1. If APPROVE: Proceed to QA Handoff (no changes needed)
2. If REVISE: Address identified gaps, add missing scenarios
3. Re-submit to Orchestrator for review or proceed to QA if gaps are minor

### QA Agent - Reading QA Handoff:
1. Copy QA Handoff block from Dev terminal
2. Verify all paths exist (story, test scenarios, Vitest tests)
3. **CRITICAL**: Verify background processes running (check URLs, confirm PIDs)
4. Begin testing workflow (Vitest first if exists, then E2E via Playwright MCP)

### QA Agent - Developer Handoff Generation:
1. If issues found (FAIL/CONCERNS gate), generate Developer Handoff
2. Be SPECIFIC about each issue (use TC numbers, describe briefly)
3. Include evidence directory path
4. Prioritize critical issues in "Fix" line
5. Include timestamp using: `$(date +%Y-%m-%d\ %H:%M:%S)`

### QA Agent - Completion Handoff Generation:
1. If all tests pass (PASS gate), generate Completion Handoff
2. Summarize test results compactly (Vitest X/X, E2E X/X)
3. Mention evidence collected briefly
4. Suggest commit message
5. Include timestamp using: `$(date +%Y-%m-%d\ %H:%M:%S)`

### Dev Agent - Reading Handoff from QA:
1. If Developer Handoff: Fix issues in priority order, re-test, output new QA Handoff
2. If Completion Handoff:
   - Commit with suggested message (Commit Point 3)
   - Update story status to COMPLETE
   - Generate Story Completion Summary (detailed document + compact snippet)
   - Output Story Completion Summary to terminal for Orchestrator
   - HALT (wait for user to request next story from Orchestrator)

### Dev Agent - Story Completion Summary Generation:
1. **CRITICAL**: After receiving Completion Handoff from QA, ALWAYS generate Story Completion Summary
2. Create detailed document with all sections (implementation, architecture, KB entries, schema, dependencies, lessons, recommendations)
3. Include timestamp using: `$(date +%Y-%m-%d\ %H:%M:%S)`
4. Extract key information: architectural decisions, KB entries created, schema changes, QA findings
5. Provide specific recommendations for next story Dev Notes
6. Output compact snippet to terminal with document reference
7. HALT and wait for user to request next story from Orchestrator

### Orchestrator Agent - Reading Story Completion Summary:
1. Copy Story Completion Summary snippet from Dev terminal
2. Read detailed document at referenced path for complete context
3. Extract key information for next story creation:
   - Architectural decisions and patterns established
   - KB entries to reference in next story Dev Notes
   - Dependencies (what next story requires from this story)
   - Lessons learned (what to avoid, edge cases to consider)
   - Schema changes (what tables/columns are available)
4. When creating next story, incorporate this context into Dev Notes and Story Handoff

---

## Best Practices

### Keep It Compact:
✅ Use single-line summaries instead of detailed lists
✅ Reference paths instead of repeating full content
✅ Focus on actionable information only

### Be Specific (But Brief):
❌ "Button doesn't work"
✅ "TC2.3 - Timeout shows blank screen (expected error modal)"

### Include Critical Info:
✅ Always include timestamp (use `$(date +%Y-%m-%d\ %H:%M:%S)`)
✅ Always include story ID and slug
✅ Always include background process URLs with PIDs (Dev → QA)
✅ Always include gate file path (QA → Dev)

### Track Locations:
✅ Use relative paths from project root
✅ Include evidence directory path, not individual files
✅ Include PID for each background process (not just shell_id)

### Copy-Paste Format:
✅ Use `═══` separator for easy visual identification
✅ Include "COPY TO {TERMINAL}" footer
✅ Keep format consistent (10-15 lines max)
✅ Use emojis for visual scanning (📋 Story, 🚀 Running, ✅ Done, ❌ Issues)

---

## Integration with Documentation Standards

**Timestamp Protocol** (from `.bmad-core/agents/*.md`):

All handoffs MUST include timestamp using bash command substitution:

```bash
$(date +%Y-%m-%d\ %H:%M:%S)
```

**In Handoff Template**:
```
📅 Handed Off: $(date +%Y-%m-%d\ %H:%M:%S) | 👤 {Agent Name}
```

**Example Output**:
```
📅 Handed Off: 2025-11-04 12:30:15 | 👤 James (Dev Agent)
```

**Agent Names** (for 👤 field):
- Dev Agent: "James (Dev Agent)"
- QA Agent: "Quinn (QA Agent)"
- Orchestrator Agent: "Alex (Orchestrator Agent)"

---

**Version**: 2.0 (Compact + Orchestrator Integration)
**Last Updated**: 2025-11-04
