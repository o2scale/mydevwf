# Framework Maintenance Guide

**Last Updated**: 2025-11-18

This guide documents critical maintenance procedures for the MyDevWF framework to prevent recurring issues.

---

## Critical: Slash Command vs Agent File Synchronization

### The Problem

**Discovery Date**: 2025-11-18

The BMad framework has two copies of agent definition files:

1. **Source Files**: `.bmad-core/agents/*.md` (10 agent files)
2. **Slash Command Files**: `.claude/commands/BMad/agents/*.md` (10 agent files)

**When you use slash commands** (e.g., `/BMad/agents/dev`, `/BMad/agents/orchestrator`), Claude Code loads from `.claude/commands/`, NOT from `.bmad-core/agents/`.

**The Issue**: When you modify agent files in `.bmad-core/agents/`, the slash command files in `.claude/commands/` do NOT automatically update. This causes:
- Slash commands to use stale agent definitions
- Missing critical workflow optimizations (Backend Restart Protocol, Git workflow, etc.)
- Inconsistent behavior between direct agent activation and slash command activation

### How We Discovered It

**Scenario**: Orchestrator auto-load files implementation (2025-11-18)
- Modified `.bmad-core/agents/bmad-orchestrator.md` with STEP 3 file loading instructions
- Made 4 commit attempts (782a428, e083146, a0178f7, 15ec996)
- Orchestrator consistently failed to load files when invoked via `/BMad/agents/orchestrator`
- **Root Cause**: Slash command was loading from `.claude/commands/BMad/agents/bmad-orchestrator.md`, which had OLD activation instructions

### The Solution

**Immediate Fix**: Copy all agent files from source to slash commands:

```powershell
# From D:\Dev\mydevwf directory
for agent in analyst architect bmad-master bmad-orchestrator dev pm po qa sm ux-expert; do
  cp .bmad-core/agents/$agent.md .claude/commands/BMad/agents/$agent.md
done
```

**Verification**: Check critical updates are present:

```bash
# Verify dev.md has Backend Restart Protocol
grep -c "Backend Restart Protocol" .claude/commands/BMad/agents/dev.md

# Verify qa.md has downloadsDir fix
grep -c "downloadsDir" .claude/commands/BMad/agents/qa.md

# Verify sm.md has Timestamp Protocol
grep -c "Timestamp Protocol" .claude/commands/BMad/agents/sm.md
```

### Prevention Strategy

**CRITICAL RULE**: When modifying ANY agent file in `.bmad-core/agents/`, you MUST also update the corresponding slash command file in `.claude/commands/BMad/agents/`.

**Recommended Workflow**:

1. **Modify agent file**: Edit `.bmad-core/agents/{agent}.md`
2. **Sync slash command**: Copy to `.claude/commands/BMad/agents/{agent}.md`
3. **Verify sync**: Check timestamps match or slash command has latest changes
4. **Commit both files together**:
   ```bash
   git add .bmad-core/agents/{agent}.md .claude/commands/BMad/agents/{agent}.md
   git commit -m "fix({agent}): Update agent and slash command with {feature}"
   ```

**Bulk Sync Check** (run periodically):

```bash
# Compare modification timestamps
for agent in analyst architect bmad-master bmad-orchestrator dev pm po qa sm ux-expert; do
  echo "=== $agent ==="
  echo -n "bmad-core: "
  stat -c "%y" .bmad-core/agents/$agent.md 2>/dev/null || echo "N/A"
  echo -n "slash cmd: "
  stat -c "%y" .claude/commands/BMad/agents/$agent.md 2>/dev/null || echo "N/A"
done
```

If bmad-core timestamp is NEWER than slash cmd, sync is required.

### Historical Sync Issues (Nov 2025)

**Commit dcc73de** (2025-11-18): Synced all 9 agent files after discovering discrepancies

**Agents Out of Sync**:
- **dev.md**: Missing Backend Restart Protocol, Git workflow (3 weeks old)
- **qa.md**: Missing Playwright downloadsDir, Git workflow (3 weeks old)
- **sm.md**: Missing Timestamp Protocol (2 weeks old)
- **analyst.md, architect.md, pm.md, ux-expert.md**: Minor differences

**Impact**: Users invoking `/BMad/agents/dev` or `/BMad/agents/qa` were missing November workflow optimizations (Backend Restart, Commit Points, Evidence Collection).

---

## Symlink Synchronization

### Active Projects Symlink Status

The framework uses symbolic links to sync `.bmad-core/` and `.claude/commands/` from master template to active projects.

**Setup Script**: `.\scripts\setup-symlinks.ps1` (requires Administrator on Windows)

**Current Symlinked Projects**:
- D:\Dev\mydevwf\projects\hdav2 (confirmed 2025-11-18)

**Verify Symlink**:
```powershell
cd D:\Dev\mydevwf\projects\{project}
Get-Item .bmad-core | Select-Object Mode, Target
# Expected: Mode: l----, Target: D:\Dev\mydevwf\.bmad-core
```

**If NOT Symlinked** (Mode: d----):
1. Delete directory: `Remove-Item .bmad-core -Recurse -Force`
2. Create symlink: `New-Item -ItemType SymbolicLink -Path .bmad-core -Target D:\Dev\mydevwf\.bmad-core`

