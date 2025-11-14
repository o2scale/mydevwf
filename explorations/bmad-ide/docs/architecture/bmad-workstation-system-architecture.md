# BMad Workstation - System Architecture

**Version**: 1.0
**Last Updated**: 2025-11-08
**Status**: Architecture Definition

---

## Executive Summary

BMad Workstation is a complete developer productivity operating system built on Ubuntu + Hyprland + DankMaterialShell + BMad Framework. It transforms the three-terminal BMad workflow into a fully automated, beautiful, and production-ready development environment that works locally or in the cloud.

**Not**: An IDE extension or plugin
**Is**: A complete operating system for agentic development

---

## Strategic Decision: Material Shell Over Caelestia

### Why Material Shell (DMS)?

**Selected**: DankMaterialShell (https://github.com/AvengeMedia/DankMaterialShell)

**Reasons**:
1. ✅ **One-command install**: `curl -fsSL https://install.danklinux.com | sh`
2. ✅ **Ubuntu 24.04 LTS OR 25.10** (flexible LTS support)
3. ✅ **Multi-distro support** (Arch, Fedora, Debian, openSUSE)
4. ✅ **Production-ready**: Stable v3.2+, maintained, plugin system
5. ✅ **Complete desktop replacement**: Replaces waybar + swaylock + swayidle + mako + fuzzel
6. ✅ **Simpler dependencies**: Quickshell (Qt6) + Go backend
7. ✅ **Better documentation**: danklinux.com with full guides
8. ✅ **Plugin ecosystem**: Extensible, community-driven

**Rejected**: Caelestia Shell
- ❌ Ubuntu 25.10 ONLY (Qt 6.8+ requirement, no LTS option)
- ❌ Complex dependencies (21 packages, custom builds)
- ❌ Long build time (30-60 minutes)
- ❌ Alpha quality (less mature)

**Decision Rationale**: Production stability and LTS support are critical for enterprise adoption. Material Shell provides immediate value with proven reliability.

---

## System Architecture

### Technology Stack

```
┌─────────────────────────────────────────────────────────────┐
│              BMad Workstation (Complete OS)                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────┐   │
│  │         DankMaterialShell (Desktop UI)             │   │
│  │  • Launcher, notifications, lock screen            │   │
│  │  • Control center (WiFi, Bluetooth, audio)         │   │
│  │  • BMad Dashboard Plugin (workflow state)          │   │
│  └────────────────────────────────────────────────────┘   │
│                        ▲                                    │
│                        │ IPC / HTTP API                     │
│                        ▼                                    │
│  ┌────────────────────────────────────────────────────┐   │
│  │      BMad Orchestration Daemon (Go/Rust)           │   │
│  │  • File watcher (handoff detection)                │   │
│  │  • tmux controller (prompt injection)              │   │
│  │  • Context monitor (4-compaction tracking)         │   │
│  │  • State machine (workflow progression)            │   │
│  └────────────────────────────────────────────────────┘   │
│                        ▲                                    │
│                        │ tmux send-keys                     │
│                        ▼                                    │
│  ┌────────────────────────────────────────────────────┐   │
│  │    tmux Session (3-pane Developer Workflow)        │   │
│  │  ┌──────────┬──────────┬──────────┐               │   │
│  │  │   Pane 0 │  Pane 1  │  Pane 2  │               │   │
│  │  │Orchestr. │   Dev    │    QA    │               │   │
│  │  │  Agent   │  Agent   │  Agent   │               │   │
│  │  └──────────┴──────────┴──────────┘               │   │
│  │  Claude Code CLI running in each pane              │   │
│  └────────────────────────────────────────────────────┘   │
│                        ▲                                    │
│                        │                                    │
│  ┌────────────────────────────────────────────────────┐   │
│  │           BMad Framework (.bmad-core/)             │   │
│  │  • Agents (PM, Architect, Dev, QA, etc.)           │   │
│  │  • Tasks (workflows, checklists)                   │   │
│  │  • Templates (PRD, stories, handoffs)              │   │
│  │  • Handoff system (dual-format documents)          │   │
│  └────────────────────────────────────────────────────┘   │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│              Hyprland (Wayland Compositor)                  │
│  • Tiling window manager                                   │
│  • Workspace management                                    │
│  • Animations, effects                                     │
├─────────────────────────────────────────────────────────────┤
│         Ubuntu Server 24.04 LTS (Minimal Base)              │
│  • BTRFS filesystem (snapshots, compression)               │
│  • GDM (fingerprint login support)                         │
│  • Firmware, drivers (ThinkPad optimized)                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Core Components

### 1. Ubuntu Server Base

**Version**: 24.04 LTS (Noble Numbat)
**Filesystem**: BTRFS with subvolumes
**Display Manager**: GDM3 with fprintd (fingerprint support)

**BTRFS Subvolumes**:
- `@` - Root filesystem
- `@home` - User home directories
- `@log` - System logs
- `@cache` - Cache data
- `@snapshots` - Timeshift snapshots

**Swap**: 20GB partition for hibernation

**Rationale**: Ubuntu 24.04 LTS provides 5-year support (until 2029), critical for enterprise adoption. BTRFS enables instant snapshots and rollback.

---

### 2. Hyprland (Wayland Compositor)

**Source**: JaKooLit/Ubuntu-Hyprland (stable PPA)
**Version**: 0.44+

**Features**:
- Dynamic tiling window management
- Per-monitor workspaces
- Smooth animations
- Touchpad gestures
- Multi-monitor support

**Configuration**: `~/.config/hypr/hyprland.conf`

**Rationale**: Lightweight, modern, Wayland-native compositor with excellent performance on Intel UHD Graphics.

---

### 3. DankMaterialShell (Desktop UI)

**Repository**: https://github.com/AvengeMedia/DankMaterialShell
**Version**: 3.2+
**Framework**: Quickshell (Qt6 QML) + Go backend

**Components**:
- **Launcher**: Spotlight-style app search
- **Notifications**: Notification center with grouping
- **Control Center**: WiFi, Bluetooth, audio, display settings
- **Lock Screen**: Idle detection, auto-lock
- **System Tray**: All system indicators
- **Plugin System**: Extensible via QML plugins

**BMad Integration**:
- Custom plugin for workflow status dashboard
- Real-time agent health indicators
- Handoff event notifications

**Rationale**: Complete desktop environment replacement, production-ready, extensible plugin system.

---

### 4. BMad Framework

**Location**: `~/.bmad-core/`

**Structure**:
```
.bmad-core/
├── agents/              # Agent definitions (PM, Dev, QA, etc.)
├── tasks/               # Reusable workflows
├── templates/           # Document templates
├── checklists/          # Definition of done checklists
├── data/                # Guides, standards, preferences
└── core-config.yaml     # Central configuration
```

**Key Features**:
- Multi-agent workflow (Orchestrator, Dev, QA)
- Dual-format handoffs (detailed docs + compact snippets)
- Context pollution awareness (4-compaction threshold)
- Story-driven development
- MCP ecosystem integration

**Rationale**: Proven workflow system with 6+ months of production use.

---

### 5. BMad Orchestration Daemon

**Language**: Go (performance, concurrency) or Rust (safety, performance)
**Binary**: `/usr/local/bin/bmad-orchestrator`
**Systemd Service**: `bmad-orchestrator.service`

**Responsibilities**:

#### A. File Watching
```go
// Watch docs/handoffs/ directory
watcher.Add("docs/handoffs/")

// Detect handoff document creation
if event.Op&fsnotify.Create == fsnotify.Create {
    if strings.Contains(event.Name, "-qa-handoff.md") {
        routeToQA(event.Name)
    } else if strings.Contains(event.Name, "-developer-handoff.md") {
        routeToDev(event.Name)
    }
    // ... other handoff types
}
```

#### B. tmux Control
```go
// Inject prompt into target tmux pane
func injectPrompt(pane, handoffPath string) {
    prompt := fmt.Sprintf(
        "[AUTO-HANDOFF] Handoff received: %s\n" +
        "Load document and proceed with workflow.",
        handoffPath,
    )
    exec.Command("tmux", "send-keys", "-t", pane, prompt, "C-m").Run()
}
```

#### C. Context Monitoring
```go
type AgentHealth struct {
    TerminalID      string
    AgentType       string  // "orchestrator", "dev", "qa"
    MessageCount    int
    CompactionCount int
    LastActivity    time.Time
    Status          string  // "healthy", "warning", "critical"
}

// Track compaction threshold
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

#### D. HTTP API (for DMS integration)
```go
// REST API endpoints
GET  /api/workflow/status        // Current workflow state
GET  /api/agents                 // Agent health status
POST /api/agent/reload           // Trigger agent reload
GET  /api/handoffs/recent        // Recent handoff events
```

**Rationale**: Go provides excellent concurrency for file watching + API server, low resource usage, fast compilation.

---

### 6. tmux Session Layout

**Session Name**: `bmad`
**Layout**: 3-pane horizontal split

```
┌─────────────────────────────────────────────────────┐
│  Pane 0: Orchestrator Agent                         │
│  ~/.config/bmad/orchestrator-session                │
│  Role: Epic planning, story creation, test vetting  │
├─────────────────────────────────────────────────────┤
│  Pane 1: Dev Agent          │  Pane 2: QA Agent    │
│  ~/.config/bmad/dev-session │  ~/.config/bmad/qa-  │
│  Role: Story implementation │  Role: Testing,      │
│        Test writing         │        Quality gates │
└─────────────────────────────┴──────────────────────┘
```

**Startup Script**: `~/.config/bmad/start-workflow.sh`
```bash
#!/bin/bash
tmux new-session -d -s bmad -n "Dev Workflow"
tmux split-window -h -t bmad:0
tmux split-window -v -t bmad:0

# Start Claude Code in each pane
tmux send-keys -t bmad:0.0 "cd ~/projects && claude-code --agent orchestrator" C-m
tmux send-keys -t bmad:0.1 "cd ~/projects && claude-code --agent dev" C-m
tmux send-keys -t bmad:0.2 "cd ~/projects && claude-code --agent qa" C-m

# Attach to session
tmux attach -t bmad
```

**Persistence**: tmux sessions survive disconnects, perfect for remote access

---

## Workflow Automation

### Handoff Detection & Routing

**File Watcher Paths**:
- `docs/handoffs/sprint-{N}/epics/epic-{N}/`

**Handoff Types & Routing**:
| Handoff Type | Filename Pattern | Target Pane | Target Agent |
|--------------|------------------|-------------|--------------|
| Story Handoff | `*-story-handoff.md` | Pane 1 | Dev |
| QA Handoff | `*-qa-handoff.md` | Pane 2 | QA |
| Developer Handoff | `*-developer-handoff.md` | Pane 1 | Dev |
| Completion Handoff | `*-completion-handoff.md` | Pane 1 | Dev |
| Test Review Handoff | `*-test-review-handoff.md` | Pane 0/1 | Orchestrator or Dev |

**Example Flow**:
```
1. Dev Agent completes story implementation
2. Creates docs/handoffs/sprint-2/epics/epic-2/2.3-auth-qa-handoff.md
3. File watcher detects creation (fsnotify event)
4. Daemon parses filename → identifies "qa-handoff"
5. Daemon injects prompt into tmux pane 2 (QA agent)
6. QA agent sees prompt, loads document, begins testing
```

---

### Context Pollution Monitoring

**Problem**: Claude Code agents degrade after ~4 compactions (conversation summarizations)

**Symptoms**:
- Hallucinations
- Forgetting architectural decisions
- Repeated questions
- Lower code quality

**Detection Heuristics**:
1. **Message Counting**: Track messages per agent (~50 messages ≈ 1 compaction)
2. **Summary Detection**: Watch for `<summary>` tags in output (indicates compaction)
3. **Time-Based**: Track session duration (>4 hours likely degraded)

**Mitigation**:
1. **Warning at Compaction 3**: DMS notification + status indicator
2. **Auto-Reload at Compaction 4**:
   - Summarize current conversation (key decisions, progress)
   - Extract story progress (tasks completed, current task)
   - Close tmux pane
   - Open new tmux pane with same agent
   - Inject context summary + resume prompt

**Context Preservation**:
```go
type ContextSummary struct {
    AgentType           string
    CompactionCount     int
    StoryPath           string
    TasksCompleted      []string
    CurrentTask         string
    KeyDecisions        []string  // "Using UUID v4 for IDs", "bcrypt for passwords"
    ArchitecturalChoices []string // "Next.js App Router", "Supabase Auth"
}

func (c *ContextSummary) GenerateResumePrompt() string {
    return fmt.Sprintf(
        "[CONTEXT RELOAD] Previous session reached %d compactions.\n" +
        "Story: %s\n" +
        "Completed: %s\n" +
        "Current: %s\n" +
        "Key Decisions: %s\n" +
        "Continue from where you left off.",
        c.CompactionCount,
        c.StoryPath,
        strings.Join(c.TasksCompleted, ", "),
        c.CurrentTask,
        strings.Join(c.KeyDecisions, "; "),
    )
}
```

---

## Deployment Scenarios

### Scenario 1: Local Development Workstation

**Hardware**: Lenovo ThinkPad T14 (or similar)

**Installation**:
```bash
# One-command install
curl -fsSL https://bmad-workstation.dev/install.sh | sh

# What it does:
# 1. Installs Ubuntu Server 24.04 LTS with BTRFS (if fresh install)
# 2. Installs Hyprland (JaKooLit PPA)
# 3. Installs DankMaterialShell
# 4. Installs BMad Framework
# 5. Installs BMad Orchestration Daemon
# 6. Configures tmux preset
# 7. Installs developer stack (Node.js, Docker, etc.)
# 8. Creates first project from template

# Time: 15-20 minutes
```

**User Experience**:
1. Boot ThinkPad → GDM login (fingerprint supported)
2. Select "Hyprland" session
3. Beautiful Material Shell UI appears
4. Press `Super+B` → Opens BMad workflow dashboard
5. Press `Super+T` → Opens tmux session (3 agents ready)
6. Start coding with automated handoff workflow

---

### Scenario 2: Cloud Server Deployment

**Platforms**: AWS EC2, DigitalOcean, Hetzner, Linode

**Installation**:
```bash
# On cloud server (Ubuntu 24.04)
curl -fsSL https://bmad-workstation.dev/install.sh | sh

# Install VNC server for remote access
sudo apt install x11vnc -y
x11vnc -storepasswd  # Set VNC password

# Start VNC server
x11vnc -forever -usepw -display :0
```

**Access**:
```bash
# From local machine
ssh -L 5900:localhost:5900 user@your-server-ip
vncviewer localhost:5900

# OR use VNC client directly
vncviewer your-server-ip:5900
```

**Benefits**:
- Full BMad Workstation UI in VNC window
- tmux sessions persist across disconnects
- Deploy once, access from anywhere
- Multiple developers can share same server (separate tmux sessions)

---

### Scenario 3: Docker Container (Future)

**Use Case**: Reproducible dev environment

```bash
# Pull image
docker pull bmad-workstation/ubuntu-24.04:latest

# Run container
docker run -it --rm \
  -v $(pwd):/workspace \
  -p 5900:5900 \
  bmad-workstation/ubuntu-24.04

# VNC to localhost:5900
vncviewer localhost:5900
```

---

## File Manager Integration

**Problem**: Users need file tree + previews (VS Code-like experience)

**Solution**: Lightweight file manager + terminal file tools

**File Manager Options**:
1. **Thunar** (Recommended): Lightweight, fast, GTK-based
2. **Nautilus**: GNOME default, familiar to Ubuntu users
3. **Dolphin**: KDE, powerful, excellent thumbnails

**Installation**:
```bash
sudo apt install thunar thunar-archive-plugin thunar-volman -y

# Add to Hyprland config
echo 'bind = SUPER, E, exec, thunar' >> ~/.config/hypr/hyprland.conf
```

**Terminal File Tools**:
```bash
# Install modern CLI tools
sudo apt install bat exa fd-find ripgrep fzf -y

# File previews
bat file.md           # Syntax-highlighted cat
exa -la --icons       # Modern ls with icons
fd pattern            # Fast find alternative
rg "search term"      # Fast grep alternative
fzf                   # Fuzzy file finder
```

**neovim/vim Integration**:
```bash
# Install neovim for quick edits
sudo apt install neovim -y

# Configure with NvChad or LazyVim for IDE-like experience
# BUT: Primary coding is via Claude Code, not manual editing
```

**User Workflow**:
1. Press `Super+E` → Opens Thunar file manager
2. Browse files, preview images/docs
3. Need to edit? Right-click → "Open with neovim"
4. For AI-assisted work → Use Claude Code in tmux

---

## Developer Stack

**Included Tools**:
```bash
# Core Development
- Node.js LTS (via NodeSource)
- pnpm + yarn
- Docker CE + Docker Compose
- Git + GitHub CLI

# Database Tools
- Supabase CLI
- PostgreSQL client
- MongoDB client (if needed)

# MCP Ecosystem
- Playwright MCP (E2E testing)
- Supabase MCP (database operations)
- MongoDB MCP (database operations)
- shadcn-ui MCP (component library)
- Context7 MCP (documentation)

# Terminal Multiplexing
- tmux (session management)
- zsh + oh-my-zsh (shell)

# Text Editing
- neovim/nvim (quick edits)
- VS Code (optional, if users prefer)

# System Monitoring
- htop (process monitoring)
- btop (modern system monitor)
- ncdu (disk usage)
```

---

## Security & Privacy

**Local-First Architecture**:
- All code stays on local machine or private cloud server
- No data sent to third-party services (except Claude API)
- BTRFS encryption supported (optional)

**Authentication**:
- Fingerprint login (fprintd + PAM)
- Password authentication
- SSH key-based for remote access

**Network Security**:
- Firewall (ufw) configured by default
- VNC access password-protected
- SSH hardening (key-only, no root login)

**Backup Strategy**:
- BTRFS snapshots (hourly, daily, weekly via Timeshift)
- Projects stored in `~/projects` (easy to backup)
- Cloud sync option (Pro tier)

---

## Performance Optimization

**System-Level**:
- BFQ I/O scheduler (better SSD performance)
- zram (compressed swap in RAM)
- tmpfs for `~/.cache` (faster temp files)
- preload (predictive file caching)

**Power Management** (ThinkPad specific):
- TLP (battery optimization)
- thermald (thermal management)
- powertop (power usage analysis)
- auto-cpufreq (CPU governor switching)

**Memory Footprint**:
- Idle: ~800 MB (Ubuntu + Hyprland + DMS)
- Dev session (3 Claude Code agents): ~3-4 GB
- Full workload: <8 GB (plenty of headroom on 16 GB RAM)

---

## Multi-Monitor Support

**DankMaterialShell**: Automatically creates panels on all connected monitors

**Hyprland**: Per-monitor workspace support
```conf
# Example Hyprland config
monitor=DP-1,1920x1080@60,0x0,1
monitor=DP-2,1920x1080@60,1920x0,1

workspace=1,monitor:DP-1
workspace=2,monitor:DP-2
```

**tmux**: Terminal sessions accessible from any monitor

---

## Maintenance & Updates

**System Updates**:
```bash
# Automated via systemd timer (bi-weekly)
sudo apt update && sudo apt upgrade -y
```

**BMad Framework Updates**:
```bash
# Git pull from .bmad-core/
cd ~/.bmad-core && git pull
```

**DMS Updates**:
```bash
# One-command updater
curl -fsSL https://install.danklinux.com/update.sh | sh
```

**Orchestration Daemon Updates**:
```bash
# Binary replacement
sudo systemctl stop bmad-orchestrator
sudo cp bmad-orchestrator-new /usr/local/bin/bmad-orchestrator
sudo systemctl start bmad-orchestrator
```

---

## Critical Validation Test

### MVD (Minimum Viable Demo)

**Goal**: Validate tmux + Claude Code cooperation (80%+ success rate required)

**Test Procedure**:
```bash
# 1. Start tmux session
tmux new-session -d -s test

# 2. Start Claude Code in pane
tmux send-keys -t test:0 "claude-code --agent dev" C-m

# 3. Wait for Claude Code to load (10 seconds)
sleep 10

# 4. Inject test prompt
tmux send-keys -t test:0 "[AUTO-HANDOFF] Test message from orchestrator" C-m

# 5. Observe response (manually)
tmux attach -t test

# 6. Record result: Did agent respond correctly? (YES/NO)
```

**Success Criteria**: Agent responds correctly ≥8 out of 10 tests (80%)

**If SUCCESS**: Proceed with orchestration daemon development
**If FAILURE**: Explore alternative approaches (hooks, API, manual with monitoring)

**Timeline**: Test THIS WEEKEND (2025-11-09/10)

---

## Next Steps

1. **Week 1**: Install Material Shell on ThinkPad T14
2. **Week 1**: Run MVD (tmux injection test)
3. **Week 2**: If MVD succeeds, build orchestration daemon (Go)
4. **Week 3**: Integrate daemon with DMS (dashboard plugin)
5. **Week 4**: Alpha testing with 5-10 users

---

**Document Version**: 1.0
**Created**: 2025-11-08
**Status**: Architecture Definition - Awaiting MVD Validation
