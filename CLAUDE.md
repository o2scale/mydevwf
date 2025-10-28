# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **MyDevWF** (My Development Workflow) system - a comprehensive workflow template combining:

1. **BMad Method**: AI-driven agile development framework with specialized agents (PM, Architect, Developer, QA, etc.)
2. **Claude Code MCP Integration**: Model Context Protocol for enhanced productivity
3. **Production Templates**: 4 battle-tested stack configurations
4. **Project Automation**: Scripts for rapid project creation

### This Repository Structure

**This is the MASTER TEMPLATE repository**. It contains:
- `.bmad-core/` - BMad framework (agents, tasks, workflows)
- `project-templates/` - 4 production-ready templates
- `scripts/` - Project creation automation
- `docs/templates/` - Master documentation

**When you create a new project** using `npm run create-project`, you'll work in a separate directory with:
- BMad framework copied over
- Template-specific structure
- Project-specific MCP configuration
- Ready-to-code environment

## Core Architecture

### Directory Structure

**Master Template Repository** (this directory):
- `.bmad-core/` - Core BMad framework files (agents, templates, checklists, workflows)
- `.bmad-infrastructure-devops/` - Infrastructure/DevOps expansion pack
- `.claude/commands/BMad/` - Claude Code slash commands for core agents and tasks
- `.claude/commands/bmadInfraDevOps/` - Claude Code commands for DevOps
- `project-templates/` - 4 production templates (Python/FastAPI, Node.js/Supabase, Node.js/MongoDB, React Native)
- `scripts/` - Automation scripts
- `docs/templates/` - Master documentation

**Generated Project** (after running `npm run create-project`):
- `.bmad-core/` - Copy of BMad framework
- `.mcp.json` - Project-specific MCP configuration
- `docs/` - Project documentation (PRD, architecture, stories, QA assessments)
- `frontend/`, `backend/`, `src/` - Project code
- `tests/` - Test suites

### Configuration Files

- `.bmad-core/core-config.yaml` - Critical configuration file that defines:
  - Document locations (PRD, architecture, stories, QA)
  - Dev agent context files (coding standards, tech stack, source tree)
  - File naming patterns
  - Sharding settings

**Important**: Always check `core-config.yaml` to understand where documents are located and what files the dev agent should always load.

### Document Locations (from core-config.yaml)

```yaml
PRD: docs/prd.md (sharded to: docs/prd/)
Architecture: docs/architecture.md (sharded to: docs/architecture/)
Stories: docs/stories/
QA Assessments: docs/qa/assessments/
QA Gates: docs/qa/gates/
```

### Dev Agent Context Files

These files are always loaded by the dev agent (defined in `core-config.yaml`):
- `docs/architecture/coding-standards.md`
- `docs/architecture/tech-stack.md`
- `docs/architecture/unified-project-structure.md` ⚠️ (was: source-tree.md)
- `.bmad-core/data/testing-stack-guide.md` ✅ (added: testing workflow guidance)

## Model Context Protocol (MCP) Integration

### What are MCPs?

MCPs give Claude Code direct access to external tools, databases, and services. This workflow system uses MCPs to dramatically enhance development productivity.

### MCP Configuration

**Global MCP** (installed once, available everywhere):
- ✅ **Playwright MCP** - E2E testing and browser automation

**Project-Specific MCPs** (configured per template):
- **Swagger MCP**: API testing via OpenAPI/Swagger specs
- **Supabase MCP**: Database operations, migrations, logs (Supabase projects)
- **MongoDB MCP**: Database queries, indexes, optimization (MongoDB projects)

### MCP Commands

```bash
# List all MCPs (global + project)
claude mcp list

# Check MCP status in Claude Code
/mcp

# Verify MCPs are working
npm run mcp:verify
```

### Using MCPs in Development

MCPs work automatically when you use BMad agents. Examples:

**Dev Agent with Swagger MCP**:
```
"Test the POST /api/users endpoint with sample data"
→ Claude Code automatically calls API via Swagger MCP
```

**Dev Agent with Database MCP**:
```
"Query all users created in the last week"
→ Claude Code queries database via Supabase/MongoDB MCP
```

**Dev Agent with Playwright MCP**:
```
"Generate E2E test for the login flow"
→ Claude Code generates Playwright test automatically
```

### MCP Benefits

- ⚡ **50-60% faster development** - Less manual testing
- 🎯 **Automatic API testing** - No need for Postman
- 🗄️ **Direct database access** - Query from natural language
- 🧪 **E2E test generation** - Playwright tests created automatically

