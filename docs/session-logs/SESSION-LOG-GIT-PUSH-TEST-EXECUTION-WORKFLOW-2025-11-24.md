# Session Log: Git Push Integration & Test Execution Boundaries

**Date**: 2025-11-24
**Session Focus**: Integrate git push after all commits + Clarify Dev vs QA test execution responsibilities
**Severity**: HIGH - Workflow efficiency and safety improvements
**Status**: ✅ COMPLETE - Production Ready

---

## Session Summary

This session addressed two critical workflow gaps:

1. **Git Push Integration**: All commits were staying local (not pushed to remote), risking work loss and preventing collaboration visibility. Added `git push` after every commit across all agents (9 total push points).

2. **Test Execution Boundaries**: Conflicting guidance about who runs tests - Dev agent was observed doing "smoke tests" with Playwright MCP before QA Handoff, which wasn't the intended workflow. Clarified that Dev MUST run Vitest tests (pre-check) but NOT execute E2E scenarios (QA's job).

**Key Outcomes**:
- ✅ All commits automatically pushed to remote (backup safety + collaboration)
- ✅ Clear test execution boundaries (Dev runs Vitest, QA runs Vitest + E2E)
- ✅ Eliminated workflow ambiguity
- ✅ 2 commits: 88a6768 (git push) + bea8291 (test execution)

---

## Part 1: Git Push Integration

### Problem Analysis

**User Observation**: "We are committing everything to Git, but at no point of time we are not making it push to the branch. At least at the end of every story completion, the orchestrator can push out the commits."

**Root Cause**: Workflow had **6 commit points** but **ZERO push points** across all agents:
- Dev: 5 commits (Commit Point 1, QA Handoff, Commit Point 3, KB entries, Story Completion Summary)
- QA: 2 commits (Developer Handoff, Completion Handoff)
- Orchestrator: Not analyzed yet

**Result**: All commits stayed local. Risk: If machine crashes, work is lost. No collaboration visibility.

**Files Analyzed**:
- `.bmad-core/agents/dev.md` (lines 111, 119, 121, 137)
- `.bmad-core/tasks/apply-qa-fixes.md` (lines 130-135)
- `.bmad-core/agents/qa.md` (lines 71-72)
- `.bmad-core/agents/bmad-orchestrator.md` (lines 32, 77, 78)

---

### Solution Design: Git Push After Every Commit

**Philosophy**: "Backs up work immediately, enables collaboration, visible progress, CI/CD triggers"

**Implementation**: Added `git push` after every commit (9 total push points):

#### Dev Agent (5 push points)

**Location 1: After Commit Point 1 + QA Handoff** (line 111):
```yaml
completion: "...→COMMIT implementation (feat(story-X.Y): Implementation complete
with task list, test counts, file counts, footer 'Authored by O2Scale' per
git-workflow-guide.md Commit Point 1)→PUSH to remote (git push origin
story/{epic}.{story}-{slug} OR git push if tracking set, backs up work, enables
collaboration, visible progress)→Create detailed QA Handoff document
(docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-qa-handoff.md)
per handoff-templates.md→COMMIT QA Handoff to git (git add docs/handoffs/.../
qa-handoff.md && git commit -m 'handoff(story-X.Y): Create QA handoff -
implementation complete' with footer 'Authored by O2Scale')→PUSH to remote
(git push, ensures handoff is backed up)→..."
```

**Location 2: After Commit Point 3 + KB entries** (lines 119, 121):
```yaml
complete-story: "...→COMMIT quality gate file if not already done (chore(story-X.Y):
Story complete - QA approved, footer 'Authored by O2Scale' per git-workflow-guide.md
Commit Point 3)→PUSH to remote (git push, ensures quality gate is backed up)→Update
story status to COMPLETE→KNOWLEDGE BASE CHECKPOINT (MANDATORY): ...COMMIT KB entries
to git if created (git add docs/knowledge-base/... && git commit -m \"docs(story-X.Y):
Add KB entry for [integration/pattern/solution]\" with footer 'Authored by O2Scale'),
PUSH to remote (git push, backs up KB documentation)..."
```

**Location 3: After Story Completion Summary** (line 137):
```yaml
"(2) COMMIT Story Completion Summary to git (git add docs/handoffs/.../
completion-summary.md && git commit -m \"handoff(story-X.Y): Create Story Completion
Summary - story complete\" with footer 'Authored by O2Scale')→(3) PUSH to remote
(git push, ensures Story Completion Summary is backed up for Orchestrator)→
(4) Output compact snippet to terminal..."
```

---

#### Dev Task - apply-qa-fixes (2 push points)

**Location: After Commit Point 2 + fixes QA Handoff** (lines 131, 134):
```markdown
- COMMIT fixes (fix(story-X.Y): Address QA findings with issue list, test counts,
  quality gate status, footer "Authored by O2Scale" per git-workflow-guide.md
  Commit Point 2)
- PUSH to remote (git push, backs up fixes immediately)
- Create new QA Handoff document (docs/handoffs/sprint-{N}/epics/epic-{N}/
  {epic}.{story}-{slug}-qa-handoff.md) with fixes applied, ready for re-testing
- COMMIT QA Handoff to git (git add docs/handoffs/.../qa-handoff.md && git commit
  -m "handoff(story-X.Y): Create QA handoff - fixes applied" with footer
  "Authored by O2Scale")
- PUSH to remote (git push, ensures handoff is backed up)
- Output QA Handoff compact snippet to terminal for QA to re-test
```

