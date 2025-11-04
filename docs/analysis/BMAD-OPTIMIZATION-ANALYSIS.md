# BMad Core Optimization Analysis

## Executive Summary

**Good News**: BMad core is already framework-agnostic for testing! The QA and Dev agents don't mandate Jest. Jest references are minimal and only appear in architecture templates as **examples of existing project structures**, not as requirements.

However, we should **optimize BMad to explicitly promote Playwright + Maestro** and create testing guidance that aligns with your stack.

---

## Current State Analysis

### ✅ What's Already Good

1. **QA Agent (Quinn)** - Framework Agnostic
   - `qa.md` - No mention of specific test framework
   - `review-story.md` - Reviews "tests" generically
   - `test-design.md` - Creates test scenarios without framework preference
   - `test-levels-framework.md` - Pure testing theory (unit/integration/e2e)
   - `test-priorities-matrix.md` - Risk-based prioritization (P0/P1/P2)

2. **Dev Agent (James)** - Framework Agnostic
   - `dev.md` - Says "Write tests" but doesn't specify how
   - develop-story command: "Write tests→Execute validations"

3. **Core Testing Philosophy** - Sound
   - Risk-based testing (probability × impact)
   - Test level framework (unit vs integration vs E2E)
   - Requirements traceability
   - Quality gates (PASS/CONCERNS/FAIL)

### ⚠️ What Needs Optimization

#### 1. Jest References (Minimal, but present)

| File | Line | Context | Issue |
|------|------|---------|-------|
| `templates/fullstack-architecture-tmpl.yaml` | 552 | `jest/` in config folder structure | Example structure for brownfield projects |
| `tasks/document-project.md` | 167-245 | "Jest tests (60% coverage)" | Example of existing project analysis |

**Impact**: LOW - These are **examples**, not requirements

#### 2. Missing Explicit Playwright/Maestro Guidance

**Current**: Agents say "write tests" but don't specify tooling
**Needed**:
- Explicit Playwright guidance for web/backend
- Explicit Maestro guidance for React Native
- MCP integration instructions
- Test generation examples

#### 3. No MCP-Aware Test Strategy

**Current**: Agents don't know about MCPs
**Needed**:
- QA agent should leverage Playwright MCP
- Dev agent should use Playwright/Maestro MCPs for test generation
- Test design should consider MCP capabilities

---

## Maestro MCP Research

### ✅ Official Maestro MCP Exists

**Repository**: https://github.com/mobile-dev-inc/maestro-mcp
**Documentation**: https://docs.maestro.dev/getting-started/maestro-mcp

### Key Features

- **Control emulators/simulators** from Claude Code
- **Write UI tests** using natural language
- **Auto-debug** test failures
- **YAML-based** test definitions (human-readable)
- **Cross-platform**: iOS + Android with single test file

### Integration

```bash
# Install Maestro MCP
claude mcp add --scope project --transport stdio maestro -- npx maestro-mcp

# Or install globally
claude mcp add --scope user --transport stdio maestro -- npx maestro-mcp
```

### Usage in Claude Code

```
"Write a Maestro test for user login flow"
"Create test that navigates to profile and verifies user data"
"Debug the failing checkout test"
```

---

## Recommended Optimizations

### Phase 1: Update Testing Guidance (BMad Core)

#### A. Create New File: `.bmad-core/data/testing-stack-guide.md`

**Purpose**: Explicit guidance on Playwright + Maestro

**Content**:
```markdown
# Testing Stack Guide

## Web & Backend Testing: Playwright

### When to Use Playwright
- Web application E2E tests
- API endpoint testing (via Playwright's request context)
- Browser automation
- Visual regression testing

### Playwright with MCP
- Playwright MCP is available globally
- Generate tests via natural language
- Use accessibility tree (faster than screenshots)

### Test Structure
```playwright
// tests/e2e/login.spec.ts
import { test, expect } from '@playwright/test';

test('user can login', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'user@example.com');
  await page.fill('[data-testid="password"]', 'password');
  await page.click('[data-testid="submit"]');
  await expect(page).toHaveURL('/dashboard');
});
```

## React Native Testing: Maestro

### When to Use Maestro
- React Native mobile app testing
- iOS + Android with single test file
- User journey validation
- Cross-platform UI testing

### Maestro with MCP
- Maestro MCP controls emulators/simulators
- Write tests in YAML (simple syntax)
- Natural language test generation

### Test Structure
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

## NO Jest Required

This workflow eliminates Jest entirely:
- **Web**: Playwright for E2E
- **Backend**: Playwright for API testing
- **Mobile**: Maestro for UI testing
- **Unit Tests**: Vitest (if needed, faster Jest alternative)
```

#### B. Update `.bmad-core/data/test-levels-framework.md`

**Add Section**: "Framework Selection by Platform"