### Template-Specific MCP Configurations

See `.mcp.json` in each project template for exact configurations:
- `project-templates/python-fastapi-postgres/.mcp.json` - Swagger only
- `project-templates/nodejs-supabase/.mcp.json` - Swagger + Supabase
- `project-templates/nodejs-mongodb/.mcp.json` - Swagger + MongoDB
- `project-templates/react-native/.mcp.json` - Backend-dependent

For comprehensive MCP documentation, see: `docs/templates/MCP-INTEGRATION-GUIDE.md`

## Available Project Templates

### 1. Python/FastAPI + PostgreSQL
- **Stack**: React/Next.js + Python/FastAPI + PostgreSQL
- **MCPs**: Playwright + Swagger
- **Use**: API-first backends, data-intensive apps, ML pipelines
- **Template**: `project-templates/python-fastapi-postgres/`

### 2. Node.js + Supabase
- **Stack**: React/Next.js + Node.js + Supabase (PostgreSQL)
- **MCPs**: Playwright + Supabase + Swagger
- **Use**: Rapid prototyping, real-time apps, serverless backends
- **Template**: `project-templates/nodejs-supabase/`

### 3. Node.js + MongoDB
- **Stack**: React/Next.js + Node.js/Express + MongoDB
- **MCPs**: Playwright + MongoDB + Swagger
- **Use**: Document-heavy apps, flexible schemas
- **Template**: `project-templates/nodejs-mongodb/`

### 4. React Native
- **Stack**: React Native (TypeScript) + Backend agnostic
- **MCPs**: Playwright + Backend-specific
- **Use**: Cross-platform mobile apps (iOS + Android)
- **Template**: `project-templates/react-native/`

## Creating New Projects

### Quick Start

```bash
# From mydevwf directory
npm run create-project <template> <project-name>

# Examples:
npm run create-project nodejs-supabase my-saas-app
npm run create-project python-fastapi-postgres my-api
npm run create-project nodejs-mongodb my-document-app
npm run create-project react-native my-mobile-app
```

### After Project Creation

```bash
cd ../my-new-project

# Verify BMad is available
ls .bmad-core/

# Verify MCPs are configured
cat .mcp.json

# Check MCPs in Claude Code
/mcp

# Follow template README for specific setup
cat README.md
```

## Available Slash Commands

### Core BMad Agents (Prefix: `/BMad`)

**Agent Commands** (in `.claude/commands/BMad/agents/`):
- `/BMad/agents/analyst` - Market research, brainstorming, project brief creation
- `/BMad/agents/architect` - System architecture design, technical decisions
- `/BMad/agents/dev` - Story implementation, coding, testing
- `/BMad/agents/pm` - PRD creation, requirements management
- `/BMad/agents/po` - Product ownership, document validation, sharding
- `/BMad/agents/qa` - Test architecture, quality gates, code review
- `/BMad/agents/sm` - Story creation from epics
- `/BMad/agents/ux-expert` - UX specifications, UI design
- `/BMad/agents/bmad-master` - Multi-role agent (can perform most tasks)

**Task Commands** (in `.claude/commands/BMad/tasks/`):
- `/BMad/tasks/create-next-story` - SM creates next story from sharded epic
- `/BMad/tasks/execute-checklist` - Dev implements story tasks sequentially
- `/BMad/tasks/document-project` - Architect documents existing codebase (brownfield)
- `/BMad/tasks/brownfield-create-epic` - Create epic for existing project
- `/BMad/tasks/brownfield-create-story` - Create story for existing project
- `/BMad/tasks/advanced-elicitation` - Deep requirements gathering
- `/BMad/tasks/correct-course` - Realign project when off-track

### Infrastructure/DevOps Commands (Prefix: `/bmadInfraDevOps`)

Available if the infrastructure expansion pack is installed.

## Development Workflows

### Standard Development Cycle (Greenfield)

1. **Planning Phase** (typically done in web UI with large context):
   - Analyst: Create project brief
   - PM: Create PRD with epics and stories
   - Architect: Design system architecture
   - PO: Validate alignment, shard documents

2. **Development Phase** (IDE):
   - SM: Draft next story (`/BMad/tasks/create-next-story`)
   - Dev: Implement story (`/BMad/tasks/execute-checklist`)
   - QA: Review and validate (optional/required based on complexity)
   - Commit and repeat

### Brownfield Workflow (Existing Projects)

For existing codebases, follow this sequence:

