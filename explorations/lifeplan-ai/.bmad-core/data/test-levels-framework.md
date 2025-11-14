<!-- Powered by BMAD™ Core -->

# Test Levels Framework

Comprehensive guide for determining appropriate test levels (unit, integration, E2E) for different scenarios.

## Test Level Decision Matrix

### Unit Tests

**When to use:**

- Testing pure functions and business logic
- Algorithm correctness
- Input validation and data transformation
- Error handling in isolated components
- Complex calculations or state machines

**Characteristics:**

- Fast execution (immediate feedback)
- No external dependencies (DB, API, file system)
- Highly maintainable and stable
- Easy to debug failures

**Example scenarios:**

```yaml
unit_test:
  component: 'PriceCalculator'
  scenario: 'Calculate discount with multiple rules'
  justification: 'Complex business logic with multiple branches'
  mock_requirements: 'None - pure function'
```

### Integration Tests

**When to use:**

- Component interaction verification
- Database operations and transactions
- API endpoint contracts
- Service-to-service communication
- Middleware and interceptor behavior

**Characteristics:**

- Moderate execution time
- Tests component boundaries
- May use test databases or containers
- Validates system integration points

**Example scenarios:**

```yaml
integration_test:
  components: ['UserService', 'AuthRepository']
  scenario: 'Create user with role assignment'
  justification: 'Critical data flow between service and persistence'
  test_environment: 'In-memory database'
```

### End-to-End Tests

**When to use:**

- Critical user journeys
- Cross-system workflows
- Visual regression testing
- Compliance and regulatory requirements
- Final validation before release

**Characteristics:**

- Slower execution
- Tests complete workflows
- Requires full environment setup
- Most realistic but most brittle

**Example scenarios:**

```yaml
e2e_test:
  journey: 'Complete checkout process'
  scenario: 'User purchases with saved payment method'
  justification: 'Revenue-critical path requiring full validation'
  environment: 'Staging with test payment gateway'
```

## Test Level Selection Rules

### Favor Unit Tests When:

- Logic can be isolated
- No side effects involved
- Fast feedback needed
- High cyclomatic complexity

### Favor Integration Tests When:

- Testing persistence layer
- Validating service contracts
- Testing middleware/interceptors
- Component boundaries critical

### Favor E2E Tests When:

- User-facing critical paths
- Multi-system interactions
- Regulatory compliance scenarios
- Visual regression important

## Anti-patterns to Avoid

- E2E testing for business logic validation
- Unit testing framework behavior
- Integration testing third-party libraries
- Duplicate coverage across levels

## Duplicate Coverage Guard

**Before adding any test, check:**

1. Is this already tested at a lower level?
2. Can a unit test cover this instead of integration?
3. Can an integration test cover this instead of E2E?

**Coverage overlap is only acceptable when:**

- Testing different aspects (unit: logic, integration: interaction, e2e: user experience)
- Critical paths requiring defense in depth
- Regression prevention for previously broken functionality

## Test Naming Conventions

- Unit: `test_{component}_{scenario}`
- Integration: `test_{flow}_{interaction}`
- E2E: `test_{journey}_{outcome}`

## Test ID Format

`{EPIC}.{STORY}-{LEVEL}-{SEQ}`

Examples:

- `1.3-UNIT-001`
- `1.3-INT-002`
- `1.3-E2E-001`

---

## Framework Selection by Platform

### Web Applications (React, Next.js, Vue, etc.)

**Unit Tests**: Vitest (selective - complex logic with 10+ edge cases)
- Complex calculations (tax, pricing, scoring)
- Pure functions with multiple branches
- Business logic with many edge cases
- Location: `docs/qa/unit/sprint-N/epics/epic-N/story-N/`

**E2E Tests**: Playwright MCP (via 26 interactive browser control tools)
- ALL user journeys (login, checkout, registration, etc.)
- API endpoint testing via Playwright request context
- Visual validation via manual observation
- Location: Test scenarios in `docs/qa/e2e/sprint-N/epics/epic-N/story-N/` (markdown)

**Key Difference**:
- Dev writes test SCENARIOS (markdown), NOT test code files
- QA executes scenarios using Playwright MCP tools interactively
- Hybrid approach: Automated browser actions + Manual observation

### React Native Applications

**Unit Tests**: Vitest (selective - complex logic with 10+ edge cases)
- Same criteria as web applications
- Location: `docs/qa/unit/sprint-N/epics/epic-N/story-N/`

**E2E Tests**: Maestro (iOS + Android with single YAML)
- Mobile user journeys
- Cross-platform UI testing
- Native component interactions
- Added when mobile sprint begins (sprint-dependent MCP)

### Backend APIs (Node.js, Python, etc.)

**Unit Tests**: Vitest (Node.js) or pytest (Python) - selective
- Complex business logic functions
- Algorithm correctness
- Location: `docs/qa/unit/sprint-N/epics/epic-N/story-N/`

