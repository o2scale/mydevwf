# Terminal Isolation Workflow Guide

**Created**: 2025-11-19 00:49:40
**Type**: Workflow Guide
**Context**: Strategic pattern for managing context and preventing compaction in multi-story epics

---

## Executive Summary

The **Terminal Isolation Workflow** is a strategic pattern where each story in a multi-story epic runs in a **fresh Dev terminal**, preventing context accumulation and compaction. This mirrors the subagent architecture principle: context isolation through handoff-based communication.

**Key Principle**: Orchestrator accumulates story handoffs (5-10k each), Dev/QA terminals dispose after each story (200k context freed).

---

## The Problem: Context Accumulation Across Stories

### Traditional Approach (Single Dev Terminal)

```
Dev Terminal (continuous across multiple stories):
├── Story 2.1: 0k → 150k (complete)
├── Story 2.2: 150k → COMPACTION → Format lost
├── Story 2.3: 170k → COMPACTION AGAIN
└── Story 2.4: 180k → Multiple compactions, chaos

Problems:
❌ Context accumulates across stories
❌ Story 2.1 implementation pollutes Story 2.2 context
❌ Compaction loses handoff formats, workflow knowledge
❌ Dev "remembers" too much (cognitive overload)
❌ Cannot cleanly separate story concerns
```

### Root Cause

**Claude Code context window**: 200,000 tokens (155,000 usable after system overhead)

**Story implementation**: Typically 100-150k tokens (story + architecture + code + tests)

**Result**: 2-3 stories = compaction inevitable

---

## The Solution: Fresh Terminal Per Story

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│  TERMINAL 1: ORCHESTRATOR                               │
│  • Lifespan: ENTIRE EPIC (all stories)                  │
│  • Context: Epic + story handoffs (accumulates)         │
│  • Role: Planning, research, story creation, handoffs   │
│  • Peak Context: 30k epic + 20k arch + 50k handoffs     │
│                  = 100k for 10 stories (SAFE)           │
└─────────────────────────────────────────────────────────┘
                       │
              Story Handoff (5-10k)
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│  TERMINAL 2: DEV (Fresh per story) ← KEY INSIGHT        │
│  • Lifespan: SINGLE STORY ONLY                          │
│  • Context: Story + implementation (starts 0k)          │
│  • Role: Implementation, testing, QA Handoff            │
│  • Peak Context: 150-170k per story                     │
│  • After story: CLOSE TERMINAL → Context DISPOSED       │
└─────────────────────────────────────────────────────────┘
                       │
               QA Handoff (5-10k)
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│  TERMINAL 3: QA (Fresh per story)                       │
│  • Lifespan: SINGLE STORY ONLY                          │
│  • Context: Story + test execution + validation         │
│  • Role: Testing, evidence, gate decision               │
│  • Peak Context: 80-100k per story                      │
│  • After story: CLOSE TERMINAL → Context DISPOSED       │
└─────────────────────────────────────────────────────────┘
```

---

## How It Works: Epic 2 Example

### Orchestrator Terminal (Stays Open)

**Session spans entire Epic 2 (Stories 2.1 - 2.5)**:

```
Context accumulation over time:
├── Epic 2 file: 30k (loaded once)
├── Architecture context: 20k (loaded once)
├── Story 2.1 Handoff (created): 5k
├── Story 2.1 Completion (received): 5k
├── Story 2.2 Handoff (created): 5k
├── Story 2.2 Completion (received): 5k
├── Story 2.3 Handoff (created): 5k
├── Story 2.3 Completion (received): 5k
├── Story 2.4 Handoff (created): 5k
├── Story 2.4 Completion (received): 5k
├── Story 2.5 Handoff (created): 5k
└── Story 2.5 Completion (received): 5k

Total after 5 stories: 30k + 20k + (5k × 10 handoffs) = 100k
NO COMPACTION (context stays manageable across weeks)
```

**Orchestrator knows**:
- ✅ What each story accomplished (from completion handoffs)
- ✅ Dependencies between stories (Story 2.2 depends on 2.1)
- ✅ Epic progress (5/5 stories complete)
- ✅ High-level architecture (from handoff summaries)

**Orchestrator does NOT need**:
- ❌ How Story 2.1 implemented Docker configuration (implementation details)
- ❌ Exact test assertions for Story 2.3 (test code)
- ❌ Line-by-line code changes (already in git commits)

### Dev Terminal 1 (Story 2.1 Only)

**Lifespan**: Story 2.1 implementation only, then CLOSE

```
Context lifecycle:
├── Start: 0k (fresh terminal)
├── Receive Story Handoff from Orchestrator: 5k
├── Read story file: 20k
├── Load architecture docs: 30k
├── Load coding standards: 10k
├── Implementation (3 Dockerfiles, docker-compose): 60k
├── Write E2E test scenarios: 10k
├── Documentation (DOCKER_README, RAILWAY_DEPLOYMENT): 10k
├── Create QA Handoff (detailed doc + compact snippet): 10k
└── Total: 155k / 200k (78% - no compaction)

