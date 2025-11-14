# Three-Terminal Workflow Guide

**Version**: 1.0
**Last Updated**: 2025-11-04
**Purpose**: Guide for orchestrating development workflows across three specialized terminals: Orchestrator, Dev, and QA

---

## Overview

The **three-terminal workflow** is an advanced BMad workflow pattern that separates planning, development, and quality assurance into three specialized terminals, each running dedicated agents. This pattern improves focus, reduces context switching, and enables parallel work across different phases of story development.

### Two-Terminal vs Three-Terminal Workflow

**Two-Terminal Workflow** (Dev + QA):
- **Use when**: Stories are well-defined, minimal planning needed, straightforward implementation
- **Terminals**: Dev terminal (implementation + testing) → QA terminal (validation + gate)
- **Handoffs**: QA Handoff (Dev → QA), Developer/Completion Handoff (QA → Dev)
- **Best for**: Mature projects with stable architecture, clear requirements

**Three-Terminal Workflow** (Orchestrator + Dev + QA):
- **Use when**: Stories need research, complex planning, test vetting, or multi-agent coordination
- **Terminals**: Orchestrator terminal (planning + vetting) → Dev terminal (implementation) → QA terminal (validation)
- **Handoffs**: Story Handoff (Orchestrator → Dev), QA Handoff (Dev → QA), Test Review Handoff (Orchestrator → QA/Dev), Developer/Completion Handoff (QA → Dev)
- **Best for**: Greenfield projects, complex features, research-heavy stories, learning new technologies

---

## Terminal Roles and Responsibilities

### Terminal 1: Orchestrator Terminal

**Agent**: BMad Orchestrator (Alex)

**Primary Responsibilities**:
1. **Epic Planning**: Break down PRD into epics with acceptance criteria
2. **Context7 Research**: Investigate libraries, patterns, best practices for upcoming stories
3. **Story Creation**: Generate comprehensive story files with technical context (via `*create-story`)
4. **Test Vetting**: Review Dev's test scenarios for coverage and completeness (via `*vet-tests`)
5. **Coordination**: Manage handoffs between Dev and QA, track overall progress

**Key Commands**:
- `*create-story` - Create next story from epic with Context7 research
- `*vet-tests {story}` - Review test scenarios and approve/revise
- `*agent pm` - Transform to PM for PRD work
- `*agent architect` - Transform to Architect for architecture decisions

**Outputs**:
- Story files (docs/stories/{epic}.{story}.story.md)
- Story Handoff (copy-paste block for Dev terminal)
- Test Review Handoff (APPROVE → QA or REVISE → Dev)

**When to Use**:
- Beginning of new epic
- Complex features requiring research
- After Dev writes test scenarios (vetting phase)
- Coordinating fixes between Dev and QA

---

### Terminal 2: Dev Terminal

**Agent**: James (Dev Agent)

**Primary Responsibilities**:
1. **Story Implementation**: Execute tasks from story file sequentially
2. **Test Writing**: Create Vitest unit tests (if complex logic) + E2E test scenarios (markdown)
3. **Background Processes**: Start and manage all required processes (frontend, backend, workers)
4. **QA Handoff**: Output structured handoff with what was done, files to check, processes running

**Key Commands**:
- `*develop-story {story-file}` - Implement story following develop-story workflow
- `*review-qa` - Apply QA fixes after receiving Developer Handoff from QA

**Outputs**:
- Source code (implementation files)
- Vitest tests (docs/qa/unit/... .test.ts files)
- E2E test scenarios (docs/qa/e2e/... markdown files)
- QA Handoff (copy-paste block for QA terminal)

**When to Use**:
- After receiving Story Handoff from Orchestrator
- After receiving Developer Handoff from QA (fix mode)
- Continuous implementation during active story development

---

### Terminal 3: QA Terminal

**Agent**: Quinn (QA Agent)

**Primary Responsibilities**:
1. **Test Execution**: Run Vitest unit tests, execute E2E scenarios via Playwright MCP
2. **Quality Gates**: Create gate files (PASS/CONCERNS/FAIL) based on test results
3. **Evidence Collection**: Capture screenshots, console logs, error states
4. **Feedback Handoff**: Output Developer Handoff (issues found) or Completion Handoff (all pass)

