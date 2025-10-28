# BMAD Playwright MCP Workflow - ISF Playground

**Version:** 2.0 (Complete Rewrite)
**Last Updated:** October 13, 2025
**Purpose:** Official workflow documentation for ISF Playground BMAD process with Playwright MCP
**Key Change:** Based on actual Playwright MCP testing - programmatic browser control via MCP tools

---

## Overview

The **BMAD (Build-Measure-Analyze-Deploy) Workflow** is a custom two-agent development and QA process optimized for the ISF Playground project. It uses **Playwright MCP tools for programmatic browser control** as the primary quality gate.

### Key Principles

1. **Playwright MCP tools for programmatic browser testing** (15 MCP tools available)
2. **Hybrid testing approach** - Automated navigation + Manual observation
3. **Two-agent workflow** - Developer Agent + QA Agent on separate terminals
4. **Story-by-story sequential development** - One story at a time to completion
5. **Quality gates via YAML files** - Clear PASS/FAIL/CONCERNS decisions

### What is Playwright MCP?

**Playwright MCP** provides programmatic browser control through Model Context Protocol:
- ✅ **QA Agent uses MCP TOOLS** to control browser (browser_navigate, browser_click, browser_snapshot, etc.)
- ✅ **QA Agent OBSERVES results** via snapshots, screenshots, console logs
- ✅ **QA Agent DECIDES** PASS/FAIL based on observations
- ✅ **Hybrid approach:** Automated browser actions + Manual verification

**NOT:**
- ❌ Automated `.spec.js` test files
- ❌ Running `npx playwright test` commands
- ❌ Pure manual testing by opening browser

**See:** `.ai/playwright-mcp-tools-reference.md` for complete MCP tool documentation

---

## Workflow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    BMAD WORKFLOW OVERVIEW                        │
└─────────────────────────────────────────────────────────────────┘

PHASE 1: STORY CREATION (Pre-Development)
├─ Product Owner creates story files in docs/stories/
├─ Stories include: User Story, Acceptance Criteria (ACs), Technical Specs
└─ Status: 📋 TODO

PHASE 2: DEVELOPMENT (Dev Agent - Terminal 1)
├─ Dev Agent reads story file completely
├─ Implements feature (backend + frontend)
├─ Writes E2E test SCENARIOS (docs/qa/e2e/{story-id}.md)
│   └─ Markdown documentation with test cases, NOT code
├─ Updates Dev Agent Record in story file
├─ Sets status: ✅ READY FOR QA
└─ HALTS - hands off to QA Agent

PHASE 3: QA TESTING (QA Agent - Terminal 2)
├─ QA Agent discovers story with "READY FOR QA" status
├─ Reads story file + E2E test scenarios
├─ STEP 1: Execute E2E Tests via Playwright MCP Tools (REQUIRED FIRST)
│   ├─ browser_navigate("http://localhost:3000")
│   ├─ browser_snapshot() → see page structure
│   ├─ browser_click, browser_type → interact per test scenarios
│   ├─ browser_console_messages() → check for errors
│   ├─ browser_take_screenshot() → capture evidence
│   └─ If ANY test fails → FAIL gate immediately
├─ STEP 2: Code Review (only if E2E tests pass)
├─ STEP 3: Create QA Results section in story file
├─ STEP 4: Create Quality Gate YAML file
└─ HALTS - returns to Dev Agent if FAIL/CONCERNS

PHASE 4: RESOLUTION (If FAIL/CONCERNS)
├─ Dev Agent addresses QA feedback
├─ Fixes bugs/issues
├─ Updates story file
├─ Sets status: ✅ READY FOR RE-TEST
└─ Returns to PHASE 3 (QA re-tests)

