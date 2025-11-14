# Orchestration Daemon - Branch Context

**Thread:** Orchestration Daemon (Go)
**Status:** Architecture Design (Pending MVD Success)
**Last Updated:** 2025-11-08 03:37:36

---

## Thread Overview

**Orchestration Daemon** is the core automation engine for BMad IDE. It watches for handoff documents, routes them to the correct terminal, monitors agent context health, and triggers reloads when necessary.

**Vision:** Lightweight, fast, single-binary daemon that runs in the background and makes BMad workflow automation invisible to the user.

**Strategic Role:** Shared component between Extension (Stage 1) and Workstation (Stage 2) - Extension uses TypeScript port, Workstation uses native Go version

---

## Current Status

### ✅ Architecture Designed

**Completed:**
- Technology decision: Go (performance, single binary, fsnotify stdlib)
- Core responsibilities defined (file watching, routing, context monitoring, HTTP API)
- Configuration format (YAML)
- API endpoints specified

### ⏸️ Pending Development

**Blocker:** Awaiting MVD success this weekend

**If MVD Succeeds:**
- Begin daemon development (Week 1-2 of Phase 1)
- Implement file watcher (fsnotify)
- Implement tmux controller (os/exec + send-keys)
- Test handoff routing

---

## Key Decisions

### Technology: Go

**Decision Date:** 2025-11-08

**Rationale:**
- **Performance:** Near-native speed, low CPU/memory overhead
- **Deployment:** Single binary (no runtime dependencies)
- **Standard Library:** Excellent stdlib (fsnotify, os/exec, net/http)
- **Cross-platform:** Easy to port to Windows for Extension version
- **Development Speed:** Simpler syntax than Rust, faster compile than Rust

**Alternatives Rejected:**
- Rust: Steeper learning curve, longer compile times, overkill for this use case
- TypeScript/Node.js: Slower runtime, dependency bloat, higher memory usage

---

## Core Responsibilities

### 1. File Watcher

**Watch:** `docs/handoffs/` directory (recursive)

**Events:** `CREATE` events only (new handoff documents)

**Filter:** Match filename patterns:
- `*-story-handoff.md` → Route to Dev terminal
- `*-qa-handoff.md` → Route to QA terminal
- `*-developer-handoff.md` → Route to Dev terminal
- `*-completion-handoff.md` → Route to Dev terminal
- `*-test-review-handoff.md` → Route to Orchestrator terminal

**Implementation:**
```go
package main

import (
    "github.com/fsnotify/fsnotify"
    "log"
    "path/filepath"
    "strings"
)

func watchHandoffs(dir string) error {
    watcher, err := fsnotify.NewWatcher()
    if err != nil {
        return err
    }
    defer watcher.Close()

    // Watch recursively (sprint-N/epics/epic-N/ structure)
    err = filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
        if info.IsDir() {
            return watcher.Add(path)
        }
        return nil
    })

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
```

### 2. Handoff Router

**Routing Rules:**
```go
func routeHandoff(filepath string) string {
    filename := filepath.Base(filepath)

    if strings.Contains(filename, "-story-handoff.md") {
        return "dev"
    } else if strings.Contains(filename, "-qa-handoff.md") {
        return "qa"
    } else if strings.Contains(filename, "-developer-handoff.md") {
        return "dev"
    } else if strings.Contains(filename, "-completion-handoff.md") {
        return "dev"
    } else if strings.Contains(filename, "-test-review-handoff.md") {
        return "orchestrator"
    }

    return "" // Unknown handoff type
}
```

### 3. tmux Controller

**Prompt Injection:**
```go
func injectPrompt(pane, handoffPath string) error {
    prompt := fmt.Sprintf(
        "[AUTO-HANDOFF] Handoff received: %s\n"+
        "Load document and proceed with workflow.",
        handoffPath,
    )

    cmd := exec.Command("tmux", "send-keys", "-t", pane, prompt, "C-m")
    return cmd.Run()
}
```

**Terminal Configuration:**
```yaml
# config.yaml
tmux:
  session_name: "bmad-dev"
  orchestrator_pane: "bmad-dev:0.0"
  dev_pane: "bmad-dev:0.1"
  qa_pane: "bmad-dev:0.2"
```

### 4. Context Monitor

