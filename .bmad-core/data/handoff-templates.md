# Handoff Format Templates

**Version**: 1.0
**Last Updated**: 2025-10-28
**Purpose**: Standardized handoff formats for Dev ↔ QA communication in BMad workflow

---

## Overview

Handoffs ensure clean communication between Dev and QA terminals with structured, copy-paste formats. These templates prevent information loss and maintain traceability across the two-terminal workflow.

---

## Three Handoff Types

1. **QA Handoff** (Dev → QA): Story ready for testing
2. **Developer Handoff** (QA → Dev): Issues found, needs fixes
3. **Completion Handoff** (QA → Dev): All tests passed, ready for commit

---

## 1. QA Handoff (Dev → QA)

**When**: Dev completes implementation and is ready for QA review
**From**: Dev Terminal
**To**: QA Terminal
**Format**: Copy-paste block

### Template:

```
═══════════════════════════════════════════════════════
🎯 QA HANDOFF - Story Ready for Review
═══════════════════════════════════════════════════════

📋 Story: Sprint-{N}.Epic-{N}.Story-{N} - {Title}
📁 Story Path: docs/sprint-{N}/epics/epic-{N}/story-{N}.md
📁 Test Scenarios: docs/qa/e2e/sprint-{N}/epics/epic-{N}/story-{N}/
📁 Vitest Tests: docs/qa/unit/sprint-{N}/epics/epic-{N}/story-{N}/ (if applicable)
📊 Status: Ready for QA

✅ Implementation Complete:
- {List completed tasks/subtasks with checkboxes}
- {Example: [x] Backend API endpoints created}
- {Example: [x] Frontend components implemented}
- {Example: [x] Database migrations applied}

📝 Vitest Unit Tests (if applicable):
- {filename.test.ts} ({N} test cases)
- {another.test.ts} ({N} test cases)
- Total: {N} unit tests
- Location: docs/qa/unit/sprint-{N}/epics/epic-{N}/story-{N}/

📝 E2E Test Scenarios Written:
- scenario-{name}.md (AC{N}: {X} test cases, AC{N}: {Y} test cases)
- scenario-{name2}.md (AC{N}: {Z} test cases)
- Total: {N} E2E test cases
- Location: docs/qa/e2e/sprint-{N}/epics/epic-{N}/story-{N}/

🚀 Background Processes Running:
- Frontend: http://localhost:{PORT} (shell_id: {ID} or PID: {NUMBER})
- Backend: http://localhost:{PORT} (shell_id: {ID} or PID: {NUMBER})
- {Database: http://localhost:{PORT} (if applicable)}

💡 Notes for QA:
- {IF Vitest exists: Run `npm run test` to execute unit tests first}
- {Test scenarios documented in scenario-*.md files}
- {Use Playwright MCP tools to execute each E2E test case}
- {Check console for errors on each interaction}
- {Any special setup needed - e.g., "Seed database with test data"}
- {Any known edge cases to pay special attention to}

🔍 Areas of Focus:
- {Specific areas QA should focus on}
- {Example: "Validation logic for email format"}
- {Example: "Error handling for network failures"}

═══════════════════════════════════════════════════════
📋 COPY THIS BLOCK AND PASTE IN QA TERMINAL
═══════════════════════════════════════════════════════
```

### Example (Filled):

