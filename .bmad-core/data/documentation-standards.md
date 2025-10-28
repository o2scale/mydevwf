# Documentation Standards

**Version**: 1.0
**Last Updated**: 2025-10-28
**Applies To**: All agents writing documentation (Dev, QA, SM, PM, Architect, PO)

---

## Overview

This document defines standards for all documentation created within the BMad workflow, ensuring consistency, traceability, and maintainability across all project artifacts.

---

## Timestamp Protocol

### CRITICAL RULE: ALL Documentation Updates MUST Include Timestamp

**When to Apply**:
- ✅ Story files (`docs/sprint-N/epics/epic-N/*.md`)
- ✅ Gate files (`docs/qa/gates/**/*-gate.md`)
- ✅ Test scenario files (`docs/qa/e2e/**/*.md`)
- ✅ Knowledge base entries (`docs/knowledge-base/**/*.md`)
- ✅ Planning documents (PRD, Architecture, Technical Preferences)
- ✅ Epic files
- ✅ Any progress logs, debug logs, or reports

### Required Command:

```bash
date '+%Y-%m-%d %H:%M:%S'
```

**Example Output**: `2025-10-28 15:45:23`

### Format in Files:

```markdown
**Last Updated:** 2025-10-28 15:45:23
**Updated By:** [Agent Name] ([Agent Type])
```

**Example**:
```markdown
**Last Updated:** 2025-10-28 15:45:23
**Updated By:** James (Dev Agent)
```

### Where to Place Timestamps:

#### In Story Files:
```markdown
## Dev Agent Record

**Last Updated:** 2025-10-28 15:45:23
**Updated By:** James (Dev Agent)

[Dev notes here...]

---

## QA Results

**Last Updated:** 2025-10-28 16:30:12
**Updated By:** Quinn (QA Agent)

[QA results here...]
```

#### In Gate Files:
```markdown
# QA Gate Decision: Story 1.1.3

**Gate Decision**: PASS
**Timestamp:** 2025-10-28 16:30:12
**QA Agent:** Quinn

[Gate details...]
```

#### In Knowledge Base Entries:
```markdown
# S3 Storage Integration

**Last Updated:** 2025-10-28 15:45:23
**Updated By:** James (Dev Agent)
**Sprint/Story:** Sprint-1 / Epic-1 / Story-3

[Knowledge base content...]
```

### Enforcement:

This rule takes **precedence over efficiency concerns**. Even for minor updates, ALWAYS include timestamps.

**Why**: Timestamps enable:
- Traceability of who updated what and when
- Debugging workflow issues
- Understanding context evolution
- Audit trails for critical decisions

---

## File Naming Conventions

### Story Files:
```
docs/sprint-N/epics/epic-N/story-N.md
```

**Example**: `docs/sprint-1/epics/epic-1/story-3.md`

**Format**:
- Sprint number: `sprint-1`, `sprint-2`, etc.
- Epic number: `epic-1`, `epic-2`, etc. (within sprint)
- Story number: `story-1`, `story-2`, etc. (within epic)

### Test Scenario Files:
```
docs/qa/e2e/sprint-N/epics/epic-N/story-N/scenario-{description}.md
```

**Example**: `docs/qa/e2e/sprint-1/epics/epic-1/story-3/scenario-login.md`

**Format**:
- Use kebab-case for descriptions
- Be specific: `scenario-login.md`, `scenario-validation.md`, `scenario-edge-cases.md`

### Vitest Unit Test Files:
```
docs/qa/unit/sprint-N/epics/epic-N/story-N/{module}.test.ts
```

**Example**: `docs/qa/unit/sprint-1/epics/epic-1/story-3/calculateTax.test.ts`

**Format**:
- Match function/module name
- Use camelCase for module names
- Always end with `.test.ts`

### Gate Files:
```
docs/qa/gates/sprint-N/epics/epic-N/story-N-gate.md
```

**Example**: `docs/qa/gates/sprint-1/epics/epic-1/story-3-gate.md`

**Format**:
- Follows story numbering
- Always ends with `-gate.md`

### Evidence Files:
```
docs/qa/evidence/sprint-N/epics/epic-N/story-N/tc{AC}.{case}-{description}.png
```

**Example**: `docs/qa/evidence/sprint-1/epics/epic-1/story-3/tc1.1-before-login.png`

**Format**:
- `tc{AC}.{case}`: Test case identifier (e.g., `tc1.1`, `tc2.3`)
- Description: Brief state description (e.g., `before-login`, `error-state`)
- Extensions: `.png`, `.jpg`, `.log`, `.json`

