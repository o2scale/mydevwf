<!-- Powered by BMAD™ Core -->

# review-story

Perform a comprehensive test architecture review with quality gate decision. This adaptive, risk-aware review creates both a story update and a detailed gate file.

## Inputs

```yaml
required:
  - story_id: '{epic}.{story}' # e.g., "1.3"
  - story_path: '{devStoryLocation}/{epic}.{story}.*.md' # Path from core-config.yaml
  - story_title: '{title}' # If missing, derive from story file H1
  - story_slug: '{slug}' # If missing, derive from title (lowercase, hyphenated)
```

## Prerequisites

- Story status must be "Review"
- Developer has completed all tasks and updated the File List
- All automated tests are passing

## Review Process - Adaptive Test Architecture

### 1. Risk Assessment (Determines Review Depth)

**Auto-escalate to deep review when:**

- Auth/payment/security files touched
- No tests added to story
- Diff > 500 lines
- Previous gate was FAIL/CONCERNS
- Story has > 5 acceptance criteria

### 2. Comprehensive Analysis

**A. Requirements Traceability**

- Map each acceptance criteria to its validating tests (document mapping with Given-When-Then, not test code)
- Identify coverage gaps
- Verify all requirements have corresponding test cases

**B. Code Quality Review**

- Architecture and design patterns
- Refactoring opportunities (and perform them)
- Code duplication or inefficiencies
- Performance optimizations
- Security vulnerabilities
- Best practices adherence

**C. Test Architecture Assessment**

- Test coverage adequacy at appropriate levels
- Test level appropriateness (what should be unit vs integration vs e2e)
- Test design quality and maintainability
- Test data management strategy
- Mock/stub usage appropriateness
- Edge case and error scenario coverage
- Test execution time and reliability

**D. Non-Functional Requirements (NFRs)**

- Security: Authentication, authorization, data protection
- Performance: Response times, resource usage
- Reliability: Error handling, recovery mechanisms
- Maintainability: Code clarity, documentation

**E. Testability Evaluation**

- Controllability: Can we control the inputs?
- Observability: Can we observe the outputs?
- Debuggability: Can we debug failures easily?

**F. Technical Debt Identification**

- Accumulated shortcuts
- Missing tests
- Outdated dependencies
- Architecture violations

**G. Knowledge Base Validation**

- Check if story implemented any KB triggers per story-dod-checklist.md section 10:
  - Third-party integration (Stripe, S3, Supabase, Vertex AI, SendGrid, etc.)
  - Reusable pattern (pagination, auth, error handling, batch processing, middleware, etc.)
  - Complex/non-obvious solution (race conditions, performance optimization, data integrity, etc.)
  - Dev Notes explicit KB documentation request
- IF KB trigger matched AND KB entry exists:
  - Read KB entry from docs/knowledge-base/
  - Verify KB entry is complete (not TODOs/placeholders)
  - Verify KB entry has actual implementation code from THIS story
  - Verify KB entry includes all required sections (Overview, Pattern, Common Mistakes, Configuration, When to Use/Not Use)
  - Verify docs/knowledge-base/README.md catalog updated with entry
  - IF incomplete: Flag as CONCERN in quality gate ("KB entry incomplete - missing [sections]")
- IF KB trigger matched BUT NO KB entry exists:
  - Flag as CONCERN in quality gate ("Story should have created KB entry for [integration/pattern/solution] - missing documentation")
  - Note this in Developer Handoff (if gate is not PASS)

**H. Navigation Integration Verification**

CRITICAL: This check is MANDATORY for stories that create/modify user-facing pages. Navigation gaps make features unreachable.

- Read story Navigation Notes section
  - IF Navigation Notes missing for user-facing story: Flag as BLOCKING FAIL ("Story lacks Navigation Notes - navigation design missing")
  - IF Navigation Notes say "N/A - Backend only": Verify story truly has zero UI changes (no new pages, no UI modifications)
- IF Navigation Notes populated, verify navigation design completeness:
  - Menu items specified (which menu, label, position)
  - Breadcrumbs specified (page hierarchy)
  - User journey documented (entry points from existing screens)
  - Contextual links identified (related pages that should link to feature)
