# .CONTEXT FOLDER - BRANCH CONTEXT ARCHITECTURE

**Created:** 2025-11-08
**Purpose:** Hierarchical context management for multi-threaded BMad IDE development
**Architecture:** Master (CLAUDE.md) → Branch Contexts → Session Logs

---

## WHY THIS ARCHITECTURE?

**Problem Solved:**
- BMad IDE has 4 parallel development threads (Workstation, Extension, Daemon, Framework)
- Each thread has distinct technical context and decision history
- Multiple terminals working on different aspects simultaneously
- Need to preserve context across conversation compactions

**Solution:**
- **CLAUDE.md** = Lean routing document (~3,000 tokens)
- **Branch contexts** = Self-contained context per development thread (~5,000 tokens each)
- **Session logs** = Daily work documentation with decisions, code, progress

---

## ARCHITECTURE DIAGRAM

```
CLAUDE.md (Master - 3,000 tokens)
     ↓ Routes to →
.context/
├── workstation-context.md      # BMad Workstation (Linux Terminal System)
├── extension-context.md         # VS Code Extension MVP
├── daemon-context.md            # Orchestration Daemon (Go)
├── framework-context.md         # BMad V4 Optimizations
└── sessions/                    # Session logs
    ├── 2025-11-08-workstation.md
    ├── 2025-11-08-framework.md
    └── archive/                 # Old session logs
     ↓ Point to →
Documentation & Code
├── docs/architecture/           # System architecture docs
├── docs/planning/               # Product roadmap, strategy
├── docs/research/               # Technical research
├── research-notes/              # Vision sessions
└── poc/                         # Proof of concept code
```

---

## BRANCH CONTEXTS (4 Total)

### 1. `workstation-context.md`
**What:** BMad Workstation - Linux terminal-based development OS
**Status:** Architecture complete, MVD pending
**Key Decisions:**
- Ubuntu 24.04 LTS + Hyprland + DankMaterialShell
- Three-terminal tmux layout (Orchestrator, Dev, QA)
- Go-based orchestration daemon
- Context pollution monitoring

**When to load:** Working on workstation architecture, Linux system design, DMS integration

### 2. `extension-context.md`
**What:** VS Code Extension - First-stage validation product
**Status:** Planning phase
**Key Decisions:**
- Stage 1 of two-stage architecture
- Validates agent cooperation assumption
- chokidar file watcher + prompt injection
- Dashboard UI for workflow monitoring

**When to load:** Working on VS Code extension, TypeScript implementation, extension API

### 3. `daemon-context.md`
**What:** Orchestration Daemon - Core automation engine
**Status:** Architecture design
**Key Decisions:**
- Go implementation (fsnotify, tmux control)
- Handoff detection & routing
- Context monitoring (3 warnings, 4 reloads)
- HTTP API for DMS integration

**When to load:** Working on orchestration daemon, Go code, tmux automation

### 4. `framework-context.md`
**What:** BMad V4 Optimizations - Framework improvements
**Status:** Production-ready, ongoing refinement
**Key Decisions:**
- Stay V4, cherry-pick V6 concepts
- Backend restart protocol
- Handoff reading optimization
- Dual-format handoffs (documents + snippets)

**When to load:** Working on BMad framework improvements, agent optimizations, workflow enhancements

---

## SESSION LOG WORKFLOW

**Purpose:** Preserve decisions, code, and context across conversation compactions

**Daily Workflow:**
1. **Start new thread:** Create session log (`.context/sessions/YYYY-MM-DD-{branch}.md`)
2. **Throughout work:** Document decisions, code changes, problems solved
3. **Conversation compaction:** Session log preserves full context
4. **End of thread:** Archive session log to `sessions/archive/`

**Session Log Template:**
```markdown
# Session Log: {Branch} - {Topic}

**Date:** YYYY-MM-DD
**Thread:** {branch-name}
**Status:** In Progress / Completed
**Key Decisions:** Brief summary

---

## Work Completed

[Chronological log of work]

## Decisions Made

[Key technical decisions with rationale]

## Code Changes

[Files created/modified with summaries]

## Next Steps

[What needs to happen next]
```

---

## MULTI-TERMINAL WORKFLOW

**Scenario:** Working on multiple threads simultaneously

**Terminal 1: Workstation Architecture**
```bash
# Load workstation context
# Work on Linux system design, DMS integration
```

**Terminal 2: Extension Development**
```bash
# Load extension context
# Work on VS Code extension, TypeScript code
```

**Terminal 3: Daemon Implementation**
```bash
# Load daemon context
# Work on Go orchestration daemon
```

**Terminal 4: Framework Optimization**
```bash
# Load framework context
# Work on BMad V4 improvements
```

**Benefits:**
- ✅ Each terminal has focused context (no bloat)
- ✅ Parallel development on different threads
- ✅ Context preserved across compactions via session logs
- ✅ Easy to resume work after breaks

---

## INTEGRATION WITH MAIN PROJECT

**BMad IDE is a sub-project of mydevwf repository:**

```
mydevwf/                         # Master repository
├── .bmad-core/                  # BMad framework (symlinked to projects)
├── project-templates/           # 4 production templates
├── docs/                        # Master repo docs
├── bmad-ide/                    # THIS PROJECT
│   ├── CLAUDE.md               # Master routing document
│   ├── .context/               # Branch contexts (THIS FOLDER)
│   ├── docs/                   # BMad IDE documentation
│   ├── research-notes/         # Vision sessions
│   └── poc/                    # Proof of concept code
└── CLAUDE.md                   # Master repo CLAUDE.md

```

**Context Loading Strategy:**
- When working on BMad IDE: Load `bmad-ide/CLAUDE.md` → Branch context
- When working on BMad framework: Load `mydevwf/CLAUDE.md` → Framework docs
- When working on both: Load both CLAUDE.md files

---

## BENEFITS OF THIS ARCHITECTURE

1. **Scalability** - Each thread can grow independently without bloating master CLAUDE.md
2. **Focus** - Load only relevant context for current work
3. **Multi-terminal** - Work on multiple threads in parallel
4. **Context Preservation** - Session logs survive conversation compactions
5. **Maintainability** - Update one branch without affecting others
6. **Onboarding** - New contributors load only relevant branch context
7. **Audit Trail** - Session logs provide complete history

---

**Architecture Version:** 1.0
**Last Updated:** 2025-11-08
**Status:** Production - Active Development
