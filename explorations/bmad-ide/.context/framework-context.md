# BMad Framework Optimizations - Branch Context

**Thread:** BMad V4 Framework Optimizations
**Status:** Production-Ready, Ongoing Refinement
**Last Updated:** 2025-11-08 03:37:36

---

## Thread Overview

**BMad Framework Optimizations** focuses on improving BMad V4 (our production framework) by cherry-picking innovations from BMad V6 Alpha and implementing pragmatic enhancements based on real-world usage.

**Vision:** Keep BMad V4 as foundation, continuously improve based on empirical evidence, avoid costly migrations.

**Strategic Role:** Foundation for both BMad IDE stages (Extension and Workstation use BMad V4 framework)

---

## Current Status

### ✅ Production-Ready (BMad V4 Optimized)

**Major Optimizations Completed:**

1. **Dual-Format Handoffs** (2025-10-30)
   - Detailed documents (comprehensive context)
   - Compact snippets (10-15 lines, terminal-friendly)
   - References between them (snippet points to document)

2. **Three-Terminal Workflow** (2025-10-30)
   - Orchestrator terminal (planning, research, vetting)
   - Dev terminal (implementation, testing)
   - QA terminal (validation, quality gates)

3. **Vitest + Playwright MCP Hybrid Testing** (2025-10-28)
   - Vitest: Complex logic (10+ edge cases)
   - Playwright MCP: All user journeys (26 interactive tools)
   - Eliminated Jest entirely

4. **Context7 MCP Proactive Integration** (2025-10-29)
   - All planning agents use Context7 for real-time docs
   - Prevents deprecated patterns
   - "use context7 - {question}" pattern

5. **Backend Restart Protocol** (2025-11-08) ⭐ NEW
   - Mandatory restart before QA Handoff (if backend files modified)
   - Eliminates "stale code" testing
   - 3-5% productivity gain

6. **Handoff Reading Optimization** (2025-11-08) ⭐ NEW
   - Dev agent reads full Story/Developer Handoff documents
   - Orchestrator reads full Test Review/Developer/Completion Handoff documents
   - QA already optimized (2025-10-30)

### 🔍 Analyzed (No Migration)

7. **BMad V6 Alpha Comprehensive Analysis** (2025-11-07)
   - Decision: STAY V4, cherry-pick V6 concepts
   - Rationale: Subagents have performance issues (20k overhead, lower quality)
   - Cherry-picks: TEA knowledge base, Story Context XML, centralized config

---

## Key Decisions

### Decision: Stay BMad V4, Don't Migrate to V6

**Date:** 2025-11-07
**Context:** User installed BMad V6 Alpha for evaluation

**V6 Innovations:**
- Module system (core/bmm/bmb/cis/custom)
- BMad Builder (BOMB) - self-extensible framework
- Update-safe customizations (_cfg/ directory)
- XML agent definitions (better LLM parsing)
- TEA Agent (Test Engineer/Architect - 21 pattern files, 12,821 lines)
- Creative Intelligence Suite (5 agents, 150+ techniques)

**Critical V6 Problems:**
- Subagent performance issues (20k token overhead per invocation)
- User's empirical evidence: "don't get things done properly. Quality is not yet there."
- Fresh Chats lose architectural memory (no state persistence)
- Migration cost: 2-3 weeks, medium risk

**Our V4 Advantages:**
- Playwright MCP core methodology (V6 treats it as optional)
- Three-terminal workflows (unique innovation)
- Dual-format handoffs (rich context + fast communication)
- Production stability (proven in hdav2 project)
- Continuous conversations (zero subagent overhead)

**Decision:** STAY V4, cherry-pick V6 concepts

**Cherry-Pick List:**
1. TEA knowledge base (21 testing pattern files, 12,821 lines)
2. Story Context XML generation (structured context for agents)
3. Centralized config pattern (single source of truth)

**Impact:** Avoid costly migration, keep production stability, gain V6 benefits incrementally

---

### Decision: Backend Restart Protocol (Mandatory)

**Date:** 2025-11-08
**Context:** User identified production gap from client work

**Problem:**
- Backend file changes (Node.js, FastAPI) don't take effect until process restart
- Dev often forgets to restart before QA Handoff
- QA tests stale code, wastes 20-40 minutes debugging non-issues

