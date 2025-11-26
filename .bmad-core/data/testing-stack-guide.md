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
- **Test Execution**: Dev runs Vitest first (pre-check before QA Handoff), then QA runs Vitest independently (validation) + executes E2E via Playwright MCP tools
- **Verification**: Hybrid approach - automated unit tests + interactive E2E with manual observation

---

## Framework Selection by Platform

### Web Applications (React, Next.js, Vue, etc.)

**Testing Approach**: Vitest (unit) + Playwright MCP (E2E)

**Developer Role**:
- **IF** complex logic (10+ edge cases) → Writes Vitest unit tests in `docs/qa/unit/`
- Writes E2E test SCENARIOS in markdown (NOT `.spec.ts` files)
- Documents acceptance criteria test cases
- **RUNS Vitest tests** (`npm run test`) and verifies ALL PASS before QA Handoff (mandatory pre-check)
- Basic manual verification (run app locally, click through UI, spot check)
- Manages background processes (frontend + backend servers)
- Does NOT execute E2E scenarios with Playwright MCP (QA's responsibility)
- Outputs QA Handoff when implementation complete + Vitest passing

**QA Role**:
- **IF** Vitest tests exist → Runs `npm run test` FIRST, verifies passing independently (validation from clean environment)
- Reads E2E test scenarios from markdown
- Executes E2E scenarios using 26 Playwright MCP tools interactively
- Observes browser actions in real-time (visible Chrome window)
- **IF** logic gaps found → Can add more Vitest tests
- Decides PASS/FAIL based on manual verification (both Vitest AND E2E must pass for PASS gate)
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
4. **MANDATORY**: Create Test Insights Document in `docs/qa/test-insights/sprint-N/epics/epic-N/{epic}.{story}-{slug}-test-insights.md`
   - Use template: `.bmad-core/templates/test-insights-tmpl.md`
   - Fill ALL sections with comprehensive testing analysis:
     - **Story Context**: Summary, acceptance criteria, implementation approach
     - **AC Testing Map**: For each AC - happy path, edge cases, error scenarios, suggested test data, priority
     - **Technical Constraints**: Infrastructure requirements, performance expectations, browser compatibility
     - **Risk Areas**: High-risk areas needing extra attention, error handling coverage, edge cases to test
     - **Realistic Test Data**: Actual test data sets (not generic "user@test.com" - use "Thank you very much" → "Muchas gracias" for transcription)
     - **Integration Testing Insights**: API endpoints, database schema changes, external service integration
     - **UI/UX Testing Insights**: User journeys (typical + alternative flows), UI states, accessibility considerations
     - **Test Execution Notes**: Prerequisites, testing order, debugging tips, environment-specific notes
   - **Purpose**: Provides QA with deep implementation knowledge for practical, consolidated test design (Dev's strength: comprehensive analysis; QA's strength: efficient test execution)
   - Commit to git: `git commit -m "docs(story-X.Y): Create Test Insights document"`
5. Start background processes:
   - Frontend: `npm run dev` (usually port 3000)
   - Backend: `npm run dev:api` (usually port 5001)
6. **Run Vitest tests FIRST** (mandatory pre-check before QA Handoff):
   - Execute: `npm run test`
   - Verify ALL tests PASS
   - Record pass count for QA Handoff (e.g., "Vitest: 15 tests pass ✅")
   - **IF any test fails**: Fix issues before creating QA Handoff (do NOT hand off failing tests to QA)
7. Basic manual verification (run app locally, click through UI, spot check functionality works)
8. **Do NOT execute E2E scenarios** with Playwright MCP (QA's responsibility)
9. Output QA Handoff (structured format) with references to Test Insights document

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

### **Navigation Test Scenarios (MANDATORY for user-facing features)**

CRITICAL: EVERY story that creates/modifies user-facing pages MUST include navigation test scenarios.
These scenarios verify users can REACH the feature via normal navigation (not just direct URL).

**Why This Matters**: Features without navigation integration are unreachable and effectively broken.
Missing menus are a common defect that significantly degrades user experience.

**When to Include**:
- Story creates new page/route
- Story adds new feature to existing application
- Story modifies navigation structure

**Navigation Test Format**:
- Create dedicated test case: `TC{AC}.nav` - Navigation Accessibility
- Test minimum 2 entry points from story Navigation Notes
- Verify menu items, breadcrumbs, contextual links

**Navigation Test Template**:
```markdown
### TC{AC}.nav: Navigation Accessibility to [Feature Name]

**Priority**: P0 (Navigation is critical - unreachable features are broken)

**Precondition**: User logged in, on starting page (dashboard/main menu/related page)

**Test Entry Point 1 - Main Menu**:
1. Navigate to [starting page - e.g., /dashboard]
2. Verify [menu name] menu exists (header/sidebar)
3. Click "[Menu Item Label]" menu item
4. Verify page navigates to [expected URL]
5. Verify page title is "[Expected Page Title]"
6. Verify breadcrumb shows "[Expected Hierarchy]"
7. Click breadcrumb elements to verify navigation works

**Expected**:
- Menu item visible in correct menu location
- Clicking menu item navigates to feature
- Breadcrumbs present and functional
- Page loads without errors

**Test Entry Point 2 - Contextual Link** (if applicable):
1. Navigate to [related page - e.g., /documents/list]
2. Verify "[Button/Link Label]" button/link exists
3. Click button/link
4. Verify navigates to feature page

**Expected**:
- Contextual link visible on related page
- Link navigates to correct destination
- Context preserved (e.g., document ID in URL)

**Negative Test**:
1. Verify feature is NOT only accessible via direct URL
2. New users should discover feature through normal navigation
```

**Example - Batch Processing Navigation**:
```markdown
### TC1.nav: Navigation Accessibility to Batch Processing

**Priority**: P0
**Precondition**: User logged in on dashboard

**Test Entry Point 1 - Primary Navigation Menu**:
1. Navigate to /dashboard
2. Verify "Documents" menu exists in primary navigation (header)
3. Click "Documents" menu item → Opens dropdown
4. Verify "Batch Processing" option in dropdown
5. Click "Batch Processing"
6. Verify navigates to /documents/batch
7. Verify page title "Batch Processing"
8. Verify breadcrumb: "Home > Documents > Batch Processing"
9. Click "Documents" in breadcrumb → Returns to /documents
10. Click "Home" in breadcrumb → Returns to /dashboard

**Expected**:
- Documents menu in header with Batch Processing submenu item
- Navigation works smoothly
- Breadcrumbs functional
- No console errors

**Test Entry Point 2 - Document List Contextual Link**:
1. Navigate to /documents/list
2. Locate any document in list
3. Verify "Start Batch" button exists on document card/row
4. Click "Start Batch" button
5. Verify navigates to /documents/batch?documentId={id}
6. Verify document pre-selected in batch form

**Expected**:
- Contextual button visible on document items
- Navigation preserves document context
- User can initiate batch from document list

**Negative Test Verification**:
- Feature accessible via 2+ navigation paths (not just direct URL)
- New user can discover Batch Processing without knowing URL
```

**QA Execution Using Playwright MCP**:
QA translates navigation scenarios to Playwright MCP commands:
1. `browser_navigate(url)` to starting page
2. `browser_snapshot()` to get menu structure
3. Find menu item reference in snapshot
4. `browser_click(element, ref)` to click menu
5. Verify URL change, page title, breadcrumbs
6. `browser_screenshot()` to capture evidence

---

### **Authentication Testing with Test Credentials**

CRITICAL: Authentication features require coordinated test data setup between Dev and QA.

#### **For Developers: Creating Test Users**

When implementing authentication features (login, signup, password reset, role-based access):

**1. Check for existing credentials file**:
```bash
# Does test-data/auth/creds.txt exist?
cat test-data/auth/creds.txt
```

**2. If missing, create test credentials**:
```bash
# Create auth directory
mkdir -p test-data/auth

# Copy template
cp .bmad-core/templates/creds-template.txt test-data/auth/creds.txt
cp .bmad-core/templates/auth-creds-README.md test-data/auth/README.md

# Edit creds.txt if needed (add more test accounts, roles, etc.)
```

**3. Create seed script matching creds.txt**:

**Location**: `database/seeds/auth_test_users.sql` OR `backend/scripts/seed_test_users.py`

**SQL Example** (Supabase Auth):
```sql
-- database/seeds/auth_test_users.sql
-- MUST match test-data/auth/creds.txt EXACTLY

INSERT INTO auth.users (email, encrypted_password, email_confirmed_at, role)
VALUES
  ('test@example.com', crypt('testpassword123', gen_salt('bf')), NOW(), 'user'),
  ('admin@example.com', crypt('adminpass456', gen_salt('bf')), NOW(), 'admin')
ON CONFLICT (email) DO NOTHING;
```

**Python Example** (FastAPI + custom auth):
```python
# backend/scripts/seed_test_users.py
from api.services.auth import create_user

# MUST match test-data/auth/creds.txt EXACTLY
async def seed_test_users():
    await create_user("test@example.com", "testpassword123", role="user")
    await create_user("admin@example.com", "adminpass456", role="admin")
```

**4. Run seed script**:
```bash
# SQL
psql $DATABASE_URL -f database/seeds/auth_test_users.sql

# Python
python backend/scripts/seed_test_users.py
```

**5. Verify test users exist**:
```bash
# Check database
psql $DATABASE_URL -c "SELECT email, role FROM auth.users WHERE email LIKE '%example.com%'"
```

**6. Include in QA Handoff**:
```markdown
✅ **Test Data Setup**:
- Credentials: test-data/auth/creds.txt
- Seed script: database/seeds/auth_test_users.sql
- Test users created: test@example.com (user), admin@example.com (admin)
- Verified in dev database: ✅
```

---

#### **For QA: Using Test Credentials**

**1. ALWAYS use test-data/auth/creds.txt** for authentication testing:

❌ **DON'T** make up random credentials:
```markdown
# WRONG - Don't do this
Fill email: "user@test.com"  ← Where did this come from?
Fill password: "password123"  ← Not in creds.txt!
```

✅ **DO** reference creds.txt explicitly:
```markdown
# CORRECT
**Test Data**: test-data/auth/creds.txt (test user account)
Fill email: test@example.com (from creds.txt)
Fill password: testpassword123 (from creds.txt)
```

**2. E2E Test Scenario Format**:

```markdown
### TC1.1: Login with valid user credentials

**Test Data**: `test-data/auth/creds.txt` (username/password)

**Prerequisites**:
- Test user exists in development database (Dev responsibility)
- Backend running on http://localhost:8000
- Frontend running on http://localhost:3000

**Steps**:
1. Navigate to http://localhost:3000/login
2. Read credentials from test-data/auth/creds.txt
3. Fill email field: test@example.com
4. Fill password field: testpassword123
5. Click "Login" button
6. Verify redirect to /dashboard
7. Verify user name displays in header
8. Verify localStorage contains auth token

**Expected**:
- Successful login
- Dashboard page loads
- User authenticated
- No console errors

**Playwright MCP Execution**:
browser_navigate("http://localhost:3000/login")
browser_snapshot()  # Get form structure
browser_fill("input[name='email']", "test@example.com")
browser_fill("input[name='password']", "testpassword123")
browser_click("button[type='submit']")
browser_snapshot()  # Verify dashboard loaded
```

**3. Role-Based Testing**:

```markdown
### TC2.1: Admin access to admin panel

**Test Data**: `test-data/auth/creds.txt` (admin_username/admin_password)

**Steps**:
1. Login as admin (admin@example.com / adminpass456 from creds.txt)
2. Navigate to /admin
3. Verify admin panel accessible
4. Verify user management features visible

### TC2.2: Standard user cannot access admin panel

**Test Data**: `test-data/auth/creds.txt` (username/password - non-admin)

**Steps**:
1. Login as standard user (test@example.com from creds.txt)
2. Attempt to navigate to /admin
3. Verify access denied (403 or redirect to dashboard)
```

**4. If test login fails**:

```
ERROR: Invalid credentials

DIAGNOSIS CHECKLIST:
□ Is backend running? (check http://localhost:8000/health)
□ Are credentials correct? (verify exact match with creds.txt)
□ Do test users exist in database? (ask Dev to verify)
□ Was seed script run? (check with Dev)
□ Database reset recently? (re-run seed script)

RESOLUTION:
- FLAG as blocking issue in Developer Handoff
- Dev must verify test users exist and credentials match
- Dev re-runs seed script if needed
- Re-test after confirmation
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
3. **MANDATORY**: Read Test Insights Document from `docs/qa/test-insights/sprint-N/epics/epic-N/{epic}.{story}-{slug}-test-insights.md`
   - Comprehensive testing analysis from Dev (edge cases, risk areas, realistic test data, technical constraints, debugging tips)
   - **Purpose**: Provides deep implementation knowledge for practical test design
   - **How to Use**:
     - Review ALL sections before writing/executing test scenarios
     - Use suggested test data (realistic production-like data)
     - Focus on risk areas identified by Dev
     - Reference technical constraints for infrastructure setup
     - Apply debugging tips when issues arise
   - **Result**: Comprehensive coverage (Dev's analysis) + Efficient execution (your test design)
4. **IF user-facing feature**: Read Navigation Guide from `docs/navigation-guide.md`
   - Cumulative UI context showing ALL existing features from previous stories
   - **Purpose**: Solves context gap - you now know what UI exists, where features are located, how to navigate
   - **How to Use**:
     - Read Feature Catalog to understand new feature's navigation entry points (minimum 2-3)
     - Check User Journey Maps for multi-story workflows (e.g., Upload → View → Transcribe)
     - Verify navigation structure matches documented menus/links
     - Use Page Inventory to understand complete UI landscape
   - **CRITICAL**: If Navigation Guide shows feature has UI (page route, menu item, user journey): You MUST test via frontend with Playwright MCP tools (browser_navigate, browser_click, browser_fill, etc.). NO API shortcuts. Navigation Guide + Test Insights provide complete context for comprehensive E2E testing through UI.
5. Write practical E2E test scenarios (7-10 tests, 20-30 min execution):
   - **Two-Stage Test Creation**: Stage 1 (Dev) = Test Insights analysis. Stage 2 (YOU) = Practical test scenario design.
   - Consolidate related tests based on Test Insights (e.g., combine "upload MP3", "upload WAV", "upload M4A" into single test with multiple file types)
   - Use realistic test data from Test Insights (not generic "user@test.com" - use Dev's suggested data)
   - Add debugging context to scenarios (common issues, tools required)
   - Cover ALL areas identified in Test Insights while optimizing for execution efficiency
   - **Save scenarios** to: `docs/qa/e2e/sprint-N/epics/epic-N/story-N/scenario-{description}.md`
6. **IF Vitest tests exist**:
   - Run `npm run test` (or `npm run test:unit`)
   - Verify all tests pass
   - **IF failures**: Document in Developer Handoff, return to Dev
7. Verify background processes running (http://localhost:3000, etc.)
8. For each test case in scenarios:
   a. Use `browser_navigate()` to start
   b. Use `browser_snapshot()` to get page structure
   c. Use interaction tools (`browser_click`, `browser_type`, `browser_fill_form`, etc.)
   d. Use `browser_console_messages()` to check for errors
   e. Use `browser_take_screenshot()` to capture evidence
   f. Manually observe: Does behavior match expected?
9. **IF logic gaps found**: Can add more Vitest tests in `docs/qa/unit/`
10. **IF environment issues** (processes not running, logs inaccessible, MCP errors): DIAGNOSE issue, DOCUMENT findings, CREATE Developer Handoff, HALT testing (QA diagnoses, Dev fixes)
11. Code review (only AFTER all tests executed and passed)
12. Decide gate: PASS, CONCERNS, FAIL, or WAIVED
13. Create gate file at `docs/qa/gates/sprint-N/epics/epic-N/{epic}.{story}-{slug}.yml`
    - Example: `docs/qa/gates/sprint-2/epics/epic-2/2.1-media-upload.yml`
14. **IF user-facing feature AND gate = PASS**: Update Navigation Guide at `docs/navigation-guide.md`
    - **QA Ownership**: YOU own Navigation Guide updates (moved from Dev for better documentation quality)
    - Use template (first time): `.bmad-core/templates/navigation-guide-tmpl.md`
    - Update existing guide based on YOUR Playwright MCP exploration during testing:
      - Add feature to Feature Catalog (document ALL navigation entry points discovered - minimum 2-3: primary menu, contextual links, breadcrumbs)
      - Update navigation structure (primary/secondary menus you tested)
      - Add user journey map (typical + alternative flows you executed)
      - Document contextual links (TO feature AND FROM feature to related pages you verified)
      - Add page to Page Inventory (route, access methods, key actions)
      - Include timestamp and story reference
    - **Why QA Updates**: Your Playwright MCP exploration makes YOU the expert on navigation (you discovered actual entry points, tested user flows, verified menu integration)
    - **Purpose**: Provides cumulative UI context for future stories (solves context gap - future QA knows what UI exists, where features are located, how to navigate)
    - Commit to git: `git commit -m "docs(story-X.Y): Update Navigation Guide with [feature-name]" --footer "Authored by O2Scale"`
    - Push to remote: `git push`
    - **Skip if**: Backend-only story (no UI changes) OR gate = FAIL/CONCERNS (update after Dev fixes)
15. Output Developer Handoff (if issues) or Completion Handoff (if PASS, including Navigation Guide update reference)

**QA Decision Criteria** (STRICT - Runtime Testing Mandatory):
- **PASS**: ALL Vitest + E2E tests executed and passed, no errors, behavior matches expected, runtime verification complete
- **CONCERNS**: Tests executed, minor non-blocking issues found (cosmetic bugs, missing nice-to-have features, low-priority edge cases)
- **FAIL**: Tests executed, critical issues found (test failures, blockers, security issues, AC not met, environment issues preventing testing)
- **WAIVED**: Issues found but accepted (with justification)

**CRITICAL**: Code review does NOT replace testing. PASS requires runtime verification of ALL tests.

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
- `playwright_screenshot(name, savePng)` - Capture visual evidence
  - **Per-project Playwright MCP automatically saves to project folder** (not Windows Downloads)
  - Organize evidence: `docs/qa/evidence/sprint-{N}/epics/epic-{N}/story-{N}/`
  - Set `savePng: true` to save file to disk

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
7. playwright_screenshot({
     name: 'tc1.1-login-success.png',
     savePng: true
   })
   → Per-project Playwright MCP saves to project folder automatically
8. Manually observe: Dashboard loaded? User name visible?
```

**NOTE**: Per-project Playwright MCP automatically saves screenshots to project folder (not Windows Downloads).

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
**A**: YES. Dev MUST run Vitest (`npm run test`) and verify all tests pass before creating QA Handoff. This is a mandatory pre-check (like a chef tasting food before serving). Dev catches obvious failures while context is fresh, preventing QA from wasting time on broken code. QA then runs Vitest AGAIN independently for validation (food critic evaluates complete dining experience). Both run Vitest but different purposes: Dev = pre-check (fast feedback), QA = validation (independent verification). Dev does NOT execute E2E scenarios with Playwright MCP - that remains QA's job.

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
**A**: **STRICT gate decision** - Both Vitest AND E2E must pass for PASS gate. If Vitest fails:
- Gate = FAIL (if critical test) or CONCERNS (if minor edge case)
- QA documents which tests failed and why
- QA creates Developer Handoff with test failure details
- Dev fixes the failing tests
- Dev outputs new QA Handoff when ready
- QA re-runs ALL tests (Vitest + E2E)

**NO exceptions** for "code looks good" or "E2E covers the Vitest failure". Runtime testing is mandatory.

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