```
═══════════════════════════════════════════════════════
🎯 QA HANDOFF - Story Ready for Review
═══════════════════════════════════════════════════════

📋 Story: Sprint-1.Epic-1.Story-3 - User Login with Email Validation
📁 Story Path: docs/sprint-1/epics/epic-1/story-3.md
📁 Test Scenarios: docs/qa/e2e/sprint-1/epics/epic-1/story-3/
📁 Vitest Tests: docs/qa/unit/sprint-1/epics/epic-1/story-3/
📊 Status: Ready for QA

✅ Implementation Complete:
- [x] Login API endpoint (/api/auth/login)
- [x] Email validation logic with regex
- [x] Login form component with React Hook Form
- [x] Error message display for invalid credentials
- [x] JWT token storage in localStorage
- [x] Redirect to dashboard on success

📝 Vitest Unit Tests:
- validateEmail.test.ts (12 test cases)
- hashPassword.test.ts (5 test cases)
- Total: 17 unit tests
- Location: docs/qa/unit/sprint-1/epics/epic-1/story-3/

📝 E2E Test Scenarios Written:
- scenario-login.md (AC1: 3 test cases, AC2: 2 test cases)
- scenario-validation.md (AC3: 4 test cases)
- Total: 9 E2E test cases
- Location: docs/qa/e2e/sprint-1/epics/epic-1/story-3/

🚀 Background Processes Running:
- Frontend: http://localhost:3000 (shell_id: bash_1234)
- Backend: http://localhost:5001 (PID: 9876)
- Database: PostgreSQL on localhost:5432

💡 Notes for QA:
- Run `npm run test` to execute Vitest unit tests first
- Test scenarios documented in scenario-login.md and scenario-validation.md
- Use Playwright MCP tools to execute each E2E test case
- Check console for errors on each interaction
- Database already seeded with test user (user@example.com / password123)

🔍 Areas of Focus:
- Email validation regex (should reject invalid formats)
- Error message visibility (CSS opacity issue in previous story)
- Console errors on failed login (should show 401, not throw)

═══════════════════════════════════════════════════════
📋 COPY THIS BLOCK AND PASTE IN QA TERMINAL
═══════════════════════════════════════════════════════
```

---

## 2. Developer Handoff (QA → Dev)

**When**: QA finds issues during testing
**From**: QA Terminal
**To**: Dev Terminal
**Format**: Copy-paste block

### Template:

```
═══════════════════════════════════════════════════════
🔄 DEVELOPER HANDOFF - Issues Found
═══════════════════════════════════════════════════════

📋 Story: Sprint-{N}.Epic-{N}.Story-{N} - {Title}
📊 Gate Decision: {FAIL / CONCERNS}
📁 Gate File: docs/qa/gates/sprint-{N}/epics/epic-{N}/story-{N}-gate.md

❌ Vitest Issues (if applicable):

**Test Suite**: {filename.test.ts}
- Failed: {X}/{N} tests
- Issue: {Brief description of failure}
- Tests: "{test name 1}", "{test name 2}"
- Location: docs/qa/unit/sprint-{N}/epics/epic-{N}/story-{N}/{filename.test.ts}
- Log Output: {Brief error message or "See gate file for details"}

❌ E2E Issues:

**Issue 1: {Title}**
- Test Case: TC{AC}.{case}
- Scenario: scenario-{name}.md
- Severity: {Critical / High / Medium / Low}
- Description: {What went wrong - be specific}
- Evidence: docs/qa/evidence/sprint-{N}/epics/epic-{N}/story-{N}/tc{AC}.{case}-{description}.{ext}
- Expected: {What should happen}
- Actual: {What actually happened}
- Console Errors: {Any JavaScript errors or "None"}

**Issue 2: {Title}**
- Test Case: TC{AC}.{case}
- Scenario: scenario-{name}.md
- Severity: {Critical / High / Medium / Low}
- Description: {What went wrong}
- Evidence: docs/qa/evidence/sprint-{N}/epics/epic-{N}/story-{N}/tc{AC}.{case}-{description}.{ext}
- Expected: {What should happen}
- Actual: {What actually happened}
- Console Errors: {Any JavaScript errors or "None"}

{Repeat for each issue}

📊 Summary:
- Vitest: {X}/{N} passed ({Y} failed) {or "N/A" if no Vitest}
- E2E Test Cases: {X}/{N} passed ({Y} failed)
- Blockers: {N} Critical, {N} High, {N} Medium, {N} Low

🔧 Next Steps:
- Fix issues listed above (prioritize Critical/High)
- {Specific fix suggestions if obvious}
- Re-test affected test cases
- Output new QA Handoff when ready

💡 QA Notes:
- {Any additional context or suggestions}
- {Example: "Consider adding validation earlier in form"}
- {Example: "This issue also affects story-2, may need knowledge base entry"}

═══════════════════════════════════════════════════════
📋 COPY THIS BLOCK AND PASTE IN DEV TERMINAL
═══════════════════════════════════════════════════════
```

