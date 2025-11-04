# Task Integration Analysis - Workflow Updates

**Date**: 2025-10-28 20:25:00
**Analyzer**: Claude Code

---

## Executive Summary

**ISSUE IDENTIFIED**: While agent persona files and data files have been updated with the new testing workflow (Playwright MCP, Vitest, Context7), the **executable task files** that agents actually run have NOT been fully updated.

**IMPACT**:
- Agents will reference correct personas and data, BUT
- Task execution instructions don't explicitly mention new tooling
- Tasks reference non-existent files ("testing-strategy.md" doesn't exist)
- Tasks don't guide agents through Playwright MCP workflow explicitly

---

## Data Files Status (✅ Good)

### ✅ testing-stack-guide.md
**Status**: COMPREHENSIVE & UP TO DATE (Oct 28 15:30)
**Contains**:
- Hybrid Vitest + Playwright MCP philosophy
- All 26 Playwright MCP tools documented
- Complete Dev/QA workflow
- Handoff templates (QA Handoff, Developer Handoff, Completion Handoff)
- Context7 integration examples
- Background process management
- Evidence collection guidelines
- Vitest configuration

### ✅ test-levels-framework.md
**Status**: UPDATED TODAY (Oct 28 20:20)
**Contains**:
- Framework selection by platform (Web, React Native, Backend)
- MCP-Enhanced Testing Workflow section
- All 26 Playwright MCP tools in 7 categories
- Dev/QA workflow descriptions
- Context7 integration for testing
- Priority-based coverage matrix
- Hybrid testing philosophy

### ✅ test-priorities-matrix.md
**Status**: Framework-agnostic (Oct 28 12:21)
**Contains**:
- P0/P1/P2/P3 priority definitions
- Risk-based adjustments
- Coverage requirements by priority
- Priority decision tree

**Assessment**: This file is fine as-is (framework-agnostic by design)

---

## Task Files Status (❌ Needs Updates)

### ❌ create-next-story.md
**Used By**: Dev agent (creates story files)
**Current Issues**:
1. **Line 49**: References "testing-strategy.md" from architecture
2. **Line 98**: Says "Include unit testing as explicit subtasks" but doesn't specify Vitest or the 10+ edge cases rule
3. **No mention of**:
   - Writing E2E test SCENARIOS in markdown (not test code)
   - Using Vitest only for complex logic (10+ edge cases)
   - Test scenario format (TC{AC}.{case})
   - Context7 usage for testing patterns

**What Needs Adding**:
```markdown
### Testing Requirements (in Dev Notes section)

**Unit Tests (Vitest)**:
- Required ONLY if complex logic with 10+ edge cases
- Location: `docs/qa/unit/sprint-N/epics/epic-N/story-N/`
- Examples: Tax calculations, complex validations, algorithms
- [Source: .bmad-core/data/testing-stack-guide.md]

**E2E Test Scenarios**:
- Required for ALL user journeys (login, checkout, forms, etc.)
- Format: Markdown test scenarios, NOT test code files
- Location: `docs/qa/e2e/sprint-N/epics/epic-N/story-N/`
- Organize by acceptance criteria: TC{AC}.{case}
- Include: Steps, Expected behavior, Priority (P0/P1/P2/P3)
- [Source: .bmad-core/data/testing-stack-guide.md]

**Context7 Usage**:
- Add "use context7" to prompts for latest testing patterns
- Get current Vitest/Playwright best practices
```

**Missing Reference Fix**:
- Change "testing-strategy.md" → "testing-stack-guide.md"

### ❌ review-story.md
**Used By**: QA agent (reviews stories and creates gate files)
**Current Issues**:
1. **Line 94**: References "docs/testing-strategy.md" (DOESN'T EXIST)
2. **No explicit mention of**:
   - Running Vitest FIRST via `npm run test`
   - Executing E2E via Playwright MCP tools
   - Evidence collection requirements
   - Handoff format specifics

**What Needs Adding**:
```markdown
### Testing Execution Order (in Review Process section)

**CRITICAL**: Follow this sequence:

1. **IF Vitest tests exist in docs/qa/unit/**:
   - Run `npm run test` FIRST
   - Verify all tests pass
   - IF failures: Document in Developer Handoff, HALT review

2. **Execute E2E test scenarios**:
   - Read scenarios from `docs/qa/e2e/sprint-N/epics/epic-N/story-N/`
   - Verify background processes running (http://localhost:3000, etc.)
   - For each test case:
     a. Use `browser_navigate()` to start
     b. Use `browser_snapshot()` to get page structure with element refs
     c. Use interaction tools (`browser_click`, `browser_type`, `browser_fill_form`)
     d. Use `browser_console_messages()` to check for JS errors
     e. Use `browser_take_screenshot()` to capture evidence
     f. Manually observe: Does behavior match expected?

3. **Evidence Collection**:
   - Save all screenshots to `docs/qa/evidence/sprint-N/epics/epic-N/story-N/`
   - Capture console logs for any errors
   - Document any deviations from expected behavior

4. **IF logic gaps found during E2E**:
   - Can add Vitest tests in `docs/qa/unit/` to fill gaps
   - Document added tests in QA Results section

[Source: .bmad-core/data/testing-stack-guide.md]
```

**Missing Reference Fix**:
- Change "docs/testing-strategy.md" → ".bmad-core/data/testing-stack-guide.md"

### ❌ test-design.md
**Used By**: QA agent (designs test scenarios)
**Current Status**: Better than others
**Issues**:
1. References "test-levels-framework.md" ✅ (CORRECT - we updated this!)
2. References "test-priorities-matrix.md" ✅ (CORRECT)
3. BUT doesn't explicitly mention:
   - Vitest vs Playwright MCP tooling selection
   - Test scenario format (markdown, not code)
   - The 10+ edge cases rule for Vitest

**What Needs Adding**:
```markdown
### Test Tooling Selection (add after section 2)

**Unit Tests (Vitest)**:
- Use for: Pure functions, algorithms, complex logic with 10+ edge cases
- Location: `docs/qa/unit/sprint-N/epics/epic-N/story-N/`
- Format: `.test.ts` or `.test.tsx` files
- Execution: `npm run test`

**E2E Tests (Playwright MCP)**:
- Use for: All user journeys, UI interactions, workflows
- Location: `docs/qa/e2e/sprint-N/epics/epic-N/story-N/`
- Format: Markdown test scenarios (NOT `.spec.ts` files)
- Execution: QA uses 26 Playwright MCP tools interactively
- Tools: browser_navigate, browser_snapshot, browser_click, browser_type, etc.

[Source: .bmad-core/data/test-levels-framework.md, testing-stack-guide.md]
```

---

## Other Tasks to Check

### 📋 Potentially Affected Tasks:

1. **apply-qa-fixes.md** - Does it reference old testing patterns?
2. **nfr-assess.md** - Does it mention testing tools?
3. **qa-gate.md** - Does it reference test execution?
4. **risk-profile.md** - Does it consider test tooling?
5. **trace-requirements.md** - Does it map to Vitest/Playwright MCP?

Need to review these files as well.

---

## Architecture File References

### Potential Issue: Architecture templates may reference old patterns

Tasks reference architecture files for testing strategy:
- `docs/architecture/testing-strategy.md` (referenced but may not exist)

**Action Needed**: Check if architecture templates need updating:
- `.bmad-core/templates/fullstack-architecture-tmpl.yaml`
- `.bmad-core/templates/architecture-tmpl.yaml`
- `.bmad-core/templates/front-end-architecture-tmpl.yaml`
- `.bmad-core/templates/brownfield-architecture-tmpl.yaml`

---

## Recommended Fix Priority

### 🔥 HIGH PRIORITY (Do First)

1. **Fix create-next-story.md**
   - Update reference: "testing-strategy.md" → "testing-stack-guide.md"
   - Add explicit testing requirements section
   - Mention Vitest (10+ edge cases rule)
   - Mention E2E test scenarios (markdown format)
   - Add Context7 usage guidance

2. **Fix review-story.md**
   - Update reference: "docs/testing-strategy.md" → ".bmad-core/data/testing-stack-guide.md"
   - Add explicit testing execution order
   - Mention running Vitest FIRST
   - Detail Playwright MCP execution workflow
   - Add evidence collection requirements

3. **Fix test-design.md**
   - Add test tooling selection section
   - Explicitly mention Vitest vs Playwright MCP
   - Add the 10+ edge cases rule
   - Clarify markdown scenarios vs test code

### 📊 MEDIUM PRIORITY (Do This Week)

4. **Review and update other QA tasks**:
   - apply-qa-fixes.md
   - nfr-assess.md
   - qa-gate.md
   - risk-profile.md
   - trace-requirements.md

5. **Check architecture templates**:
   - Verify testing-strategy sections reference testing-stack-guide.md
   - Update templates to mention Playwright MCP and Vitest specifically

### 📝 LOW PRIORITY (Nice to Have)

6. **Add task-level Context7 reminders**
   - Add "use context7" prompts in task files where agents need current patterns

---

## Impact Assessment

### Without These Updates:

**Dev Agent** (create-next-story):
- Will still create stories correctly (persona has guidance)
- BUT story template won't have explicit testing requirements
- Dev might not know to write markdown E2E scenarios vs test code
- Won't have clear 10+ edge cases rule for Vitest

**QA Agent** (review-story, test-design):
- Will still review correctly (persona has Playwright MCP guidance)
- BUT task workflow doesn't explicitly say "run Vitest FIRST"
- Task doesn't detail Playwright MCP tool usage step-by-step
- Might miss evidence collection requirements

### With These Updates:

- ✅ Tasks reinforce agent personas with explicit instructions
- ✅ Clear step-by-step workflows in tasks
- ✅ Consistent guidance across agents, data files, and tasks
- ✅ No ambiguity about tooling or file formats
- ✅ Proper file references (no broken links)

---

## Summary

**STATUS**: Agent personas ✅ | Data files ✅ | Task files ❌

**ACTION REQUIRED**: Update 3 critical task files to explicitly reference new workflow:
1. create-next-story.md (Dev uses this most)
2. review-story.md (QA uses this most)
3. test-design.md (QA uses for test planning)

**ESTIMATED TIME**: 15-20 minutes per task file = 45-60 minutes total

**RECOMMENDATION**: Proceed with HIGH PRIORITY updates now, MEDIUM PRIORITY this week.

---

**Updated**: 2025-10-28 20:25:00