**Key Commands**:
- `*review {story}` - Comprehensive QA review with active refactoring
- `*gate {story}` - Update quality gate after Dev fixes issues

**Outputs**:
- Quality gate files (docs/qa/gates/sprint-N/epics/epic-N/{epic}.{story}-{slug}.yml)
- Evidence (screenshots, logs in docs/qa/evidence/)
- Developer Handoff (issues → Dev) OR Completion Handoff (approved → Dev for commit)

**When to Use**:
- After receiving QA Handoff from Dev
- After Dev applies fixes (re-test phase)
- Final approval before commit

---

## Workflow Patterns

### Pattern 1: Story Creation → Implementation → QA (Standard Flow)

**Sequence**:

1. **Orchestrator Terminal**:
   - Run `*create-story`
   - Orchestrator creates story file, researches with Context7 if needed
   - Create detailed **Story Handoff document** (docs/handoffs/sprint-N/epics/epic-N/{story}-story-handoff.md)
   - Output compact **Story Handoff snippet** to terminal with document reference
   - HALT (wait for Dev to implement)

2. **Dev Terminal**:
   - Copy Story Handoff snippet from Orchestrator terminal
   - Read full Story Handoff document for comprehensive implementation context
   - Run `*develop-story {story-file}`
   - Dev implements features, writes Vitest tests (if complex logic), writes E2E test scenarios (markdown)
   - Dev starts all background processes (frontend, backend, workers)
   - Dev verifies processes running, records PIDs and URLs
   - Create detailed **QA Handoff document** (docs/handoffs/sprint-N/epics/epic-N/{story}-qa-handoff.md)
   - Output compact **QA Handoff snippet** to terminal with document reference
   - HALT (wait for QA to test)

3. **QA Terminal**:
   - Copy QA Handoff snippet from Dev terminal
   - Read full QA Handoff document at path specified in snippet for comprehensive context
   - Verify background processes running (check URLs, confirm PIDs)
   - Run Vitest tests first (`npm run test` if exists)
   - Execute E2E scenarios via Playwright MCP tools (navigate, screenshot, console logs)
   - Create quality gate file (PASS/CONCERNS/FAIL)
   - If FAIL/CONCERNS: Create detailed **Developer Handoff document** + output compact snippet with issues → Go to Step 4
   - If PASS: Create detailed **Completion Handoff document** + output compact snippet with approval → Go to Step 5

4. **Dev Terminal** (Fix Mode):
   - Copy Developer Handoff snippet from QA terminal
   - Read full Developer Handoff document for detailed issue context
   - Fix issues in priority order
   - Re-run tests locally
   - Create new detailed **QA Handoff document** (overwrite previous)
   - Output new compact **QA Handoff snippet** to terminal
   - HALT (QA re-tests) → Return to Step 3

5. **Dev Terminal** (Completion):
   - Copy Completion Handoff from QA terminal
   - Commit with suggested message
   - Update story status to "Done"
   - Close story

**Duration**: 1-3 iterations (typically 1 if well-planned, 2-3 if edge cases found)

---

### Pattern 2: Story Creation → Test Vetting → Implementation → QA (With Vetting)

**Sequence**:

1. **Orchestrator Terminal** (Story Creation):
   - Run `*create-story`
   - Create detailed **Story Handoff document** + output compact snippet → Copy to Dev terminal

2. **Dev Terminal** (Implementation + Test Writing):
   - Copy Story Handoff snippet + read full document
   - Run `*develop-story {story-file}`
   - Dev implements features
   - Dev writes E2E test scenarios (markdown files in docs/qa/e2e/)
   - **PAUSE before starting background processes** (test vetting phase)
   - Inform Orchestrator: "Story {epic}.{story} implemented. E2E scenarios written. Ready for test vetting."

3. **Orchestrator Terminal** (Test Vetting):
   - Run `*vet-tests {story-file}`
   - Review E2E test scenarios for coverage
   - Check each AC has test cases, verify edge cases covered
   - If gaps found: Create detailed **Test Review Handoff (REVISE) document** + output compact snippet → Copy to Dev terminal → Go to Step 4
   - If complete: Create detailed **Test Review Handoff (APPROVE) document** + output compact snippet → Copy to QA terminal → Go to Step 5

