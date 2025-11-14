# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working on BMad IDE development.

**Last Updated:** 2025-11-08 03:37:36

---

## Project Overview

**BMad IDE** - Agentic development environment for power users combining local-first development, automated agent handoffs, context pollution monitoring, and full transparency.

- **Vision:** Automated workflow orchestration while maintaining full user control
- **Strategy:** Two-stage architecture (VS Code Extension → Linux Terminal System)
- **Status:** Phase 0 - Architecture Definition & MVD Planning
- **Primary Dev:** Anjai Itty Jacob
- **Parent Project:** MyDevWF (d:\Dev\mydevwf)

---

## ⚠️ CRITICAL: Branch Context Architecture

**BMad IDE has 4 parallel development threads.** Each thread has its own context file in `.context/` folder.

### Active Threads:

| Thread | Context File | When to Load |
|--------|--------------|--------------|
| **BMad Workstation** | `.context/workstation-context.md` | Linux terminal system, Ubuntu+Hyprland+DMS, orchestration daemon architecture |
| **VS Code Extension** | `.context/extension-context.md` | Extension MVP, TypeScript/Node.js, file watcher, dashboard UI |
| **Orchestration Daemon** | `.context/daemon-context.md` | Go daemon, tmux control, handoff routing, context monitoring |
| **Framework Optimizations** | `.context/framework-context.md` | BMad V4 improvements, agent optimizations, workflow enhancements |

### How to Use Branch Contexts:

**Single Thread Work:**
1. Identify which thread you're working on
2. Read relevant `.context/{thread}-context.md` file
3. Work with focused context (not entire project)

**Multi-Terminal Work:**
- Terminal 1: Load `workstation-context.md` → Linux system design
- Terminal 2: Load `extension-context.md` → VS Code extension dev
- Terminal 3: Load `daemon-context.md` → Go orchestration daemon
- Terminal 4: Load `framework-context.md` → BMad framework improvements

**Cross-Thread Work:**
- Load multiple branch contexts as needed
- Each branch context documents integration points with other threads

**Architecture Details:** `.context/README.md`

---

## Two-Stage Architecture

### Stage 1: VS Code Extension (Months 1-3)
**Goal:** Validate core concept fast
- Market: 100M+ VS Code users
- Tech: TypeScript, chokidar file watcher, webview UI
- Validation: Prove agents respond to programmatic prompt injection ≥80% reliably

### Stage 2: Linux Terminal System (Months 4-12)
**Goal:** Revolutionary power-user platform
- Market: Terminal power users, Linux enthusiasts
- Tech: Ubuntu 24.04 LTS + Hyprland + DankMaterialShell + Go daemon + tmux
- Differentiation: Complete developer productivity OS

**Rationale:** Extension validates concept and generates revenue while we build Terminal System

---

## Critical Validation (MVD - Minimum Viable Demo)

**Timeline:** This Weekend
**Status:** ⏳ PENDING

**Goal:** Prove agents respond reliably to programmatic prompt injection

**Test Procedure:**
1. Create 3 handoff documents manually
2. Inject prompts into Claude Code terminals via tmux send-keys
3. Measure agent response rate
4. **GO/NO-GO:** ≥80% success → Proceed, <80% → Pivot immediately

**Why Critical:** Entire concept depends on this. If agents ignore injections >20% of time, system fails.

---

## Key Decisions Made

**Desktop Environment:** DankMaterialShell ✅
- One-command install, Ubuntu 24.04 LTS support, production-ready
- Rejected: Caelestia (complex, Ubuntu 25.10 only, alpha state)

**Base System:** Ubuntu Server 24.04 LTS + BTRFS + Hyprland ✅
- 5 years support, developer familiarity, AWS deployment capable

**Orchestration Language:** Go ✅
- Performance, single binary, excellent stdlib (fsnotify, tmux control)

**BMad Framework:** Stay V4, cherry-pick V6 concepts ✅
- V6 subagents have performance issues (20k overhead, lower quality)
- Port V6 TEA knowledge base, Story Context XML to V4

**Context Architecture:** Branch contexts in .context/ folder ✅
- Prevents context bloat, enables multi-terminal workflow
- Pattern proven in Mango Cabs project

---

## Documentation Structure

