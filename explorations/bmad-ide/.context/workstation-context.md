# BMad Workstation - Branch Context

**Thread:** BMad Workstation (Linux Terminal System)
**Status:** Phase 0 - Architecture Complete, MVD Pending
**Last Updated:** 2025-11-08 03:37:36

---

## Thread Overview

**BMad Workstation** is a complete developer productivity operating system combining Ubuntu 24.04 LTS, Hyprland compositor, DankMaterialShell desktop environment, and a Go-based orchestration daemon to automate BMad Method three-terminal workflows.

**Vision:** Power-user focused, Linux-native, terminal-centric development environment with automated agent handoffs, context monitoring, and full transparency.

**Strategic Role:** Stage 2 of two-stage architecture (after VS Code Extension validates concept)

---

## Current Status

### ✅ Completed

1. **Desktop Environment Decision:** DankMaterialShell chosen over Caelestia
   - Rationale: LTS support (Ubuntu 24.04), production-ready, one-command install
   - Decision Date: 2025-11-08

2. **System Architecture Documentation:** Complete 9,800+ line architecture document
   - File: `docs/architecture/bmad-workstation-system-architecture.md`
   - Covers: Technology stack, components, workflow automation, deployment scenarios

3. **Technology Stack Finalized:**
   - Base: Ubuntu Server 24.04 LTS + BTRFS
   - Compositor: Hyprland (Wayland)
   - Desktop: DankMaterialShell (Quickshell + Go backend)
   - Orchestration: Go daemon (fsnotify + tmux control)
   - Runtime: tmux (3-pane) + Claude Code CLI

### ⏳ In Progress

4. **MVD (Minimum Viable Demo) - THIS WEEKEND**
   - Goal: Validate agent cooperation (tmux prompt injection)
   - Success: ≥80% agent response rate
   - Action: User installs DMS, tests tmux send-keys, measures reliability

### ⏸️ Pending

5. **Orchestration Daemon Development** (If MVD succeeds)
6. **DankMaterialShell Plugin Development** (BMad workflow status panel)
7. **End-to-End Testing** (Full three-terminal workflow)

---

## Key Decisions

### Strategic Decisions

**Decision 1: DankMaterialShell over Caelestia** ✅ 2025-11-08

**Context:**
- User building Ubuntu + Hyprland system on ThinkPad T14
- Initially considering Caelestia Shell (beautiful Qt6 interface)
- User feedback: "don't get stuck on Caelestia... it's very complicated"

**Analysis:**
- **Caelestia Issues:**
  - Ubuntu 25.10 only (non-LTS, 9 months support)
  - Complex build (21+ dependencies, 30-60 min compile, Qt 6.8+ required)
  - Alpha state (frequent breaking changes)
  - Limited documentation

- **DankMaterialShell Advantages:**
  - Ubuntu 24.04 LTS support (5 years support)
  - One-command install: `curl -fsSL https://install.danklinux.com | sh`
  - Production-ready (stable release)
  - Multi-distro support (Arch, Fedora, Debian, openSUSE)
  - Mature plugin system

**Decision:** Use DankMaterialShell

**Rationale:**
- User priority: "I want Ubuntu because I want the developers to be comfortable. If they need to, they can ship this to an AWS server"
- Pragmatism over perfection: LTS stability > bleeding-edge features
- Faster time-to-market: No 30-60 min build, no dependency hell
- Lower maintenance burden: Stable release vs alpha state

**Impact:** Development can proceed faster, AWS deployment enabled, team adoption easier

---

**Decision 2: Ubuntu 24.04 LTS over Ubuntu 25.10** ✅ 2025-11-08

**Context:** Desktop environment choice dictates Ubuntu version

**Options:**
- Ubuntu 25.10: Latest (for Caelestia), 9 months support
- Ubuntu 24.04 LTS: Mature, 5 years support

**Decision:** Ubuntu 24.04 LTS

**Rationale:**
- Enterprise-grade support window (5 years)
- Proven stability (released April 2024)
- DankMaterialShell officially supports 24.04 LTS
- AWS deployment friendly (Ubuntu Server standard)
- Team familiarity (most devs use Ubuntu LTS)