Handoff to QA → CLOSE TERMINAL → 155k context DISPOSED
```

**Output**: QA Handoff (5-10k compact snippet)

### Dev Terminal 2 (Story 2.2, FRESH START)

**Lifespan**: Story 2.2 implementation only, then CLOSE

```
Context lifecycle:
├── Start: 0k (NEW FRESH TERMINAL - no Story 2.1 context!)
├── Receive Story Handoff from Orchestrator: 5k
├── Read story file: 20k
├── Load architecture docs: 30k (same files, reloaded)
├── Load coding standards: 10k
├── Implementation (media processors, factory pattern): 70k
├── Write Vitest tests: 15k
├── Write E2E scenarios: 10k
├── Create KB entry: 5k
├── Create QA Handoff: 10k
└── Total: 175k / 200k (87% - still no compaction)

Handoff to QA → CLOSE TERMINAL → 175k context DISPOSED
```

**Key Point**: Dev Terminal 2 does NOT have Story 2.1's 155k context. It's completely fresh!

### QA Terminal (Fresh Per Story)

**Lifespan**: Single story validation, then CLOSE

```
Story 2.2 QA:
├── Start: 0k (fresh)
├── Receive QA Handoff from Dev: 5k
├── Read detailed handoff document: 25k
├── Load testing guide: 10k
├── Run Vitest tests: 5k (execution, not reading code)
├── Execute E2E scenarios via Playwright MCP: 20k
├── Collect evidence (screenshots, logs): 10k
├── Create Completion Handoff or Developer Handoff: 10k
└── Total: 85k / 200k (42% - very safe)

