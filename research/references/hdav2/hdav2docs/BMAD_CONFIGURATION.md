# BMAD Configuration Summary

**Version**: 1.0
**Last Updated**: 2025-10-03
**Purpose**: Document BMAD team configuration, DevNotes integration, and Playwright MCP setup

---

## Overview

The HDA Translation Platform v2.0 uses BMAD (Business Model-Driven Agile Development) Core for team orchestration, with integrated Playwright MCP for automated E2E testing and a shared DevNotes context system for cross-agent communication.

---

## Team Configuration

### Team Fullstack (`.bmad-core/agent-teams/team-fullstack.yaml`)

**Active Agents**:
- `bmad-orchestrator` - Team coordination
- `analyst` - Requirements analysis
- `pm` - Project management
- `ux-expert` - UX/UI guidance
- `architect` - Technical architecture
- `po` - Product ownership
- `dev` (James 💻) - Full Stack Developer
- `qa` (Quinn 🧪) - Test Architect & Quality Advisor

**Shared Context**:
- **DevNotes File**: `.ai/devnotes.md`
- **Update Policy**: Append-only (never delete others' entries)
- **Purpose**: Cross-agent, cross-terminal, cross-session communication

---

## DevNotes Integration

### What is DevNotes?

DevNotes (`.ai/devnotes.md`) is a shared context file that enables:
1. **Cross-Agent Communication** - Dev, QA, Architect can share updates
2. **Cross-Terminal Coordination** - Multiple terminals stay in sync
3. **Cross-Session Persistence** - Context survives Claude Code restarts
4. **Append-Only Policy** - Historical record maintained

### Usage Patterns

#### Dev Agent Commands
- `*update-devnotes` - Append task updates, blockers, or decisions
- `*read-devnotes` - Read current shared context

#### QA Agent Commands
- `*update-devnotes` - Append test results and findings
- `*read-devnotes` - Check dev progress and context
- `*playwright-test {story}` - Run tests and append results to devnotes

### Entry Templates

#### [DEV] Entry
```markdown
### YYYY-MM-DD HH:MM:SS - [DEV] Story X.Y - Task Name
- Status: [In Progress/Completed/Blocked]
- Files Modified: [list]
- Tests: [Pass/Fail/Pending]
- Notes: [important context]
```

#### [QA] Entry
```markdown
### YYYY-MM-DD HH:MM:SS - [QA] Test Suite: Name
- Test Type: [E2E/Integration/Unit]
- Results: X/Y passed
- Failures: [list if any]
- Playwright Report: [link]
```

#### [ARCHITECT] Entry
```markdown
### YYYY-MM-DD HH:MM:SS - [ARCHITECT] Technical Decision
- Decision: [what was decided]
- Rationale: [why]
- Impact: [affected components]
- Alternatives Considered: [list]
```

---

## Playwright MCP Integration

### Configuration

**File**: `playwright.config.ts`

**Browsers Configured**:
- Chromium (Desktop Chrome)
- Firefox
- WebKit (Safari)
- Mobile Chrome (Pixel 5)
- Mobile Safari (iPhone 12)

**Test Directory**: `tests/e2e/`

**Base URLs**:
- Frontend: `http://localhost:5173`
- Backend API: `http://localhost:8000`

### How It Works

1. **QA Agent Activation**: Run `/BMad:agents:qa` to activate Quinn
2. **Read Story**: Quinn reads story acceptance criteria
3. **Generate Tests**: Playwright MCP dynamically generates test scenarios
4. **Execute Tests**: Tests run across all configured browsers
5. **Report Results**: Results appended to `.ai/devnotes.md`

### Test Execution Flow

```bash
# Activate QA Agent
/BMad:agents:qa

# Generate and run tests for a story
*playwright-test 1.2

# Results automatically written to:
# 1. tests/e2e/reports/html/index.html
# 2. tests/e2e/reports/results.json
# 3. .ai/devnotes.md (summary)
```

### Test Patterns

All tests follow **Given-When-Then** structure:

```typescript
test('should upload document', async ({ page }) => {
  // Given: User is on upload page
  await page.goto('/upload');

  // When: User uploads PDF
  await page.locator('input[type="file"]').setInputFiles('sample.pdf');

  // Then: Success message displayed
  await expect(page.locator('[data-testid="success"]')).toBeVisible();
});
```

---

## Core Configuration (`.bmad-core/core-config.yaml`)

### Key Settings

```yaml
# Shared Context
sharedContext:
  devNotesFile: .ai/devnotes.md
  enabled: true
  updatePolicy: append-only

# Playwright MCP
playwrightMCP:
  enabled: true
  testDirectory: tests/e2e
  configFile: playwright.config.ts
  browsers: [chromium, firefox, webkit]
  baseURL: http://localhost:5173
  apiURL: http://localhost:8000

# Dev Load Always Files (loaded on dev agent activation)
devLoadAlwaysFiles:
  - docs/architecture/coding-standards.md
  - .ai/devnotes.md

# Other Settings
devDebugLog: .ai/debug-log.md
devStoryLocation: docs/stories
qaLocation: docs/qa
```

---

## Agent Modifications

### Dev Agent (James - `.bmad-core/agents/dev.md`)

**Added Activation Steps**:
- STEP 3.5: Load `.ai/devnotes.md` for shared context
- DevNotes integration: Append updates after task completion

**New Commands**:
- `*update-devnotes` - Append entry with [DEV] tag
- `*read-devnotes` - Read shared context

### QA Agent (Quinn - `.bmad-core/agents/qa.md`)

**Added Activation Steps**:
- STEP 3.5: Load `.ai/devnotes.md` for development context
- Playwright MCP: Use for E2E test automation
- DevNotes integration: Append test results

**New Commands**:
- `*update-devnotes` - Append entry with [QA] tag
- `*read-devnotes` - Read shared context
- `*playwright-test {story}` - Generate and execute E2E tests

---

## Workflow Examples

### Example 1: Dev Implements Story, QA Tests

**Terminal 1 (Dev Agent)**:
```bash
/BMad:agents:dev
*develop-story 1.2
# ... implementation happens ...
*update-devnotes  # Appends: Story 1.2 implemented, ready for QA
```

**Terminal 2 (QA Agent)**:
```bash
/BMad:agents:qa
*read-devnotes  # Sees dev completed Story 1.2
*playwright-test 1.2  # Generates and runs E2E tests
*update-devnotes  # Appends: All tests passed for Story 1.2
```

### Example 2: Architect Makes Decision

**Terminal (Architect Agent)**:
```bash
/BMad:agents:architect
*update-devnotes
# Manual entry in devnotes.md:
# Decision: Use token-based batch processing
# Rationale: Stays within Vertex AI 1M token limit
# Impact: batch_processor.py, processing_batches table
```

**Dev Agent** (later):
```bash
*read-devnotes  # Sees architect's decision
# Implements according to decision
```

### Example 3: Cross-Session Continuity

**Session 1 (Morning)**:
```bash
/BMad:agents:dev
*develop-story 1.3
*update-devnotes  # Progress: Completed Task 1, starting Task 2
# Claude Code closed
```

**Session 2 (Afternoon)**:
```bash
/BMad:agents:dev
# On activation, auto-loads .ai/devnotes.md
*read-devnotes  # Sees morning's progress: "Completed Task 1, starting Task 2"
# Continues from where left off
```

---

## File Locations Reference

### BMAD Core (Not in Git)
- `.bmad-core/core-config.yaml` - Core configuration
- `.bmad-core/agents/dev.md` - Dev agent definition
- `.bmad-core/agents/qa.md` - QA agent definition
- `.bmad-core/agent-teams/team-fullstack.yaml` - Team configuration
- `.bmad-core/tasks/*.md` - Task workflows
- `.bmad-core/checklists/*.md` - Checklists

### Shared Context (In Git)
- `.ai/devnotes.md` - Shared context file ✅
- `.ai/debug-log.md` - Debug log

### Tests (In Git)
- `playwright.config.ts` - Playwright configuration ✅
- `tests/e2e/` - E2E test directory ✅
- `tests/e2e/README.md` - Test documentation ✅
- `tests/e2e/example.spec.ts` - Example tests ✅

### Documentation (In Git)
- `docs/BMAD_CONFIGURATION.md` - This file ✅
- `docs/stories/*.md` - Story files
- `docs/architecture/*.md` - Architecture docs

---

## Quick Start Commands

### Activate Agents
```bash
# Dev Agent
/BMad:agents:dev

# QA Agent
/BMad:agents:qa

# Architect Agent
/BMad:agents:architect
```

### Dev Agent Workflow
```bash
*help                    # Show commands
*read-devnotes          # Read shared context
*develop-story 1.2      # Implement story
*update-devnotes        # Share progress
*run-tests              # Execute tests
*review-qa              # Apply QA fixes
*exit                   # Exit agent
```

### QA Agent Workflow
```bash
*help                    # Show commands
*read-devnotes          # Check dev progress
*playwright-test 1.2    # Run E2E tests
*review 1.2             # Full story review
*gate 1.2               # Quality gate decision
*update-devnotes        # Share test results
*exit                   # Exit agent
```

---

## Benefits

### 1. **Context Preservation**
- Shared devnotes survive session restarts
- No context loss between agent switches
- Historical record of all decisions

### 2. **Team Coordination**
- Dev and QA stay in sync
- Architect decisions visible to all
- Blockers communicated immediately

### 3. **Automated Testing**
- Playwright MCP generates tests from stories
- Multi-browser coverage automatically
- Results tracked in devnotes

### 4. **Traceability**
- All updates timestamped
- Clear agent attribution ([DEV], [QA])
- Append-only ensures audit trail

---

## Troubleshooting

### DevNotes Not Loading
**Issue**: Agent doesn't see devnotes on activation
**Solution**: Check `devLoadAlwaysFiles` in `.bmad-core/core-config.yaml` includes `.ai/devnotes.md`

### Playwright Tests Failing
**Issue**: Tests can't reach frontend/backend
**Solution**: Ensure services running:
```bash
# Terminal 1: Backend
cd backend && uvicorn api.main:app --reload

# Terminal 2: Frontend
cd frontend && npm run dev

# Terminal 3: Tests
npx playwright test
```

### DevNotes Conflicts
**Issue**: Multiple agents writing simultaneously
**Solution**: Append-only policy prevents conflicts. Each agent appends with timestamp.

---

## Next Steps

1. ✅ **Initialize all agents** with devnotes integration
2. ✅ **Configure Playwright MCP** for E2E testing
3. ⏳ **Implement Story 1.1** - Supabase setup
4. ⏳ **Generate tests for Story 1.1** using `*playwright-test 1.1`
5. ⏳ **Build Story 1.2** - Upload API
6. ⏳ **Continuous testing** with QA agent

---

**Document Version**: 1.0
**Last Updated**: 2025-10-03 by Dev Agent (James)
