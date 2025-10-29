# Testing Stack Guide

**Version**: 1.0
**Last Updated**: 2025-10-28

---

## Testing Philosophy: Hybrid Vitest + Playwright MCP

This workflow uses a **hybrid testing approach**:

- **Unit Testing**: Vitest (for complex pure functions with 10+ edge cases)
- **E2E Testing**: Playwright MCP (interactive browser control for all user journeys)
- **NO Jest** - Eliminated entirely
- **Test Scenarios**: Dev writes markdown documentation (NOT test code files for E2E)
- **Test Execution**: QA runs Vitest first, then executes E2E via Playwright MCP tools
- **Verification**: Hybrid approach - automated unit tests + interactive E2E with manual observation

---

## Framework Selection by Platform

### Web Applications (React, Next.js, Vue, etc.)

**Testing Approach**: Vitest (unit) + Playwright MCP (E2E)

**Developer Role**:
- **IF** complex logic (10+ edge cases) → Writes Vitest unit tests in `docs/qa/unit/`
- Writes E2E test SCENARIOS in markdown (NOT `.spec.ts` files)
- Documents acceptance criteria test cases
- Manages background processes (frontend + backend servers)
- Does NOT run tests (QA's responsibility)
- Outputs QA Handoff when implementation complete

**QA Role**:
- **IF** Vitest tests exist → Runs `npm run test` FIRST, verifies passing
- Reads E2E test scenarios from markdown
- Executes E2E scenarios using 26 Playwright MCP tools interactively
- Observes browser actions in real-time (visible Chrome window)
- **IF** logic gaps found → Can add more Vitest tests
- Decides PASS/FAIL based on manual verification
- Collects evidence (screenshots, console logs, page snapshots)
- Outputs Developer Handoff (if issues) or Completion Handoff (if PASS)

**When Dev Writes Vitest**:
- Functions with 10+ edge cases
- Complex algorithms (calculations, validations, transformations)
- Pure utility functions with multiple branches
- Dev's discretion (no hard rule)

**When Dev Skips Vitest**:
- Simple CRUD operations (test via E2E only)
- UI components (test via E2E only)
- Features with < 10 edge cases

### React Native Applications

**Testing Approach**: Maestro (iOS + Android with single YAML)

**When to Add**: When mobile sprint begins (sprint-dependent MCP)

**Installation** (in project):
```bash
claude mcp add --scope project --transport stdio maestro -- npx maestro-mcp
```

**Test Structure**:
```yaml
# flows/login.yaml
appId: com.yourapp
---
- launchApp
- tapOn: "Email Input"
- inputText: "user@example.com"
- tapOn: "Password Input"
- inputText: "password"
- tapOn: "Login Button"
- assertVisible: "Dashboard"
```

### Backend APIs (Node.js, Python, etc.)

**Testing Approach**: Vitest (unit) + Playwright request context OR Swagger MCP (API)

**Options**:
1. **Vitest**: Unit test business logic functions
2. **Playwright request context**: Test APIs via browser fetch/XHR
3. **Swagger MCP**: Auto-test API contracts (if OpenAPI spec available)
4. **Direct MCP tools**: Use `browser_evaluate()` for API calls

---

## Testing Workflow: Hybrid Vitest + Playwright MCP

### Phase 1: Dev Implementation + Test Writing

**Dev Terminal**:
1. Implement feature according to story
2. **IF complex logic exists (10+ edge cases)**:
   - Write Vitest unit tests in `docs/qa/unit/sprint-N/epics/epic-N/story-N/`
   - Example: `calculateTax.test.ts`, `validateEmail.test.ts`
   - Use descriptive test names
   - Cover all edge cases
3. Write E2E test scenarios in `docs/qa/e2e/sprint-N/epics/epic-N/story-N/`
   - Format: `scenario-{description}.md` (e.g., `scenario-login.md`)
   - Organize test cases by acceptance criteria (AC)
   - Number test cases: TC{AC}.{case} (e.g., TC1.1, TC1.2, TC2.1)
   - Include: Steps, Expected behavior, Priority
4. Start background processes:
   - Frontend: `npm run dev` (usually port 3000)
   - Backend: `npm run dev:api` (usually port 5001)
5. **Do NOT run tests** (QA's responsibility)
6. Output QA Handoff (structured format)

**Test Scenario Writing Guidelines**:
- One test scenario document per feature/flow
- Organize test cases by acceptance criteria (AC)
- Number test cases: TC{AC-number}.{case-number}
- Include: Steps, Expected behavior, Edge cases
- Write in natural language (QA will translate to MCP commands)

**Example Test Scenario**:
```markdown
# Test Scenarios: Story 1.1.3 - User Login

## AC1: User can login with valid credentials

### TC1.1: Login with email and password
**Priority**: P0
**Steps**:
1. Navigate to /login
2. Fill email field with "user@example.com"
3. Fill password field with "password123"
4. Click "Login" button
5. Verify redirect to /dashboard
6. Verify user name "John Doe" displays in header

**Expected**:
- Successful login
- Dashboard page loads
- User name visible
- No console errors

### TC1.2: Login validation shows errors for invalid email
**Priority**: P1
**Steps**:
1. Navigate to /login
2. Fill email field with "invalid-email"
3. Click "Login" button
4. Verify error message "Invalid email format" displays
5. Verify no redirect occurs

**Expected**:
- Error message visible
- Stays on login page
- Form is not submitted

## AC2: User cannot login with invalid credentials

### TC2.1: Error message for wrong password
**Priority**: P0
**Steps**:
1. Navigate to /login
2. Fill email field with "user@example.com"
3. Fill password field with "wrongpassword"
4. Click "Login" button
5. Verify error message "Invalid credentials" displays
6. Verify user stays on login page

**Expected**:
- Error message displayed
- No redirect
- Console shows no errors (expected API 401)
```

**Example Vitest Unit Test**:
```typescript
// docs/qa/unit/sprint-1/epics/epic-1/story-3/calculateTax.test.ts
import { describe, it, expect } from 'vitest';
import { calculateTax } from '@/lib/calculateTax';

describe('calculateTax', () => {
  it('calculates tax for single filer with standard deduction', () => {
    const result = calculateTax(50000, 'single', []);
    expect(result).toBe(6789);
  });

  it('calculates tax for married filing jointly', () => {
    const result = calculateTax(100000, 'married', []);
    expect(result).toBe(12345);
  });

  it('applies deductions correctly', () => {
    const result = calculateTax(50000, 'single', [5000, 3000]);
    expect(result).toBe(5239);
  });

  // ... 10+ more edge cases
});
```

### Phase 2: QA Testing Execution

**QA Terminal** (separate Claude Code instance):
1. Receive QA Handoff from Dev
2. Read story from `docs/sprint-N/epics/epic-N/story-N.md`
3. **IF Vitest tests exist**:
   - Run `npm run test` (or `npm run test:unit`)
   - Verify all tests pass
   - **IF failures**: Document in Developer Handoff, return to Dev
4. Read E2E test scenarios from `docs/qa/e2e/sprint-N/epics/epic-N/story-N/`
5. Verify background processes running (http://localhost:3000, etc.)
6. For each test case in scenarios:
   a. Use `browser_navigate()` to start
   b. Use `browser_snapshot()` to get page structure
   c. Use interaction tools (`browser_click`, `browser_type`, `browser_fill_form`, etc.)
   d. Use `browser_console_messages()` to check for errors
   e. Use `browser_take_screenshot()` to capture evidence
   f. Manually observe: Does behavior match expected?
7. **IF logic gaps found**: Can add more Vitest tests in `docs/qa/unit/`
8. Code review (if E2E tests pass)
9. Decide gate: PASS, CONCERNS, FAIL, or WAIVED
10. Create gate file at `docs/qa/gates/sprint-N/epics/epic-N/story-N-gate.md`
11. Output Developer Handoff (if issues) or Completion Handoff (if PASS)

**QA Decision Criteria**:
- **PASS**: All Vitest + E2E tests passed, no errors, behavior matches expected
- **CONCERNS**: Mostly works, minor issues, Vitest failures acceptable if E2E covers (flexible gate)
- **FAIL**: Critical issues, test cases failed, blockers found
- **WAIVED**: Issues found but accepted (with justification)

**QA Can Add Vitest Tests**:
- If Dev missed edge cases
- If complex logic found during E2E testing
- If repetitive testing via E2E would be inefficient

### Phase 3: Completion or Iteration

**If PASS** (Completion Handoff → Dev):
- Dev commits changes
- Dev closes story
- Move to next story

**If CONCERNS/FAIL** (Developer Handoff → Dev):
- Dev reads QA findings
- Dev fixes issues
- Dev outputs new QA Handoff
- Return to Phase 2

---

## Playwright MCP: 26 Interactive Tools

QA Agent uses these tools to execute E2E test scenarios interactively.

### Navigation Tools
- `browser_navigate(url)` - Navigate to URL
- `browser_navigate_back()` - Go back in history
- `browser_navigate_forward()` - Go forward in history

### Inspection Tools
- `browser_snapshot()` - Get page structure with element refs (use this FIRST before interactions)
- `browser_console_messages()` - Check for JavaScript errors/warnings
- `browser_take_screenshot(filename)` - Capture visual evidence

### Interaction Tools
- `browser_click(element, ref)` - Click element (use ref from snapshot)
- `browser_type(element, ref, text)` - Type text into input
- `browser_fill_form(fields)` - Fill multiple form fields at once
- `browser_select_option(element, ref, value)` - Select dropdown option
- `browser_hover(element, ref)` - Hover over element
- `browser_drag(sourceRef, targetRef)` - Drag and drop
- `browser_press_key(key)` - Press keyboard key

### Utility Tools
- `browser_wait_for(condition, timeout)` - Wait for condition (element visible, URL change, etc.)
- `browser_resize(width, height)` - Resize viewport (responsive testing)
- `browser_evaluate(script)` - Execute JavaScript in browser context
- `browser_handle_dialog(action)` - Handle alert/confirm/prompt dialogs
- `browser_file_upload(element, ref, filepath)` - Upload file

### Advanced Tools
- `browser_network_requests()` - Inspect network traffic (XHR, fetch requests)
- `browser_close()` - Close browser
- `browser_install()` - Install browser if missing

### Tab Management Tools
- `browser_tab_list()` - List all open tabs
- `browser_tab_new(url)` - Open new tab
- `browser_tab_select(tabId)` - Switch to tab
- `browser_tab_close(tabId)` - Close tab

### PDF & Code Tools
- `browser_pdf_save(filename)` - Save page as PDF
- `browser_generate_playwright_test()` - Generate `.spec.ts` file from current session (RARELY used - only for regression test automation)

**Usage Pattern**:
```
1. browser_navigate('http://localhost:3000/login')
2. browser_snapshot() → Get element refs
3. browser_type('[data-testid="email"]', ref, 'user@example.com')
4. browser_type('[data-testid="password"]', ref, 'password123')
5. browser_click('[data-testid="submit"]', ref)
6. browser_console_messages() → Check for errors
7. browser_take_screenshot('login-success.png')
8. Manually observe: Dashboard loaded? User name visible?
```

---

## Dev Visual Debugging with Playwright MCP

**IMPORTANT**: Dev can use Playwright MCP for **understanding/debugging UI issues ONLY** (NOT for testing - that's QA's job).

### When Dev Uses Playwright MCP:
- User describes UI issue ("button is misaligned", "form doesn't submit")
- Dev needs to understand current UI state before proposing fix
- Verifying implementation matches design

### Dev Visual Debugging Workflow:

**Scenario**: User says "The login button is not aligned properly"

**Dev Response Pattern**:
```
I'll inspect the UI to understand the issue.

[Uses Playwright MCP:]
1. browser_navigate('http://localhost:3000/login')
2. browser_snapshot() → Gets page structure
3. browser_take_screenshot('login-button-issue.png')

I can see the login form. The button has these styles:
- Element: <button class="btn-primary" ref="abc123">
- Position: Absolute positioning with left: 10px
- Parent container: Flexbox with justify-content: flex-start

I notice the button is left-aligned while other buttons are centered.

**My understanding**: The button should be centered like the "Sign Up" button above it?

**Proposed fix**: Change parent container's justify-content from 'flex-start' to 'center' in src/components/LoginForm.tsx:45

Is my understanding correct?
```

**User**: "Yes, exactly!"

**Dev**: Proceeds with fix

### Dev Playwright MCP Usage Boundaries:
- ✅ Use for understanding/debugging when user describes UI issues
- ✅ Use to verify current state before implementing changes
- ❌ Do NOT use for systematic testing (QA's responsibility)
- ❌ Do NOT execute all test scenarios via MCP (leave for QA)

---

## Handoff Protocols

### QA Handoff (Dev → QA)

**Format**:
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
- [List of completed tasks/subtasks]

📝 Vitest Unit Tests (if applicable):
- calculateTax.test.ts (15 test cases)
- validateEmail.test.ts (8 test cases)
- Total: 23 unit tests

📝 E2E Test Scenarios Written:
- scenario-login.md (AC1: 3 test cases, AC2: 2 test cases)
- scenario-validation.md (AC3: 4 test cases)
- Total: 9 E2E test cases

🚀 Background Processes Running:
- Frontend: http://localhost:3000
- Backend: http://localhost:5001

💡 Notes for QA:
- Run `npm run test` to execute Vitest unit tests first
- Test scenarios documented in scenario-*.md files
- Use Playwright MCP tools to execute each E2E test case
- Check console for errors on each interaction
- [Any special setup needed]

═══════════════════════════════════════════════════════
📋 COPY THIS BLOCK AND PASTE IN QA TERMINAL
═══════════════════════════════════════════════════════
```

### Developer Handoff (QA → Dev, if issues found)

**Format**:
```
═══════════════════════════════════════════════════════
🔄 DEVELOPER HANDOFF - Issues Found
═══════════════════════════════════════════════════════

📋 Story: Sprint-{N}.Epic-{N}.Story-{N} - {Title}
📊 Gate Decision: [FAIL/CONCERNS]

❌ Vitest Issues (if applicable):

**Test Suite**: calculateTax.test.ts
- Failed: 2/15 tests
- Issue: Edge case for negative income not handled
- Tests: "should handle negative income", "should reject invalid status"

❌ E2E Issues:

**Issue 1: Login button not clickable**
- Test Case: TC1.1
- Severity: Critical
- Description: Button click doesn't trigger submit (z-index issue)
- Evidence: docs/qa/evidence/sprint-N/epics/epic-N/story-N/tc1.1-button-issue.png
- Expected: Form submits on button click
- Actual: No response, console shows no event listener

**Issue 2: Validation error message not displaying**
- Test Case: TC1.2
- Severity: High
- Description: Error message element exists but opacity: 0
- Evidence: docs/qa/evidence/sprint-N/epics/epic-N/story-N/tc1.2-no-error.png
- Expected: Error message visible with red text
- Actual: Element rendered but invisible

📊 Summary:
- Vitest: 13/15 passed (2 failed)
- E2E Test Cases: 7/9 passed (2 failed)
- Blockers: 1 Critical, 1 High severity

🔧 Next Steps:
- Fix Vitest edge cases for negative income
- Fix button z-index issue
- Fix error message visibility
- Re-test affected test cases
- Output new QA Handoff when ready

═══════════════════════════════════════════════════════
📋 COPY THIS BLOCK AND PASTE IN DEV TERMINAL
═══════════════════════════════════════════════════════
```

### Completion Handoff (QA → Dev, if PASS)

**Format**:
```
═══════════════════════════════════════════════════════
✅ COMPLETION HANDOFF - Story Approved
═══════════════════════════════════════════════════════

📋 Story: Sprint-{N}.Epic-{N}.Story-{N} - {Title}
📊 Gate Decision: PASS

✅ Vitest Unit Tests (if applicable):
- calculateTax.test.ts: 15/15 passed
- validateEmail.test.ts: 8/8 passed
- Total: 23/23 passed (100%)

✅ E2E Test Cases Passed:
- AC1: 3/3 test cases passed
- AC2: 2/2 test cases passed
- AC3: 4/4 test cases passed
- Total: 9/9 test cases passed (100%)

📸 Evidence Collected:
- Screenshots: 18 files in docs/qa/evidence/sprint-N/epics/epic-N/story-N/
- Console Logs: No errors
- Network Requests: All successful

💡 QA Added Tests:
- Added validatePhone.test.ts (6 edge cases for phone validation)
- Reason: Dev didn't account for international formats

💡 Notes:
- All acceptance criteria validated
- No blockers or concerns
- Performance is good (login < 500ms)
- Responsive design works (tested 375px, 768px, 1920px)

🎯 Ready for Commit:
- All tests passing
- Story can be closed

═══════════════════════════════════════════════════════
📋 COPY THIS BLOCK AND PASTE IN DEV TERMINAL
═══════════════════════════════════════════════════════
```

---

## Background Process Management

**Developer Responsibility**:
- Always start frontend and backend dev servers before outputting QA Handoff
- Keep processes running during QA review
- Include process URLs in QA Handoff (http://localhost:3000, etc.)
- Track shell_id or PID for safe restart
- If processes need restart, notify QA

**Common Ports**:
- Frontend: 3000 (Next.js), 3001 (React), 5173 (Vite)
- Backend: 5001 (Node.js), 8000 (FastAPI), 4000 (Express)
- Database: 5432 (PostgreSQL), 27017 (MongoDB), 54321 (Supabase)

**Safe Restart Protocol** (CRITICAL):

**NEVER kill all node processes** - Claude Code runs on Node.js!

**Forbidden Commands**:
```bash
# ❌ NEVER DO THIS - Kills Claude Code session
taskkill /F /IM node.exe
pkill node
killall node
```

**Safe Restart Methods**:

**Option 1: Use KillShell Tool** (Preferred)
```
1. Track shell_id when starting background process
2. Use KillShell tool with shell_id to terminate
```

**Option 2: Kill Specific PID**
```bash
# 1. Find specific PID on port
netstat -ano | findstr :5001 | findstr LISTENING
# Output: TCP  0.0.0.0:5001  0.0.0.0:0  LISTENING  12345

# 2. Kill ONLY that specific PID
taskkill //F //PID 12345
```

**Verification Command**:
```bash
# Check what's running on ports
netstat -ano | findstr :3000
netstat -ano | findstr :5001
```

---

## Evidence Collection

**QA Must Collect**:
1. **Screenshots**: Capture key states (before action, after action, error states)
2. **Console Logs**: Check for JavaScript errors/warnings after each interaction
3. **Page Snapshots**: Get page structure for reference
4. **Network Requests**: Verify API calls succeed (optional, for API-heavy features)

**Evidence Naming Convention**:
```
docs/qa/evidence/sprint-N/epics/epic-N/story-N/
├── tc1.1-before-login.png
├── tc1.1-after-login.png
├── tc1.2-error-state.png
├── tc2.1-dashboard-view.png
└── console-logs.txt
```

**Storage Location**: `docs/qa/evidence/sprint-N/epics/epic-N/story-N/`

---

## Test Levels & Coverage

### P0 (Must Test) - >90% Coverage
- Revenue-critical features (checkout, payments)
- Security features (login, auth, permissions)
- Data integrity (CRUD operations)
- Legal/compliance requirements

### P1 (Should Test) - >80% Coverage
- Core user journeys (signup, profile management)
- Frequent features (search, filters, navigation)
- Integration points (API contracts, third-party services)

### P2 (Nice to Test) - >60% Coverage
- Secondary features (settings, preferences)
- Admin functionality (if not revenue-critical)
- Edge cases (unusual workflows)

### P3 (If Time) - Best Effort
- Rarely used features
- Nice-to-have functionality
- Future enhancements

**Coverage Calculation**:
- Coverage = (Test Cases Executed / Total Test Cases) × 100%
- Measured per story, epic, and release
- Tracked in story metadata and gate files

---

## Vitest Configuration

Since unit tests are located at `docs/qa/unit/`, you need to configure Vitest:

**vitest.config.ts**:
```typescript
import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
  test: {
    include: ['docs/qa/unit/**/*.test.ts', 'docs/qa/unit/**/*.test.tsx'],
    exclude: ['node_modules', 'dist', '.idea', '.git', '.cache'],
    globals: true,
    environment: 'node', // or 'jsdom' for frontend tests
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
```

**package.json scripts**:
```json
{
  "scripts": {
    "test": "vitest run",
    "test:unit": "vitest run",
    "test:watch": "vitest",
    "test:ui": "vitest --ui"
  }
}
```

---

## Context7 MCP Integration

**Usage**: Add "use context7" to all prompts for real-time documentation

**Benefits**:
- Latest Playwright best practices
- Current React/Next.js patterns
- Up-to-date library APIs (no deprecated code)
- Latest Vitest patterns

**When to Use**:
- Dev: Writing implementation code
- Dev: Writing test scenarios (for latest testing patterns)
- Dev: Writing Vitest tests (for latest Vitest patterns)
- QA: Executing tests (for latest MCP tool usage)
- Architect: Designing system (for latest architecture patterns)

**Example Prompt** (Dev):
```
use context7
Implement user login form with email/password validation using latest React Hook Form patterns and write Vitest tests for validation logic
```

**Example Prompt** (QA):
```
use context7
Execute login test scenario using Playwright MCP browser_snapshot and browser_click tools
```

---

## When to Use Vitest vs. E2E Only

### Use Vitest When:
- ✅ Function has 10+ edge cases
- ✅ Complex calculations (tax, pricing, scoring)
- ✅ Multiple conditional branches
- ✅ Pure functions (no UI, no DB)
- ✅ Testing via UI would be slow/repetitive

### Skip Vitest When:
- ❌ Simple CRUD operations
- ❌ UI components (use E2E instead)
- ❌ Features with < 10 edge cases
- ❌ Testing via UI is straightforward

### Example: When Vitest Makes Sense

**Scenario**: Tax calculation with complex rules

```typescript
// Requires Vitest (30+ edge cases):
- Single vs Married filing status
- Standard vs Itemized deductions
- Multiple tax brackets
- State tax variations
- Edge cases: negative income, zero income, high income
- Special cases: capital gains, self-employment
```

**Why Vitest**: Testing 30 scenarios via UI (entering forms, submitting, checking results) would take too long. Vitest tests run in milliseconds.

### Example: When E2E is Sufficient

**Scenario**: User login form

```typescript
// Use E2E only (< 10 test cases):
- Valid credentials → success
- Invalid email → error
- Wrong password → error
- Empty fields → validation
- Network error → error message
```

**Why E2E only**: Testing via UI is straightforward and covers the real user experience.

---

## Migration from Jest

### If Existing Project Has Jest Tests:

**Option A: Gradual Migration** (Recommended)
1. Keep existing Jest tests running (don't delete)
2. New features use Vitest + Playwright MCP workflow
3. Migrate critical paths over time (P0/P1 stories first)
4. Remove Jest when coverage equivalent

**Option B: Full Rewrite**
1. Identify all Jest test files
2. Extract test scenarios (what's being tested)
3. Rewrite unit tests as Vitest (in `docs/qa/unit/`)
4. Rewrite integration/E2E as markdown scenarios
5. QA validates via Playwright MCP
6. Delete Jest configuration
7. Remove Jest dependencies

**BMad Can Help**:
- Use Analyst agent to assess test migration complexity
- Use Dev agent to extract test scenarios from Jest files
- Use QA agent to validate new coverage

---

## Frequently Asked Questions

### Q: Why Vitest instead of Jest?
**A**: Vitest is 10-20x faster than Jest, has better TypeScript support, and is actively maintained. Jest is not eliminated for ideological reasons - we just prefer Vitest for performance.

### Q: When should Dev write Vitest vs. when should QA add it?
**A**: Dev writes Vitest during implementation if complexity is obvious (10+ edge cases). QA adds Vitest during review if gaps found or if logic testing via UI is inefficient.

### Q: Does Dev run Vitest before handing off to QA?
**A**: NO. QA is responsible for ALL test execution (Vitest + E2E). Dev writes tests but doesn't run them. This keeps Dev's context focused on implementation.

### Q: Why write E2E test scenarios instead of test code?
**A**: Test scenarios are:
- Faster to write (natural language, not code)
- Easier to review (stakeholders can read)
- Flexible (QA can execute different ways)
- Maintainable (no test code to update with refactors)

### Q: Can I generate `.spec.ts` files?
**A**: Playwright MCP has `browser_generate_playwright_test()` tool, but it's RARELY used. Use only for:
- Regression test automation (same test runs repeatedly)
- CI/CD pipeline integration
- Handoff to non-AI QA team

Default workflow is interactive execution, not test code generation.

### Q: What if Vitest fails but E2E passes?
**A**: Flexible gate decision. QA can mark as CONCERNS if:
- E2E coverage validates behavior
- Vitest failure is edge case not critical
- Dependencies incomplete (future story needed)

Prefer strict (both must pass), but allow flexibility for blockers.

### Q: How do I test APIs?
**A**: Three options:
1. **Vitest**: Unit test API handler functions
2. **Swagger MCP**: Auto-test OpenAPI contracts
3. **Playwright request context / browser_evaluate()**: Execute fetch/axios

Choose based on project setup.

### Q: What about mobile testing?
**A**: Add Maestro MCP when mobile sprint begins:
```bash
claude mcp add --scope project --transport stdio maestro -- npx maestro-mcp
```
Use YAML-based flows for iOS + Android testing.

---

## Testing shadcn/ui Components

**Component Library**: All projects use shadcn/ui (Next.js + Tailwind + TypeScript)

**Key Insight**: shadcn/ui components are built on Radix UI primitives, which have **consistent DOM structure** and **predictable accessibility attributes**. This makes E2E testing more reliable.

### Component Testing Strategy

**NO Component Unit Testing Required**:
- shadcn/ui components are copy-pasted into your project
- They're well-tested by the shadcn/ui and Radix UI projects
- Testing individual components in isolation is unnecessary
- Focus on testing YOUR business logic and user workflows

**YES E2E Testing for User Workflows**:
- Test complete user journeys that use shadcn components
- Test YOUR application logic, not shadcn component internals
- Test integration of components with YOUR data/state

### shadcn Component Selectors (Playwright MCP)

shadcn/ui components have consistent structure. Use these patterns in E2E scenarios:

#### Button Component
```markdown
**Selector Pattern**: button (text), button[type="submit"], button[aria-label="..."]

**Example Scenario**:
1. Click button "Submit" (finds <Button> by text content)
2. Click button[type="submit"] (finds submit button)
3. Verify button is disabled (check aria-disabled="true")
```

#### Form Components (Form + Input + Label)
```markdown
**Selector Pattern**: input[name="..."], input[type="..."], input[aria-label="..."]

**Example Scenario**:
1. Type "john@example.com" into input[name="email"]
2. Type "password123" into input[type="password"]
3. Verify input[name="email"] shows error (check aria-invalid="true")
```

#### Dialog Component
```markdown
**Selector Pattern**: div[role="dialog"], button[aria-label="Close"]

**Example Scenario**:
1. Click button "Delete Account"
2. Wait for div[role="dialog"] to appear
3. Verify dialog contains text "Are you sure?"
4. Click button "Confirm" within dialog
5. Wait for dialog to disappear
```

#### Table Component
```markdown
**Selector Pattern**: table, thead, tbody, tr, td, th

**Example Scenario**:
1. Verify table contains 10 rows (count tbody tr)
2. Click th "Name" to sort by name
3. Verify first td contains "Alice"
```

#### Select/Dropdown Component
```markdown
**Selector Pattern**: button[role="combobox"], div[role="listbox"], div[role="option"]

**Example Scenario**:
1. Click button[role="combobox"] (opens dropdown)
2. Click div[role="option"][data-value="option-1"]
3. Verify button shows "Option 1" (check textContent)
```

### Accessibility Testing with shadcn/ui

**Built-in Accessibility**:
- All shadcn/ui components use proper ARIA attributes
- Keyboard navigation works by default
- Screen reader support included

**What Dev Tests**:
- ✅ YOUR application's focus management
- ✅ YOUR custom keyboard shortcuts
- ✅ YOUR error messages are announced
- ✅ YOUR loading states are communicated

**What Dev Does NOT Test**:
- ❌ shadcn component ARIA attributes (already correct)
- ❌ Built-in keyboard navigation (already works)
- ❌ Component focus trapping (Radix UI handles this)

**E2E Scenario for Accessibility**:
```markdown
### TC1.5: Keyboard Navigation

**Test**: Form can be completed using keyboard only

**Steps**:
1. Press Tab (focus moves to first input)
2. Type "John"
3. Press Tab (focus moves to second input)
4. Type "Doe"
5. Press Tab (focus moves to Submit button)
6. Press Enter (form submits)

**Expected Result**:
- Focus indicator visible at each step
- Form submits successfully
- Toast notification appears and is announced to screen readers
```

### Testing Component Variants

**shadcn/ui Button Variants**: default, destructive, outline, secondary, ghost, link

**Dev's Responsibility**:
- Test that YOUR code applies correct variant
- Test that variant changes based on YOUR application state

**Example E2E Scenario**:
```markdown
### TC2.3: Delete Button Shows Destructive Variant

**Test**: Delete actions use destructive button variant

**Steps**:
1. Navigate to /users/123
2. Locate button "Delete User"
3. Use browser_snapshot() to inspect button classes

**Expected Result**:
- Button has class "bg-destructive text-destructive-foreground"
- Button shows red color (destructive styling)
```

### Testing Component States

**Common States**: default, hover, active, focus, disabled, loading, error

**Dev Tests via E2E**:
- Disabled state prevents interaction
- Loading state shows spinner
- Error state displays error message
- Focus state is visible

**Example E2E Scenario**:
```markdown
### TC3.1: Submit Button Disabled During Loading

**Test**: Form submission disables button

**Steps**:
1. Fill form inputs
2. Click button "Submit"
3. Immediately check button state

**Expected Result**:
- Button shows aria-disabled="true"
- Button shows loading spinner
- Button cannot be clicked again
- After response, button becomes enabled
```

### Testing Responsive Behavior

**shadcn/ui + Tailwind**: Components adapt to screen size

**Dev Tests**:
- Layout changes at breakpoints
- Mobile navigation (hamburger menu)
- Touch targets are large enough (44x44px minimum)

**Example E2E Scenario**:
```markdown
### TC4.1: Mobile Menu

**Test**: Navigation works on mobile viewport

**Steps**:
1. Use browser_resize(375, 667) (iPhone SE)
2. Verify hamburger button is visible
3. Click hamburger button
4. Verify mobile menu slides in
5. Click "Dashboard" link
6. Verify navigation to /dashboard
```

### Common Pitfalls to Avoid

**❌ DON'T**:
- Don't write Vitest tests for shadcn component rendering
- Don't test internal component state
- Don't test Radix UI primitive behavior
- Don't test Tailwind CSS classes directly

**✅ DO**:
- Test YOUR user workflows that happen to use shadcn components
- Test YOUR data integration with components
- Test YOUR business logic triggered by component interactions
- Test YOUR application state changes from component events

### Example: Complete E2E Test Scenario

**Feature**: User Registration Form (uses shadcn Form + Input + Button + Toast)

```markdown
### TC5.1: Successful User Registration

**Component Stack**: Form, Input (email, password, confirmPassword), Button (submit), Toast (success notification)

**Steps**:
1. Navigate to http://localhost:3000/register
2. Type "test@example.com" into input[name="email"]
3. Type "SecurePass123!" into input[name="password"]
4. Type "SecurePass123!" into input[name="confirmPassword"]
5. Click button[type="submit"]
6. Wait for toast notification to appear

**Expected Result**:
- Toast shows "Registration successful!"
- User redirected to /dashboard
- No error messages displayed

**Priority**: P0 (critical user journey)

**Reference**: [UX Spec: front-end-spec.md - User Registration Flow]
```

---

## Summary

**This hybrid testing approach prioritizes**:
✅ Unit tests for complex logic (Vitest)
✅ End-to-end validation for user journeys (Playwright MCP)
✅ Interactive execution over automated test suites
✅ Manual observation over brittle assertions
✅ Natural language scenarios over test code
✅ Evidence collection over code coverage metrics
✅ Fast feedback loops over comprehensive test pyramids

**Benefits**:
- Fast unit test feedback (milliseconds via Vitest)
- Comprehensive E2E validation (Playwright MCP)
- 50-60% faster development (MCP-enhanced)
- No test code maintenance burden for E2E
- Flexible test execution
- Stakeholder-readable test documentation
- Real-world testing (visible browser, manual verification)

**Trade-offs**:
- Requires human QA (not fully automated E2E)
- Manual observation needed (not unattended CI/CD for E2E)
- Dev must decide when Vitest makes sense
- Two testing frameworks to maintain (Vitest + Playwright)

**Best for**:
- Small-to-medium projects (< 50k LOC)
- AI-driven development workflows (BMad Method)
- Teams with dedicated QA review step
- Projects with complex business logic + user journeys
- Projects prioritizing speed + quality over exhaustive automation