```markdown
## Framework Selection by Platform

### Web Applications (React, Next.js, Vue, etc.)
- **E2E Tests**: Playwright
- **Component Tests**: Playwright Component Testing (or Vitest)
- **API Tests**: Playwright's request context

### React Native Applications
- **E2E Tests**: Maestro
- **Component Tests**: React Native Testing Library
- **Unit Tests**: Vitest (or Jest alternative)

### Backend APIs (Node.js, Python, etc.)
- **API Tests**: Playwright request context
- **Integration Tests**: Supertest (Node.js) or httpx (Python)
- **Unit Tests**: Vitest (Node.js) or pytest (Python)

## MCP-Enhanced Testing

When MCPs are available:
- **Playwright MCP**: Generate web E2E tests via natural language
- **Maestro MCP**: Generate mobile tests via natural language
- **Swagger MCP**: Validate API contracts automatically
- **Database MCPs**: Verify data persistence
```

#### C. Update QA Agent (`qa.md`)

**Add to `dependencies.data`**:
```yaml
dependencies:
  data:
    - technical-preferences.md
    - testing-stack-guide.md  # NEW: Explicit testing framework guidance
```

**Update QA `persona.core_principles`**:
```yaml
core_principles:
  # ... existing principles ...
  - MCP-Aware Testing - Leverage Playwright/Maestro MCPs for test generation and validation
  - Framework Alignment - Ensure tests use project's stack (Playwright for web, Maestro for mobile)
```

#### D. Update Dev Agent (`dev.md`)

**Add to `dependencies.data`**:
```yaml
dependencies:
  data:
    - testing-stack-guide.md  # NEW: Testing framework guidance
```

**Update Dev `core_principles`**:
```yaml
core_principles:
  # ... existing principles ...
  - CRITICAL: Use Playwright for web/backend E2E tests, Maestro for React Native
  - CRITICAL: Leverage Playwright/Maestro MCPs for test generation when available
  - CRITICAL: NO Jest - use Playwright + Maestro exclusively
```

#### E. Create Story Template Update

**File**: `.bmad-core/templates/story-tmpl.yaml`

**Update Testing Section**:
```yaml
testing:
  framework:
    web: "Playwright"
    mobile: "Maestro"
  test_levels:
    unit: "// If needed, specific to business logic"
    integration: "// Via Playwright request context or backend framework"
    e2e: "// Playwright (web) or Maestro (mobile)"
  test_data: "// Required test data and setup"
  mcp_available: "// Playwright MCP (global), Maestro MCP (if React Native)"
```

---

### Phase 2: Update Architecture Templates

#### A. Update `fullstack-architecture-tmpl.yaml`

**Line 552** - Replace Jest reference:

**Before**:
```yaml
│       └── jest/
```

**After**:
```yaml
│       └── playwright/    # Web E2E test configuration
```

**Add New Section** - "Testing Strategy":

```yaml
testing_strategy:
  web_backend:
    e2e: "Playwright"
    api: "Playwright request context"
    framework_note: "NO Jest - Playwright for all E2E testing"
  mobile:
    e2e: "Maestro"
    platform_note: "Single YAML file runs on iOS + Android"
  mcps:
    playwright: "Global MCP for web test generation"
    maestro: "Project MCP for mobile test generation (if React Native)"
  test_structure:
    web: |
      tests/
      ├── e2e/                    # Playwright E2E tests
      │   ├── user-flows/         # Critical user journeys
      │   └── api/                # API contract tests
      └── playwright.config.ts    # Playwright configuration
    mobile: |
      flows/                      # Maestro test flows
      ├── critical/               # P0 user journeys
      ├── regression/             # P1/P2 tests
      └── .maestro/               # Maestro config
```

#### B. Update `document-project.md`

**Lines 167, 245** - Make Jest example generic:

**Before**:
```markdown
├── tests/               # Jest tests (60% coverage)
```

**After**:
```markdown
├── tests/               # Tests (60% coverage - framework TBD, recommend Playwright)
```

**Before**:
```markdown
- Unit Tests: 60% coverage (Jest)
```

**After**:
```markdown
- E2E Tests: 60% coverage (Existing framework - recommend migrating to Playwright)
```

---

### Phase 3: Create MCP-Aware Test Tasks

#### A. Create `.bmad-core/tasks/generate-playwright-tests.md`

```markdown
# generate-playwright-tests

Use Playwright MCP to generate E2E tests for story acceptance criteria.

## Prerequisites
- Playwright MCP available (check with /mcp)
- Story has approved acceptance criteria

## Process

1. **Load Story**: Read story file to understand ACs
2. **Check MCP**: Verify Playwright MCP is active
3. **Generate Tests**: For each AC, use Playwright MCP to generate test
4. **Review Generated Tests**: Ensure tests are comprehensive
5. **Save Tests**: Write to tests/e2e/{feature-name}.spec.ts
6. **Update Story**: Mark test generation subtask complete

## Example Prompt for Playwright MCP

"Generate Playwright test for user login flow:
- Navigate to /login
- Fill email: test@example.com
- Fill password: password123
- Click submit
- Verify redirect to /dashboard
- Assert user name displays"

## Output
- Test file created in tests/e2e/
- Story test subtask marked complete
```

#### B. Create `.bmad-core/tasks/generate-maestro-tests.md`