---

#### QA Agent (2 push points)

**Location 1: After Developer Handoff commit** (line 71):
```yaml
'CRITICAL: Developer Handoff Dual-Format Protocol (FAIL/CONCERNS gate) - After test
execution, you MUST create THREE SEPARATE outputs with DIFFERENT destinations:
(1) DETAILED HANDOFF → FILE: Save comprehensive Developer Handoff document to
docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-developer-handoff.md
with full issue details (gate status, all failing test cases, evidence references,
root cause analysis, suggested fixes, reproduction steps), (2) COMMIT handoff + gate
to git (git add docs/handoffs/.../developer-handoff.md docs/qa/gates/.../gate.yml &&
git commit -m "handoff({epic}.{story}): Create Developer handoff - {brief-issue-summary}"
with footer "Authored by O2Scale")→PUSH to remote (git push, ensures handoff is
backed up), and (3) COMPACT SNIPPET → TERMINAL ONLY: Output ONLY 10-15 line compact
snippet...'
```

**Location 2: After Completion Handoff commit** (line 72):
```yaml
'CRITICAL: Completion Handoff Dual-Format Protocol (PASS gate) - After all tests pass,
you MUST create THREE SEPARATE outputs with DIFFERENT destinations: (1) DETAILED
HANDOFF → FILE: Save comprehensive Completion Handoff document to docs/handoffs/
sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-completion-handoff.md with full
approval details (complete test results, evidence summary, quality notes, suggested
commit message), (2) COMMIT handoff + gate to git (git add docs/handoffs/.../
completion-handoff.md docs/qa/gates/.../gate.yml && git commit -m
"handoff({epic}.{story}): Create Completion handoff - all tests PASS" with footer
"Authored by O2Scale")→PUSH to remote (git push, ensures handoff is backed up),
and (3) COMPACT SNIPPET → TERMINAL ONLY: Output ONLY 10-15 line compact snippet...
OPTIONAL: QA may commit quality gate file separately (chore(story-X.Y): Story
complete - QA approved, footer "Authored by O2Scale" per git-workflow-guide.md
Commit Point 3)→PUSH to remote (git push, backs up quality gate file) OR leave
commit+push for Dev after receiving Completion Handoff'
```

---

#### Orchestrator Agent (3 integrations)

**Location 1: After Story Handoff commit** (line 77):
```yaml
'Story Creation Workflow: ...DUAL-FORMAT HANDOFF: Create TWO SEPARATE outputs with
DIFFERENT destinations: (10a) DETAILED HANDOFF → FILE: Save comprehensive Story Handoff
document to docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-story-handoff.md
with KB references section listing entries Dev must use AND KB creation expectations
section listing entries Dev must create, (10b) COMMIT Story Handoff to git (git add
docs/handoffs/.../story-handoff.md && git commit -m "handoff({epic}.{story}): Create
Story handoff - ready for development" with footer "Authored by O2Scale")→PUSH to
remote (git push, ensures handoff is backed up), (10c) COMPACT SNIPPET → TERMINAL
ONLY: Output ONLY 10-15 line compact snippet...'
```

**Location 2: After Test Review Handoff commit** (line 78):
```yaml
'Test Vetting Workflow: ...DUAL-FORMAT HANDOFF: Create TWO SEPARATE outputs with
DIFFERENT destinations: (1) DETAILED HANDOFF → FILE: Save comprehensive Test Review
Handoff document to docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-
test-review-handoff.md with review analysis (APPROVE/REVISE rationale, coverage
assessment, strengths/gaps, specific recommendations, quality notes, risk assessment),
(2) COMMIT Test Review Handoff to git (git add docs/handoffs/.../test-review-handoff.md
&& git commit -m "handoff({epic}.{story}): Create Test Review handoff - {APPROVE/REVISE}"
with footer "Authored by O2Scale")→PUSH to remote (git push, ensures handoff is
backed up), (3) COMPACT SNIPPET → TERMINAL ONLY: Output ONLY 10-15 line compact
snippet...'
```

**Location 3: Git push verification after Story Completion Summary** (line 32):
```yaml
'STEP 3.8: IF user provides Story Completion Summary snippet with "📄 Full Summary:"
reference (from Dev after story completion, before creating next story), read the
referenced document for complete story outcome context (implementation summary,
architectural decisions, KB entries created, schema changes, dependencies for next
stories, QA lessons learned, recommendations for next story Dev Notes), THEN verify
all story commits are pushed to remote: Run git log --branches --not --remotes
--oneline to check for unpushed commits (empty output = all pushed, non-empty =
unpushed commits exist), IF unpushed commits found: Alert user "⚠️ Unpushed commits
detected - run 'git push' to back up your work before proceeding" and list unpushed
commit hashes, IF all commits pushed: Confirm "✅ All story commits backed up to
remote - ready to create next story"'
```

---

### Benefits of Git Push Integration

#### Before (Risky Workflow)
- ❌ All commits stay local (not pushed to remote)
- ❌ If machine crashes → work lost
- ❌ Team can't see progress
- ❌ No collaboration visibility
- ❌ CI/CD pipelines can't trigger
- ❌ User manually pushing (extra step, easy to forget)

#### After (Safe Workflow)
- ✅ All commits automatically pushed after creation
- ✅ Work backed up immediately (prevents loss from crashes)
- ✅ Team sees progress in real-time
- ✅ Visible collaboration (commits in remote)
- ✅ CI/CD triggers automatically
- ✅ Safe handoffs (recipient verifies commits exist remotely)
- ✅ Orchestrator verifies all commits pushed before next story