**Impact:** Long-term support, enterprise adoption possible, reduced system maintenance

---

**Decision 3: Go for Orchestration Daemon** ✅ 2025-11-08

**Context:** Need native daemon to watch files, control tmux, monitor agent context

**Options:**
- Go: Fast, single binary, excellent stdlib (fsnotify)
- Rust: Fastest, but steeper learning curve, longer compile times
- TypeScript/Node.js: Familiar, but slower runtime, dependency bloat

**Decision:** Go

**Rationale:**
- Performance: Near-native speed, low overhead
- Deployment: Single binary (no runtime dependencies)
- Standard library: fsnotify (file watching), os/exec (tmux control)
- Development speed: Simpler syntax than Rust
- Cross-platform: Easy Windows support for Extension version

**Impact:** Fast development, easy deployment, maintainable codebase

---

### Technical Decisions

**Decision 4: Three-Terminal tmux Layout** ✅ 2025-11-08

**Layout:**
```
+---------------------+---------------------+
| Orchestrator        | Dev Agent           |
| (Pane 0)            | (Pane 1)            |
|                     |                     |
| - Story creation    | - Implementation    |
| - Context7 research | - Test writing      |
| - Test vetting      | - Background procs  |
+---------------------+---------------------+
| QA Agent (Pane 2)                         |
|                                           |
| - Test execution                          |
| - Quality gates                           |
| - Evidence collection                     |
+-------------------------------------------+
```

**Rationale:**
- Orchestrator: Planning and coordination (top-left)
- Dev: Heavy lifting, needs space (top-right)
- QA: Validation, needs full width for test output (bottom)

**Impact:** Visual separation of roles, efficient screen usage, easy to navigate

---

**Decision 5: Context Monitoring with 3-Warning, 4-Reload** ✅ 2025-11-08

**Protocol:**
- Track compaction count per agent
- Compaction 3: Show warning (context approaching limit)
- Compaction 4: Trigger automatic reload

**Rationale:**
- User's empirical finding: "After the 4th compaction, the dev starts forgetting and hallucinating"
- Balance: Preserve architectural memory vs prevent degradation
- User's insight: "Sometimes it's pollution, sometimes it's actually useful context. That's the razor's edge."

**Implementation:**
```go
type AgentHealth struct {
    TerminalID      string
    AgentType       string  // "orchestrator", "dev", "qa"
    MessageCount    int
    CompactionCount int
    LastActivity    time.Time
    Status          string  // "healthy", "warning", "critical"
}

func (a *AgentHealth) CheckHealth() {
    if a.CompactionCount >= 3 {
        a.Status = "warning"
        notifyUser(a.AgentType + " approaching context limit")
    }
    if a.CompactionCount >= 4 {
        a.Status = "critical"
        triggerReload(a.TerminalID, a.AgentType)
    }
}
```

**Impact:** Proactive context management, balance architectural memory with quality

---

## Technology Stack

### System Layer

**Operating System:** Ubuntu Server 24.04 LTS (Minimal Install)
- Why: Lightweight, stable, 5 years support
- Installation: Minimal server install, add desktop components manually
- Updates: Standard apt, no snap where possible

**Filesystem:** BTRFS
- Features: Transparent compression (zstd), snapshots, subvolumes
- Layout:
  - `@` - Root filesystem
  - `@home` - User home directories
  - `@snapshots` - Timeshift backups
- Compression: `compress=zstd:1` (balance speed/compression)
- Benefits: Fast snapshots, reduced disk usage, easy rollback

**Display Server:** Wayland (via Hyprland compositor)
- Why: Modern, secure, better multi-monitor support
- No X11 fallback needed (DankMaterialShell is Wayland-native)

### Desktop Layer

**Compositor:** Hyprland
- Type: Dynamic tiling Wayland compositor
- Installation: JaKooLit PPA (Ubuntu-optimized build)
- Features: Animations, workspace management, multi-monitor
- Config: `~/.config/hypr/hyprland.conf`

