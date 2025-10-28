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
- `docs/architecture/source-tree.md`

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
- `docs/SESSION-LOG-WORKFLOW-OPTIMIZATION-2025-10-28.md` - MCP integration + BMad core optimization (IN PROGRESS)

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