1. **Document First**: `/BMad/tasks/document-project` - Architect analyzes and documents existing system
2. **Plan Enhancement**: Create brownfield PRD/epic/story
3. **Implement**: Follow standard dev cycle
4. **Test Rigorously**: QA is critical for brownfield to prevent regressions

**See**: `.bmad-core/working-in-the-brownfield.md` for complete brownfield guide

## QA/Test Architect Integration

The QA agent (Quinn) provides comprehensive quality assurance throughout the development lifecycle.

### QA Command Shortcuts

Commands support both short and full forms:
- `*risk` → `*risk-profile`
- `*design` → `*test-design`
- `*trace` → `*trace-requirements`
- `*nfr` → `*nfr-assess`
- `*review` → `*review`
- `*gate` → `*gate`

### When to Use QA Commands

**Before Development:**
- `*risk` - Identify integration and regression risks (critical for brownfield)
- `*design` - Create test strategy to guide implementation

**During Development:**
- `*trace` - Verify test coverage of all acceptance criteria
- `*nfr` - Validate non-functional requirements (security, performance, reliability, maintainability)

**After Development:**
- `*review` - Comprehensive assessment + active refactoring (REQUIRED)
- `*gate` - Update quality gate status after addressing issues

### QA Output Locations

```
*risk → docs/qa/assessments/{epic}.{story}-risk-{YYYYMMDD}.md
*design → docs/qa/assessments/{epic}.{story}-test-design-{YYYYMMDD}.md
*trace → docs/qa/assessments/{epic}.{story}-trace-{YYYYMMDD}.md
*nfr → docs/qa/assessments/{epic}.{story}-nfr-{YYYYMMDD}.md
*review → QA Results in story + docs/qa/gates/{epic}.{story}-{slug}.yml
*gate → docs/qa/gates/{epic}.{story}-{slug}.yml
```

### Quality Gate Status

- **PASS** - All requirements met, no blocking issues
- **CONCERNS** - Non-critical issues, team should review
- **FAIL** - Critical issues must be addressed
- **WAIVED** - Issues acknowledged and explicitly accepted

## Best Practices for Working with BMad

### Context Management

1. **Fresh Conversations**: Start new chats for each agent role to keep context clean
2. **Sequential Progress**: Work on one story at a time
3. **Load Minimal Context**: Only include relevant files for current task
4. **Reference Documents**: Always check sharded epics/stories before implementation

### Story Implementation Flow

1. Start new conversation with dev agent
2. Execute `/BMad/tasks/execute-checklist {story-path}`
3. Dev agent will:
   - Load always-required context files
   - Read story file
   - Execute tasks sequentially
   - Run tests and validations
   - Mark tasks complete
4. Update story status when complete

### Brownfield Critical Notes

- **Always run QA risk assessment** before touching legacy code
- **Document existing patterns** before implementing changes
- **Regression tests are mandatory** for all brownfield changes
- **Use feature flags** for risky changes
- **Plan rollback strategies** for data migrations

### Document Sharding

Large documents (PRD, Architecture) are "sharded" into smaller, focused files:
- **Epics**: Split from PRD into individual epic files
- **Stories**: Split from epics into individual story files
- **Architecture sections**: Split into focused documents (coding-standards, tech-stack, etc.)

This keeps agent context manageable and focused.

## Common Commands for Development

### Start Story Development
```bash
/BMad/tasks/create-next-story
# Review and approve the generated story
/BMad/tasks/execute-checklist docs/stories/{story-file}.md
```

### QA Review Process
```bash
# For high-risk or brownfield stories (before dev):
/BMad/agents/qa
*risk {story}
*design {story}

# During development:
*trace {story}
*nfr {story}

# After development (required):
*review {story}

# After fixes:
*gate {story}
```

### Document Existing Project
```bash
/BMad/tasks/document-project
```

## Key Resources

- **User Guide**: `.bmad-core/user-guide.md` - Complete BMad methodology
- **IDE Workflow**: `.bmad-core/enhanced-ide-development-workflow.md` - Step-by-step dev cycle
- **Brownfield Guide**: `.bmad-core/working-in-the-brownfield.md` - Existing project workflow
- **Knowledge Base**: `.bmad-core/data/bmad-kb.md` - Framework overview
- **Technical Preferences**: `.bmad-core/data/technical-preferences.md` - Team preferences for tech choices

## Recent System Optimizations (October 2024)

### ⚡ Major Changes Summary

**Status**: PRODUCTION READY ✅
**Last Updated**: 2025-10-28
**Phase 1 Critical Path**: VALIDATED ✅