**API Tests**: Playwright request context OR Swagger MCP
- API endpoint contracts
- Request/response validation
- Integration with database

---

## MCP-Enhanced Testing Workflow

### Playwright MCP: 26 Interactive Browser Control Tools

**NOT**: Test code generation, automated `.spec.ts` files, `npx playwright test`

**IS**: Programmatic browser control for interactive testing by QA

**Tool Categories**:

1. **Navigation** (3 tools): browser_navigate, browser_navigate_back, browser_navigate_forward
2. **Inspection** (3 tools): browser_snapshot, browser_console_messages, browser_take_screenshot
3. **Interaction** (7 tools): browser_click, browser_type, browser_fill_form, browser_select_option, browser_hover, browser_drag, browser_press_key
4. **Utility** (5 tools): browser_wait_for, browser_resize, browser_evaluate, browser_handle_dialog, browser_file_upload
5. **Advanced** (3 tools): browser_network_requests, browser_close, browser_install
6. **Tab Management** (4 tools): browser_tab_list, browser_tab_new, browser_tab_select, browser_tab_close
7. **PDF & Code** (2 tools): browser_pdf_save, browser_generate_playwright_test

### Testing Workflow with MCPs

**Dev Workflow:**
1. Implements feature
2. IF complex logic (10+ edge cases) → Writes Vitest tests in `docs/qa/unit/`
3. Writes E2E test scenarios (markdown) in `docs/qa/e2e/`
   - Format: TC{AC}.{case} - organized by acceptance criteria
   - Content: Steps, expected results, priority
4. Starts background processes (frontend + backend)
5. Outputs QA Handoff
6. HALT (does NOT run tests)

**QA Workflow:**
1. Reads QA Handoff
2. IF Vitest exists → Runs `npm run test` FIRST, verifies passing
3. Reads E2E scenarios from markdown
4. Executes scenarios using Playwright MCP tools interactively:
   - browser_navigate → Go to page
   - browser_snapshot → Get page structure with element refs
   - browser_click, browser_type → Interact with elements
   - browser_console_messages → Check for JS errors
   - browser_take_screenshot → Capture evidence
   - browser_resize → Test responsive design
5. Observes results (visible browser), decides PASS/FAIL manually
6. IF gaps found → Can add more Vitest tests
7. Creates gate file
8. Outputs Developer Handoff (if issues) or Completion Handoff (if PASS)

### Benefits of Hybrid Approach

**Vitest Benefits:**
- Fast feedback (milliseconds for 100+ tests)
- Perfect for pure functions with many edge cases
- TDD workflow for complex logic
- No UI needed for logic testing

**Playwright MCP Benefits:**
- Real-world testing (visible browser)
- Human observation catches visual/UX issues
- No test code maintenance (just markdown scenarios)
- Flexible execution (QA adapts on the fly)
- Evidence collection (screenshots, console logs)
- Tests actual user experience

**When Each Makes Sense:**
- Vitest: Tax calculation with 50 edge cases (seconds to test all)
- Playwright MCP: Login flow (2 min to test via UI, but validates real UX)

### Context7 Integration for Testing

**Use Context7 MCP** for up-to-date testing patterns:

**Dev Usage:**
```
"use context7 - How do I test authentication in FastAPI?"
"use context7 - Show me the latest Vitest mocking patterns"
```

**QA Usage:**
```
"use context7 - What are the latest Playwright best practices for testing file uploads?"
"use context7 - How should I test responsive design with Playwright MCP?"
```

**Benefits:**
- Latest testing patterns (no deprecated methods)
- Current assertion libraries
- Modern test data management approaches

---

## Priority-Based Testing Coverage

### P0 (Must Test - >90% coverage)
- Revenue-critical features (checkout, payments)
- Security features (login, auth, permissions)
- Data integrity (CRUD operations)
- Legal/compliance requirements

### P1 (Should Test - >80% coverage)
- Core user journeys (signup, profile management)
- Frequent features (search, filters, navigation)
- Integration points (API contracts, third-party services)

### P2 (Nice to Test - >60% coverage)
- Secondary features (settings, preferences)
- Admin functionality (if not revenue-critical)
- Edge cases (unusual workflows)

### P3 (If Time) - Best Effort
- Rarely used features
- Nice-to-have functionality
- Future enhancements

---

## Summary: Hybrid Testing Philosophy

**This workflow uses:**
- ✅ Vitest for complex pure functions (10+ edge cases)
- ✅ Playwright MCP for E2E testing (interactive browser control)
- ✅ Maestro for React Native (when mobile sprint begins)
- ❌ NO Jest
- ❌ NO traditional `.spec.ts` files for E2E (scenarios in markdown instead)

**Key Insight**:
- Automated unit tests for speed (Vitest milliseconds)
- Interactive E2E tests for reality (Playwright MCP with human observation)
- Best of both worlds: Fast logic testing + Real user experience validation