### Knowledge Base Files:
```
docs/knowledge-base/{category}/{pattern-name}.md
```

**Categories**:
- `integrations/` - Third-party services (S3, Stripe, Auth0)
- `ui-patterns/` - Frontend patterns (forms, tables, modals)
- `backend-patterns/` - Backend patterns (error handling, transactions)
- `common-issues/` - Recurring bugs and fixes

**Example**: `docs/knowledge-base/integrations/s3-storage.md`

---

## Folder Structure Standards

### Complete Hierarchy:

```
docs/
├── prd.md                              # Planning docs (root level)
├── architecture.md
├── technical-preferences.md
├── sprint-1/                           # Sprint folders
│   └── epics/
│       ├── epic-1/
│       │   ├── story-1.md              # Story files (not folders)
│       │   ├── story-2.md
│       │   └── story-3.md
│       └── epic-2/
│           ├── story-1.md
│           └── story-2.md
├── sprint-2/
│   └── epics/...
├── knowledge-base/                     # Patterns and lessons learned
│   ├── integrations/
│   ├── ui-patterns/
│   ├── backend-patterns/
│   └── common-issues/
└── qa/                                 # ALL QA artifacts together
    ├── unit/                           # Vitest unit tests
    │   └── sprint-1/
    │       └── epics/
    │           ├── epic-1/
    │           │   ├── story-1/        # Story folder (multiple test files)
    │           │   │   ├── calculateTax.test.ts
    │           │   │   └── validateEmail.test.ts
    │           │   └── story-2/
    │           │       └── processCheckout.test.ts
    │           └── epic-2/
    │               └── story-1/
    │                   └── updateProfile.test.ts
    ├── e2e/                            # E2E test scenarios
    │   └── sprint-1/
    │       └── epics/
    │           ├── epic-1/
    │           │   ├── story-1/        # Story folder (multiple scenarios)
    │           │   │   ├── scenario-login.md
    │           │   │   ├── scenario-validation.md
    │           │   │   └── scenario-edge-cases.md
    │           │   └── story-2/
    │           │       └── scenario-checkout.md
    │           └── epic-2/
    │               └── story-1/
    │                   └── scenario-profile.md
    ├── evidence/                       # Screenshots, logs
    │   └── sprint-1/
    │       └── epics/
    │           └── epic-1/
    │               └── story-1/        # Story folder (multiple screenshots)
    │                   ├── tc1.1-before-login.png
    │                   ├── tc1.1-after-login.png
    │                   └── tc1.2-error-state.png
    └── gates/                          # PASS/FAIL/CONCERNS decisions
        └── sprint-1/
            └── epics/
                └── epic-1/
                    └── story-1-gate.md
```

### Key Structural Rules:

1. **Planning documents**: Root level in `docs/` (span multiple sprints)
2. **Story files**: Direct `.md` files (not folders)
3. **Test files**: Stories become folders (can contain multiple test files/scenarios)
4. **QA artifacts**: All under `docs/qa/` (unit, e2e, evidence, gates)
5. **No archiving**: All sprints at same level (no `archive/` folder)

---

## Markdown Standards

### Headings:

```markdown
# H1 - Document Title (only one per file)

## H2 - Major Sections

### H3 - Subsections

#### H4 - Details (use sparingly)
```

### Code Blocks:

Always specify language:
```markdown
```typescript
// Good - language specified
const foo = 'bar';
```

```bash
# Good - shell commands
npm install
```

```
# Bad - no language specified
```
```

### Lists:

**Unordered**:
```markdown
- Item 1
- Item 2
  - Nested item
```

**Ordered**:
```markdown
1. First step
2. Second step
3. Third step
```

**Task Lists** (for checklists):
```markdown
- [ ] Incomplete task
- [x] Completed task
```