**Solution:** Mandatory backend restart protocol before QA Handoff

**Protocol Steps:**
1. IF story modified ANY backend files (routes, controllers, models, middleware, services, server.js, app.js, or ANY .js/.ts files in backend/server directories)
2. BEFORE creating QA Handoff:
   - Identify all backend process PIDs currently running
   - Stop backend processes ONLY (NEVER kill all node processes)
   - Restart backend with fresh code using configured start command
   - Verify backend started successfully (check logs, test health endpoint)
   - Record NEW PID and restart timestamp
   - Include in QA Handoff: "Backend Restarted ✅ at [timestamp] (PID: [new-pid], Reason: Modified [file-list])"

**Files Modified:**
- `.bmad-core/agents/dev.md` (lines 70, 89)
- `.bmad-core/data/handoff-templates.md` (lines 81, 101, 117)
- `.bmad-core/checklists/story-dod-checklist.md` (line 88)
- `CLAUDE.md` (lines 284, 391-422)

**Expected Impact:**
- Eliminate 20-40 minutes wasted time per backend story
- 3-5% productivity gain
- Reduce "works on my machine" debugging

---

### Decision: Handoff Reading Optimization

**Date:** 2025-11-08
**Context:** Noticed Dev and Orchestrator might rely only on compact snippets

**Problem:**
- Dual-format handoffs create detailed documents (Context7 findings, technical decisions, edge cases)
- Compact snippets reference documents ("📄 Full Handoff: {path}")
- Dev and Orchestrator agents lacked explicit instructions to read full documents
- Risk: Agents miss valuable context, make suboptimal decisions

**Solution:** Add explicit reading instructions to agent activation steps

**Dev Agent (lines 29-30):**
- STEP 3.8: Read Story Handoff document (Context7 findings, technical decisions, AC breakdown, expected tests, dependencies, implementation guidance, KB references)
- STEP 3.9: Read Developer Handoff document (failing test cases, evidence, root cause analysis, suggested fixes, reproduction steps)

**Orchestrator Agent (lines 23-24):**
- STEP 3.5: Read Test Review Handoff document (review summary, coverage analysis, strengths/gaps, recommendations, quality notes, risk assessment)
- STEP 3.6: Read Developer/Completion Handoff document (issues, evidence, test results, quality notes)

**QA Agent:** Already optimized (line 23, added 2025-10-30)

**Impact:**
- Agents automatically read full documents
- Full Context7 research available
- Better decision-making quality
- No information loss

---

## Recent Optimizations (Details)

### Backend Restart Protocol

**Implementation Example (Dev Agent):**
```yaml
- 'CRITICAL: Backend Restart Protocol - IF story modified ANY backend files
  (routes, controllers, models, middleware, services, server.js, app.js, or ANY
  .js/.ts files in backend/server directories): BEFORE creating QA Handoff,
  (1) Identify all backend process PIDs currently running, (2) Stop backend
  processes ONLY using KillShell tool or kill SPECIFIC PIDs (NEVER kill all
  node processes), (3) Restart backend with fresh code using configured start
  command (npm run dev, npm run server, etc.), (4) Verify backend started
  successfully (check logs for "Server running" or similar, test health/status
  endpoint if available), (5) Record NEW PID and restart timestamp, (6) Include
  in QA Handoff: Backend Restarted ✅ at [timestamp] (PID: [new-pid], Reason:
  Modified [file-list]). This ensures QA tests against LATEST backend code, not
  stale cached version.'
```

**QA Handoff Template (Detailed Document):**
```markdown
### Backend Restart Confirmation
- **Status:** {Restarted ✅ | No restart needed ⏭️}
- **Timestamp:** {YYYY-MM-DD HH:MM:SS}
- **New PID:** {pid}
- **Files Modified:** {comma-separated list of backend files that triggered restart}
- **Verification:** {health check result, log confirmation}
```

**QA Handoff Template (Compact Snippet):**
```
🔄 Backend: {Restarted ✅ at [timestamp] (PID: [new-pid]) | No restart needed ⏭️}
```

**Example:**
```
🔄 Backend: Restarted ✅ at 2025-11-04 12:29:45 (PID: 12346, Modified: backend/api/routers/media.py)
```