### 🎯 Key Architectural Decisions

#### 1. **Testing Strategy: Vitest + Playwright MCP Hybrid**

**DECIDED**: Hybrid approach for maximum efficiency + reality
- ✅ **Vitest**: ONLY for complex logic with 10+ edge cases (tax calculations, algorithms, validation)
- ✅ **Playwright MCP**: ALL user journeys via 26 interactive browser control tools
- ❌ **Jest**: ELIMINATED ENTIRELY (replaced by Vitest)

**Why**:
- Vitest = Fast (milliseconds for 100+ tests), perfect for pure functions
- Playwright MCP = Real-world testing with human observation, no test code maintenance

**Where**: `.bmad-core/data/testing-stack-guide.md` (comprehensive 326-line guide)

**Test Scenarios Format**:
- Dev writes: Markdown test scenarios (NOT `.spec.ts` files)
- Format: `TC{AC}.{case}` (e.g., TC1.1, TC1.2)
- Location: `docs/qa/e2e/sprint-N/epics/epic-N/story-N/`
- Execution: QA uses Playwright MCP tools interactively

**Workflow**:
1. Dev writes feature + Vitest tests (if complex) + E2E scenarios (markdown)
2. Dev starts background processes, outputs QA Handoff, HALTS (does NOT run tests)
3. QA runs Vitest FIRST (`npm run test`), then E2E via Playwright MCP tools
4. QA manually observes, captures screenshots/console logs, decides PASS/FAIL

#### 2. **Context7 MCP Integration**

**DECIDED**: All planning agents use Context7 MCP for real-time documentation
- ✅ **Analyst**: Tech stack research, competitive analysis
- ✅ **PM**: Technical feasibility validation
- ✅ **Architect**: Framework/library selection, API design (MOST CRITICAL)
- ✅ **UX Expert**: React/React Native component patterns, UI libraries
- ✅ **Dev**: Already has Context7 (writes code daily)
- ✅ **QA**: Already has Context7 (testing patterns)

**Why**: Prevents deprecated code patterns, ensures current best practices

**How**: Add "use context7 - {question}" to prompts when researching technical solutions

#### 3. **Two-Terminal Development Workflow**

**DECIDED**: Dev and QA agents run in separate terminals with structured handoffs
- **Dev Terminal**: Implements features, writes tests, starts processes
- **QA Terminal**: Executes tests, validates quality, creates gate files

**Handoff Templates** (in `.bmad-core/data/handoff-templates.md`):
- QA Handoff (Dev → QA)
- Developer Handoff (QA → Dev, if issues found)
- Completion Handoff (QA → SM, if PASS)

### 🔧 Critical Integration Rules

**⚠️ NEVER BREAK THESE INVARIANTS:**

#### File Location Facts

1. **testing-stack-guide.md**:
   - ✅ LOCATION: `.bmad-core/data/testing-stack-guide.md`
   - ❌ NOT IN: `docs/architecture/testing-stack-guide.md`
   - WHO LOADS: create-next-story, review-story, dev agent, QA agent

2. **Architecture Files** (created by architect agent):
   - ✅ LOCATION: `docs/architecture/`
   - FILES: coding-standards.md, tech-stack.md, unified-project-structure.md
   - ❌ NOT: source-tree.md (old name, now unified-project-structure.md)

3. **Story Files**:
   - ✅ PATTERN: v3 (flat) = `docs/stories/{epic}.{story}.story.md`
   - ℹ️ ALTERNATIVE: v4 (hierarchical) = `docs/sprint-N/epics/epic-N/story-N.md`
   - CONFIGURED IN: `core-config.yaml` → `devStoryLocation`

4. **Dev Agent Context Files** (from core-config.yaml):
   ```yaml
   devLoadAlwaysFiles:
     - docs/architecture/coding-standards.md
     - docs/architecture/tech-stack.md
     - docs/architecture/unified-project-structure.md
     - .bmad-core/data/testing-stack-guide.md
   ```

#### Integration Flow Rules

1. **Workflows → Agents**: Workflows invoke agents by ID (must match `.bmad-core/agents/{agent-id}.md`)
2. **Agents → Tasks**: Agent commands map to tasks in `.bmad-core/tasks/{task-name}.md`
3. **Tasks → Templates**: Tasks load templates from `.bmad-core/templates/{template-name}.yaml`
4. **Tasks → Data**: Tasks reference data files in `.bmad-core/data/{data-file}.md`
5. **Config Drives All**: `core-config.yaml` defines all paths, ALWAYS check this first