### Tables:

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data 1   | Data 2   | Data 3   |
```

### Links:

```markdown
[Link text](relative/path/to/file.md)
[External link](https://example.com)
```

### Emphasis:

```markdown
**Bold** for emphasis
*Italic* for subtle emphasis
`code` for inline code
```

---

## Story File Template

```markdown
# Story {sprint}.{epic}.{story}: {Title}

**Epic**: {Epic Name}
**Sprint**: {Sprint Number}
**Priority**: P0 / P1 / P2 / P3
**Status**: Draft / Ready / In Progress / QA Review / Complete

---

## Overview

Brief description of what this story accomplishes.

---

## Acceptance Criteria

### AC1: {Description}
**Given** [context]
**When** [action]
**Then** [expected outcome]

### AC2: {Description}
**Given** [context]
**When** [action]
**Then** [expected outcome]

---

## Technical Notes

- Implementation details
- API endpoints
- Database changes
- Dependencies

---

## Dev Agent Record

**Last Updated:** {timestamp}
**Updated By:** James (Dev Agent)

### Implementation Summary
- [x] Backend API endpoints
- [x] Frontend components
- [x] Vitest unit tests (if applicable)
- [x] E2E test scenarios
- [x] QA Handoff generated

### Vitest Tests Created
- `docs/qa/unit/sprint-N/epics/epic-N/story-N/module.test.ts` (if applicable)

### Test Scenarios Created
- `docs/qa/e2e/sprint-N/epics/epic-N/story-N/scenario-{description}.md`

### Background Processes
- Frontend: http://localhost:3000
- Backend: http://localhost:5001

### Notes
[Any implementation notes, gotchas, or decisions]

---

## QA Results

**Last Updated:** {timestamp}
**Updated By:** Quinn (QA Agent)

### Test Execution Summary
- Vitest: [X/Y tests passed] (if applicable)
- E2E: [X/Y test cases passed]

### Issues Found
[List issues or "None - all tests passed"]

### Gate Decision
See: `docs/qa/gates/sprint-N/epics/epic-N/story-N-gate.md`

---

## Completion

**Completed**: {timestamp}
**Committed**: {git commit hash}
```

---

## Gate File Template

```markdown
# QA Gate Decision: Story {sprint}.{epic}.{story}

**Gate Decision**: PASS / CONCERNS / FAIL / WAIVED
**Timestamp:** {timestamp}
**QA Agent:** Quinn

---

## Story Details

**Story**: {Sprint}.{Epic}.{Story} - {Title}
**Story Path**: `docs/sprint-N/epics/epic-N/story-N.md`
**Priority**: P0 / P1 / P2 / P3

---

## Test Results Summary

### Vitest Unit Tests (if applicable)
- **Status**: PASS / FAIL
- **Tests Run**: X
- **Tests Passed**: Y
- **Tests Failed**: Z
- **Location**: `docs/qa/unit/sprint-N/epics/epic-N/story-N/`

### E2E Test Scenarios (Playwright MCP)
- **Status**: PASS / FAIL
- **Total Test Cases**: X
- **Passed**: Y
- **Failed**: Z
- **Scenarios**: `docs/qa/e2e/sprint-N/epics/epic-N/story-N/`

---

## Issues Found

### Issue 1: {Title}
- **Test Case**: TC{AC}.{case}
- **Severity**: Critical / High / Medium / Low
- **Description**: [What went wrong]
- **Evidence**: `docs/qa/evidence/sprint-N/epics/epic-N/story-N/tc{AC}.{case}-{description}.png`
- **Expected**: [What should happen]
- **Actual**: [What actually happened]

[Repeat for each issue]

---

## Gate Decision Rationale

[Explanation of why PASS/CONCERNS/FAIL/WAIVED was chosen]

---

## Next Steps

- [ ] {Action items based on gate decision}

---

## Evidence

**Evidence Location**: `docs/qa/evidence/sprint-N/epics/epic-N/story-N/`

**Files**:
- tc1.1-before-login.png
- tc1.1-after-login.png
- console-logs.txt
[List all evidence files]
```

---

## Knowledge Base Entry Template

```markdown
# {Pattern/Integration Name}

**Last Updated:** {timestamp}
**Updated By:** {Agent Name} ({Agent Type})
**Sprint/Story**: Sprint-{N} / Epic-{N} / Story-{N}

---

## Overview

Brief description of the pattern/integration and when to use it.

---

## Reference Implementation

**File**: `{path/to/reference/file.ts}`
**Story**: `docs/sprint-N/epics/epic-N/story-N.md`

---

## Pattern

```{language}
// Code example showing the correct pattern
```

---

## Common Mistakes

❌ **DON'T**: {Description of mistake}
❌ **DON'T**: {Description of another mistake}

✅ **DO**: {Correct approach}

---

## Gotchas

- **{Gotcha 1}**: {Description and solution}
- **{Gotcha 2}**: {Description and solution}

---

## When to Use

- {Use case 1}
- {Use case 2}

---

## When NOT to Use

- {Anti-pattern 1}
- {Anti-pattern 2}

---

## Related Patterns

- See: `{related-pattern-1.md}`
- See: `{related-pattern-2.md}`
```

---

## Enforcement

All agents MUST follow these standards. Non-compliant documentation will be flagged during QA review.

**Priority**: These standards are **CRITICAL** and take precedence over efficiency concerns.