**Core Principle:** Hierarchical context management - Master CLAUDE.md routes to branch contexts, branch contexts point to detailed docs.

```
bmad-ide/
├── CLAUDE.md                        # THIS FILE - Master routing
├── README.md                        # Project overview
├── .context/                        # Branch contexts & session logs
│   ├── README.md                    # Architecture documentation
│   ├── workstation-context.md       # BMad Workstation thread
│   ├── extension-context.md         # VS Code Extension thread
│   ├── daemon-context.md            # Orchestration Daemon thread
│   ├── framework-context.md         # Framework Optimizations thread
│   └── sessions/                    # Daily work logs
│       ├── 2025-11-08-workstation.md
│       └── archive/
├── docs/
│   ├── architecture/                # System architecture docs
│   │   └── bmad-workstation-system-architecture.md
│   ├── planning/                    # Product roadmap, strategy
│   │   └── product-roadmap.md
│   ├── research/                    # Technical research
│   ├── design/                      # UI/UX design
│   └── api/                         # API specs
├── research-notes/                  # Vision sessions
│   └── 2025-11-08-bmad-ide-vision-session.md
├── poc/                             # Proof of concept code
└── assets/                          # Images, diagrams
```

**Key Locations:**
- Architecture: `docs/architecture/bmad-workstation-system-architecture.md`
- Product Roadmap: `docs/planning/product-roadmap.md`
- Vision Session: `research-notes/2025-11-08-bmad-ide-vision-session.md`
- Session Logs: `.context/sessions/YYYY-MM-DD-{thread}.md`

---

## Key Working Practices

1. **⚠️ Load relevant branch context** - Read `.context/{thread}-context.md` for focused work
2. **⚠️ Create session logs** - Document decisions in `.context/sessions/` for conversation compactions
3. **Check previous session logs** - Read yesterday's work before starting
4. **Multi-terminal workflow** - Work on different threads in parallel without context bloat
5. **MVD validation first** - Don't build until agent cooperation validated
6. **Document decisions** - All strategic decisions go in session logs + branch contexts
7. **Integration with mydevwf** - BMad IDE is sub-project, shares `.bmad-core/` framework

---

## Current Phase Status

**Phase 0: MVD - Minimum Viable Demo** ⏳ IN PROGRESS

**Completed:**
- ✅ Vision documentation (15,000+ words)
- ✅ Product roadmap (500 lines, phased approach)
- ✅ Workstation architecture documentation (9,800+ lines)
- ✅ Desktop environment decision (DankMaterialShell)
- ✅ Context architecture setup (.context/ folder)
- ✅ Framework optimizations (backend restart protocol, handoff reading)

**Next:**
- ⏳ Install DankMaterialShell on ThinkPad T14 (user action, this weekend)
- ⏳ Run MVD test (tmux + Claude Code prompt injection)
- ⏳ Measure success rate (target: ≥80%)
- ⏳ GO/NO-GO decision

**Success Criteria:**
- ✅ Agents respond correctly ≥80% of time → Proceed to Phase 1 (Extension MVP)
- ❌ <80% reliable → Pivot immediately (Options: hooks-based, manual workflow, abandon IDE)

---

## Competitive Landscape

**emergent.sh** (Primary Competitor):
- ❌ Expensive ($10-167/month + 1-5 credits per app)
- ❌ Cloud-only (no local development)
- ❌ Black box (no visibility into agent decisions)
- ❌ No intervention capability

**BMad IDE Differentiation:**
- ✅ Local-first (full control, data privacy)
- ✅ Transparent (see all handoffs, agent decisions)
- ✅ Intervention-friendly (pause, guide, override)
- ✅ Cost-effective (self-hosted, pay for API only)
- ✅ Open framework (BMad Method open source)

**Strategic Positioning:** "emergent.sh for power users who want full control"

---

## Technology Stack

### BMad Workstation (Stage 2)
- **OS:** Ubuntu Server 24.04 LTS (minimal)
- **Filesystem:** BTRFS (snapshots, compression, subvolumes)
- **Compositor:** Hyprland (Wayland)
- **Desktop Shell:** DankMaterialShell (Quickshell + Go backend)
- **Orchestration:** Custom Go daemon (fsnotify + tmux control)
- **Terminal Multiplexer:** tmux (3-pane: Orchestrator, Dev, QA)
- **Agent Runtime:** Claude Code CLI
- **Context Management:** Go daemon with compaction tracking
- **Integration:** HTTP API for DMS plugins