### Example (Filled):

```
═══════════════════════════════════════════════════════
🔄 DEVELOPER HANDOFF - Issues Found
═══════════════════════════════════════════════════════

📋 Story: Sprint-1.Epic-1.Story-3 - User Login with Email Validation
📊 Gate Decision: FAIL
📁 Gate File: docs/qa/gates/sprint-1/epics/epic-1/story-3-gate.md

❌ Vitest Issues:

**Test Suite**: validateEmail.test.ts
- Failed: 2/12 tests
- Issue: Edge cases for international email domains not handled
- Tests: "should accept .co.uk domains", "should accept .info domains"
- Location: docs/qa/unit/sprint-1/epics/epic-1/story-3/validateEmail.test.ts
- Log Output: Expected true, received false

❌ E2E Issues:

**Issue 1: Login button not clickable**
- Test Case: TC1.1
- Scenario: scenario-login.md
- Severity: Critical
- Description: Login button appears but click event doesn't fire. Suspect z-index overlap with modal backdrop.
- Evidence: docs/qa/evidence/sprint-1/epics/epic-1/story-3/tc1.1-button-not-clickable.png
- Expected: Button click triggers form submission
- Actual: Button click has no effect, no network request, no console error
- Console Errors: None (no event listener attached?)

**Issue 2: Validation error message not visible**
- Test Case: TC1.2
- Scenario: scenario-validation.md
- Severity: High
- Description: Error message element exists in DOM but has opacity: 0 in CSS
- Evidence: docs/qa/evidence/sprint-1/epics/epic-1/story-3/tc1.2-error-invisible.png
- Expected: Red error message displays below email input
- Actual: Element rendered but invisible (opacity: 0, check CSS)
- Console Errors: None

**Issue 3: Redirect after login fails**
- Test Case: TC1.3
- Scenario: scenario-login.md
- Severity: High
- Description: Login succeeds (200 response, token stored) but no redirect to /dashboard
- Evidence: docs/qa/evidence/sprint-1/epics/epic-1/story-3/tc1.3-no-redirect.png
- Expected: Automatic redirect to /dashboard after successful login
- Actual: Stays on /login page, token is in localStorage
- Console Errors: None

📊 Summary:
- Vitest: 10/12 passed (2 failed)
- E2E Test Cases: 6/9 passed (3 failed)
- Blockers: 1 Critical, 2 High, 0 Medium, 0 Low

🔧 Next Steps:
- Fix button z-index issue (check modal CSS, likely overlapping)
- Fix error message visibility (remove opacity: 0 or add visible class)
- Fix redirect logic (check if router.push() is called after token storage)
- Fix Vitest edge cases for international email domains (update regex)
- Re-test TC1.1, TC1.2, TC1.3 and Vitest tests
- Output new QA Handoff when ready

💡 QA Notes:
- Button issue is a blocker - cannot test any login flows
- Error message CSS issue also appeared in story-2 (consider knowledge base entry for "common CSS visibility issues")
- Redirect logic might need delay (wait for token storage to complete?)

═══════════════════════════════════════════════════════
📋 COPY THIS BLOCK AND PASTE IN DEV TERMINAL
═══════════════════════════════════════════════════════
```

---

## 3. Completion Handoff (QA → Dev)

**When**: All tests pass, story approved for commit
**From**: QA Terminal
**To**: Dev Terminal
**Format**: Copy-paste block

### Template:

```
═══════════════════════════════════════════════════════
✅ COMPLETION HANDOFF - Story Approved
═══════════════════════════════════════════════════════

📋 Story: Sprint-{N}.Epic-{N}.Story-{N} - {Title}
📊 Gate Decision: PASS
📁 Gate File: docs/qa/gates/sprint-{N}/epics/epic-{N}/story-{N}-gate.md

✅ Vitest Unit Tests (if applicable):
- {filename.test.ts}: {X}/{X} passed
- {filename2.test.ts}: {X}/{X} passed
- Total: {N}/{N} passed (100%)
- Location: docs/qa/unit/sprint-{N}/epics/epic-{N}/story-{N}/

✅ E2E Test Cases Passed:
- AC{N}: {X}/{X} test cases passed
- AC{N}: {X}/{X} test cases passed
- AC{N}: {X}/{X} test cases passed
- Total: {N}/{N} test cases passed (100%)
- Location: docs/qa/e2e/sprint-{N}/epics/epic-{N}/story-{N}/

📸 Evidence Collected:
- Screenshots: {N} files in docs/qa/evidence/sprint-{N}/epics/epic-{N}/story-{N}/
- Console Logs: No errors
- Network Requests: All successful ({N} API calls verified)
- Page Snapshots: {N} snapshots captured

💡 QA Added Tests (if applicable):
- Added {filename.test.ts} ({N} edge cases for {feature})
- Reason: {Why tests were added}
- Location: docs/qa/unit/sprint-{N}/epics/epic-{N}/story-{N}/{filename.test.ts}

💡 QA Notes:
- {Any observations about implementation quality}
- {Performance notes - e.g., "Login response time < 300ms"}
- {Suggestions for future improvements}
- {Example: "Consider caching user data to reduce API calls"}

✨ Highlights:
- {Positive observations}
- {Example: "Excellent error handling"}
- {Example: "Clean component structure"}

🎯 Ready for Commit:
- All acceptance criteria validated
- All tests passing (Vitest + E2E)
- No blockers or concerns
- Story can be closed

🚀 Next Steps:
- Commit changes with message: "{Suggested commit message}"
- Update story status to "Complete"
- Close background processes (if no longer needed)
- Move to next story

═══════════════════════════════════════════════════════
📋 COPY THIS BLOCK AND PASTE IN DEV TERMINAL
═══════════════════════════════════════════════════════
```

### Example (Filled):

```
═══════════════════════════════════════════════════════
✅ COMPLETION HANDOFF - Story Approved
═══════════════════════════════════════════════════════

📋 Story: Sprint-1.Epic-1.Story-3 - User Login with Email Validation
📊 Gate Decision: PASS
📁 Gate File: docs/qa/gates/sprint-1/epics/epic-1/story-3-gate.md

✅ Vitest Unit Tests:
- validateEmail.test.ts: 12/12 passed
- hashPassword.test.ts: 5/5 passed
- Total: 17/17 passed (100%)
- Location: docs/qa/unit/sprint-1/epics/epic-1/story-3/

✅ E2E Test Cases Passed:
- AC1: 3/3 test cases passed (login with valid credentials)
- AC2: 2/2 test cases passed (error handling for invalid credentials)
- AC3: 4/4 test cases passed (email validation)
- Total: 9/9 test cases passed (100%)
- Location: docs/qa/e2e/sprint-1/epics/epic-1/story-3/

📸 Evidence Collected:
- Screenshots: 18 files in docs/qa/evidence/sprint-1/epics/epic-1/story-3/
- Console Logs: No errors
- Network Requests: All successful (3 API calls verified: /api/auth/login, /api/user/me, /api/config)
- Page Snapshots: 9 snapshots captured (one per test case)

💡 QA Added Tests:
- Added validatePhone.test.ts (6 edge cases for phone number validation)
- Reason: Story mentions "contact info" but Dev didn't add phone validation tests (out of scope but good to have)
- Location: docs/qa/unit/sprint-1/epics/epic-1/story-3/validatePhone.test.ts

💡 QA Notes:
- Excellent implementation - all edge cases covered
- Login response time consistently < 300ms (very fast)
- Error messages are clear and user-friendly
- Console logs are clean (no warnings or errors during any test)
- Responsive design works perfectly (tested 375px, 768px, 1920px viewports)

✨ Highlights:
- Email validation regex handles all edge cases (including international domains after fix)
- Error handling is robust (network errors, 401, 500 all handled gracefully)
- Loading states are smooth (spinner displays properly)
- Accessibility is good (keyboard navigation works, focus styles present)

🎯 Ready for Commit:
- All acceptance criteria validated
- All tests passing (17 Vitest + 9 E2E = 26/26 tests)
- No blockers or concerns
- Story can be closed

🚀 Next Steps:
- Commit changes with message: "feat: implement user login with email validation (story 1.1.3)"
- Update story status to "Complete"
- Close background processes (if no longer needed)
- Move to Sprint-1.Epic-1.Story-4

═══════════════════════════════════════════════════════
📋 COPY THIS BLOCK AND PASTE IN DEV TERMINAL
═══════════════════════════════════════════════════════
```