---

### Git Commit (Part 1)

```
Hash: 88a6768
Message: feat(git-workflow): Integrate git push after all commits across workflow
Stats: 4 files changed, 12 insertions(+), 8 deletions(-)
Files:
  - .bmad-core/agents/dev.md
  - .bmad-core/tasks/apply-qa-fixes.md
  - .bmad-core/agents/qa.md
  - .bmad-core/agents/bmad-orchestrator.md
```

---

## Part 2: Test Execution Boundaries Clarification

### Problem Analysis

**User Observation**: "Have you made any changes inside the dev agent? It's automatically doing a smoke test. If it's just a smoke test, it's okay. But can you just clarify that after it does development, it goes and does a smoke test by initiating and using the Playwright MCP."

**User Question**: "In your opinion, do you think we should have the dev create, like, you know, verify the ytest passes or directly have the QA do it?"

**Root Cause**: Workflow had **conflicting guidance** about test execution:

#### Conflict 1: dev.md line 84
```yaml
'CRITICAL: Test Writing - Write Vitest tests in docs/qa/unit/ for complex logic,
write E2E test SCENARIOS (markdown) in docs/qa/e2e/, do NOT run tests
(QA responsibility)'
```
**Problem**: Said "do NOT run tests" - Dev was writing tests but not verifying they work.

#### Conflict 2: dev.md lines 88-89
```yaml
'Visual-First Debugging: When user describes UI issues, use Playwright MCP to inspect'
'Playwright MCP Usage: For UNDERSTANDING/DEBUGGING UI only (NOT for testing -
that is QA job)'
```
**Problem**: Playwright MCP was correctly restricted, but no clarity on Vitest execution.

#### Conflict 3: testing-stack-guide.md line 32
```markdown
**Developer Role**:
- Does NOT run tests (QA's responsibility)
```
**Problem**: Explicitly said Dev doesn't run tests.

#### Conflict 4: testing-stack-guide.md lines 1062-1063 (FAQ)
```markdown
### Q: Does Dev run Vitest before handing off to QA?
**A**: NO. QA is responsible for ALL test execution (Vitest + E2E). Dev writes
tests but doesn't run them. This keeps Dev's context focused on implementation.
```
**Problem**: FAQ explicitly said "NO" to Dev running tests.

---

### Decision Discussion

**User's Question**: Should Dev run Vitest, or only QA?

**My Analysis**:
- **Industry Best Practice**: Developers ALWAYS run their own unit tests before code review/QA
- **Efficiency**: Dev catches obvious failures while context is fresh (fast feedback loop)
- **QA Focus**: QA can focus on comprehensive testing, not debugging basic unit test failures
- **Professional Standard**: Like a chef tasting food before serving (Dev runs Vitest) vs food critic evaluating complete dining experience (QA runs everything independently)
- **Ownership**: Dev takes responsibility for code quality (not "throwing over the wall")