**Track Agent Health:**
```go
type AgentHealth struct {
    TerminalID      string
    AgentType       string  // "orchestrator", "dev", "qa"
    MessageCount    int
    CompactionCount int
    LastActivity    time.Time
    Status          string  // "healthy", "warning", "critical"
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
        notifyUser(a.AgentType + " approaching context limit")
    }
    if a.CompactionCount >= 4 {
        a.Status = "critical"
        triggerReload(a.TerminalID, a.AgentType)
    }
}
```

**Agent Reload:**
```go
func triggerReload(terminalID, agentType string) {
    log.Printf("⚠️ Reloading %s agent (4 compactions reached)", agentType)

    // Save context to session log
    saveContextToSessionLog(agentType)

    // Send Ctrl-C to stop current conversation
    exec.Command("tmux", "send-keys", "-t", terminalID, "C-c").Run()
    time.Sleep(500 * time.Millisecond)

    // Restart agent
    agentCommand := fmt.Sprintf("/BMad/agents/%s", agentType)
    exec.Command("tmux", "send-keys", "-t", terminalID, agentCommand, "C-m").Run()

    log.Printf("✅ %s agent reloaded with fresh context", agentType)
}
```

### 5. HTTP API

**Purpose:** Expose daemon status for DankMaterialShell plugin integration

**Endpoints:**
```go
// GET /status - Current workflow state
{
    "current_story": "1.3",
    "current_epic": "1",
    "sprint": "1",
    "workflow_phase": "development", // planning, development, qa, complete
    "agents": {
        "orchestrator": {"status": "healthy", "compactions": 2},
        "dev": {"status": "warning", "compactions": 3},
        "qa": {"status": "healthy", "compactions": 1}
    }
}

// GET /agents - Detailed agent health
{
    "orchestrator": {
        "terminal_id": "bmad-dev:0.0",
        "status": "healthy",
        "message_count": 15,
        "compaction_count": 2,
        "last_activity": "2025-11-08T03:45:12Z"
    },
    "dev": { ... },
    "qa": { ... }
}

// POST /reload/:agent - Manually trigger agent reload
// Request: POST /reload/dev
// Response: {"success": true, "message": "Dev agent reloaded"}

// GET /handoffs/recent - Last 10 handoffs
[
    {
        "timestamp": "2025-11-08T03:40:00Z",
        "type": "qa-handoff",
        "filepath": "docs/handoffs/sprint-1/epics/epic-1/1.3-qa-handoff.md",
        "routed_to": "qa"
    },
    ...
]
```

**Implementation:**
```go
func startHTTPServer(port int) {
    http.HandleFunc("/status", handleStatus)
    http.HandleFunc("/agents", handleAgents)
    http.HandleFunc("/reload/", handleReload)
    http.HandleFunc("/handoffs/recent", handleRecentHandoffs)

    addr := fmt.Sprintf("localhost:%d", port)
    log.Printf("HTTP API listening on %s", addr)
    log.Fatal(http.ListenAndServe(addr, nil))
}
```

---

## Configuration

### config.yaml

```yaml
# BMad Orchestration Daemon Configuration

# Handoff settings
handoffs:
  watch_dir: "docs/handoffs/"
  recursive: true

# tmux settings
tmux:
  session_name: "bmad-dev"
  orchestrator_pane: "bmad-dev:0.0"
  dev_pane: "bmad-dev:0.1"
  qa_pane: "bmad-dev:0.2"

# Context monitoring
context_monitoring:
  message_estimate: 30  # Assume compaction every 30 messages
  warning_threshold: 3  # Warn at 3 compactions
  reload_threshold: 4   # Auto-reload at 4 compactions

# HTTP API
http_api:
  enabled: true
  port: 8765
  host: "localhost"

# Logging
logging:
  level: "info"  # debug, info, warn, error
  file: "/var/log/bmad-orchestrator.log"
  console: true
```

**Location:** `~/.config/bmad-orchestrator/config.yaml`

---

## Architecture

### Project Structure

```
bmad-orchestrator/
├── main.go                   # Entry point
├── config/
│   └── config.go             # Configuration loading (YAML)
├── watcher/
│   └── file_watcher.go       # fsnotify integration
├── router/
│   └── handoff_router.go     # Route handoffs to terminals
├── tmux/
│   └── tmux_controller.go    # tmux send-keys integration
├── monitor/
│   └── context_monitor.go    # Agent health tracking
├── api/
│   └── http_server.go        # HTTP API endpoints
├── state/
│   └── state_manager.go      # Workflow state machine
└── utils/
    └── logger.go             # Logging utilities
```