**Desktop Shell:** DankMaterialShell (DMS)
- Architecture: Quickshell (Qt6 QML) + Go backend
- Components:
  - **Panel:** Workspace switcher, system tray, status indicators
  - **Dashboard:** System metrics, calendar, weather, media controls
  - **Launcher:** Spotlight-style app/file/emoji/command search
  - **Control Center:** Network, Bluetooth, audio, display settings
  - **Notifications:** Grouped notifications with rich text
  - **Lock Screen:** Idle detection, auto-lock/suspend
- Installation: `curl -fsSL https://install.danklinux.com | sh`
- IPC: `dms ipc call {module} {action}`
- Plugin System: https://plugins.danklinux.com

**File Manager Integration:**
- GUI: Thunar or Nautilus (for file browsing)
- Terminal: bat, exa, fd, ripgrep (for quick operations)
- Preview: DMS panels can show file previews

### Orchestration Layer

**BMad Orchestration Daemon** (Custom Go application)

**Responsibilities:**
1. **File Watcher:** Monitor `docs/handoffs/` for new handoff documents
2. **Handoff Router:** Parse filenames, route to correct tmux pane
3. **Prompt Injector:** Use `tmux send-keys` to inject prompts into agent terminals
4. **Context Monitor:** Track message counts, estimate compaction events
5. **Agent Reload:** Automatically reload agents at 4 compactions
6. **HTTP API:** Expose status for DMS plugin integration

**Technology:**
- Language: Go 1.21+
- File Watching: `fsnotify` (stdlib-like)
- tmux Control: `os/exec` + `tmux send-keys`
- HTTP Server: `net/http` (stdlib)
- Configuration: YAML (`gopkg.in/yaml.v3`)

**Configuration File:** `~/.config/bmad-orchestrator/config.yaml`
```yaml
handoffs:
  watch_dir: "docs/handoffs/"

tmux:
  session_name: "bmad-dev"
  orchestrator_pane: "bmad-dev:0.0"
  dev_pane: "bmad-dev:0.1"
  qa_pane: "bmad-dev:0.2"

context_monitoring:
  warning_threshold: 3
  reload_threshold: 4

http_api:
  port: 8765
  host: "localhost"
```

**API Endpoints:**
- `GET /status` - Current workflow state
- `GET /agents` - Agent health (context, compactions)
- `POST /reload/{agent}` - Manually reload agent
- `GET /handoffs/recent` - Recent handoff history

### Terminal Layer

**Terminal Multiplexer:** tmux 3.3+
- Session: `bmad-dev` (persistent across reboots)
- Layout: 3-pane (Orchestrator, Dev, QA)
- Config: `~/.tmux.conf` (custom keybindings, status bar)
- Automation: Controlled by orchestration daemon via `send-keys`

**Agent Runtime:** Claude Code CLI
- Installation: npm global or standalone binary
- Configuration: `.claude-config.json` (API key, MCP servers)
- Context: Each pane runs separate agent with role-specific instructions

### Development Layer

**Core Framework:** BMad V4 Optimized
- Location: `~/.bmad-core/` (symlinked from mydevwf)
- Agents: Orchestrator, Dev (James), QA (Quinn)
- Workflows: Three-terminal handoff automation
- MCPs: Playwright, Context7, Supabase/MongoDB, shadcn-ui

**Version Control:** Git
- Configuration: User's standard git config
- Workflow: Standard BMad commit messages

**Developer Tools:**
- VS Code: Code editing, file browsing
- Cursor: Alternative editor (if stable on Linux)
- Docker: Container management
- Node.js: Runtime for MCPs, project development
- Supabase CLI: Database management (for Supabase projects)

---

## Workflow Automation

### Handoff Detection & Routing

