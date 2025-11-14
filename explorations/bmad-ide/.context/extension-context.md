# VS Code Extension - Branch Context

**Thread:** VS Code Extension MVP
**Status:** Phase 1 - Planning (Pending MVD Success)
**Last Updated:** 2025-11-08 03:37:36

---

## Thread Overview

**VS Code Extension** is Stage 1 of two-stage BMad IDE architecture. It validates the core concept (agent cooperation via programmatic prompt injection) quickly by targeting 100M+ VS Code users with familiar tooling.

**Vision:** Automated three-terminal workflow orchestration within VS Code, with dashboard UI for monitoring workflow state and agent health.

**Strategic Role:** Fast validation + revenue generation while building Linux Terminal System (Stage 2)

---

## Current Status

### ⏸️ Pending

**Blocker:** Awaiting MVD (Minimum Viable Demo) success this weekend

**If MVD Succeeds (≥80% agent response rate):**
- Begin Phase 1 development (Months 1-3)
- Month 1: Foundation & automation
- Month 2: Monitoring & UI
- Month 3: Polish & launch

**If MVD Fails (<80% agent response rate):**
- Pivot to alternative approaches (hooks-based, manual workflow, or abandon IDE)

---

## Key Decisions (Planned)

### Technology Stack (To Be Finalized)

**Language:** TypeScript
- Why: Native VS Code extension language, strong typing, large ecosystem

**File Watcher:** chokidar
- Why: Robust, cross-platform, well-maintained
- Alternative: fs.watch (stdlib, but less reliable)

**Prompt Injection:** VS Code Terminal API
- Method: `terminal.sendText()` to inject prompts
- Alternative: Clipboard-based (user copies snippet, but not automated)

**UI Framework:** React (for Webview)
- Why: Popular, many component libraries, fast development
- Alternative: Svelte (smaller bundle, but less ecosystem)

**State Management:** VS Code Extension Context
- Why: Built-in, persistent across reloads
- Alternative: Redux (overkill for this scope)

---

## Planned Features

### Month 1: Foundation & Automation

**Week 1-2: Extension Foundation**
- VS Code extension scaffolding (manifest.json, activation events)
- File watcher integration (chokidar)
- Basic prompt injection (terminal.sendText)
- Settings page (enable/disable, configure paths)

**Week 3-4: Handoff Automation**
- Parse all 5 handoff types (Story, QA, Developer, Completion, Test Review)
- Route to correct terminal (detect which terminal has which agent)
- Workflow state machine (track story progress)
- Error handling (agent not found, timeout, refuses)

### Month 2: Monitoring & UI

**Week 5-6: Context Monitoring**
- Message counting (estimate compactions, no direct API)
- Warning notifications (3 compactions)
- Manual reload capability (button to restart agent)
- Context preservation (save summary before reload)

**Week 7-8: Dashboard UI**
- Webview panel with workflow state
- Terminal status (context health indicators: green/yellow/red)
- Quick-jump to terminals (click to focus)
- Recent events log (last 10 handoffs, reloads, errors)
- Manual override controls (pause, reload, skip handoff)

### Month 3: Polish & Launch

**Week 9-10: Testing & Refinement**
- Error handling improvements
- User testing (5-10 alpha testers)
- Bug fixes from feedback
- Performance optimization (reduce CPU usage, memory footprint)

**Week 11-12: Launch**
- Documentation (README, usage guide, video demo)
- Publish to VS Code Marketplace (free tier)
- Launch announcement (HN, Reddit, Twitter, Product Hunt)
- Community setup (Discord, GitHub Discussions)

---

## Architecture (Planned)

### Extension Structure

```
bmad-ide-vscode/
├── package.json                  # Extension manifest
├── src/
│   ├── extension.ts              # Entry point, activation
│   ├── fileWatcher.ts            # chokidar integration
│   ├── handoffRouter.ts          # Route handoffs to terminals
│   ├── contextMonitor.ts         # Track agent context health
│   ├── stateManager.ts           # Workflow state machine
│   ├── dashboardProvider.ts      # Webview UI
│   └── commands/                 # Extension commands
│       ├── reloadAgent.ts
│       ├── pauseWorkflow.ts
│       └── skipHandoff.ts
├── webview/                      # Dashboard UI (React)
│   ├── App.tsx
│   ├── WorkflowStatus.tsx
│   ├── AgentHealth.tsx
│   └── EventLog.tsx
└── test/                         # Extension tests
```