### State Management

**Workflow State Machine:**
```go
type WorkflowState struct {
    CurrentSprint int
    CurrentEpic   int
    CurrentStory  string
    Phase         string // "planning", "development", "qa", "complete"
    Agents        map[string]*AgentHealth
    RecentHandoffs []HandoffEvent
}

type HandoffEvent struct {
    Timestamp time.Time
    Type      string // "story", "qa", "developer", "completion", "test-review"
    Filepath  string
    RoutedTo  string
}
```

---

## Deployment

### Installation

**Option 1: From Source**
```bash
git clone https://github.com/user/bmad-orchestrator.git
cd bmad-orchestrator
go build -o bmad-orchestrator
sudo mv bmad-orchestrator /usr/local/bin/
```

**Option 2: Pre-built Binary** (Future)
```bash
curl -fsSL https://install.bmad.dev/orchestrator | sh
```

### Systemd Service

**File:** `/etc/systemd/system/bmad-orchestrator.service`
```ini
[Unit]
Description=BMad Orchestration Daemon
After=network.target

[Service]
Type=simple
User=%u
ExecStart=/usr/local/bin/bmad-orchestrator
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=default.target
```

**Commands:**
```bash
sudo systemctl enable bmad-orchestrator
sudo systemctl start bmad-orchestrator
sudo systemctl status bmad-orchestrator
```

---

## Testing

### Unit Tests

```go
// watcher/file_watcher_test.go
func TestHandoffDetection(t *testing.T) {
    // Create test handoff file
    filepath := "docs/handoffs/sprint-1/epics/epic-1/1.1-story-handoff.md"
    os.WriteFile(filepath, []byte("test"), 0644)

    // Expect routing to dev terminal
    agent := routeHandoff(filepath)
    assert.Equal(t, "dev", agent)
}
```

### Integration Tests

```bash
# Test tmux control
tmux new-session -d -s bmad-dev
tmux send-keys -t bmad-dev:0 "echo 'Test prompt'" C-m

# Verify output
tmux capture-pane -t bmad-dev:0 -p | grep "Test prompt"
```

---

## Performance Targets

- **CPU Usage:** <1% idle, <5% during handoff routing
- **Memory Usage:** <50MB
- **Startup Time:** <100ms
- **Handoff Routing Latency:** <50ms (file detection → prompt injection)
- **API Response Time:** <10ms (status endpoint)

---

## Security

**Threat Model:**
- Malicious handoff files (code injection via tmux send-keys)
- Unauthorized API access (localhost only by default)
- Process privilege escalation (runs as user, not root)

**Mitigations:**
- Sanitize handoff content before injection (escape special chars)
- API authentication via tokens (optional, for remote access)
- File permissions (only user can write to handoff directory)
- Audit logging (all handoffs logged with timestamp)

---

## Next Steps (After MVD Success)

1. **Week 1: Core Development**
   - Initialize Go project
   - Implement file watcher (fsnotify)
   - Implement handoff router
   - Test with manual file creation

2. **Week 2: tmux Integration**
   - Implement tmux controller (send-keys)
   - Test prompt injection
   - Measure success rate (should match MVD: ≥80%)

3. **Week 3: Context Monitoring**
   - Implement message counting (heuristic)
   - Implement compaction detection
   - Implement agent reload logic
   - Test with real workflow (create 5 stories, observe reloads)

4. **Week 4: HTTP API**
   - Implement status endpoint
   - Implement agents endpoint
   - Implement reload endpoint
   - Test with curl, document API

5. **Week 5: Polish & Testing**
   - Unit tests for all components
   - Integration tests (end-to-end workflow)
   - Performance optimization
   - Documentation (README, API docs, troubleshooting)

---

## Resources

### Documentation
- **Workstation Architecture:** `docs/architecture/bmad-workstation-system-architecture.md`
- **Vision Session:** `research-notes/2025-11-08-bmad-ide-vision-session.md`

### External Resources
- **fsnotify:** https://github.com/fsnotify/fsnotify
- **tmux manual:** `man tmux`
- **Go net/http:** https://pkg.go.dev/net/http

---

**Context Version:** 1.0
**Completeness:** Architecture Design Complete
**Next Update:** After development begins (Week 1-2 of Phase 1)