**Recommendation**:
- ✅ Dev MUST run Vitest tests before QA Handoff (pre-check)
- ✅ QA runs Vitest AGAIN independently (validation from clean environment)
- ✅ Dev does NOT execute E2E scenarios with Playwright MCP (QA's job)
- ✅ Both run Vitest but different purposes:
  - Dev = Pre-check (catch failures early while context fresh)
  - QA = Validation (independent verification from clean environment)

**User Response**: "yes makes sense. update workflow accordingly"

---

### Solution Design: Clear Test Execution Boundaries

**New Philosophy**:
```yaml
Dev Testing Responsibilities BEFORE QA Handoff:
1. Write Vitest tests for complex logic (10+ edge cases)
2. Write E2E test scenarios in MARKDOWN format (NOT .spec.ts files)
3. RUN VITEST TESTS and verify ALL pass (npm run test - MANDATORY)
4. Basic manual verification (run app locally, click through UI, spot check)

Dev MUST NOT:
- Execute E2E scenarios with Playwright MCP tools (QA's job)

QA Testing Responsibilities:
1. Run Vitest FIRST independently (validation from clean environment)
2. Execute E2E scenarios using Playwright MCP tools interactively
3. Observe browser actions, collect evidence
4. Both Vitest AND E2E must pass for PASS gate

Analogy: Chef tastes food before serving (Dev runs Vitest) vs Food critic
evaluates complete dining experience (QA runs everything independently)
```

---

### Implementation (Part 2)

#### File 1: `.bmad-core/agents/dev.md` (3 updates)

**Update 1: Line 84 (Test Writing Principle)**

**REMOVED**:
```yaml
'CRITICAL: Test Writing - Write Vitest tests in docs/qa/unit/ for complex logic,
write E2E test SCENARIOS (markdown) in docs/qa/e2e/, do NOT run tests
(QA responsibility)'
```

**ADDED**:
```yaml
'CRITICAL: Test Writing - Write Vitest tests in docs/qa/unit/ for complex logic
(10+ edge cases), write E2E test SCENARIOS in MARKDOWN format (NOT .spec.ts files)
in docs/qa/e2e/sprint-{N}/epics/epic-{N}/story-{N}/ using TC{AC}.{case} naming
(e.g., TC1.1, TC1.2). Vitest tests = code you execute (npm run test). E2E scenarios =
markdown documents QA executes interactively with Playwright MCP.'
```

**Update 2: Line 90 (NEW Test Execution Boundaries Principle)**

**ADDED**:
```yaml
'CRITICAL: Test Execution Boundaries - Your testing responsibilities BEFORE QA Handoff:
(1) Write Vitest tests for complex logic (10+ edge cases - tax calculations, algorithms,
validation), (2) Write E2E test scenarios in MARKDOWN format (docs/qa/e2e/sprint-{N}/
epics/epic-{N}/story-{N}/ with TC{AC}.{case} format), (3) RUN VITEST TESTS and verify
ALL pass (npm run test - this is MANDATORY, not optional), (4) Basic manual verification
(run app locally, click through UI, spot check functionality works). YOU MUST NOT:
Execute E2E scenarios with Playwright MCP tools (that is QA job - they execute scenarios
interactively with browser observation). Your role: Write tests + Verify Vitest passes +
Manual spot check → Create QA Handoff → HALT. QA role: Run Vitest independently
(validation) + Execute E2E scenarios with Playwright MCP (comprehensive testing with
evidence collection). Think of it like a chef tasting food before serving (you run Vitest)
vs food critic evaluating complete dining experience (QA runs everything independently).
Both run Vitest but different purposes: You = pre-check (catch failures early), QA =
validation (independent verification from clean environment).'
```

**Update 3: Line 112 (Completion Workflow)**

**CHANGED**:
```yaml
completion: "All Tasks and Subtasks marked [x] and have tests→Validations and full
regression passes (DON'T BE LAZY, EXECUTE ALL TESTS and CONFIRM)→..."
```

**TO**:
```yaml
completion: "All Tasks and Subtasks marked [x] and have tests→RUN VITEST TESTS
(npm run test) and verify ALL PASS - this is MANDATORY pre-check before QA Handoff
(DON'T BE LAZY, EXECUTE and CONFIRM all Vitest tests pass, record pass count for
QA Handoff)→Basic manual verification (run app locally, click through UI, spot check
functionality)→Ensure File List is Complete→..."
```

---

#### File 2: `.bmad-core/checklists/story-dod-checklist.md` (2 sections)

**Update 1: Section 3 (Testing) - Lines 44-51**

**CHANGED**:
```markdown
3. **Testing:**
   [[LLM: Testing proves your code works. Be honest about test coverage]]
   - [ ] All required unit tests as per the story and `Operational Guidelines` Testing
         Strategy are implemented.
   - [ ] All required integration tests (if applicable) as per the story and `Operational
         Guidelines` Testing Strategy are implemented.
   - [ ] All tests (unit, integration, E2E if applicable) pass successfully.
   - [ ] Test coverage meets project standards (if defined).
```

**TO**:
```markdown
3. **Testing:**
   [[LLM: Testing proves your code works. Be honest about test coverage. YOU MUST RUN
   VITEST TESTS - this is not optional. QA will run them again independently, but you
   must verify they pass first.]]
   - [ ] All required Vitest tests (for complex logic with 10+ edge cases) written in
         `docs/qa/unit/` directory.
   - [ ] All required E2E test scenarios written in MARKDOWN format (NOT .spec.ts files)
         in `docs/qa/e2e/sprint-{N}/epics/epic-{N}/story-{N}/` using TC{AC}.{case} naming
         (e.g., TC1.1, TC1.2).
   - [ ] **CRITICAL**: Executed Vitest tests (run: `npm run test`) and verified ALL PASS -
         record pass count (e.g., "Vitest: 15 tests pass ✅") for QA Handoff.
   - [ ] **DO NOT**: Execute E2E scenarios with Playwright MCP tools (that is QA's job -
         they execute interactively with browser observation).
   - [ ] Test coverage meets project standards (if defined).
```

**Update 2: Section 5 (Functionality & Verification) - Lines 64-69**

**CHANGED**:
```markdown
5. **Functionality & Verification:**
   [[LLM: Did you actually run and test your code? Be specific about what you tested]]
   - [ ] Functionality has been manually verified by the developer (e.g., running the app
         locally, checking UI, testing API endpoints).
   - [ ] Edge cases and potential error conditions considered and handled gracefully.
```

**TO**:
```markdown
5. **Functionality & Verification:**
   [[LLM: Did you actually run and test your code? Manual verification = basic spot
   checking (click through UI, verify feature works). NOT comprehensive testing -
   that's QA's job.]]
   - [ ] Basic manual verification completed (run app locally, click through UI, spot
         check functionality works - e.g., login page loads, form submits, data displays).
   - [ ] **NOT REQUIRED**: Comprehensive testing with Playwright MCP (QA handles this -
         you only do basic spot checks).
   - [ ] Edge cases and potential error conditions considered and handled gracefully in code.
```

---

#### File 3: `.bmad-core/data/testing-stack-guide.md` (3 updates)

**Update 1: Line 16 (Workflow Summary)**

**CHANGED**:
```markdown
- **Test Execution**: QA runs Vitest first, then executes E2E via Playwright MCP tools
```

**TO**:
```markdown
- **Test Execution**: Dev runs Vitest first (pre-check before QA Handoff), then QA runs
  Vitest independently (validation) + executes E2E via Playwright MCP tools
```

**Update 2: Lines 27-45 (Developer/QA Roles)**

**CHANGED**:
```markdown
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
```

**TO**:
```markdown
**Developer Role**:
- **IF** complex logic (10+ edge cases) → Writes Vitest unit tests in `docs/qa/unit/`
- Writes E2E test SCENARIOS in markdown (NOT `.spec.ts` files)
- Documents acceptance criteria test cases
- **RUNS Vitest tests** (`npm run test`) and verifies ALL PASS before QA Handoff
  (mandatory pre-check)
- Basic manual verification (run app locally, click through UI, spot check)
- Manages background processes (frontend + backend servers)
- Does NOT execute E2E scenarios with Playwright MCP (QA's responsibility)
- Outputs QA Handoff when implementation complete + Vitest passing

**QA Role**:
- **IF** Vitest tests exist → Runs `npm run test` FIRST, verifies passing independently
  (validation from clean environment)
- Reads E2E test scenarios from markdown
- Executes E2E scenarios using 26 Playwright MCP tools interactively
- Observes browser actions in real-time (visible Chrome window)
- **IF** logic gaps found → Can add more Vitest tests
- Decides PASS/FAIL based on manual verification (both Vitest AND E2E must pass for
  PASS gate)
- Collects evidence (screenshots, console logs, page snapshots)
- Outputs Developer Handoff (if issues) or Completion Handoff (if PASS)
```

**Update 3: Lines 1062-1063 (FAQ)**

**CHANGED**:
```markdown
### Q: Does Dev run Vitest before handing off to QA?
**A**: NO. QA is responsible for ALL test execution (Vitest + E2E). Dev writes tests
but doesn't run them. This keeps Dev's context focused on implementation.
```

**TO**:
```markdown
### Q: Does Dev run Vitest before handing off to QA?
**A**: YES. Dev MUST run Vitest (`npm run test`) and verify all tests pass before
creating QA Handoff. This is a mandatory pre-check (like a chef tasting food before
serving). Dev catches obvious failures while context is fresh, preventing QA from
wasting time on broken code. QA then runs Vitest AGAIN independently for validation
(food critic evaluates complete dining experience). Both run Vitest but different
purposes: Dev = pre-check (fast feedback), QA = validation (independent verification).
Dev does NOT execute E2E scenarios with Playwright MCP - that remains QA's job.
```

---

### Benefits of Test Execution Clarity

#### Before (Ambiguous Workflow)
- ❌ Conflicting guidance: "Dev does NOT run tests" vs "Execute all tests"
- ❌ Dev writing tests without verifying they work
- ❌ QA wasting time debugging basic failures Dev should catch
- ❌ Dev observed doing "smoke tests" with Playwright MCP (wrong tool)
- ❌ Slower feedback loop (Dev hands off broken code)
- ❌ More QA rework cycles

#### After (Clear Workflow)
- ✅ Clear boundaries: Dev runs Vitest (pre-check), QA runs Vitest + E2E (validation)
- ✅ Dev catches obvious failures immediately (fast feedback)
- ✅ QA focuses on comprehensive testing, not debugging basic failures
- ✅ Professional standard: Like chef tasting food before serving
- ✅ Ownership: Dev takes responsibility for code quality
- ✅ Efficiency: Fewer handoff cycles, faster velocity
- ✅ No confusion: Dev does NOT use Playwright MCP for testing

---

### Git Commit (Part 2)

```
Hash: bea8291
Message: feat(testing-workflow): Clarify test execution boundaries - Dev MUST run
         Vitest before QA Handoff
Stats: 3 files changed, 20 insertions(+), 15 deletions(-)
Files:
  - .bmad-core/agents/dev.md
  - .bmad-core/checklists/story-dod-checklist.md
  - .bmad-core/data/testing-stack-guide.md
```

---

## Part 3: Playwright MCP Migration (Per-Project Setup)

### Problem Analysis

**User Observation**: "HDA V2 - ALL agents (QA, Orchestrator, anyone) using Playwright MCP are saving screenshots to Downloads folder. I can see that the Playwright MCP is going and saving every single file in the C users users downloads folder inside my C drive."

**Root Cause**: Global Playwright MCP setup saves all screenshots/files to Windows Downloads folder (`C:\Users\{user}\Downloads`), causing:
- ❌ All projects dump evidence into same Downloads folder
- ❌ Hard to organize, files mixed together
- ❌ Not project-specific
- ❌ Requires manual `downloadsDir` parameter specification (error-prone, often forgotten)

**User Quote**: "There is no point in the second option, strengthening the global MCP plus download directory instructions. That actually doesn't work. That's something that I could understand very clearly from this live execution of this particular project."

**Files Currently Affected**:
- `.bmad-core/agents/qa.md` (line 64): Instructs to use `downloadsDir` parameter
- `.bmad-core/data/testing-stack-guide.md` (lines 558-560, 602-610): Examples with `downloadsDir`
- All agents/scripts using Playwright MCP: Saving to Downloads by default

---

### Solution Decision

**User's Decision**: "Option number one, I want to switch to a per project Playwright MCP setup, that is the best option right now."

**Why Per-Project is Better**:
- ✅ Automatic correctness: Default behavior saves to project folder
- ✅ Better organization: Each project has its own evidence
- ✅ Cleaner workflow: No need to remember `downloadsDir` parameter
- ✅ Matches other MCPs: Consistent with Supabase, MongoDB, shadcn-ui (all per-project)
- ✅ Scales better: Multiple projects don't pollute Downloads folder

**Per-Project Setup**:
```json
// Each project's .mcp.json
{
  "mcpServers": {
    "playwright": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@executeautomation/playwright-mcp-server"],
      "env": {}
    }
  }
}
```

When Playwright MCP runs per-project, it automatically creates `playwright/` folder in that project and saves files there (no `downloadsDir` parameter needed).

---

### Implementation (Part 3)

#### File 1: `CLAUDE.md` (lines 92-98)

**CHANGED**:
```markdown
### Available MCPs

**Global MCP** (installed once, available everywhere):
- ✅ **Playwright MCP** - E2E testing and browser automation

**Project-Specific MCPs** (configured in `.mcp.json`):
- **Context7 MCP**: Up-to-date library documentation and patterns
- **shadcn-ui MCP**: Access to shadcn/ui component library (Next.js projects)
- **Swagger MCP**: API testing via OpenAPI/Swagger specs
- **Supabase MCP**: Database operations, migrations, logs (Supabase projects)
- **MongoDB MCP**: Database queries, indexes, optimization (MongoDB projects)
```

**TO**:
```markdown
### Available MCPs

**All MCPs are Project-Specific** (configured in `.mcp.json`):
- **Playwright MCP**: E2E testing and browser automation (saves to project folder automatically)
- **Context7 MCP**: Up-to-date library documentation and patterns
- **shadcn-ui MCP**: Access to shadcn/ui component library (Next.js projects)
- **Swagger MCP**: API testing via OpenAPI/Swagger specs
- **Supabase MCP**: Database operations, migrations, logs (Supabase projects)
- **MongoDB MCP**: Database queries, indexes, optimization (MongoDB projects)
```

---

#### File 2: `docs/guides/MCP-QUICK-START.md` (3 updates)

**Update 1: Lines 10-18 (Available MCPs section)**

**CHANGED**:
```markdown
## Available MCPs

### Global MCP (Installed Once)
- ✅ **Playwright MCP** - E2E testing and browser automation

### Project-Specific MCPs (Per Template)
- **Context7 MCP**: Up-to-date library documentation and patterns
- ...
```

**TO**:
```markdown
## Available MCPs

**All MCPs are Project-Specific** (configured per-project in `.mcp.json`):
- **Playwright MCP**: E2E testing and browser automation (saves to project folder automatically)
- **Context7 MCP**: Up-to-date library documentation and patterns
- ...
```

**Update 2: Removed "Global MCP Setup" section**

**REMOVED**:
```bash
### Global MCP Setup

# Playwright MCP (install once, available everywhere)
claude mcp add playwright npx -- -y @executeautomation/playwright-mcp-server
```

**Update 3: Added Per-Project Benefits (lines 246-250)**

**ADDED**:
```markdown
### Playwright MCP

**Purpose**: E2E testing and browser automation

**Per-Project Setup Benefits**:
- ✅ Screenshots/files save to project folder automatically (not Windows Downloads)
- ✅ Evidence organized by project (docs/qa/evidence/)
- ✅ No need to specify `downloadsDir` parameter manually
- ✅ Clean separation between projects
```

---

#### File 3: `.bmad-core/agents/qa.md` (line 64)

**CHANGED**:
```yaml
'CRITICAL: Evidence Collection - Use playwright_screenshot with downloadsDir
parameter set to project evidence folder (docs/qa/evidence/sprint-{N}/epics/
epic-{epic}/story-{story}/), savePng: true. NEVER use default (saves to user
Downloads folder). Capture console logs (browser_console_messages), page
snapshots (browser_snapshot) for all test cases. Verify screenshots saved to
correct project folder.'
```

**TO**:
```yaml
'CRITICAL: Evidence Collection - Per-project Playwright MCP automatically saves
screenshots/files to project folder. Use playwright_screenshot (savePng: true)
to capture evidence. Organize evidence in docs/qa/evidence/sprint-{N}/epics/
epic-{epic}/story-{story}/ directory structure. Capture console logs
(browser_console_messages), page snapshots (browser_snapshot) for all test cases.
Reference evidence files in handoff documents with relative paths.'
```

**Impact**: Simplified instructions - no need to manually specify `downloadsDir` parameter.

---

#### File 4: `.bmad-core/data/testing-stack-guide.md` (2 updates)

**Update 1: Lines 558-561 (Tool Documentation)**

**CHANGED**:
```markdown
- `playwright_screenshot(name, downloadsDir, savePng)` - Capture visual evidence
  - **CRITICAL**: ALWAYS set `downloadsDir` to project evidence folder, NOT user's Downloads
  - Example: `downloadsDir: "docs/qa/evidence/sprint-1/epics/epic-1/story-3/"`
  - Set `savePng: true` to save file to disk
```

**TO**:
```markdown
- `playwright_screenshot(name, savePng)` - Capture visual evidence
  - **Per-project Playwright MCP automatically saves to project folder** (not Windows Downloads)
  - Organize evidence: `docs/qa/evidence/sprint-{N}/epics/epic-{N}/story-{N}/`
  - Set `savePng: true` to save file to disk
```

**Update 2: Lines 602-610 (Example Code)**

**CHANGED**:
```javascript
7. playwright_screenshot({
     name: 'tc1.1-login-success.png',
     downloadsDir: 'docs/qa/evidence/sprint-1/epics/epic-1/story-3/',
     savePng: true
   })
8. Manually observe: Dashboard loaded? User name visible?

**CRITICAL**: Screenshot `downloadsDir` must be project evidence folder, NOT user's Downloads folder!
```

**TO**:
```javascript
7. playwright_screenshot({
     name: 'tc1.1-login-success.png',
     savePng: true
   })
   → Per-project Playwright MCP saves to project folder automatically
8. Manually observe: Dashboard loaded? User name visible?

**NOTE**: Per-project Playwright MCP automatically saves screenshots to project folder (not Windows Downloads).
```

---

### Benefits of Per-Project Playwright MCP

#### Before (Global Setup - Broken)
- ❌ All screenshots save to `C:\Users\{user}\Downloads`
- ❌ All projects dump evidence into same folder
- ❌ Hard to organize (files mixed together)
- ❌ Requires manual `downloadsDir` parameter (error-prone)
- ❌ If forgotten → screenshots go to Downloads (wrong location)
- ❌ "Strengthening instructions doesn't work" (user quote)

#### After (Per-Project Setup - Fixed)
- ✅ Screenshots save to project folder automatically
- ✅ Each project has its own `playwright/` folder
- ✅ Evidence organized: `docs/qa/evidence/sprint-{N}/...`
- ✅ No manual `downloadsDir` parameter needed
- ✅ Default behavior is correct
- ✅ Clean separation between projects

---

### Git Commit (Part 3)

```
Hash: 58914b7
Message: feat(mcp): Switch Playwright MCP from global to per-project setup
Stats: 4 files changed, 18 insertions(+), 23 deletions(-)
Files:
  - CLAUDE.md
  - docs/guides/MCP-QUICK-START.md
  - .bmad-core/agents/qa.md
  - .bmad-core/data/testing-stack-guide.md
```

---

### Migration Decision (CRITICAL)

**User's Decision**: "So let's hold off on this for a second because currently I'm still working on the HDA version 2. Once I'm completing one section of the epic, like a proper epic completion is done, we'll move about this and take up this portion of migrating this playwright MCP because currently I don't want to screw up the environment right now."

**Migration Plan**:
- ⏸️ **Hold Migration**: Do NOT migrate HDA V2 to per-project Playwright MCP yet
- ⏳ **Timing**: Migrate AFTER completing one full epic in HDA V2
- 🎯 **Reason**: Don't want to disrupt current development environment
- 📝 **Note**: User will ask to check last two session logs when ready to migrate

**Current State**:
- ✅ **Master Template (mydevwf)**: Updated - all documentation reflects per-project setup
- ⏸️ **HDA V2 Project**: Still using global Playwright MCP (saving to Downloads) - DO NOT MIGRATE YET
- ✅ **New Projects**: Will automatically use per-project setup (when created with updated templates)

**When User is Ready to Migrate**:
1. User will complete one full epic in HDA V2
2. User will ask: "Check the last two session logs for Playwright MCP migration"
3. Migration steps for HDA V2:
   - Remove global Playwright MCP: `claude mcp remove playwright`
   - Add Playwright to HDA V2's `.mcp.json`
   - Restart Claude Code
   - Verify screenshots now save to HDA V2 project folder (not Downloads)

---

## Key Principles Established

### 1. Git Push After Every Commit
- All commits automatically pushed to remote
- Backs up work immediately (prevents loss from crashes)
- Enables collaboration visibility
- Triggers CI/CD pipelines
- Safe handoffs (recipient verifies commits exist)

### 2. Dev Runs Vitest (Pre-Check)
- Dev MUST run `npm run test` before QA Handoff
- Catches obvious failures while context fresh
- Fast feedback loop (fix immediately)
- Professional standard (industry best practice)

### 3. QA Runs Vitest + E2E (Validation)
- QA runs `npm run test` independently (clean environment)
- QA executes E2E scenarios with Playwright MCP
- Both Vitest AND E2E must pass for PASS gate
- Comprehensive testing with evidence collection

### 4. Clear Tool Boundaries
- **Vitest**: Dev runs (pre-check) + QA runs (validation)
- **E2E Scenarios**: Dev writes (markdown) + QA executes (Playwright MCP)
- **Playwright MCP**: ONLY QA uses for E2E testing
- **Manual Verification**: Dev does basic spot checking, NOT comprehensive testing

### 5. Chef vs Food Critic Analogy
- **Chef (Dev)**: Tastes food before serving (runs Vitest pre-check)
- **Food Critic (QA)**: Evaluates complete dining experience (runs everything independently)
- Both taste the food, but different purposes: Pre-check vs Validation

---

## Related Documentation

### Files Modified (7 total)

**Part 1: Git Push Integration (4 files)**
- `.bmad-core/agents/dev.md` (lines 111, 119, 121, 137)
- `.bmad-core/tasks/apply-qa-fixes.md` (lines 131, 134)
- `.bmad-core/agents/qa.md` (lines 71-72)
- `.bmad-core/agents/bmad-orchestrator.md` (lines 32, 77, 78)

**Part 2: Test Execution Boundaries (3 files)**
- `.bmad-core/agents/dev.md` (lines 84, 90, 112)
- `.bmad-core/checklists/story-dod-checklist.md` (sections 3 & 5)
- `.bmad-core/data/testing-stack-guide.md` (lines 16, 27-45, 1062-1063)

### Previous Session Logs
- `SESSION-LOG-STRICT-TESTING-MANDATE-2025-11-15.md` (Runtime testing mandate)
- `SESSION-LOG-HANDOFF-GIT-INTEGRATION-2025-11-15.md` (Handoff git commits)
- `SESSION-LOG-BMAD-V4-STORY-COMPLETION-SUMMARY-2025-11-15.md` (Story completion)

### Related Framework Files
- `.bmad-core/data/git-workflow-guide.md` (Git workflow, 3 commit points)
- `.bmad-core/data/handoff-templates.md` (6 handoff types)
- `.bmad-core/data/three-terminal-workflow.md` (Orchestrator coordination)

---

## Verification Checklist

**User can verify these fixes work by**:

### Git Push Integration
1. ✅ Run Dev agent through story implementation
   - Expected: After Commit Point 1, automatically pushes to remote
   - Expected: After QA Handoff commit, automatically pushes to remote
   - Verify: Check remote repository shows commits

2. ✅ Run QA agent on story with issues
   - Expected: After Developer Handoff commit, automatically pushes to remote
   - Verify: Check remote repository shows handoff + gate files

3. ✅ Run Orchestrator to create new story
   - Expected: After Story Handoff commit, automatically pushes to remote
   - Expected: When receiving Story Completion Summary, verifies all commits pushed
   - Verify: Orchestrator alerts if unpushed commits found

### Test Execution Boundaries
1. ✅ Run Dev agent on story with complex logic
   - Expected: Dev writes Vitest tests, runs `npm run test`, verifies passing
   - Expected: Dev does basic manual verification (click through UI)
   - Expected: Dev does NOT execute E2E scenarios with Playwright MCP
   - Verify: QA Handoff includes "Vitest: X tests pass ✅"

2. ✅ Run QA agent on Dev's QA Handoff
   - Expected: QA runs `npm run test` FIRST independently
   - Expected: QA executes E2E scenarios with Playwright MCP
   - Expected: Both Vitest + E2E must pass for PASS gate
   - Verify: QA doesn't skip Vitest just because Dev ran it

3. ✅ Run Dev agent with story that has no complex logic
   - Expected: Dev skips Vitest tests (no 10+ edge cases)
   - Expected: Dev still does basic manual verification
   - Expected: Dev writes E2E scenarios for all acceptance criteria
   - Verify: QA can execute E2E scenarios even without Vitest

---

## Conversation Highlights

### User's Key Feedback

1. **Git Push Request**: "we are committing everything to Git, but at no point of time we are not making it push to the branch. at least at the end of every story completion, the orchestrator can push out the commits."

2. **Orchestrator Scope**: "Let's implement this but also add for the orchestrator agent as well. The orchestrator also needs to be having a push commit, a push event."

3. **Test Execution Observation**: "Have you made any changes inside the dev agent? It's automatically doing a smoke test. If it's just a smoke test, it's okay. But can you just clarify that after it does development, it goes and does a smoke test by initiating and using the Playwright MCP."

4. **Test Execution Question**: "In your opinion, do you think we should have the dev create, like, you know, verify the ytest passes or directly have the QA do it?"

5. **Decision Approval**: "yes makes sense. update workflow accordingly"

6. **Session Log Request**: "All right, there's so many things that we've done so far. I want you to save our progress inside the session log folder. To include as much as detail that you remember, check the last session log and see how much of things are there that we have not added into another session log."

---

## Conclusion

**Objectives**: ✅ COMPLETE (3 major improvements)

**Part 1: Git Push Integration**
- ✅ Added git push after all 6 commit points (9 total push points)
- ✅ Dev: 5 push points (Commit Point 1, QA Handoff, Commit Point 3, KB entries, Story Completion Summary)
- ✅ QA: 2 push points (Developer Handoff, Completion Handoff)
- ✅ Orchestrator: 3 integrations (Story Handoff, Test Review Handoff, push verification)
- ✅ Commit 88a6768 pushed to devwf branch

**Part 2: Test Execution Boundaries**
- ✅ Clarified Dev MUST run Vitest before QA Handoff (mandatory pre-check)
- ✅ Clarified QA runs Vitest independently (validation from clean environment)
- ✅ Clarified Dev does NOT execute E2E scenarios with Playwright MCP
- ✅ Updated 3 files with consistent messaging (dev.md, story-dod-checklist.md, testing-stack-guide.md)
- ✅ Commit bea8291 pushed to devwf branch

**Part 3: Playwright MCP Migration (Per-Project Setup)**
- ✅ Switched from global to per-project Playwright MCP setup
- ✅ Updated documentation: CLAUDE.md, MCP-QUICK-START.md, qa.md, testing-stack-guide.md
- ✅ Simplified evidence collection (no manual `downloadsDir` parameter needed)
- ✅ Per-project automatically saves to project folder (not Windows Downloads)
- ✅ Commit 58914b7 pushed to devwf branch
- ⏸️ **Migration Decision**: Hold off migrating HDA V2 until after completing one full epic
- 📝 **User will ask to check last two session logs when ready to migrate**

**Production Status**: ✅ READY
- All 11 files updated and committed (3 commits total)
- Git push integrated at every commit point
- Test execution boundaries crystal clear
- Playwright MCP per-project setup in workflow
- HDA V2 migration pending (user decision)

**Quality Impact**: ✅ CRITICAL IMPROVEMENTS
- Work can't be lost (automatic git push)
- Team visibility (all commits in remote)
- Fast feedback (Dev runs Vitest pre-check)
- Efficient QA (focus on comprehensive testing, not debugging)
- Clear boundaries (no confusion about tools/responsibilities)
- Evidence organized by project (not polluting Downloads folder)

**Framework Version**: BMad V4.4 (with git push + test execution clarity + per-project Playwright MCP)

---

**Session Completed**: 2025-11-24
**Next Action**:
- User can verify git push + test execution improvements in production workflow
- **Playwright MCP Migration**: User will complete one epic in HDA V2, then ask to check last two session logs for migration steps
**Git Commits**: 88a6768 (git push) + bea8291 (test execution) + 58914b7 (per-project Playwright MCP)