### Handoff Reading Optimization

**Why Critical:**
- Orchestrator uses Context7 MCP to research technical decisions
- Research findings go into detailed Story Handoff document
- Without explicit reading instruction, Dev might miss Context7 research
- Example: Orchestrator researches "Next.js 14 App Router best practices" → Dev needs this context

**Before Optimization:**
- Dev received compact snippet (10-15 lines)
- Snippet mentioned document reference, but no explicit instruction to read
- Risk: Dev makes decisions without Context7 research context

**After Optimization:**
- Dev activation explicitly instructs: "IF user provides Story Handoff snippet with '📄 Full Handoff:' reference, read the referenced handoff document for comprehensive implementation context"
- Dev automatically reads full document before implementation
- Full Context7 research, technical decisions, edge cases available

---

## BMad V4 Optimized Feature Set

### Core Features

1. **Dual-Format Handoffs**
   - Detailed documents (~500-1000 lines)
   - Compact snippets (10-15 lines)
   - Five types: Story, QA, Developer, Completion, Test Review

2. **Three-Terminal Workflow**
   - Orchestrator: Planning, research (Context7), test vetting
   - Dev: Implementation, testing, background processes
   - QA: Validation, quality gates, evidence collection

3. **Vitest + Playwright MCP Hybrid Testing**
   - Vitest: Unit tests for complex logic (tax calculations, algorithms, validation)
   - Playwright MCP: E2E tests via 26 interactive browser tools
   - E2E scenarios: Markdown format (not .spec.ts files)

4. **Context7 MCP Integration**
   - Proactive documentation lookup
   - Prevents deprecated patterns
   - Used by: Analyst, PM, Architect (MOST CRITICAL), UX Expert, Dev, QA

5. **Quality Gates (YAML format)**
   - File: `docs/qa/gates/sprint-{sprint}/epics/epic-{epic}/{epic}.{story}-{slug}.yml`
   - Statuses: PASS, CONCERNS, FAIL, WAIVED
   - Includes: Test results, risk assessment, recommendations

6. **Backend Restart Protocol** ⭐ NEW
   - Mandatory before QA Handoff (if backend files modified)
   - Process safety (kill specific PIDs, never all node processes)
   - Verification (health check, log confirmation)

7. **Handoff Reading Optimization** ⭐ NEW
   - Explicit instructions to read full documents
   - Ensures Context7 research, technical decisions available
   - Applies to: Dev (Story/Developer Handoffs), Orchestrator (Test Review/Developer/Completion Handoffs), QA (already optimized)

### Configuration

**Location:** `.bmad-core/core-config.yaml`

**Key Settings:**
```yaml
document_locations:
  prd: "docs/prd.md"
  prd_shards: "docs/prd/"
  architecture: "docs/architecture.md"
  architecture_shards: "docs/architecture/"
  stories: "docs/stories/"
  qa_assessments: "docs/qa/assessments/"
  qa_gates: "docs/qa/gates/"
  handoffs: "docs/handoffs/"

dev_agent_context_files:
  - "docs/architecture/coding-standards.md"
  - "docs/architecture/tech-stack.md"
  - "docs/architecture/unified-project-structure.md"
  - ".bmad-core/data/testing-stack-guide.md"

file_naming:
  story: "{epic}.{story}.story.md"
  qa_assessment: "{epic}.{story}-{type}-{YYYYMMDD}.md"
  qa_gate: "{epic}.{story}-{slug}.yml"
  handoff: "{epic}.{story}-{slug}-{type}-handoff.md"
```

---

## Cherry-Picked V6 Concepts (Planned)

### 1. TEA Knowledge Base (To Be Ported)

**Source:** BMad V6 `core/agents/TEA/knowledge/`

**Contents:**
- 21 testing pattern files (12,821 total lines)
- Comprehensive testing patterns (unit, integration, E2E, accessibility, performance, security, edge cases)
- Testing anti-patterns (what NOT to do)
- Framework-specific patterns (React, Vue, Node.js, Python, etc.)

**Port Strategy:**
- Create: `.bmad-core/data/testing-patterns/` directory
- Copy: All 21 files from V6
- Update: QA agent to reference testing patterns proactively
- Timeline: Week 1-2 after BMad IDE MVD validation