**File Watcher Implementation (Go):**
```go
package main

import (
    "github.com/fsnotify/fsnotify"
    "log"
    "os/exec"
    "path/filepath"
    "strings"
)

func watchHandoffs(handoffDir string) error {
    watcher, err := fsnotify.NewWatcher()
    if err != nil {
        return err
    }
    defer watcher.Close()

    err = watcher.Add(handoffDir)
    if err != nil {
        return err
    }

    for {
        select {
        case event := <-watcher.Events:
            if event.Op&fsnotify.Create == fsnotify.Create {
                handleNewHandoff(event.Name)
            }
        case err := <-watcher.Errors:
            log.Println("Watcher error:", err)
        }
    }
}

func handleNewHandoff(filepath string) {
    filename := filepath.Base(filepath)

    if strings.Contains(filename, "-story-handoff.md") {
        routeToTerminal("dev", filepath)
    } else if strings.Contains(filename, "-qa-handoff.md") {
        routeToTerminal("qa", filepath)
    } else if strings.Contains(filename, "-developer-handoff.md") {
        routeToTerminal("dev", filepath)
    } else if strings.Contains(filename, "-completion-handoff.md") {
        routeToTerminal("dev", filepath)
    } else if strings.Contains(filename, "-test-review-handoff.md") {
        routeToTerminal("orchestrator", filepath)
    }
}

func routeToTerminal(agent, handoffPath string) {
    pane := config.Tmux.GetPaneFor(agent)
    prompt := fmt.Sprintf(
        "[AUTO-HANDOFF] New %s handoff received: %s\n"+
        "Load document and proceed with workflow.",
        agent, handoffPath,
    )

    cmd := exec.Command("tmux", "send-keys", "-t", pane, prompt, "C-m")
    if err := cmd.Run(); err != nil {
        log.Printf("Failed to inject prompt to %s: %v", agent, err)
    } else {
        log.Printf("✅ Routed handoff to %s agent", agent)
    }
}
```

### Context Pollution Monitoring