4. **Dev Terminal** (Add Missing Test Scenarios):
   - Copy Test Review Handoff snippet + read full document for gap details
   - Add missing test scenarios as specified
   - Inform Orchestrator: "Test scenarios updated. Ready for re-vetting."
   - Return to Step 3 (Orchestrator re-vets)

5. **Dev Terminal** (Background Processes + QA Handoff):
   - After Test Review Handoff (APPROVE) received
   - Start all background processes
   - Create detailed **QA Handoff document** + output compact snippet → Copy to QA terminal

6. **QA Terminal** (Testing):
   - Follow Pattern 1, Step 3 (standard QA workflow)

**Duration**: 2-4 iterations (vetting adds 1 iteration, but reduces QA rework)

**When to Use This Pattern**:
- High-stakes features (payment, auth, data integrity)
- First few stories in a new project (establish test quality standards)
- When learning new testing patterns
- Complex user journeys with many edge cases

---

### Pattern 3: Research → Story Creation → Implementation → QA (Research-Heavy)

**Sequence**:

1. **Orchestrator Terminal** (Research Phase):
   - Before running `*create-story`, conduct Context7 research
   - Example: "use context7 - What's the best approach for implementing real-time notifications with Next.js App Router and Supabase?"
   - Example: "use context7 - How do I handle file uploads over 50MB with progress tracking in Next.js?"
   - Document findings in notes (not in story yet)

2. **Orchestrator Terminal** (Story Creation with Research):
   - Run `*create-story`
   - Include research findings in story Dev Notes section
   - Specify recommended libraries, patterns, constraints based on research
   - Create detailed **Story Handoff document** with comprehensive research findings
   - Output compact **Story Handoff snippet** to terminal with research summary
   - Example in snippet: "🔍 Research: Supabase has 50MB upload limit via API, use direct S3 upload with signed URLs (Context7)"

3. **Dev Terminal** (Implementation):
   - Follow Pattern 1, Step 2 (standard implementation)
   - Dev uses research findings from story Dev Notes to implement correctly

4. **QA Terminal** (Testing):
   - Follow Pattern 1, Step 3 (standard QA workflow)

**Duration**: 1-3 iterations (research upfront reduces Dev trial-and-error)

**When to Use This Pattern**:
- New technology stack or library
- Unclear best practices for feature
- Performance/scalability concerns
- Integration with third-party services

---

## Handoff Reference

**See**: `.bmad-core/data/handoff-templates.md` for full handoff format templates

**Quick Reference**:

| Handoff Type | From | To | When | Key Info |
|--------------|------|-----|------|----------|
| Story Handoff | Orchestrator | Dev | Story created | Story path, scope, research, guidance |
| QA Handoff | Dev | QA | Implementation done | Tasks done, files, tests, process URLs + PIDs |
| Developer Handoff | QA | Dev | Issues found | Gate status (FAIL/CONCERNS), issues, evidence, fix needed |
| Completion Handoff | QA | Dev | All tests pass | Gate status (PASS), test summary, commit message |
| Test Review Handoff | Orchestrator | QA or Dev | Test vetting done | Coverage status, gaps (if any), APPROVE or REVISE |

---

## Best Practices

### For Orchestrator Terminal

1. **Use Context7 Proactively**: Research before creating stories, not during implementation
2. **Detailed Story Handoffs**: Include implementation hints, architecture patterns, risks
3. **Strict Test Vetting**: Don't approve test scenarios with obvious gaps (AC without test case)
4. **Document Decisions**: When research leads to technical decisions, document in story Dev Notes

### For Dev Terminal

1. **Read Story Handoff First**: Don't skip research findings or implementation guidance
2. **Write Tests Before Handoff**: Never output QA Handoff without E2E scenarios written
3. **Verify Processes Running**: Check URLs accessible, record actual PIDs (not shell_id)
4. **Compact Handoffs**: Use handoff template format, keep under 15 lines

### For QA Terminal

1. **Check Processes First**: Before testing, verify all URLs from QA Handoff are accessible
2. **Vitest Before E2E**: Always run unit tests first (faster feedback)
3. **Evidence Collection**: Screenshot every failure, capture console errors, document steps
4. **Specific Issues in Developer Handoff**: Use TC{AC}.{case} references, describe briefly

### Terminal Management