### 2. Story Context XML (To Be Implemented)

**Source:** BMad V6 `core/workflows/Story/context.xml`

**Example:**
```xml
<story>
  <identification>
    <epic>1</epic>
    <story>3</story>
    <title>User Authentication System</title>
  </identification>

  <context>
    <architectural_decisions>
      <decision>JWT tokens with 7-day expiry</decision>
      <decision>bcrypt password hashing (12 rounds)</decision>
      <decision>Redis for session storage</decision>
    </architectural_decisions>

    <technical_constraints>
      <constraint>Must support OAuth2 (Google, GitHub)</constraint>
      <constraint>GDPR compliance required (EU users)</constraint>
    </technical_constraints>

    <dependencies>
      <story>1.1</story>  <!-- Database schema -->
      <story>1.2</story>  <!-- User model -->
    </dependencies>
  </context>

  <acceptance_criteria>
    <criterion id="AC1">User can register with email/password</criterion>
    <criterion id="AC2">User can login with email/password</criterion>
    <criterion id="AC3">User can logout</criterion>
    <criterion id="AC4">User can reset password via email</criterion>
  </acceptance_criteria>
</story>
```

**Benefits:**
- Structured context (easier for agents to parse)
- Explicit dependencies (agents know prerequisite stories)
- Architectural decisions preserved (agents reference when implementing)

**Port Strategy:**
- Generate XML at story creation time (SM agent)
- Store alongside Markdown: `docs/stories/{epic}.{story}.story.xml`
- Dev agent reads both Markdown (for humans) and XML (for structured parsing)
- Timeline: Month 2-3 after BMad IDE MVD validation

### 3. Centralized Config (Partially Implemented)

**Source:** BMad V6 `core/config/settings.xml`

**Our Implementation:** `.bmad-core/core-config.yaml`

**V6 Additions to Port:**
- Agent memory settings (how many stories to remember)
- MCP server configurations (centralized, not per-agent)
- Workflow templates (reusable workflow definitions)

**Timeline:** Month 3-4 after BMad IDE MVD validation

---

## Session Logs (Framework Work)

**Location:** `docs/session-logs/` (master repo, not bmad-ide)

**Key Sessions:**
1. `SESSION-LOG-WORKFLOW-OPTIMIZATION-2025-10-28.md` - Vitest + Playwright MCP decision
2. `SESSION-UPDATE-2025-10-28-PLAYWRIGHT-MCP-DISCOVERY.md` - Playwright MCP integration
3. `SESSION-LOG-BMAD-V6-CRITICAL-ANALYSIS-2025-11-07.md` - BMad V6 evaluation, decision to stay V4

---

## Integration with BMad IDE

**BMad IDE uses BMad V4 framework:**

1. **Extension (Stage 1):** Uses BMad V4 agents, handoff formats, workflows
2. **Workstation (Stage 2):** Uses BMad V4 agents, handoff formats, workflows
3. **Orchestration Daemon:** Automates BMad V4 three-terminal workflow

**Framework Location:** `d:\Dev\mydevwf\.bmad-core/` (symlinked to all projects)

**Synchronization Strategy:**
- Master: `d:\Dev\mydevwf\.bmad-core/`
- Active Projects: Symlinked to master (instant updates)
- Framework improvements benefit all projects immediately

**See:** `scripts/README-SYMLINKS.md` for symlink setup guide

---

## Testing Stack

### Vitest (Unit Tests)

**When to Use:**
- Complex logic with 10+ edge cases
- Tax calculations, algorithms, validation functions
- Pure functions (no DOM, no I/O)

**Example:**
```typescript
// src/utils/calculateTax.test.ts
import { describe, it, expect } from 'vitest';
import { calculateTax } from './calculateTax';

describe('calculateTax', () => {
  it('TC1.1: Standard rate (income < 50k)', () => {
    expect(calculateTax(40000)).toBe(4000);
  });

  it('TC1.2: Higher rate (income 50k-150k)', () => {
    expect(calculateTax(100000)).toBe(18000);
  });

  // ... 10+ edge cases
});
```

**Run:** `npm run test` (Vitest watch mode)

### Playwright MCP (E2E Tests)

**When to Use:**
- ALL user journeys
- UI interactions
- Multi-page workflows
- Form submissions
- Authentication flows