#### Task File References

**create-next-story.md** (Line 49-51):
```markdown
For ALL Stories (from docs/architecture/):
  - tech-stack.md
  - unified-project-structure.md
  - coding-standards.md

For ALL Stories (from .bmad-core/data/):
  - testing-stack-guide.md
```

**review-story.md** (Line 135):
```markdown
Validate testing approach against `.bmad-core/data/testing-stack-guide.md`
```

### ⚠️ Common Pitfalls to AVOID

1. **DON'T** reference `testing-strategy.md` (file DOESN'T EXIST)
   - ✅ USE: `testing-stack-guide.md` (in .bmad-core/data/)

2. **DON'T** reference `source-tree.md` (old name)
   - ✅ USE: `unified-project-structure.md`

3. **DON'T** assume architecture files exist on fresh projects
   - ℹ️ CHECK: `docs/architecture/` may be empty until architect agent creates them

4. **DON'T** update agent personas without updating tasks
   - ✅ RULE: Persona + Tasks + Templates must all align

5. **DON'T** write `.spec.ts` files for E2E tests
   - ✅ WRITE: Markdown test scenarios instead
   - ✅ FORMAT: TC{AC}.{case} with steps, expected results, priority

6. **DON'T** let Dev run tests
   - ✅ RULE: Dev writes tests, QA executes them
   - ✅ WHY: Separation of concerns, prevents "works on my machine"

### 📚 New Documentation Reference

**Comprehensive Guides Created**:
- `docs/BMAD-SYSTEM-ARCHITECTURE-MAP.md` - Complete system architecture, all relationships
- `docs/CONSOLIDATION-PLAN.md` - Phased consolidation plan (Phases 1-3 complete)
- `docs/PHASE-1-VERIFICATION.md` - Critical path validation report
- `docs/PHASE-2-AGENT-VERIFICATION.md` - Agent verification with command matrix
- `docs/TASK-INTEGRATION-ANALYSIS.md` - Task file integration analysis
- `.bmad-core/data/DATA-INDEX.md` - Complete data directory index (all 9 files documented)
- `.bmad-core/data/testing-stack-guide.md` - Testing workflow (326 lines)
- `.bmad-core/data/test-levels-framework.md` - Test level decision matrix
- `.bmad-core/data/test-priorities-matrix.md` - Priority-based testing
- `.bmad-core/data/handoff-templates.md` - Structured handoff formats

### 🔄 Git Commit History (Recent)

```
5e4d6d2 - Fix critical path integration issues (Phase 1 Consolidation) ✅
e2c2b7e - Update task files and architecture templates (testing workflow) ✅
7e8ec03 - Add Context7 MCP integration across agents ✅
2959929 - Optimize MyDevWF with hybrid Vitest + Playwright MCP ✅
```

### 📊 System Status

**✅ VALIDATED**: Story creation flow works without file reference errors
**✅ VALIDATED**: Dev agent loads correct context files
**✅ VALIDATED**: QA agent has testing workflow guidance
**✅ VALIDATED**: All integration points consistent

**✅ PHASE 2 COMPLETE** (2025-10-28): Agent Verification
- Verified all 10 BMad agents (analyst, pm, architect, ux-expert, po, sm, dev, qa, orchestrator, master)
- Created comprehensive agent command matrix (agents → tasks → templates)
- Fixed SM agent story location inconsistency (now reads from core-config.yaml)
- Validated: 23/23 tasks exist, 13/13 templates exist, 6/6 checklists exist
- Report: `docs/PHASE-2-AGENT-VERIFICATION.md`

**✅ PHASE 3 COMPLETE** (2025-10-28): Data Directory Audit
- Documented all 9 data files in `.bmad-core/data/`
- Created comprehensive index: `.bmad-core/data/DATA-INDEX.md`
- Verified all agent/task references to data files
- Identified 2 findings:
  - ⚠️ handoff-templates.md not directly referenced by dev/qa (should be)
  - ⚠️ technical-preferences.md currently empty (user should populate)
- All data files properly integrated, no orphaned references

**🚀 NEXT PHASE**:
- Phase 4: Integration testing (test end-to-end workflows - story creation, architecture generation, dev→QA handoff)

### 🎯 Quick Reference for Development

**When Creating Stories**:
1. SM agent uses `create-next-story` task
2. Task loads from `docs/architecture/` + `.bmad-core/data/`
3. Story includes testing requirements (Vitest + E2E scenarios)
4. Story saved to `docs/stories/{epic}.{story}.story.md`