**See**: `scripts/README-SYMLINKS.md` for complete symlink documentation

---

## Framework Update Checklist

When making framework improvements, follow this checklist to ensure complete propagation:

### 1. Agent Updates
- [ ] Modify `.bmad-core/agents/{agent}.md`
- [ ] Copy to `.claude/commands/BMad/agents/{agent}.md`
- [ ] Verify both files have identical content (or slash command has latest changes)
- [ ] Commit both files together

### 2. Task/Template Updates
- [ ] Modify `.bmad-core/tasks/{task}.md` or `.bmad-core/templates/{template}.yaml`
- [ ] Check if any agents reference this task/template
- [ ] Update agent dependencies if needed
- [ ] Update core-config.yaml if new auto-load files added

### 3. Data/Guide Updates
- [ ] Modify `.bmad-core/data/{guide}.md`
- [ ] Check core-config.yaml devLoadAlwaysFiles and orchestratorLoadAlwaysFiles
- [ ] Update if guide should be auto-loaded
- [ ] Verify agents reference correct file paths

### 4. Cross-Agent Impact Analysis
- [ ] Identify all agents affected by change (use Agent Alignment Audit process)
- [ ] Create dependency matrix (Changes × Agents)
- [ ] Update all affected agents
- [ ] Sync all affected slash commands
- [ ] Test with actual agent invocations

### 5. Documentation Updates
- [ ] Update CLAUDE.md if user-facing behavior changes
- [ ] Update session logs if major architectural decision
- [ ] Update relevant docs/guides/ files
- [ ] Add entry to this maintenance guide if new procedure

---

## Agent Alignment Audit Process

**When to Run**: After implementing any workflow optimization or framework change

**Purpose**: Ensure all 10 agents work correctly with framework changes, prevent tunnel vision on specific agents

**Process** (From 2025-11-15 Navigation Integration example):

1. **Catalog All Agents**: List all 10 BMad agents (analyst, pm, architect, ux-expert, po, sm, dev, qa, orchestrator, bmad-master)

2. **Create Dependency Matrix**:
   ```
   Change: Navigation Integration (Option B)
   Files Modified: core-config.yaml, story-tmpl.yaml, story-dod-checklist.md

   Agent Impact Analysis:
   - analyst: No impact (doesn't create stories)
   - pm: No impact (doesn't create stories)
   - architect: No impact (doesn't create stories)
   - ux-expert: High impact (creates front-end-spec.md, must document navigation)
   - po: No impact (validates/shards, doesn't create)
   - sm: HIGH IMPACT (creates stories via create-next-story.md task)
   - dev: Medium impact (reads story with Navigation Notes, implements)
   - qa: Low impact (verifies navigation via DoD checklist)
   - orchestrator: HIGH IMPACT (creates stories via *create-story command)
   - bmad-master: HIGH IMPACT (can perform most tasks including story creation)
   ```

3. **Identify Gaps**: For high-impact agents, verify they have necessary instructions
   - Example: SM/Orchestrator/bmad-master use `create-next-story.md` task
   - Gap Found: Task had no Navigation Notes population instructions (Step 5.3)
   - Fix Applied: Added Step 5.3 to create-next-story.md (commit 950c5fb)

4. **Test Critical Paths**: Verify agents work end-to-end with changes
   - Create story via SM: Verify Navigation Notes populated
   - Implement story via Dev: Verify navigation implemented
   - Review via QA: Verify DoD checklist includes navigation

---

## Related Documentation

- **Framework Synchronization**: `scripts/README-SYMLINKS.md`
- **Workflow Optimizations**: `docs/analysis/`, `docs/planning/`, `docs/verification/`
- **Session Logs**: `docs/session-logs/` (architectural decisions and evolution)
- **User Guide**: `.bmad-core/user-guide.md`

---

## Maintenance History

### 2025-11-18: Slash Command Sync Issue Discovery and Resolution
- **Issue**: Orchestrator auto-load files not working after 4 commit attempts
- **Root Cause**: Slash command file out of sync with agent file
- **Resolution**: Synced all 10 agent slash commands (commits 8ea0717, dcc73de)
- **Prevention**: Created this maintenance guide with sync procedures

### 2025-11-15: Navigation Integration (Option B)
- **Change**: Added Navigation Notes to story template and DoD checklist
- **Agent Alignment**: Discovered create-next-story.md gap, added Step 5.3
- **Process**: Established Agent Alignment Audit process to prevent tunnel vision

### 2025-11-07: Backend Restart Protocol
- **Change**: Added mandatory backend restart before QA Handoff
- **Affected Agents**: dev.md (protocol), qa.md (handoff format)
- **Sync Status**: Initially only updated .bmad-core/, synced to slash commands 2025-11-18

### 2025-11-04: Timestamp Protocol
- **Change**: Linux-first approach for timestamps
- **Affected Agents**: sm.md, dev.md, qa.md
- **Sync Status**: Initially only updated .bmad-core/, synced to slash commands 2025-11-18

---

**Remember**: The framework is a living system. When you improve one part, check for ripple effects across all agents, tasks, and documentation. Use the Agent Alignment Audit process to avoid tunnel vision.