**Compaction Detection:**
- Method: Message counting (Claude Code doesn't expose compaction events)
- Heuristic: Estimate compaction after ~30-40 messages
- Tracking: Per-agent message count in daemon state

**Implementation:**
```go
type AgentHealth struct {
    TerminalID      string
    AgentType       string
    MessageCount    int
    CompactionCount int
    LastActivity    time.Time
    Status          string
}

func (a *AgentHealth) IncrementMessages(count int) {
    a.MessageCount += count
    a.LastActivity = time.Now()

    // Estimate compaction every 30-40 messages
    if a.MessageCount >= 30 {
        a.CompactionCount++
        a.MessageCount = 0
    }

    a.CheckHealth()
}

func (a *AgentHealth) CheckHealth() {
    if a.CompactionCount >= 3 {
        a.Status = "warning"
        notifyUser(a.AgentType + " approaching context limit (3 compactions)")
    }
    if a.CompactionCount >= 4 {
        a.Status = "critical"
        log.Printf("⚠️ %s agent at 4 compactions - triggering reload", a.AgentType)
        triggerReload(a.TerminalID, a.AgentType)
    }
}

func triggerReload(terminalID, agentType string) {
    // Save current context to session log
    saveContextToSessionLog(agentType)

    // Inject reload command to terminal
    cmd := exec.Command("tmux", "send-keys", "-t", terminalID, "C-c")
    cmd.Run()

    time.Sleep(500 * time.Millisecond)

    // Restart agent with fresh context
    agentCommand := fmt.Sprintf("/BMad/agents/%s", agentType)
    cmd = exec.Command("tmux", "send-keys", "-t", terminalID, agentCommand, "C-m")
    cmd.Run()

    log.Printf("✅ Reloaded %s agent with fresh context", agentType)
}
```

---

## DankMaterialShell Integration

### BMad Plugin for DMS

**Plugin Purpose:** Visualize BMad workflow status in DMS interface

**Features:**
1. **Workflow Status Panel:** Show current story, epic progress, agent states
2. **Context Health Indicators:** Color-coded agent health (green/yellow/red)
3. **Recent Events Log:** Last 10 handoffs, agent reloads, errors
4. **Manual Controls:** Buttons to pause workflow, reload agents, override routing

**Implementation:**
- Type: DMS plugin (Quickshell QML + HTTP client)
- Communication: HTTP API to orchestration daemon (localhost:8765)
- Location: `~/.config/dms/plugins/bmad-workflow/`
- Installation: `dms plugin install bmad-workflow` (from plugin registry)

**Example Panel (QML):**
```qml
import Quickshell
import Quickshell.Services.Http

Rectangle {
    id: bmadPanel
    width: 300
    height: 200

    property var workflowState: {}

    HttpClient {
        id: httpClient
        url: "http://localhost:8765/status"

        onResponse: function(data) {
            workflowState = JSON.parse(data)
            updateUI()
        }
    }

    Column {
        anchors.fill: parent
        spacing: 10

        Text {
            text: "Current Story: " + workflowState.current_story
            font.bold: true
        }

        Row {
            spacing: 10

            AgentHealthIndicator {
                agentName: "Orchestrator"
                status: workflowState.agents?.orchestrator?.status
            }

            AgentHealthIndicator {
                agentName: "Dev"
                status: workflowState.agents?.dev?.status
            }

            AgentHealthIndicator {
                agentName: "QA"
                status: workflowState.agents?.qa?.status
            }
        }

        Button {
            text: "Reload All Agents"
            onClicked: httpClient.post("/reload/all")
        }
    }

    Timer {
        interval: 5000  // Poll every 5 seconds
        running: true
        repeat: true
        onTriggered: httpClient.request()
    }
}
```

---

## Deployment Scenarios

### Scenario 1: Local Workstation (Primary)

**Hardware:** ThinkPad T14 (or similar)
**Use Case:** Daily development, full BMad workflow

**Setup:**
1. Install Ubuntu Server 24.04 LTS (minimal)
2. Install BTRFS, configure subvolumes
3. Install Hyprland (JaKooLit PPA)
4. Install DankMaterialShell: `curl -fsSL https://install.danklinux.com | sh`
5. Install development tools (Node.js, Docker, Git, VS Code)
6. Build and install orchestration daemon
7. Install BMad plugin for DMS
8. Configure tmux 3-pane layout
9. Set up Claude Code CLI

**Benefits:**
- Full performance (native hardware)
- Complete privacy (all data local)
- Offline capable (MCP services local)
- Low latency (no network round-trip)

### Scenario 2: Cloud Server (Future)

**Platform:** AWS EC2, DigitalOcean Droplet, or similar
**Use Case:** Remote development, team collaboration

**Setup:**
1. Launch Ubuntu Server 24.04 LTS instance
2. Install Hyprland + DMS (same as local)
3. Configure VNC or RDP for remote desktop access
4. Open port 8765 for orchestration daemon API (optional, for monitoring)
5. Configure firewall (restrict to trusted IPs)

**Benefits:**
- Accessible from anywhere
- Team can share orchestration daemon
- Scalable resources (upgrade instance as needed)
- Consistent environment across team

**Security:**
- VPN required (WireGuard recommended)
- SSH key authentication only
- API authentication via tokens
- Audit logging enabled

### Scenario 3: Docker Container (Future)

**Use Case:** Portable development environment, CI/CD integration

**Dockerfile (Conceptual):**
```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    curl git tmux nodejs npm \
    && curl -fsSL https://install.danklinux.com | sh

COPY orchestration-daemon /usr/local/bin/
COPY .bmad-core/ /root/.bmad-core/

EXPOSE 8765

CMD ["orchestration-daemon"]
```

**Benefits:**
- Reproducible environment
- Version pinning
- CI/CD integration
- Easy distribution

---

## Critical Validation Test (MVD)

### Test Procedure

**Goal:** Validate tmux + Claude Code cooperation (agents respond to injected prompts)

**Setup:**
1. Install DankMaterialShell on ThinkPad T14
2. Create tmux session with 3 panes
3. Start Claude Code CLI in each pane
4. Activate agents (Orchestrator, Dev, QA)

**Test Steps:**
1. Create 3 handoff documents manually:
   - `docs/handoffs/sprint-1/epics/epic-1/1.1-test-story-handoff.md`
   - `docs/handoffs/sprint-1/epics/epic-1/1.1-test-qa-handoff.md`
   - `docs/handoffs/sprint-1/epics/epic-1/1.1-test-developer-handoff.md`

2. Inject prompts via tmux send-keys:
   ```bash
   tmux send-keys -t bmad-dev:0.1 "[AUTO-HANDOFF] Story Handoff: docs/handoffs/.../1.1-test-story-handoff.md" C-m
   ```

3. Observe agent response:
   - Did agent acknowledge prompt?
   - Did agent read handoff document?
   - Did agent follow instructions?

4. Repeat 3 times per agent (9 total tests)

5. Calculate success rate:
   - Success: Agent reads document and follows instructions
   - Failure: Agent ignores prompt, or responds incorrectly

**Success Criteria:**
- ✅ **GO:** ≥80% success rate → Proceed to Phase 1 (daemon development)
- ❌ **NO-GO:** <80% success rate → Pivot immediately

**Pivot Options (If MVD Fails):**
- Option A: Wait for Claude Code hooks support (may never come)
- Option B: Manual workflow + monitoring only (smaller product)
- Option C: Focus on BMad framework, abandon IDE concept

---

## Next Steps

### Immediate (This Weekend)

1. **User Action: Install DankMaterialShell**
   ```bash
   curl -fsSL https://install.danklinux.com | sh
   ```

2. **User Action: Run MVD Test**
   - Set up tmux 3-pane session
   - Create 3 test handoff files
   - Test tmux send-keys prompt injection
   - Measure agent response rate
   - Document results

3. **Next Session: Document MVD Results**
   - Success rate (%)
   - Issues encountered
   - GO/NO-GO decision
   - If NO-GO: Pivot analysis

### Phase 1 (If MVD Succeeds)

4. **Week 1-2: Orchestration Daemon Development**
   - Initialize Go project (`bmad-orchestrator`)
   - Implement file watcher (fsnotify)
   - Implement tmux controller
   - Test handoff routing (manual file creation)

5. **Week 3-4: Context Monitoring Implementation**
   - Message counting (heuristic for compactions)
   - Warning at 3 compactions
   - Auto-reload at 4 compactions
   - Session log preservation

6. **Week 4: HTTP API Development**
   - `/status` endpoint (workflow state)
   - `/agents` endpoint (agent health)
   - `/reload/{agent}` endpoint (manual reload)
   - `/handoffs/recent` endpoint (history)

7. **Week 5-6: DMS Plugin Development**
   - Create plugin scaffold
   - Implement workflow status panel
   - Add context health indicators
   - Add manual controls
   - Publish to plugin registry

8. **Week 6: End-to-End Testing**
   - Full workflow test (Orchestrator → Dev → QA)
   - Verify handoff automation
   - Verify context monitoring
   - Measure reliability (target: 90%+)

---

## Integration with Extension (Stage 1)

**Shared Code:**
- Handoff detection logic (port Go → TypeScript)
- Handoff routing rules (same across both stages)
- Context monitoring heuristics (message counting)

**Extension-Specific:**
- chokidar file watcher (Node.js)
- VS Code terminal API (prompt injection)
- Webview UI (React dashboard)

**Workstation-Specific:**
- fsnotify file watcher (Go)
- tmux control (send-keys)
- DMS plugin UI (Quickshell QML)

**Strategy:** Build Extension first (validates concept), then port proven logic to Workstation

---

## Resources

### Documentation
- **System Architecture:** `docs/architecture/bmad-workstation-system-architecture.md`
- **Product Roadmap:** `docs/planning/product-roadmap.md`
- **Vision Session:** `research-notes/2025-11-08-bmad-ide-vision-session.md`
- **Session Log (Today):** `.context/sessions/2025-11-08-workstation.md`

### External Resources
- **DankMaterialShell:** https://github.com/AvengeMedia/DankMaterialShell
- **Installation:** https://install.danklinux.com
- **Documentation:** https://danklinux.com/docs
- **Plugin Registry:** https://plugins.danklinux.com
- **Hyprland:** https://hyprland.org
- **tmux:** https://github.com/tmux/tmux

### ThinkPad T14 Setup Guide
- **Location:** `d:\Dev\ubuntu hyprland\Think Pad T14 — Btrfs Workstation (short Guide).pdf`
- **Contents:** Complete Ubuntu 24.04 LTS + BTRFS + Hyprland setup for ThinkPad T14

---

**Context Version:** 1.0
**Completeness:** 100% - Ready for Development
**Next Update:** After MVD results (this weekend)