```markdown
# generate-maestro-tests

Use Maestro MCP to generate mobile E2E tests for React Native apps.

## Prerequisites
- Maestro MCP available (check with /mcp)
- React Native app configured
- Story has approved acceptance criteria

## Process

1. **Load Story**: Read story file to understand ACs
2. **Check MCP**: Verify Maestro MCP is active
3. **Generate Tests**: For each AC, use Maestro MCP to generate YAML flow
4. **Review Generated Tests**: Ensure flows are correct
5. **Save Tests**: Write to flows/{feature-name}.yaml
6. **Update Story**: Mark test generation subtask complete

## Example Prompt for Maestro MCP

"Generate Maestro test for user login:
- Launch app
- Tap on Email Input
- Input: user@example.com
- Tap on Password Input
- Input: password
- Tap Login Button
- Assert Dashboard is visible"

## Output
- Flow file created in flows/
- Story test subtask marked complete
- Test can run on iOS + Android
```

---

### Phase 4: Update Project Templates

Once BMad core is optimized, update all 4 project templates:

#### Template Updates Needed

1. **Python/FastAPI + PostgreSQL**
   - Add Playwright config
   - Remove any Jest references
   - Update README with Playwright examples

2. **Node.js + Supabase**
   - Add Playwright config
   - Remove any Jest references
   - Update README with Playwright + Supabase MCP examples

3. **Node.js + MongoDB**
   - Add Playwright config
   - Remove any Jest references
   - Update README with Playwright + MongoDB MCP examples

4. **React Native**
   - Add Maestro config
   - Add Playwright config (for backend testing)
   - Remove any Jest references
   - Update README with Maestro + Playwright examples
   - Document Maestro MCP setup

---

## Implementation Priority

### High Priority (Do First)

1. ✅ **Research Maestro MCP** - COMPLETE
2. 🔄 **Create `testing-stack-guide.md`** - Explicit Playwright/Maestro guidance
3. 🔄 **Update QA agent dependencies** - Add testing-stack-guide.md
4. 🔄 **Update Dev agent dependencies** - Add testing-stack-guide.md
5. 🔄 **Create generate-playwright-tests.md task**
6. 🔄 **Create generate-maestro-tests.md task**

### Medium Priority (Do Second)

7. Update `fullstack-architecture-tmpl.yaml` - Replace Jest references
8. Update `document-project.md` - Make Jest references generic
9. Update story template - Add testing framework fields
10. Update all other architecture templates

### Low Priority (Do After Templates Work)

11. Update project templates with Playwright configs
12. Update project templates with Maestro configs (React Native)
13. Add Playwright/Maestro examples to template READMEs

---

## Migration Path for Existing Projects

### If You Have Jest Tests Now

**Option A: Gradual Migration**
1. Keep existing Jest tests running
2. New features use Playwright/Maestro
3. Migrate critical paths to Playwright over time

**Option B: Full Rewrite**
1. Identify all Jest test files
2. Rewrite as Playwright tests
3. Delete Jest configuration
4. Remove Jest dependencies

**BMad can help**: Use QA agent to assess test migration complexity

---

## Key Decisions Needed from You

### 1. Maestro MCP Scope

**Question**: Should Maestro MCP be global or project-specific?

**Options**:
- **Global** (like Playwright): Available in all projects
  - Pro: Always available for React Native projects
  - Con: Not needed for web-only projects
- **Project-specific**: Only React Native templates
  - Pro: Cleaner MCP list for web projects
  - Con: Must configure per React Native project

**Recommendation**: **Project-specific** - Only install for React Native projects

### 2. Unit Testing Framework

**Question**: Do you need unit tests at all?

**Options**:
- **No unit tests**: Rely on Playwright E2E + integration tests
  - Pro: Simpler, fewer frameworks
  - Con: Slower feedback, harder to test pure logic
- **Vitest**: Modern, fast Jest alternative
  - Pro: Fast, compatible with Vite ecosystem
  - Con: Another framework to learn
- **Playwright Component Testing**: Test React components
  - Pro: One framework for everything
  - Con: Newer, less mature

**Recommendation**: **Playwright only** for E2E/integration, skip unit tests unless you have pure logic

### 3. Backend API Testing

**Question**: How to test backend APIs?

**Options**:
- **Playwright request context**: All-in-one solution
  - Pro: Same framework as E2E tests
  - Con: Tied to Playwright
- **Supertest** (Node.js) / **httpx** (Python): Dedicated API testing
  - Pro: Framework-agnostic
  - Con: Another dependency

**Recommendation**: **Playwright request context** - Keep it simple

---

## Next Steps

I'm ready to implement the optimizations. Here's what I'll do:

1. Create `testing-stack-guide.md` with Playwright/Maestro guidance
2. Update QA and Dev agents to reference the guide
3. Create Playwright/Maestro test generation tasks
4. Update architecture templates to remove Jest references
5. Create Maestro MCP setup instructions

**Your Input Needed**:
- Confirm Maestro MCP scope (global vs project-specific)
- Confirm no Jest/unit testing requirement
- Any other preferences?

Once you confirm, I'll proceed with the updates!