**Format:** Markdown test scenarios (NOT .spec.ts files)

**Example:**
```markdown
# Test Scenario: User Registration (AC1)

**Story:** 1.3 - User Authentication System
**Test Case ID:** TC1.1 - Happy Path Registration

## Setup
1. Navigate to http://localhost:3000/register
2. Verify registration form visible

## Steps
1. Fill email: "test@example.com"
2. Fill password: "SecurePass123!"
3. Fill confirm password: "SecurePass123!"
4. Click "Register" button

## Expected Results
- Success message displayed: "Account created successfully"
- Redirect to /dashboard
- User logged in (JWT token in localStorage)

## Teardown
- Delete test user from database
```

**Execution:** QA uses 26 Playwright MCP tools interactively
- `mcp__playwright__navigate` (url)
- `mcp__playwright__fill` (selector, value)
- `mcp__playwright__click` (selector)
- `mcp__playwright__screenshot` (name)
- `mcp__playwright__get_visible_html` (selector)
- `mcp__playwright__console_logs` (type, search)

**Location:** `docs/qa/e2e/sprint-N/epics/epic-N/story-N/`

**See:** `.bmad-core/data/testing-stack-guide.md` for complete guide

---

## Timestamp Protocol

**CRITICAL:** All documentation updates MUST include timestamp

**Command:**
```bash
date +%Y-%m-%d\ %H:%M:%S  # bash/WSL (PRIMARY)
Get-Date -Format "yyyy-MM-dd HH:mm:ss"  # PowerShell (FALLBACK)
```

**Why:** User environment is WSL (Windows Subsystem for Linux), bash commands work natively

**Affected Agents:** QA (Quinn), Dev (James), SM (Bob), Orchestrator

**Files Modified:**
- `.bmad-core/agents/qa.md`
- `.bmad-core/agents/dev.md`
- `.bmad-core/agents/sm.md`

**Philosophy:** Linux-first approach (user planning migration to full Linux environment)

---

## Next Steps

### Immediate (After BMad IDE MVD)

1. **Port TEA Knowledge Base** (Week 1-2)
   - Copy 21 testing pattern files from V6
   - Update QA agent to reference patterns
   - Test with real stories

2. **Implement Story Context XML** (Month 2-3)
   - Update SM agent to generate XML at story creation
   - Update Dev agent to read XML (alongside Markdown)
   - Test with 5 stories, verify structured context benefits

3. **Centralized MCP Configuration** (Month 3-4)
   - Move MCP configs from per-agent to centralized
   - Single source of truth in `core-config.yaml`
   - Update all agents to reference centralized config

### Long-Term (Year 2)

4. **V6 Module System Concepts** (If needed)
   - Evaluate if modular structure benefits our workflow
   - Only port if clear productivity gain (avoid migration for migration's sake)

5. **BMad Builder (BOMB) Concepts** (If needed)
   - Self-extensible framework patterns
   - Only if we need dynamic agent creation

---

## Resources

### Documentation (Master Repo)
- **User Guide:** `.bmad-core/user-guide.md`
- **Testing Guide:** `.bmad-core/data/testing-stack-guide.md`
- **Knowledge Base:** `.bmad-core/data/bmad-kb.md`
- **Technical Preferences:** `.bmad-core/data/technical-preferences.md`
- **Three-Terminal Workflow:** `.bmad-core/data/three-terminal-workflow.md`
- **Handoff Templates:** `.bmad-core/data/handoff-templates.md`

### Session Logs
- **V6 Analysis:** `docs/session-logs/SESSION-LOG-BMAD-V6-CRITICAL-ANALYSIS-2025-11-07.md`
- **Workflow Optimization:** `docs/session-logs/SESSION-LOG-WORKFLOW-OPTIMIZATION-2025-10-28.md`

### BMad V6 (For Reference Only)
- **Location:** `d:\Dev\mydevwf\bmadv6/`
- **Purpose:** Cherry-pick concepts, NOT for migration
- **Key Files to Port:** `core/agents/TEA/knowledge/` (21 testing pattern files)

---

**Context Version:** 1.0
**Completeness:** Production-Ready, Continuously Improving
**Next Update:** After TEA knowledge base port (Week 1-2 post-MVD)