### File Watcher

**Watch:** `docs/handoffs/` directory (configured in settings)

**On Create:**
1. Detect handoff type (Story, QA, Developer, Completion, Test Review)
2. Find target terminal (scan for agent activation command)
3. Inject prompt via `terminal.sendText()`
4. Log event to dashboard
5. Update workflow state

**Implementation:**
```typescript
import chokidar from 'chokidar';

const watcher = chokidar.watch('docs/handoffs/', {
  persistent: true,
  ignoreInitial: true,
});

watcher.on('add', (filepath) => {
  handleNewHandoff(filepath);
});

function handleNewHandoff(filepath: string) {
  const handoffType = detectHandoffType(filepath);
  const targetTerminal = findAgentTerminal(handoffType);

  if (targetTerminal) {
    const prompt = `[AUTO-HANDOFF] New ${handoffType} handoff: ${filepath}\nLoad and proceed.`;
    targetTerminal.sendText(prompt);
    logEvent(`Routed ${handoffType} to ${targetTerminal.name}`);
  }
}
```

---

## Integration with Workstation

**Shared Logic:**
- Handoff detection (same filename patterns)
- Handoff routing (same rules)
- Context monitoring (same thresholds: 3 warnings, 4 reload)

**Extension → Workstation Port:**
- TypeScript file watcher → Go fsnotify
- VS Code terminal API → tmux send-keys
- React dashboard → Quickshell QML (DMS plugin)

**Strategy:** Extension proves concept, Workstation scales it

---

## Success Metrics (End of Phase 1)

**Adoption:**
- 100+ active users (realistic for niche tool)
- 80%+ handoff automation success rate
- 50%+ Day-7 retention

**Quality:**
- 90%+ user satisfaction (NPS >50)
- <5% critical bugs reported
- 5+ community contributions (issues, PRs)

**Revenue:**
- $0 (all free tier, focus on validation)

**GO/NO-GO Decision:**
- ✅ GO → Phase 2 (Terminal System): >100 users, >80% success, >90% satisfaction
- ❌ NO-GO (Iterate): <50 users, <70% success, low satisfaction

---

## Competitive Landscape

**Cursor Composer:**
- Multi-file editing, but no workflow automation
- No agent handoffs, no context monitoring

**Windsurf:**
- Similar to Cursor, focuses on code generation
- No workflow orchestration

**Aider:**
- Terminal-based, Git-focused
- No IDE integration, manual workflow

**BMad Extension Differentiation:**
- Automated handoffs (zero manual copy-paste)
- Context monitoring (proactive reload)
- Workflow visualization (dashboard UI)
- Open framework (BMad Method)

---

## Resources

### Documentation (To Be Created)
- Architecture document (after MVD success)
- API specification (terminal control, state management)
- UI mockups (dashboard design)

### References
- **VS Code Extension API:** https://code.visualstudio.com/api
- **chokidar:** https://github.com/paulmillr/chokidar
- **Webview API:** https://code.visualstudio.com/api/extension-guides/webview

---

## Next Steps (After MVD Success)

1. **Month 1, Week 1: Project Setup**
   - Initialize VS Code extension project
   - Set up TypeScript, ESLint, Prettier
   - Configure webpack for webview bundling
   - Create extension manifest

2. **Month 1, Week 2: File Watcher POC**
   - Integrate chokidar
   - Test handoff detection
   - Implement basic routing logic

3. **Month 1, Week 3: Terminal Control POC**
   - Find agent terminals
   - Test prompt injection
   - Measure success rate (should match MVD: ≥80%)

---

**Context Version:** 1.0
**Completeness:** Planning Phase - Awaiting MVD
**Next Update:** After MVD results determine GO/NO-GO