**When Implementing**:
1. Dev loads: coding-standards, tech-stack, unified-project-structure, testing-stack-guide
2. Dev writes: Code + Vitest tests (if 10+ edge cases) + E2E scenarios (markdown)
3. Dev starts: Background processes (frontend, backend)
4. Dev outputs: QA Handoff, then HALTS

**When Testing**:
1. QA reads: QA Handoff
2. QA runs: `npm run test` (Vitest) FIRST
3. QA executes: E2E via Playwright MCP tools (browser_navigate, browser_snapshot, browser_click, etc.)
4. QA captures: Screenshots, console logs
5. QA creates: Gate file (PASS/CONCERNS/FAIL/WAIVED)
6. QA outputs: Developer Handoff (if issues) OR Completion Handoff (if PASS)

## Session Management & Context Preservation

### Automatic Session Logging Workflow

**CRITICAL WORKFLOW**: When working on long-term optimization or planning tasks:

**Trigger Point**: When context usage reaches **80-85% of usable context (~124,000-132,000 / ~155,000 usable tokens)**

**Note**: Total context window is 200,000 tokens, but Claude Code reserves an autocompact buffer of ~45,000 tokens (22.5%) for conversation management. This leaves approximately 155,000 tokens of usable context. Calculate triggers based on usable context, not total.

**Action Required**:
1. **Create session log**: Save complete conversation to `docs/SESSION-LOG-{TOPIC}-{YYYY-MM-DD}.md`
2. **Include in session log**:
   - Complete conversation history
   - All decisions made
   - All prompts and commands used
   - All files created/modified
   - Current progress status
   - Next steps and resumption points
   - Key configurations and settings
   - User preferences identified
3. **Update this CLAUDE.md**: Add reference to session log in relevant section
4. **Inform user**: Session log created, ready to continue or compact conversation

**Session Log Template Location**: See existing logs in `docs/` for format examples

**Why This Matters**:
- Preserves decisions across conversation compactions
- Enables seamless resumption after breaks
- Creates audit trail of project evolution
- Prevents loss of context and rationale

**Example Trigger**:
```
Context: 165,000 / 200,000 tokens (82.5%)
Action: Create session log before continuing
File: docs/SESSION-LOG-BMAD-OPTIMIZATION-2025-10-28.md
```

### Current Session Logs

**Active Optimizations**:
- `docs/SESSION-LOG-WORKFLOW-OPTIMIZATION-2025-10-28.md` - MCP integration + BMad core optimization ✅ COMPLETE
- `docs/SESSION-UPDATE-2025-10-28-PLAYWRIGHT-MCP-DISCOVERY.md` - Playwright MCP testing workflow discovery ✅ COMPLETE
- `docs/BMAD-OPTIMIZATION-ANALYSIS.md` - System analysis ✅ COMPLETE
- `docs/WORKFLOW-ECOSYSTEM-OPTIMIZATION.md` - Complete ecosystem optimization plan ✅ COMPLETE
- `docs/PENDING-OPTIMIZATIONS-ANALYSIS.md` - Pending work identification ✅ COMPLETE
- `docs/TASK-INTEGRATION-ANALYSIS.md` - Task file integration gaps ✅ COMPLETE
- `docs/BMAD-SYSTEM-ARCHITECTURE-MAP.md` - Complete system architecture map ✅ COMPLETE
- `docs/CONSOLIDATION-PLAN.md` - Phased consolidation action plan ✅ COMPLETE
- `docs/PHASE-1-VERIFICATION.md` - Critical path fixes verification ✅ COMPLETE

### Working Session Best Practices

1. **Long-term work**: Use session logs proactively (don't wait until 95% context)
2. **Quick tasks**: No session log needed for simple operations
3. **Complex analysis**: Create session logs at natural breakpoints
4. **Decision points**: Always document key decisions in session logs
5. **File references**: Include absolute paths and line numbers in logs

## Important Notes

1. **Never modify `.bmad-core/` files** unless intentionally customizing the framework
2. **Always check `core-config.yaml`** to understand project structure
3. **Use appropriate agent for task** - don't use dev agent for planning tasks
4. **Keep conversations focused** - one agent, one task per conversation
5. **Commit regularly** - especially after completing stories
6. **QA review is not optional** for production code
7. **Brownfield requires extra diligence** - always assess risks first
8. **Create session logs at 80-85% context** - preserve long-term work