PHASE 5: COMPLETION (If PASS)
├─ Story status: ✅ QA PASSED → ✅ DONE
├─ Dev Agent proceeds to next story
└─ QA Agent waits for next "READY FOR QA" story
```

---

## Agent Roles

### Developer Agent (Terminal 1)
**Name:** James (or any dev agent)
**Onboarding Guide:** `.ai/developer-onboarding-guide.md`

**Responsibilities:**
- Read and understand story requirements
- Implement features (backend + frontend)
- Write E2E test SCENARIOS in markdown (`docs/qa/e2e/{story-id}.md`)
  - NOT test code, just documentation
  - Test cases organized by Acceptance Criteria
  - Format: TC 1.1, TC 1.2 (for AC1), TC 2.1, TC 2.2 (for AC2)
- Ensure frontend and backend servers are running
- Update Dev Agent Record section in story file
- Address QA feedback when story returns with FAIL/CONCERNS

**Key Rules:**
- ONE story at a time (no parallel development)
- ONE test case per Acceptance Criteria MINIMUM (typically 2-4 per AC)
- Test scenarios guide QA Agent's use of Playwright MCP tools
- HALT after setting "READY FOR QA" status
- Do NOT modify Sprint 1 code (brownfield approach)

---

### QA Agent (Terminal 2)
**Name:** Quinn (Test Architect)
**Onboarding Guide:** `.ai/qa-onboarding-guide.md`

**Responsibilities:**
- Discover stories with "READY FOR QA" status
- Read E2E test scenarios from `docs/qa/e2e/`
- Use Playwright MCP tools to execute tests programmatically
- Observe results via page snapshots, screenshots, console logs
- Verify behavior against expected results in test scenarios
- Create QA Results section in story file
- Create Quality Gate YAML files (`docs/qa/gates/{story}.yml`)
- Make PASS/FAIL/CONCERNS decisions

**Key Rules:**
- E2E tests via Playwright MCP are MANDATORY FIRST STEP
- ANY E2E test failure → automatic FAIL gate
- Use MCP tools to control browser (see `.ai/playwright-mcp-tools-reference.md`)
- ONLY update "QA Results" section in story files
- Do NOT modify other sections (Status, ACs, Dev Agent Record, etc.)

---

## Testing Strategy

### PRIMARY: Playwright MCP Tools

**Available MCP Tools (Top 10 Most Used):**

1. **browser_navigate(url)** - Navigate to URLs
2. **browser_snapshot()** - Get page structure (all elements with refs)
3. **browser_click(element, ref)** - Click buttons/links
4. **browser_type(element, ref, text)** - Type into inputs
5. **browser_take_screenshot(filename)** - Capture evidence
6. **browser_console_messages()** - Check for JS errors
7. **browser_fill_form(fields)** - Fill multiple form fields
8. **browser_wait_for(text)** - Wait for elements to appear
9. **browser_resize(width, height)** - Test responsive design
10. **browser_evaluate(function)** - Run custom JavaScript

**See:** `.ai/playwright-mcp-tools-reference.md` for all 19 MCP tools

---

### How QA Agent Uses Playwright MCP

**Typical Testing Flow:**

```
1. Navigate to app
   → browser_navigate("http://localhost:3000")

2. Get page structure
   → browser_snapshot()
   → Observe: All elements with references (ref="e45", ref="e67", etc.)

3. Interact based on test scenario
   → browser_click(element="Login button", ref="e45")
   → browser_type(element="username", ref="e12", text="test_student")
   → browser_type(element="password", ref="e13", text="password123")
   → browser_click(element="Submit", ref="e23")

4. Wait for result
   → browser_wait_for(text="Welcome")

5. Verify no errors
   → browser_console_messages()
   → Check output: Should be empty or only info logs

6. Capture evidence
   → browser_take_screenshot("login-success.png")

7. Test responsive
   → browser_resize(375, 667)  # Mobile
   → browser_take_screenshot("mobile-view.png")

8. Document result
   → TC 1.1: PASS - Login successful, no console errors, responsive layout works