Handoff to Orchestrator → CLOSE TERMINAL → 85k context DISPOSED
```

---

## Workflow Steps

### 1. Orchestrator Creates Story

**In Orchestrator Terminal** (already open from epic start):

```bash
/BMad/agents/orchestrator
*create-story
```

**Orchestrator**:
1. Reads Epic 2 file (if not already loaded)
2. Reviews previous story completions (understands what's done)
3. Uses Context7 MCP for research (if needed)
4. Creates next story file
5. Creates Story Handoff (detailed doc + compact snippet)
6. Outputs compact snippet to terminal

**Story Handoff Format**:
```
═══ STORY HANDOFF: 2.2-UNIFIED-MEDIA-FOUNDATION ═══
📋 Story: 2.2-unified-media-foundation | docs/stories/sprint-2/epics/epic-2/2.2.story.md
📄 Full Handoff: docs/handoffs/sprint-2/epics/epic-2/2.2-unified-media-foundation-story-handoff.md
📅 Created: 2025-11-19 00:45:00 | 👤 Orchestrator
🎯 Objective: Create base media processing classes (audio, video, document)
🔍 Context7: Google Cloud Storage SDK, FFmpeg Python wrapper patterns
📁 Files: services/media/base.py, audio.py, video.py, document.py
💡 Guidance: Factory pattern per architecture, async processing, GCS integration
🔗 Dependencies: Story 2.1 Docker infrastructure (completed ✅)
📋 Tasks: 5 tasks (Media base class, Audio processor, Video processor, Document processor, Tests)
═══ COPY TO DEV TERMINAL ═══
```

**User copies this snippet** (ready to paste in fresh Dev terminal)

### 2. Open Fresh Dev Terminal

**User starts NEW conversation**:

```bash
# In NEW terminal/tab
/BMad/agents/dev
```

**Dev agent activates** (fresh 200k context):
- Loads always-required files (architecture, standards, testing guide): ~50k
- Greets user
- Ready for Story Handoff

### 3. Dev Receives Story Handoff

**User pastes Story Handoff snippet** from Orchestrator

**Dev agent**:
1. Reads compact snippet (5k)
2. Loads story file: `docs/stories/.../2.2.story.md` (20k)
3. (Optional) Reads detailed handoff document if needed (25k)
4. **Current context**: 50k (always-files) + 5k (snippet) + 20k (story) = 75k
5. Ready to implement

### 4. Dev Implements Story

**Dev executes**: `/BMad/tasks/execute-checklist docs/stories/.../2.2.story.md`

**Implementation** (~80k context):
- Reads story tasks
- Implements features
- Writes Vitest tests (if complex logic)
- Writes E2E test scenarios (markdown)
- Creates KB entry (if applicable)
- Validates against DoD checklist

**Total context**: 75k + 80k = 155k (safe, no compaction)

### 5. Dev Creates QA Handoff

**After implementation complete**, Dev:
1. Starts background processes (frontend, backend if needed)
2. Creates detailed QA Handoff document (200-300 lines)
3. Commits handoff to git
4. Creates compact QA Handoff snippet (10-15 lines)
5. Outputs snippet to terminal
6. **HALTS** (does not run tests)

**QA Handoff Snippet**:
```
═══ QA HANDOFF ═══
📋 Story: 2.2-unified-media-foundation | docs/stories/...
📄 Full Handoff: docs/handoffs/sprint-2/epics/epic-2/2.2-...-qa-handoff.md
📅 Handed Off: 2025-11-19 01:15:30 | 👤 James (Dev Agent)
✅ Done: Media processors (4 classes), factory pattern, GCS integration
📁 Check: services/media/base.py, audio.py, video.py, document.py
🧪 Tests: 8 Vitest (media.test.ts), 6 E2E (docs/qa/e2e/.../story-2.2/)
🚀 Running: http://localhost:5173 (PID: 12345), http://localhost:8000 (PID: 12346)
🔄 Backend: Restarted ✅ at 2025-11-19 01:14:50 (PID: 12346, Modified: services/media/*)
💡 Focus: Factory pattern correctness, async processing, GCS upload/download
═══ COPY TO QA TERMINAL ═══
```

**User copies this snippet**

### 6. CLOSE Dev Terminal

**CRITICAL STEP**: User closes Dev terminal conversation

**Result**: 155k context DISPOSED, only QA Handoff snippet remains (in clipboard)

### 7. Open Fresh QA Terminal

**User starts NEW conversation**:

```bash
# In NEW terminal/tab
/BMad/agents/qa
```

**QA agent activates** (fresh 200k context):
- Loads testing guide, handoff templates, git workflow: ~40k
- Greets user
- Ready for QA Handoff

### 8. QA Tests Story

**User pastes QA Handoff snippet**

**QA agent**:
1. Reads compact snippet (5k)
2. Reads detailed handoff document (25k)
3. Runs Vitest tests: `npm run test` (5k)
4. Executes E2E scenarios via Playwright MCP (20k)
5. Collects evidence (screenshots, console logs) (10k)
6. Makes gate decision (PASS, FAIL, CONCERNS)

**Total context**: 40k + 5k + 25k + 40k = 110k (safe)

### 9. QA Creates Completion/Developer Handoff

**If PASS**:
- Creates Completion Handoff (10-15 lines)
- Optionally commits story (Commit Point 3)
- Outputs snippet to terminal

**If FAIL/CONCERNS**:
- Creates Developer Handoff with issues (10-15 lines + detailed doc)
- Outputs snippet to terminal

**Completion Handoff Snippet**:
```
═══ COMPLETION HANDOFF ═══
📋 Story: 2.2-unified-media-foundation | PASS ✅
📄 Full Handoff: docs/handoffs/.../2.2-...-completion-handoff.md
📅 Completed: 2025-11-19 02:30:15 | 👤 Quinn (QA Agent)
✅ Gate: PASS (all tests pass, DoD met)
🧪 Results: 8/8 Vitest ✅, 6/6 E2E ✅
📸 Evidence: docs/qa/evidence/sprint-2/epics/epic-2/story-2.2/
💬 Summary: Factory pattern correct, async works, GCS integration tested
🎯 Next: Story complete, ready for next story
═══ COPY TO ORCHESTRATOR TERMINAL ═══
```

### 10. CLOSE QA Terminal

**User closes QA terminal conversation**

**Result**: 110k context DISPOSED

### 11. Orchestrator Receives Completion

**User pastes Completion Handoff** in Orchestrator terminal (still open)

**Orchestrator**:
- Reads Completion Handoff (5k)
- Marks Story 2.2 complete
- **Current context**: 100k + 5k = 105k (still very safe)
- Ready to create Story 2.3

**REPEAT** steps 1-11 for each subsequent story in epic

---

## Context Math: Why This Works

### Without Terminal Isolation (Traditional)

```
Dev Terminal (continuous):
Story 2.1: 0k → 155k
Story 2.2: 155k → 330k → COMPACTION (context lost)
Story 2.3: 170k → 340k → COMPACTION AGAIN
Story 2.4: 180k → 360k → Multiple compactions
Story 2.5: 190k → 380k → Complete chaos

Result: Format loss, workflow degradation, context pollution
```

### With Terminal Isolation (This Pattern)

```
Orchestrator (continuous):
Start: 50k (epic + architecture)
Story 2.1: +10k (story handoff + completion) = 60k
Story 2.2: +10k = 70k
Story 2.3: +10k = 80k
Story 2.4: +10k = 90k
Story 2.5: +10k = 100k
After 5 stories: 100k / 200k (50% capacity, NO COMPACTION)

Dev Terminal 1 (Story 2.1 only): 0k → 155k → CLOSE → DISPOSED
Dev Terminal 2 (Story 2.2 only): 0k → 175k → CLOSE → DISPOSED
Dev Terminal 3 (Story 2.3 only): 0k → 160k → CLOSE → DISPOSED
Dev Terminal 4 (Story 2.4 only): 0k → 165k → CLOSE → DISPOSED
Dev Terminal 5 (Story 2.5 only): 0k → 170k → CLOSE → DISPOSED

Result: No compaction ever, clean context per story
```

### Scalability

**Orchestrator can handle**:
- 10 stories: 50k base + 100k handoffs = 150k (75% capacity)
- 15 stories: 50k base + 150k handoffs = 200k (100% - at limit)
- **Solution for 15+ stories**: Create session log at 80%, compact Orchestrator, continue

**Each Dev/QA terminal**: Fresh 200k every time

---

## Comparison to Subagent Architecture

This pattern mirrors the subagent architecture at the **story level**:

### Task-Level Subagents (Within Story)

```
Main Dev Agent → Subagent 1 (Task 1) → Handoff (5k) → Disposed
              → Subagent 2 (Task 2) → Handoff (5k) → Disposed
              → Subagent 3 (Task 3) → Handoff (5k) → Disposed

Main agent accumulates handoffs: 15k
Each subagent context: DISPOSED after task
```

### Story-Level Isolation (Across Epic)

```
Orchestrator → Dev 1 (Story 2.1) → QA Handoff (5k) → Disposed
            → Dev 2 (Story 2.2) → QA Handoff (5k) → Disposed
            → Dev 3 (Story 2.3) → QA Handoff (5k) → Disposed

Orchestrator accumulates handoffs: 30k
Each Dev/QA context: DISPOSED after story
```

**Same principles**:
1. ✅ Context isolation (fresh start per unit of work)
2. ✅ Handoff-based communication (compact, structured)
3. ✅ Orchestrator accumulates summaries only (not full context)
4. ✅ No compaction risk (terminals disposed before limit)
5. ✅ Scalability (unlimited stories/tasks)

---

## Critical Success Factors

### 1. Story Handoff Quality

**Story Handoff MUST be**:
- **Compact**: 5-10k tokens (not 50k)
- **Complete**: All necessary context for Dev
- **Actionable**: Clear guidance, dependencies, research findings
- **Structured**: Consistent emoji format

**Template**: See `.bmad-core/data/handoff-templates.md` (Story Handoff section)

### 2. Discipline to Close Terminals

**After each story**:
- ✅ Dev creates QA Handoff
- ✅ User copies snippet
- ✅ **User CLOSES Dev terminal** (critical!)
- ✅ User opens fresh QA terminal
- ✅ QA completes, creates Completion Handoff
- ✅ **User CLOSES QA terminal** (critical!)

**Why closing matters**:
- Ensures context is truly disposed
- Forces reliance on handoffs (validates quality)
- Prevents accidental context accumulation
- Reinforces clean separation of concerns

### 3. Orchestrator Context Management

**If Orchestrator approaches 80% context** (after 10-15 stories):
1. Create session log: `docs/session-logs/SESSION-LOG-EPIC-2-{DATE}.md`
2. Include: All story handoffs, completion summaries, decisions
3. Inform user: "Orchestrator at 80%, session log created"
4. Compact conversation (or continue, knowing session log exists)
5. Reference session log for historical context if needed

---

## Benefits

### 1. No Compaction

**Ever**. Each Dev/QA terminal closes before reaching compaction threshold.

### 2. Context Isolation

**Story 2.3 Dev doesn't "remember"**:
- ❌ How Story 2.1 implemented Docker configuration
- ❌ Story 2.2's media processor implementation details
- ❌ Old discussions about alternative approaches

**Story 2.3 Dev DOES know** (from Story Handoff):
- ✅ Dependencies met (Stories 2.1, 2.2 complete)
- ✅ Architectural decisions (factory pattern, async processing)
- ✅ Context7 research findings (latest best practices)

### 3. Format Consistency

**Because terminals close before compaction**:
- ✅ Handoff formats never lost
- ✅ Dev always has fresh template knowledge
- ✅ QA always has fresh testing guide
- ✅ No degradation over time

### 4. Scalability

**Orchestrator can handle entire epic** (10-15 stories) in single conversation:
- Accumulates only handoffs (5k each)
- Total context: 50k base + 150k handoffs (15 stories) = 200k

**For epics with 20+ stories**:
- Create session log at story 15
- Compact Orchestrator
- Continue with fresh context
- Session log preserves all story handoffs

### 5. Clean Mental Model

**Each story is isolated**:
- Fresh terminal = fresh context
- Story Handoff = entry point
- QA Handoff = exit point
- Close terminal = disposal

**Easy to understand**: "One story, one Dev terminal"

---

## When to Use This Pattern

### ✅ Use Terminal Isolation For:

1. **Multi-story epics** (3+ stories)
2. **Complex stories** (100k+ context each)
3. **Long-running epics** (spanning weeks)
4. **Stories with dependencies** (need clean handoffs)
5. **Production brownfield projects** (high context load)

### ⚠️ Optional for:

1. **Single-story work** (no epic context)
2. **Quick fixes** (single story, minimal context)
3. **Exploration/prototyping** (not following workflow)

### ❌ Not Needed for:

1. **Non-story work** (documentation, research)
2. **Planning sessions** (PM, Architect, UX Expert)
3. **QA-only tasks** (review without implementation)

---

## Troubleshooting

### Issue: Dev Terminal Context Still High

**Symptom**: Dev terminal reaches 180k+ context for single story

**Causes**:
- Loading too many existing files (brownfield)
- Reading entire codebase (use targeted reads)
- Story too large (should be split)

**Solutions**:
1. Use subagent architecture within story (task-level isolation)
2. Split story into smaller stories
3. Use session logs for research phase
4. Read files selectively (not entire codebase)

### Issue: Story Handoff Too Large

**Symptom**: Story Handoff is 30k+ tokens (should be 5-10k)

**Causes**:
- Orchestrator including too much detail
- Research findings not summarized
- Copy-pasting entire Context7 responses

**Solutions**:
1. Reference detailed handoff document (don't inline)
2. Summarize Context7 findings (key takeaways only)
3. Use compact snippet format strictly

### Issue: Dev Doesn't Have Enough Context

**Symptom**: Dev asks questions already answered in previous stories

**Causes**:
- Story Handoff missing dependencies section
- Detailed handoff document incomplete
- Orchestrator not reviewing previous completions

**Solutions**:
1. Orchestrator reviews previous story completions before creating new story
2. Include dependencies section in Story Handoff
3. Reference KB entries if pattern established
4. Link to previous story handoffs if needed

---

## Related Documentation

- **Handoff Templates**: `.bmad-core/data/handoff-templates.md` (Story Handoff, QA Handoff, Completion Handoff)
- **Three-Terminal Workflow**: `.bmad-core/data/three-terminal-workflow.md` (complete workflow patterns)
- **Workflow Reference**: `docs/guides/WORKFLOW-REFERENCE.md` (general workflow examples)
- **Context Loss Analysis**: `docs/planning/CONTEXT-LOSS-COMPACTION-ANALYSIS.md` (why this pattern solves compaction)
- **Subagent Architecture**: (future) Task-level isolation within stories

---

## Quick Reference

### Story Lifecycle (Dev)

```
1. Orchestrator creates Story Handoff → Copy snippet
2. Open fresh Dev terminal → /BMad/agents/dev
3. Paste Story Handoff snippet → Dev loads context
4. Dev implements → /BMad/tasks/execute-checklist {story}
5. Dev creates QA Handoff → Copy snippet
6. CLOSE Dev terminal ← CRITICAL (context disposed)
```

### Story Lifecycle (QA)

```
1. Open fresh QA terminal → /BMad/agents/qa
2. Paste QA Handoff snippet → QA loads context
3. QA tests → Vitest + E2E scenarios
4. QA creates Completion/Developer Handoff → Copy snippet
5. CLOSE QA terminal ← CRITICAL (context disposed)
```

### Context Accumulation

```
Orchestrator: 50k base + (5k per story × N stories) = Total
Dev/QA: 0k fresh start → 150-180k peak → CLOSE → DISPOSED

Epic with 10 stories:
- Orchestrator: 50k + 100k = 150k (safe)
- Dev terminals: 10 × (fresh → close) = 0k accumulated
- QA terminals: 10 × (fresh → close) = 0k accumulated
```

---

**Pattern Status**: ✅ VALIDATED (hdav2 Story 2.1 → 2.2 transition)
**Recommended**: YES (for all multi-story epics)
**Last Updated**: 2025-11-19 00:49:40
