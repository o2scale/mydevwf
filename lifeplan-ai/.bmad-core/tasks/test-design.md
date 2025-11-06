<!-- Powered by BMAD™ Core -->

# test-design

Create comprehensive test scenarios with appropriate test level recommendations for story implementation.

## Inputs

```yaml
required:
  - story_id: '{epic}.{story}' # e.g., "1.3"
  - story_path: '{devStoryLocation}/{epic}.{story}.*.md' # Path from core-config.yaml
  - story_title: '{title}' # If missing, derive from story file H1
  - story_slug: '{slug}' # If missing, derive from title (lowercase, hyphenated)
```

## Purpose

Design a complete test strategy that identifies what to test, at which level (unit/integration/e2e), and why. This ensures efficient test coverage without redundancy while maintaining appropriate test boundaries.

## Dependencies

```yaml
data:
  - test-levels-framework.md # Unit/Integration/E2E decision criteria
  - test-priorities-matrix.md # P0/P1/P2/P3 classification system
```

## Process

### 1. Analyze Story Requirements

Break down each acceptance criterion into testable scenarios. For each AC:

- Identify the core functionality to test
- Determine data variations needed
- Consider error conditions
- Note edge cases

### 2. Apply Test Level Framework

**Reference:** Load `test-levels-framework.md` for detailed criteria

Quick rules:

- **Unit**: Pure logic, algorithms, calculations
- **Integration**: Component interactions, DB operations
- **E2E**: Critical user journeys, compliance

### 2.5. Test Tooling Selection (CRITICAL)

**Based on test level, select appropriate tooling:**

**Unit Tests → Vitest**
- **When**: Pure functions, algorithms, complex logic with 10+ edge cases
- **Format**: `.test.ts` or `.test.tsx` files with actual test code
- **Location**: `docs/qa/unit/sprint-N/epics/epic-N/story-N/`
- **Execution**: `npm run test` (QA runs this FIRST)
- **Examples**:
  - Tax calculation with 15 tax bracket combinations
  - Email validation with 12 edge cases (special chars, domains, etc.)
  - Date parsing with timezone handling (10+ scenarios)
  - Complex business rules with multiple conditional branches

**E2E Tests → Playwright MCP (Interactive Browser Control)**
- **When**: ALL user journeys, UI interactions, workflows
- **Format**: Markdown test scenarios, NOT test code files (no `.spec.ts`)
- **Location**: `docs/qa/e2e/sprint-N/epics/epic-N/story-N/`
- **Execution**: QA uses 26 Playwright MCP tools interactively
  - Navigation: `browser_navigate`, `browser_navigate_back`, `browser_navigate_forward`
  - Inspection: `browser_snapshot`, `browser_console_messages`, `browser_take_screenshot`
  - Interaction: `browser_click`, `browser_type`, `browser_fill_form`, `browser_select_option`, `browser_hover`, `browser_drag`, `browser_press_key`
  - Utility: `browser_wait_for`, `browser_resize`, `browser_evaluate`, `browser_handle_dialog`, `browser_file_upload`
  - Advanced: `browser_network_requests`, `browser_close`, `browser_install`
  - Tabs: `browser_tab_list`, `browser_tab_new`, `browser_tab_select`, `browser_tab_close`
  - PDF/Code: `browser_pdf_save`, `browser_generate_playwright_test`
- **Examples**:
  - Login flow (navigate → fill form → submit → verify redirect)
  - Checkout process (add to cart → enter shipping → payment → confirm)
  - Form validation (test error states, field interactions)

**Decision Rule - Vitest vs E2E Only:**
- Use Vitest: Complex logic with 10+ edge cases (faster to test via code)
- Use E2E only: Simple CRUD, UI components, features with < 10 edge cases
- Use Both: Complex calculations (Vitest) + User workflow that uses them (E2E)

**Example - When Both Make Sense:**
```
Feature: Tax Calculator Widget
- Vitest: Test calculateTax() function with 20 edge cases (seconds to run)
- E2E: Test user entering income → widget displays calculated tax (validates real UX)
```

[Source: .bmad-core/data/test-levels-framework.md#framework-selection-by-platform]
[Source: .bmad-core/data/testing-stack-guide.md#when-to-use-vitest-vs-e2e-only]

### 3. Assign Priorities

**Reference:** Load `test-priorities-matrix.md` for classification

Quick priority assignment:

- **P0**: Revenue-critical, security, compliance
- **P1**: Core user journeys, frequently used
- **P2**: Secondary features, admin functions
- **P3**: Nice-to-have, rarely used

### 4. Design Test Scenarios

For each identified test need, create:

```yaml
test_scenario:
  id: '{epic}.{story}-{LEVEL}-{SEQ}'
  requirement: 'AC reference'
  priority: P0|P1|P2|P3
  level: unit|integration|e2e
  description: 'What is being tested'
  justification: 'Why this level was chosen'
  mitigates_risks: ['RISK-001'] # If risk profile exists
```

### 5. Validate Coverage

Ensure:

- Every AC has at least one test
- No duplicate coverage across levels
- Critical paths have multiple levels
- Risk mitigations are addressed

## Outputs

### Output 1: Test Design Document

**Save to:** `qa.qaLocation/assessments/{epic}.{story}-test-design-{YYYYMMDD}.md`

```markdown
# Test Design: Story {epic}.{story}

Date: {date}
Designer: Quinn (Test Architect)

## Test Strategy Overview

- Total test scenarios: X
- Unit tests: Y (A%)
- Integration tests: Z (B%)
- E2E tests: W (C%)
- Priority distribution: P0: X, P1: Y, P2: Z

## Test Scenarios by Acceptance Criteria

### AC1: {description}

#### Scenarios

| ID           | Level       | Priority | Test                      | Justification            |
| ------------ | ----------- | -------- | ------------------------- | ------------------------ |
| 1.3-UNIT-001 | Unit        | P0       | Validate input format     | Pure validation logic    |
| 1.3-INT-001  | Integration | P0       | Service processes request | Multi-component flow     |
| 1.3-E2E-001  | E2E         | P1       | User completes journey    | Critical path validation |

[Continue for all ACs...]

## Risk Coverage

[Map test scenarios to identified risks if risk profile exists]

## Recommended Execution Order

1. P0 Unit tests (fail fast)
2. P0 Integration tests
3. P0 E2E tests
4. P1 tests in order
5. P2+ as time permits
```

### Output 2: Gate YAML Block

Generate for inclusion in quality gate:

```yaml
test_design:
  scenarios_total: X
  by_level:
    unit: Y
    integration: Z
    e2e: W
  by_priority:
    p0: A
    p1: B
    p2: C
  coverage_gaps: [] # List any ACs without tests
```

### Output 3: Trace References

Print for use by trace-requirements task:

```text
Test design matrix: qa.qaLocation/assessments/{epic}.{story}-test-design-{YYYYMMDD}.md
P0 tests identified: {count}
```

## Quality Checklist

Before finalizing, verify:

- [ ] Every AC has test coverage
- [ ] Test levels are appropriate (not over-testing)
- [ ] No duplicate coverage across levels
- [ ] Priorities align with business risk
- [ ] Test IDs follow naming convention
- [ ] Scenarios are atomic and independent

## Key Principles

- **Shift left**: Prefer unit over integration, integration over E2E
- **Risk-based**: Focus on what could go wrong
- **Efficient coverage**: Test once at the right level
- **Maintainability**: Consider long-term test maintenance
- **Fast feedback**: Quick tests run first