```

---

### NOT USED: Automated Test Files

**Important:** This workflow does NOT use:
- ❌ `.spec.js` automated test files
- ❌ `npx playwright test` commands
- ❌ Jest unit/integration tests
- ❌ Automated expect() assertions

**Why:** Your workflow emphasizes **programmatic browser control with manual observation**, not fully automated testing.

---

## File Structure

```
ISF_Playground/
│
├── .ai/
│   ├── bmad-playwright-workflow.md          ← THIS FILE (core workflow)
│   ├── playwright-mcp-tools-reference.md    ← Complete MCP tool reference (NEW!)
│   ├── developer-onboarding-guide.md        ← Dev Agent onboarding
│   ├── qa-onboarding-guide.md               ← QA Agent onboarding
│   └── workflow-quick-reference.md          ← 1-page cheat sheet
│
├── .playwright-mcp/                          ← Screenshots saved here
│   └── {filename}.png
│
├── docs/
│   ├── stories/                              ← Story files
│   │   ├── sprint5-story-01-product-catalog.md
│   │   └── ... (12 total)
│   │
│   └── qa/
│       ├── e2e/                              ← E2E test SCENARIOS (markdown)
│       │   ├── story-05-product-crud.md
│       │   ├── story-06-inventory-management.md
│       │   └── ...
│       │
│       └── gates/                            ← Quality gate YAML files
│           ├── sprint5-epic-01.story-01-product-catalog.yml
│           └── ...
```

**Note:** No `frontend/tests/e2e/*.spec.js` files - test scenarios are markdown only

---

## Story Workflow (Step-by-Step)

### Dev Agent: Story Implementation

**Step 1: Read Story Requirements**
```bash
cd docs/stories/
# Find next TODO story
ls sprint5-story-*.md
# Read story file completely
```

**Step 2: Implement Feature**
- Backend: Models, Services, Controllers, Routes
- Frontend: Components, Pages, State Management
- Follow brownfield approach (don't modify Sprint 1 code)

**Step 3: Write E2E Test Scenarios (Markdown)**

Create file: `docs/qa/e2e/story-{n}-{feature-name}.md`

**Format:**
```markdown
# E2E Test Scenarios: Sprint5-Story-{n} - {Feature Name}

## AC1: {Acceptance Criteria Description}

### TC 1.1: {Test Case Description}
**Priority:** P0
**Type:** E2E
**Steps:**
1. Navigate to http://localhost:3000
2. Click "Login" button
3. Enter username: test_student
4. Enter password: password123
5. Click "Submit"

**Expected Result:**
- User logged in successfully
- Welcome message displayed
- No console errors
- Responsive layout on mobile/tablet/desktop

### TC 1.2: {Another Test Case}
...

## AC2: {Next Acceptance Criteria}

### TC 2.1: ...
```

**Key Points:**
- Organize by Acceptance Criteria (AC1, AC2, AC3)
- One or more test cases per AC (TC 1.1, TC 1.2, TC 2.1, etc.)
- Include: Priority, Type, Steps, Expected Results
- These scenarios guide QA Agent's MCP tool usage

**Step 4: Update Story File**
- Add "Dev Agent Record" section
- List all files created/modified (including E2E scenario file)
- Update status: `✅ READY FOR QA`

**Step 5: HALT**
- Do NOT start next story
- Wait for QA Agent to review

---

### QA Agent: Story Review

**Step 1: Discover Story**
```bash
cd docs/stories/
grep "READY FOR QA" sprint5-story-*.md
```

**Step 2: Read Documentation**
- Story file: `docs/stories/sprint5-story-{n}.md`
- E2E scenarios: `docs/qa/e2e/story-{n}-*.md`

**Step 3: Verify Servers Running**
```bash
curl http://localhost:3000              # Frontend
curl http://localhost:5001/api/health   # Backend
```

**Step 4: Execute E2E Tests via Playwright MCP**

**For each test case in E2E scenarios:**

**Example: TC 1.1 - Login Flow**

```
1. Navigate
   → browser_navigate("http://localhost:3000")

2. See page structure
   → browser_snapshot()
   → Output shows: button "Login" [ref=e45], etc.

3. Click login
   → browser_click(element="Login button", ref="e45")

4. Fill form
   → browser_type(element="username", ref="e12", text="test_student")
   → browser_type(element="password", ref="e13", text="password123")

5. Submit
   → browser_click(element="Submit", ref="e23")

6. Wait for success
   → browser_wait_for(text="Welcome")

7. Check console
   → browser_console_messages()
   → Result: No errors ✅

8. Capture evidence
   → browser_take_screenshot("tc-1-1-success.png")

9. Test responsive
   → browser_resize(375, 667)
   → browser_take_screenshot("tc-1-1-mobile.png")
   → browser_snapshot() → verify mobile layout

10. Document
    → TC 1.1: PASS
    → Evidence: tc-1-1-success.png, tc-1-1-mobile.png
    → Console: No errors
    → Responsive: Mobile layout correct
```

**Decision Point:**
- **ANY test case fails** → FAIL gate immediately, return to Dev Agent
- **ALL test cases pass** → Proceed to Step 5

**Step 5: Code Review (Only if E2E tests pass)**
- Review backend code (architecture, security, performance)
- Review frontend code (UI patterns, state management)
- Identify refactoring opportunities
- Document findings

**Step 6: Create QA Results Section**

Open story file and add:

```markdown
## QA Results

### Review Date: {date}
### Reviewed By: Quinn (Test Architect)

### E2E Test Execution Results (Playwright MCP)

**Test Scenarios:** `docs/qa/e2e/story-{n}-{feature}.md`

**Execution Summary:**
- Total Test Cases: 8
- Passed: ✅ 8
- Failed: ❌ 0
- Duration: 25 minutes

**Test Results by Acceptance Criteria:**

| AC# | Test Case | Status | Evidence | Notes |
|-----|-----------|--------|----------|-------|
| AC1 | TC 1.1 - Login flow | ✅ PASS | tc-1-1-success.png | No console errors |
| AC1 | TC 1.2 - Invalid password | ✅ PASS | tc-1-2-error.png | Error shown correctly |
| AC2 | TC 2.1 - Profile page | ✅ PASS | tc-2-1-profile.png | Data displayed correctly |
| ... | ... | ... | ... | ... |

**Playwright MCP Tools Used:**
- browser_navigate: Navigate to pages
- browser_snapshot: Verify page structure
- browser_click: Interact with UI
- browser_type: Fill forms
- browser_console_messages: Check for errors
- browser_take_screenshot: Capture evidence
- browser_resize: Test responsive design

**Console Error Check:**
- ✅ No console errors detected across all test cases

**Responsive Design:**
- Mobile (375x667): ✅ PASS
- Tablet (768x1024): ✅ PASS
- Desktop (1920x1080): ✅ PASS

**Screenshots:** `.playwright-mcp/` directory

### Code Quality Assessment
[Your findings from code review]

### Gate Status
**Gate:** ✅ PASS
**Quality Score:** 90/100
**Status Reason:** All test cases pass, no console errors, responsive design verified, code quality good

### Recommended Status
✅ **Ready for Done**
```

**Step 7: Create Quality Gate YAML File**

Create: `docs/qa/gates/sprint5-epic-{n}.story-{n}-{slug}.yml`

```yaml
schema: 1
story: 'sprint5-epic-{n}.story-{n}'
story_title: '{Story Title}'
gate: PASS
status_reason: 'All E2E test cases pass via Playwright MCP, no console errors, responsive design verified'
reviewer: 'Quinn (Test Architect)'
updated: '2025-10-13T18:00:00Z'

quality_score: 90

evidence:
  test_cases_executed: 8
  test_cases_passed: 8
  test_cases_failed: 0
  mcp_tools_used:
    - browser_navigate
    - browser_snapshot
    - browser_click
    - browser_type
    - browser_console_messages
    - browser_take_screenshot
    - browser_resize
  screenshots_captured: 12
  console_errors: 0

nfr_validation:
  security:
    status: PASS
    notes: 'Input validation present, no console errors indicating XSS/injection'
  performance:
    status: PASS
    notes: 'Page loads quickly, responsive interactions'
  reliability:
    status: PASS
    notes: 'Error handling works, no crashes observed'
  maintainability:
    status: PASS
    notes: 'Code quality good, clear structure'

recommendations:
  immediate: []
  future:
    - action: 'Consider adding more edge case test scenarios'
```

**Step 8: Update Story Status & Return**
- If **PASS**: Status → `✅ DONE`
- If **CONCERNS**: Status → `⚠️ QA CONCERNS - REVIEW NEEDED`
- If **FAIL**: Status → `❌ QA FAILED - RETURN TO DEV`

---

## Quality Gate Decision Tree

```
STEP 1: E2E Test Results (HIGHEST PRIORITY)
├─ ANY E2E test case failed? → ❌ FAIL (automatic)
├─ Test case count < AC count? → ❌ FAIL (missing coverage)
├─ No E2E test scenarios exist? → ❌ FAIL (required)
└─ All E2E test cases passed? → Proceed to STEP 2

STEP 2: Console Errors
├─ JavaScript errors in console? → ❌ FAIL or ⚠️ CONCERNS (depending on severity)
└─ No console errors? → Proceed to STEP 3

STEP 3: Critical Security/Functionality Issues
├─ Critical security vulnerability? → ❌ FAIL
├─ Data loss risk? → ❌ FAIL
├─ Core functionality broken? → ❌ FAIL
└─ No critical issues? → Proceed to STEP 4

STEP 4: Non-Critical Issues
├─ Medium severity bugs? → ⚠️ CONCERNS
├─ Performance issues (non-blocking)? → ⚠️ CONCERNS
└─ No medium issues? → Proceed to STEP 5

STEP 5: NFR Validation
├─ All NFRs validated? → ✅ PASS
├─ Minor improvements suggested? → ✅ PASS (with recommendations)
└─ All criteria met? → ✅ PASS
```

---

## Example: Complete Story Flow

### Day 1 - Dev Agent

1. Reads `docs/stories/sprint5-story-07-stock-alerts.md`
2. Implements stock alert feature
3. Writes E2E test scenarios: `docs/qa/e2e/story-07-stock-alerts.md`
   - AC1: 3 test cases
   - AC2: 2 test cases
   - AC3: 3 test cases
   - Total: 8 test cases
4. Updates story file with Dev Agent Record
5. Sets status: `✅ READY FOR QA`
6. **HALTS**

### Day 2 - QA Agent

1. Discovers story-07 is "READY FOR QA"
2. Reads story file + E2E scenarios
3. Verifies servers running
4. Executes test cases using Playwright MCP:
   - TC 1.1: browser_navigate, browser_click, browser_snapshot → ✅ PASS
   - TC 1.2: browser_resize(mobile), browser_take_screenshot → ✅ PASS
   - TC 1.3: browser_console_messages → ✅ PASS (no errors)
   - TC 2.1: browser_type, browser_click, browser_wait_for → ❌ FAIL (email not sent)
   - **Stopped here due to failure**
5. **Gate Decision:** ❌ FAIL (TC 2.1 failed)
6. Documents failure in QA Results
7. Creates gate file: FAIL, quality score 60/100
8. Returns to Dev Agent: "Email notification not triggering - check emailService.js"
9. **HALTS**

### Day 3 - Dev Agent

1. Reads QA Results
2. Fixes bug in `backend/services/emailService.js`
3. Updates story file with bug fix notes
4. Sets status: `✅ READY FOR RE-TEST`
5. **HALTS**

### Day 4 - QA Agent

1. Re-runs all test cases using Playwright MCP
2. All 8 test cases pass ✅
3. Proceeds to code review: No issues
4. Updates QA Results: Bug fixed, all tests pass
5. Updates gate file: `✅ PASS`, quality score 90/100
6. Sets story status: `✅ DONE`
7. **HALTS**

### Day 5 - Dev Agent

1. Sees story-07 marked DONE
2. Proceeds to story-08

---

## Best Practices

### For Dev Agents

1. **Write clear test scenarios**
   - Detailed steps QA can follow
   - Specific element descriptions (button names, field labels)
   - Clear expected results

2. **Test coverage**
   - Minimum ONE test case per AC
   - Include error states
   - Include responsive behavior
   - Include edge cases

3. **Keep servers running**
   - QA needs both frontend and backend
   - Monitor for crashes
   - Restart if needed

### For QA Agents

1. **Always browser_snapshot() first**
   - See page structure before interacting
   - Get element references (refs)
   - Verify expected elements exist

2. **Always browser_console_messages() after actions**
   - Check for JS errors
   - Document any warnings
   - Clean console = quality indicator

3. **Test responsive systematically**
   - Mobile: 375x667
   - Tablet: 768x1024
   - Desktop: 1920x1080
   - Screenshot each size

4. **Document everything**
   - Which MCP tools used
   - What you observed
   - Screenshots as evidence
   - Console output

5. **Use browser_wait_for() liberally**
   - Wait for text to appear
   - Wait for loading to finish
   - Prevents timing issues

---

## Troubleshooting

### Problem: Can't find element reference

**Symptoms:** browser_snapshot() doesn't show expected element

**Solution:**
1. Verify page loaded: browser_wait_for(text="Expected Text")
2. Run browser_snapshot() again
3. Check element is visible (not hidden or in collapsed menu)
4. Scroll if needed, then snapshot again

---

### Problem: Console shows errors

**Symptoms:** browser_console_messages() shows JavaScript errors

**Solution:**
1. **FAIL the gate** if errors are related to test case
2. Document errors in QA Results
3. Return to Dev Agent with console output
4. Dev Agent must fix errors before re-test

---

### Problem: Screenshot is empty

**Symptoms:** browser_take_screenshot() creates blank image

**Solution:**
1. Add browser_wait_for() before screenshot
2. Verify page actually loaded
3. Try fullPage=true parameter
4. Check `.playwright-mcp/` directory for file

---

## Success Metrics

**Your BMAD workflow completed Stories 1-10 successfully!** ✅

### What's Working:
- ✅ Playwright MCP programmatic browser control
- ✅ E2E test scenarios provide clear testing guidance
- ✅ Quality gate YAML files track decisions transparently
- ✅ Two-agent workflow prevents bottlenecks
- ✅ Story-by-story approach maintains focus

---

## FAQ

**Q: Why no `.spec.js` files?**
**A:** Your workflow uses Playwright MCP tools interactively, not automated test scripts. QA Agent controls browser programmatically but makes PASS/FAIL decisions manually.

**Q: Can Dev Agent use MCP tools?**
**A:** Yes, but Dev Agent's job is to write test SCENARIOS (markdown documentation), not execute tests. QA Agent executes tests using MCP tools.

**Q: What if I need to test something complex?**
**A:** Playwright MCP has 19 tools including browser_evaluate() for custom JavaScript. See `.ai/playwright-mcp-tools-reference.md` for all tools.

**Q: How do I learn all MCP tools?**
**A:** Read `.ai/playwright-mcp-tools-reference.md` - complete guide with examples, workflows, and best practices.

---

## Related Documents

- **`.ai/playwright-mcp-tools-reference.md`** - Complete MCP tool reference (MUST READ!)
- `.ai/workflow-quick-reference.md` - 1-page cheat sheet
- `.ai/developer-onboarding-guide.md` - Dev Agent onboarding
- `.ai/qa-onboarding-guide.md` - QA Agent onboarding
- `.ai/playwright-mcp-capabilities-report.md` - Live testing results

---

**Version:** 2.0 (Complete Rewrite)
**Last Updated:** October 13, 2025
**Based On:** Actual Playwright MCP testing (Linux Mint page)
**Maintained By:** BMad Orchestrator