1. **Keep Terminals Focused**: Orchestrator = planning only, Dev = implementation only, QA = testing only
2. **Don't Mix Contexts**: Don't use Dev terminal for story creation or QA terminal for code fixes
3. **Preserve Conversations**: Each terminal maintains its own conversation history
4. **Handoff = Context Transfer**: Copy-paste handoff blocks, don't retype or summarize

---

## Common Anti-Patterns (Avoid These)

❌ **Orchestrator Creates Story Without Research** (for complex features)
- **Problem**: Dev encounters unknown issues during implementation, has to stop and research
- **Solution**: Orchestrator researches with Context7 first, includes findings in Story Handoff

❌ **Dev Outputs QA Handoff Without Starting Processes**
- **Problem**: QA can't test, has to ask Dev to start processes
- **Solution**: Dev MUST start all processes before QA Handoff (checklist item enforces this)

❌ **Dev Skips Test Scenario Writing**
- **Problem**: QA has no guidance on what to test, misses edge cases
- **Solution**: E2E scenarios are mandatory for all user-facing features (not optional)

❌ **QA Tests Without Checking Processes First**
- **Problem**: QA wastes time testing against dead processes, thinks feature is broken
- **Solution**: QA verifies all URLs accessible before starting test execution

❌ **Orchestrator Approves Incomplete Test Scenarios**
- **Problem**: QA executes tests, finds missing coverage, Dev has to add more tests
- **Solution**: Orchestrator vets strictly (each AC must have test cases, edge cases covered)

❌ **Dev Forgets to Output QA Handoff**
- **Problem**: QA doesn't know what was done, which files to check, what's running
- **Solution**: story-dod-checklist.md enforces QA Handoff output (section 8)

---

## Migration from Two-Terminal to Three-Terminal

**When to Migrate**:
- Project complexity increasing (need more planning)
- Team wants to separate concerns (planning vs coding vs testing)
- Learning new tech stack (research-heavy stories)
- Quality issues from insufficient test coverage

**Migration Steps**:

1. **Add Orchestrator Terminal**: Open third Claude Code terminal, activate Orchestrator agent
2. **Update Workflow**: Use Orchestrator for story creation (instead of SM agent)
3. **Keep Dev + QA As-Is**: Two-terminal handoffs still work (Orchestrator just adds story creation step)
4. **Optional Test Vetting**: Use `*vet-tests` for high-stakes stories only initially
5. **Full Adoption**: Once comfortable, use Orchestrator for all stories + test vetting

**Backwards Compatibility**: Two-terminal workflow still works (Dev can create stories via SM agent if needed)

---

## Troubleshooting

### "Orchestrator can't create stories"

**Symptoms**: `*create-story` command not found, Orchestrator says it can't create stories

**Solution**: Orchestrator must have `create-next-story.md` in dependencies. Check `.bmad-core/agents/bmad-orchestrator.md` line 154 has `- create-next-story.md`

---

### "Dev forgets to start background processes"

**Symptoms**: QA Handoff missing process URLs, QA can't test

**Solution**:
- Check dev.md line 69 has CRITICAL Background Process Management instruction
- Check story-dod-checklist.md section 8 has process management items
- Dev runs `*develop-story` which enforces checklist completion

---

### "QA doesn't know which files to check"

**Symptoms**: QA Handoff missing file list, QA asks Dev for file locations

**Solution**: QA Handoff template requires "📁 Check: {Key files for QA to review}". Dev must list files explicitly.

---

### "Test Review Handoff not working"

**Symptoms**: Orchestrator doesn't output Test Review Handoff, just comments on tests

**Solution**: Orchestrator must explicitly use handoff template from `.bmad-core/data/handoff-templates.md`. Check orchestrator.md line 59 has Test Vetting Workflow instruction.

---

## Additional Resources

- **Handoff Templates**: `.bmad-core/data/handoff-templates.md` - All handoff formats with examples
- **Dev Agent Guide**: `.bmad-core/agents/dev.md` - Dev responsibilities and workflows
- **QA Agent Guide**: `.bmad-core/agents/qa.md` - QA commands and testing protocols
- **Orchestrator Agent Guide**: `.bmad-core/agents/bmad-orchestrator.md` - Orchestrator commands and coordination
- **Testing Stack Guide**: `.bmad-core/data/testing-stack-guide.md` - Vitest + Playwright MCP hybrid approach

---

**Version**: 1.0
**Last Updated**: 2025-11-04