---

## Usage Guidelines

### Dev Agent - QA Handoff Generation:
1. At end of implementation, generate QA Handoff
2. Include ALL required fields (story path, test locations, process URLs)
3. Be specific about test counts and locations
4. Mention any areas QA should focus on
5. HALT after outputting handoff (wait for QA)

### QA Agent - Reading QA Handoff:
1. Copy entire handoff block from Dev terminal
2. Verify all paths exist (story, test scenarios, Vitest tests)
3. Verify background processes are running (curl or browser_navigate)
4. Begin testing workflow (Vitest first if applicable, then E2E)

### QA Agent - Developer Handoff Generation:
1. If issues found (FAIL/CONCERNS gate), generate Developer Handoff
2. Be SPECIFIC about each issue (what/where/why/how to reproduce)
3. Include evidence file paths
4. Prioritize by severity (Critical first)
5. Suggest fixes if obvious

### QA Agent - Completion Handoff Generation:
1. If all tests pass (PASS gate), generate Completion Handoff
2. Summarize all test results (Vitest + E2E)
3. Mention evidence collected
4. Include any QA-added tests with justification
5. Provide positive notes and highlights
6. Suggest commit message

### Dev Agent - Reading Handoff from QA:
1. If Developer Handoff: Fix issues in priority order (Critical → High → Medium → Low)
2. Re-test affected test cases
3. Generate new QA Handoff when done
4. If Completion Handoff: Commit changes, update story status, close story

---

## Best Practices

### Be Specific:
❌ "Button doesn't work"
✅ "Login button click event doesn't fire, suspect z-index overlap with modal backdrop"

### Include Evidence:
❌ "Error message not visible"
✅ "Error message element has opacity: 0 in CSS, see tc1.2-error-invisible.png"

### Track Locations:
✅ Always include full paths to stories, test scenarios, Vitest tests, evidence
✅ Include shell_id or PID for background processes

### Copy-Paste Format:
✅ Use `═══` separator lines for easy visual identification
✅ Include "COPY THIS BLOCK" footer
✅ Keep format consistent across all handoffs

---

## Integration with Documentation Standards

All handoff contents should follow the timestamp protocol:
- QA Handoff: Include timestamp of when handoff was generated
- Developer Handoff: Include timestamp and QA agent name
- Completion Handoff: Include timestamp and QA agent name

**Timestamp Format**:
```bash
date '+%Y-%m-%d %H:%M:%S'
```

**In Handoff**:
```
📅 Handoff Generated: 2025-10-28 15:45:23
👤 Generated By: James (Dev Agent) / Quinn (QA Agent)
```

---

**Version**: 1.0
**Last Updated**: 2025-10-28