- Use Playwright MCP to verify navigation implementation (INDEPENDENT verification, don't trust Dev checklist):
  - browser_navigate to dashboard or main landing page
  - browser_snapshot to get page structure with element references
  - Verify menu item exists per Navigation Notes (search snapshot for menu label)
  - browser_click menu item reference → verify navigates to new feature (check URL, page title)
  - Check breadcrumbs present and functional (click breadcrumb links)
  - Test minimum 2 entry points from Navigation Notes (different paths to reach feature)
  - If story specifies contextual links: Navigate to related page, verify link exists, click to test
- Navigation verification results:
  - IF all navigation elements implemented correctly: PASS navigation check
  - IF menu items missing: Flag as FAIL ("Feature unreachable - missing menu items: [list specific items from Navigation Notes]")
  - IF breadcrumbs missing/incorrect: Flag as CONCERN ("Breadcrumbs missing or incorrect - expected: [hierarchy from Navigation Notes]")
  - IF contextual links missing: Flag as CONCERN ("Missing contextual links from: [list pages from Navigation Notes]")
  - IF only accessible via direct URL (no menu entry): Flag as FAIL ("Feature has no navigation entry point - users cannot discover feature")
- Document navigation gaps in Developer Handoff with specific details:
  - Which menu items are missing (exact label, expected location)
  - Which entry points don't work (expected path vs actual)
  - Screenshots showing navigation gaps (use browser_screenshot)

### 3. Active Refactoring

- Refactor code where safe and appropriate
- Run tests to ensure changes don't break functionality
- Document all changes in QA Results section with clear WHY and HOW
- Do NOT alter story content beyond QA Results section
- Do NOT change story Status or File List; recommend next status only

### 4. Testing Execution (CRITICAL - Follow This Order)

**MANDATORY RUNTIME TESTING**: NEVER mark PASS without actual test execution. Code review does NOT replace testing. If tests cannot run due to environment issues, DIAGNOSE the issue, CREATE Developer Handoff with detailed findings, and HALT testing. QA diagnoses environment issues, Dev fixes them.

**STRICT GATE DECISION**: Both Vitest AND E2E must pass for PASS gate. NO exceptions for "code looks good" or "E2E covers Vitest failures". If ANY test fails, gate = FAIL or CONCERNS (never PASS).

**STEP 1: Run Vitest Tests (if they exist)**
- Check if Vitest tests exist in `docs/qa/unit/sprint-N/epics/epic-N/story-N/`
- IF tests exist:
  - Run `npm run test` (or `npm run test:unit`) FIRST
  - Verify all tests pass
  - IF failures: Document in QA Results section, create Developer Handoff, HALT review
  - IF pass: Proceed to E2E execution

**STEP 2: Execute E2E Test Scenarios via Playwright MCP**
- Read test scenarios from `docs/qa/e2e/sprint-N/epics/epic-N/story-N/`
- Verify background processes running (http://localhost:3000, backend port, etc.)
- For each test case (TC{AC}.{case}):
  1. Use `browser_navigate(url)` to navigate to starting page
  2. Use `browser_snapshot()` to get page structure with element refs
  3. Use interaction tools for actions:
     - `browser_click(element, ref)` - Click buttons/links
     - `browser_type(element, ref, text)` - Type into inputs
     - `browser_fill_form(fields)` - Fill multiple form fields at once
     - `browser_select_option(element, ref, value)` - Select dropdowns
  4. Use `browser_console_messages()` to check for JavaScript errors after each interaction
  5. Use `playwright_screenshot(name, downloadsDir, savePng)` to capture visual evidence
     - CRITICAL: Set `downloadsDir: "docs/qa/evidence/sprint-{N}/epics/epic-{epic}/story-{story}/"` (project folder, NOT user's Downloads)
     - Set `savePng: true` to save file to disk
  6. Use `browser_wait_for(condition, timeout)` if needed for async operations
  7. **Manually observe**: Does the behavior match expected outcome?
  8. Record PASS/FAIL decision for each test case

**STEP 3: Evidence Collection**
- CRITICAL: Use `downloadsDir` parameter for ALL screenshots to save to project folder
  - Example: `playwright_screenshot({ name: 'tc1.1-login-success.png', downloadsDir: 'docs/qa/evidence/sprint-N/epics/epic-N/story-N/', savePng: true })`
  - DO NOT use default (saves to user's Downloads folder)
- Naming convention: `tc{AC}.{case}-{description}.png` (e.g., `tc1.1-login-success.png`)
- Capture console logs if any errors found (save to `console-logs.txt`)
- Document any deviations from expected behavior in notes
- Verify screenshots saved to correct project folder, NOT user's Downloads folder

**STEP 4: Gap Analysis (Optional)**
- IF logic gaps found during E2E testing:
  - QA CAN add Vitest tests in `docs/qa/unit/` to fill gaps
  - Document added tests in QA Results section
  - Explain why gap existed and what was added

[Source: .bmad-core/data/testing-stack-guide.md#phase-2-qa-testing-execution]

### 5. Standards Compliance Check

- Verify adherence to `docs/coding-standards.md`
- Check compliance with `docs/unified-project-structure.md`
- Validate testing approach against `.bmad-core/data/testing-stack-guide.md`
- Ensure all guidelines mentioned in the story are followed

### 5. Acceptance Criteria Validation

- Verify each AC is fully implemented
- Check for any missing functionality
- Validate edge cases are handled

### 6. Documentation and Comments

- Verify code is self-documenting where possible
- Add comments for complex logic if missing
- Ensure any API changes are documented

## Output 1: Update Story File - QA Results Section ONLY

**CRITICAL**: You are ONLY authorized to update the "QA Results" section of the story file. DO NOT modify any other sections.

**QA Results Anchor Rule:**

- If `## QA Results` doesn't exist, append it at end of file
- If it exists, append a new dated entry below existing entries
- Never edit other sections

After review and any refactoring, append your results to the story file in the QA Results section:

```markdown
## QA Results

### Review Date: [Date]

### Reviewed By: Quinn (Test Architect)

### Code Quality Assessment

[Overall assessment of implementation quality]

### Refactoring Performed

[List any refactoring you performed with explanations]

- **File**: [filename]
  - **Change**: [what was changed]
  - **Why**: [reason for change]
  - **How**: [how it improves the code]

### Compliance Check

- Coding Standards: [✓/✗] [notes if any]
- Project Structure: [✓/✗] [notes if any]
- Testing Strategy: [✓/✗] [notes if any]
- All ACs Met: [✓/✗] [notes if any]

### Improvements Checklist

[Check off items you handled yourself, leave unchecked for dev to address]

- [x] Refactored user service for better error handling (services/user.service.ts)
- [x] Added missing edge case tests (services/user.service.test.ts)
- [ ] Consider extracting validation logic to separate validator class
- [ ] Add integration test for error scenarios
- [ ] Update API documentation for new error codes

### Security Review

[Any security concerns found and whether addressed]

### Performance Considerations

[Any performance issues found and whether addressed]

### Files Modified During Review

[If you modified files, list them here - ask Dev to update File List]

### Gate Status

Gate: {STATUS} → qa.qaLocation/gates/sprint-{sprint}/epics/epic-{epic}/{epic}.{story}-{slug}.yml
Risk profile: qa.qaLocation/assessments/{epic}.{story}-risk-{YYYYMMDD}.md
NFR assessment: qa.qaLocation/assessments/{epic}.{story}-nfr-{YYYYMMDD}.md

# Note: Paths should reference core-config.yaml for custom configurations

### Recommended Status

[✓ Ready for Done] / [✗ Changes Required - See unchecked items above]
(Story owner decides final status)
```

## Output 2: Create Quality Gate File

**Template and Directory:**

- Render from `../templates/qa-gate-tmpl.yaml`
- Create directory defined in `qa.qaLocation/gates` (see `.bmad-core/core-config.yaml`) if missing
- Save to: `qa.qaLocation/gates/sprint-{sprint}/epics/epic-{epic}/{epic}.{story}-{slug}.yml`

Gate file structure:

```yaml
schema: 1
story: '{epic}.{story}'
story_title: '{story title}'
gate: PASS|CONCERNS|FAIL|WAIVED
status_reason: '1-2 sentence explanation of gate decision'
reviewer: 'Quinn (Test Architect)'
updated: '{ISO-8601 timestamp}'

top_issues: [] # Empty if no issues
waiver: { active: false } # Set active: true only if WAIVED

# Extended fields (optional but recommended):
quality_score: 0-100 # 100 - (20*FAILs) - (10*CONCERNS) or use technical-preferences.md weights
expires: '{ISO-8601 timestamp}' # Typically 2 weeks from review

evidence:
  tests_reviewed: { count }
  risks_identified: { count }
  trace:
    ac_covered: [1, 2, 3] # AC numbers with test coverage
    ac_gaps: [4] # AC numbers lacking coverage

nfr_validation:
  security:
    status: PASS|CONCERNS|FAIL
    notes: 'Specific findings'
  performance:
    status: PASS|CONCERNS|FAIL
    notes: 'Specific findings'
  reliability:
    status: PASS|CONCERNS|FAIL
    notes: 'Specific findings'
  maintainability:
    status: PASS|CONCERNS|FAIL
    notes: 'Specific findings'

recommendations:
  immediate: # Must fix before production
    - action: 'Add rate limiting'
      refs: ['api/auth/login.ts']
  future: # Can be addressed later
    - action: 'Consider caching'
      refs: ['services/data.ts']
```

### Gate Decision Criteria

**Deterministic rule (apply in order):**

If risk_summary exists, apply its thresholds first (≥9 → FAIL, ≥6 → CONCERNS), then NFR statuses, then top_issues severity.

1. **Risk thresholds (if risk_summary present):**
   - If any risk score ≥ 9 → Gate = FAIL (unless waived)
   - Else if any score ≥ 6 → Gate = CONCERNS

2. **Test coverage gaps (if trace available):**
   - If any P0 test from test-design is missing → Gate = CONCERNS
   - If security/data-loss P0 test missing → Gate = FAIL

3. **Issue severity:**
   - If any `top_issues.severity == high` → Gate = FAIL (unless waived)
   - Else if any `severity == medium` → Gate = CONCERNS

4. **NFR statuses:**
   - If any NFR status is FAIL → Gate = FAIL
   - Else if any NFR status is CONCERNS → Gate = CONCERNS
   - Else → Gate = PASS

- WAIVED only when waiver.active: true with reason/approver

Detailed criteria:

- **PASS**: All critical requirements met, no blocking issues
- **CONCERNS**: Non-critical issues found, team should review
- **FAIL**: Critical issues that should be addressed
- **WAIVED**: Issues acknowledged but explicitly waived by team

### Quality Score Calculation

```text
quality_score = 100 - (20 × number of FAILs) - (10 × number of CONCERNS)
Bounded between 0 and 100
```

If `technical-preferences.md` defines custom weights, use those instead.

### Suggested Owner Convention

For each issue in `top_issues`, include a `suggested_owner`:

- `dev`: Code changes needed
- `sm`: Requirements clarification needed
- `po`: Business decision needed

## Key Principles

- You are a Test Architect providing comprehensive quality assessment
- You have the authority to improve code directly when appropriate
- Always explain your changes for learning purposes
- Balance between perfection and pragmatism
- Focus on risk-based prioritization
- Provide actionable recommendations with clear ownership

## Blocking Conditions

Stop the review and create Developer Handoff if:

- Story file is incomplete or missing critical sections
- File List is empty or clearly incomplete
- No tests exist when they were required
- Code changes don't align with story requirements
- Critical architectural issues that require discussion

**Environment Issues (QA Diagnoses, Dev Fixes)**:

Stop testing and create Developer Handoff if:

- **Background processes not running**: Cannot access frontend (localhost:3000) or backend (specified port)
  - Diagnose: Which process? What port? What error message?
  - Document: Expected URL, actual error, screenshot of "connection refused"
  - Handoff to Dev: "Environment Issue - Backend not running on port 3001"

- **Logs not accessible**: Cannot find logs specified in Dev's QA Handoff
  - Diagnose: Where did Dev say logs are? What's actually at that location?
  - Document: Expected path, actual directory contents, error accessing logs
  - Handoff to Dev: "Environment Issue - Cannot access logs at specified path"

- **Playwright MCP errors**: MCP tools fail (browser_navigate timeout, browser_click element not found, etc.)
  - Diagnose: Which tool failed? What error? Is it environment or code issue?
  - Document: Exact MCP command attempted, error message, screenshot
  - Determine: Is this Dev's code bug or environment setup issue?
  - If environment: Handoff to Dev with diagnosis
  - If code bug: Continue testing, document in gate as test failure

- **Vitest won't run**: `npm run test` fails with errors
  - Diagnose: What error? Import issues? Config issues? Missing dependencies?
  - Document: Exact command run, full error output, environment details
  - Handoff to Dev: "Environment Issue - Vitest execution failed"

**CRITICAL**: QA's job is to DIAGNOSE and DOCUMENT environment issues, then CREATE Developer Handoff and HALT testing. Dev's job is to FIX environment issues. QA does NOT attempt to fix environment setup, start processes, or debug Dev's configuration.

## Completion

After review:

1. Update the QA Results section in the story file
2. Create the gate file in directory from `qa.qaLocation/gates`
3. Recommend status: "Ready for Done" or "Changes Required" (owner decides)
4. If files were modified, list them in QA Results and ask Dev to update File List
5. Always provide constructive feedback and actionable recommendations