### VS Code Extension (Stage 1)
- **Language:** TypeScript
- **File Watcher:** chokidar
- **Prompt Injection:** VS Code terminal API
- **UI:** Webview panel (React)
- **State Management:** VS Code extension context
- **Publishing:** VS Code Marketplace

### Shared (Both Stages)
- **Handoff Format:** Dual-format (detailed documents + compact snippets)
- **Workflow:** Three-terminal (Orchestrator, Dev, QA)
- **Context Monitoring:** Message counting + compaction tracking
- **MCP Integration:** Playwright, Context7, Supabase/MongoDB, shadcn-ui

---

## BMad Framework Integration

**BMad IDE uses BMad V4 Optimized framework:**

**Location:** `d:\Dev\mydevwf\.bmad-core/` (symlinked to all projects)

**Key Framework Features:**
- Three-terminal workflow (Orchestrator, Dev, QA)
- Dual-format handoffs (documents + snippets)
- Vitest + Playwright MCP hybrid testing
- Context7 MCP integration
- Quality gates (PASS/CONCERNS/FAIL/WAIVED)
- Backend restart protocol
- Handoff reading optimization

**Framework Docs:** See `d:\Dev\mydevwf\CLAUDE.md` for complete BMad Method documentation

---

## Session Log Protocol

**Trigger Point:** When working on any thread for >30 minutes or making strategic decisions

**Action Required:**
1. Create session log: `.context/sessions/YYYY-MM-DD-{thread}.md`
2. Document: Decisions, code changes, problems solved, next steps
3. Reference: Include file paths and line numbers
4. Status: Mark as "In Progress" or "Completed"

**Session Log Template:** See `.context/README.md` for format

**Why Critical:**
- Preserves decisions across conversation compactions
- Enables seamless resumption after breaks
- Creates audit trail of project evolution
- Prevents loss of context and rationale

---

## Git Workflow

**Branches:**
- `main` - Not yet created (BMad IDE is documentation-only currently)
- `devwf` - Current mydevwf development branch (parent project)

**Commit Strategy:**
- Document strategic decisions → commit to git
- Architecture documentation → commit to git
- Code implementations → commit to git with BMad-style messages

**Commit Message Format:**
```
{type}: {brief description}

{detailed context}

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## Important Notes

1. **Load branch context for focused work** - Don't load entire project unnecessarily
2. **MVD validation is critical** - Everything depends on agent cooperation reliability
3. **Document decisions in session logs** - Conversation compactions lose context
4. **Two-stage architecture is strategy** - Extension validates, Terminal differentiates
5. **DankMaterialShell chosen for pragmatism** - LTS support > bleeding-edge features
6. **BMad V4 is foundation** - Don't migrate to V6, cherry-pick concepts instead
7. **Context pollution at 4 compactions** - Reload agents, preserve architectural memory

---

## Quick Commands

**Check Session Logs:**
```bash
ls -la .context/sessions/
```

**Read Branch Context:**
```bash
# For workstation work:
cat .context/workstation-context.md

# For extension work:
cat .context/extension-context.md

# For daemon work:
cat .context/daemon-context.md

# For framework work:
cat .context/framework-context.md
```

**Get Timestamp (for documentation):**
```bash
date "+%Y-%m-%d %H:%M:%S"
```

---

## Resources

- **Architecture Details:** `.context/README.md`
- **Workstation Architecture:** `docs/architecture/bmad-workstation-system-architecture.md`
- **Product Roadmap:** `docs/planning/product-roadmap.md`
- **Vision Session:** `research-notes/2025-11-08-bmad-ide-vision-session.md`
- **BMad Framework:** `d:\Dev\mydevwf\CLAUDE.md`
- **DankMaterialShell:** https://github.com/AvengeMedia/DankMaterialShell

---

**Architecture Note:** This project uses hierarchical context management. CLAUDE.md is the master routing document. For detailed context on any thread, load the relevant branch context file from `.context/` folder. This allows multiple terminals to work on different threads simultaneously without context bloat.

**For full architecture details:** `.context/README.md`

---

**Document Version:** 1.0
**Status:** Production - Active Development (Phase 0)
