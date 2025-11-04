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
- `docs/` - Master repository documentation (analysis/, planning/, verification/, knowledge-base/, session-logs/, templates/, guides/)

**When you create a new project** using `npm run create-project`, you'll work in a separate directory with:
- BMad framework copied over
- Template-specific structure
- Project-specific MCP configuration
- Ready-to-code environment

## Core Architecture

### Directory Structure

**Master Template Repository** (this directory):
- `.bmad-core/` - Core BMad framework (agents, tasks, workflows, templates, checklists, data)
- `project-templates/` - 4 production templates
- `docs/` - Documentation (see `docs/` structure below)

**Generated Project** (after running `npm run create-project`):
- `.bmad-core/` - Copy of BMad framework
- `.mcp.json` - Project-specific MCP configuration
- `CLAUDE.md` - Project-specific instructions
- `docs/` - Project documentation (PRD, architecture, stories, QA assessments, knowledge-base)

### Configuration Files

- `.bmad-core/core-config.yaml` - Critical configuration (document locations, dev agent context files, file naming patterns, sharding settings)

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
- `docs/architecture/unified-project-structure.md`
- `.bmad-core/data/testing-stack-guide.md`

### Knowledge Base

**Location**: `docs/knowledge-base/`

The Knowledge Base (KB) is a living documentation system that captures reusable patterns, integrations, and solutions as your project evolves. KB entries are created by Dev agents during story implementation.

**When to Create KB Entries**:
1. **Integration Implementation** - Third-party services (Stripe, SendGrid, AWS S3)
2. **Reusable Pattern** - Architecture patterns used across stories
3. **Non-Obvious Solution** - Complex issues with non-trivial solutions
4. **Story Requirement** - Dev Notes explicitly request KB documentation

**See**: `docs/knowledge-base/README.md` for complete KB usage guide

## Model Context Protocol (MCP) Integration

MCPs give Claude Code direct access to external tools, databases, and services.

### Available MCPs

**Global MCP** (installed once, available everywhere):
- ✅ **Playwright MCP** - E2E testing and browser automation

**Project-Specific MCPs** (configured in `.mcp.json`):
- **Context7 MCP**: Up-to-date library documentation and patterns
- **shadcn-ui MCP**: Access to shadcn/ui component library (Next.js projects)
- **Swagger MCP**: API testing via OpenAPI/Swagger specs
- **Supabase MCP**: Database operations, migrations, logs (Supabase projects)
- **MongoDB MCP**: Database queries, indexes, optimization (MongoDB projects)

### MCP Usage

MCPs work automatically when you use BMad agents. Quick examples:

```
"use context7 - How do I implement authentication with NextAuth.js?"
"Show me all shadcn/ui components"
"Create a 'posts' table with user_id foreign key"
"Call GET /api/users and show me the results"
"Navigate to http://localhost:3000 and take a screenshot"
```

**For detailed MCP setup, configuration, and examples**: See `docs/guides/MCP-QUICK-START.md`

### GitHub Personal Access Token (shadcn-ui MCP)

**Required for shadcn-ui MCP** (better rate limits: 60/hour → 5000/hour)

UX Expert and Dev agents will proactively ask for your GitHub token during activation if it's not configured.

1. Create token: https://github.com/settings/tokens/new (scope: `public_repo`)
2. Add to `.mcp.json`: `"GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token_here"`
3. Restart Claude Code

**Note**: `.mcp.json` is in `.gitignore` - your token stays private.

## Available Project Templates

**All web templates include**: Next.js 14+ (App Router) + Tailwind CSS + TypeScript + shadcn/ui components

1. **Next.js + Node.js + Supabase** (Fullstack Web)
   - Frontend: Next.js + shadcn/ui
   - Backend: Node.js + Express
   - Database: Supabase (PostgreSQL + Auth + Storage + Real-time)
   - MCPs: Playwright, Supabase, Swagger, shadcn-ui, Context7

2. **Next.js + Node.js + MongoDB** (Fullstack Web)
   - Frontend: Next.js + shadcn/ui
   - Backend: Node.js + Express
   - Database: MongoDB
   - MCPs: Playwright, MongoDB, Swagger, shadcn-ui, Context7

3. **Next.js + FastAPI + Supabase** (Fullstack Web)
   - Frontend: Next.js + shadcn/ui
   - Backend: Python + FastAPI
   - Database: Supabase
   - MCPs: Playwright, Supabase, Swagger, shadcn-ui, Context7

4. **React Native Mobile** (Mobile Only - Needs Backend)
   - Stack: React Native (TypeScript)
   - Backend: Pair with one of the above templates
   - MCPs: Playwright, Backend-specific MCPs

## Creating New Projects

```bash
# From mydevwf directory
npm run create-project <template> <project-name>

# Examples:
npm run create-project nextjs-nodejs-supabase my-saas-app
npm run create-project nextjs-fastapi-supabase my-ml-app
npm run create-project react-native-mobile my-mobile-app
```

## Available Slash Commands

### Core BMad Agents (`/BMad/agents/*`)
- `pm` - PRD creation, requirements management
- `architect` - System architecture design, technical decisions
- `ux-expert` - UX specifications, UI design
- `po` - Product ownership, document validation, sharding
- `sm` - Story creation from epics
- `dev` - Story implementation, coding, testing
- `qa` - Test architecture, quality gates, code review
- `analyst` - Market research, brainstorming, project brief creation
- `orchestrator` - Multi-role coordination
- `bmad-master` - Multi-role agent (can perform most tasks)

### Core BMad Tasks (`/BMad/tasks/*`)
- `create-next-story` - SM creates next story from sharded epic
- `execute-checklist` - Dev implements story tasks sequentially
- `document-project` - Architect documents existing codebase (brownfield)
- `brownfield-create-epic` - Create epic for existing project
- `brownfield-create-story` - Create story for existing project
- `advanced-elicitation` - Deep requirements gathering
- `correct-course` - Realign project when off-track

## Development Workflows

### Standard Development Cycle (Greenfield)

1. **Planning Phase** (web UI with large context):
   - Analyst → PM → Architect → PO: Create project brief, PRD, architecture, validate/shard

2. **Development Phase** (IDE):
   - SM: Draft next story (`/BMad/tasks/create-next-story`)
   - Dev: Implement story (`/BMad/tasks/execute-checklist`)
   - QA: Review and validate
   - Commit and repeat

### Brownfield Workflow (Existing Projects)

1. **Document First**: `/BMad/tasks/document-project` - Architect analyzes and documents existing system
2. **Plan Enhancement**: Create brownfield PRD/epic/story
3. **Implement**: Follow standard dev cycle
4. **Test Rigorously**: QA is critical for brownfield to prevent regressions

**See**: `.bmad-core/working-in-the-brownfield.md` for complete brownfield guide

**For detailed workflow examples**: See `docs/guides/WORKFLOW-REFERENCE.md`

## QA/Test Architect Integration

The QA agent (Quinn) provides comprehensive quality assurance throughout the development lifecycle.

### QA Command Shortcuts

- `*risk` - Identify integration and regression risks
- `*design` - Create test strategy
- `*trace` - Verify test coverage of all acceptance criteria
- `*nfr` - Validate non-functional requirements
- `*review` - Comprehensive assessment + active refactoring (REQUIRED)
- `*gate` - Update quality gate status after addressing issues

### When to Use QA Commands

**Before Development**: `*risk`, `*design`
**During Development**: `*trace`, `*nfr`
**After Development**: `*review` (REQUIRED), `*gate`

### QA Output Locations

```
docs/qa/assessments/{epic}.{story}-{type}-{YYYYMMDD}.md
docs/qa/gates/{epic}.{story}-{slug}.yml
```

## Recent System Optimizations (October-November 2025)

**Status**: PRODUCTION READY ✅
**Last Updated**: 2025-11-02
**Phase 1 Critical Path**: VALIDATED ✅

### Key Architectural Decisions

#### 1. Testing Strategy: Vitest + Playwright MCP Hybrid

**Decided**:
- ✅ **Vitest**: ONLY for complex logic with 10+ edge cases (tax calculations, algorithms, validation)
- ✅ **Playwright MCP**: ALL user journeys via 26 interactive browser control tools
- ❌ **Jest**: ELIMINATED ENTIRELY (replaced by Vitest)

**Why**: Vitest = Fast (milliseconds for 100+ tests), perfect for pure functions. Playwright MCP = Real-world testing with human observation, no test code maintenance.

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

**Reference**: `.bmad-core/data/testing-stack-guide.md`

#### 2. Context7 MCP Integration

**Decided**: All planning agents use Context7 MCP for real-time documentation
- ✅ Analyst, PM, Architect (MOST CRITICAL), UX Expert, Dev, QA

**Why**: Prevents deprecated code patterns, ensures current best practices

**How**: Add "use context7 - {question}" to prompts when researching technical solutions

#### 3. Two-Terminal Development Workflow

**Decided**: Dev and QA agents run in separate terminals with structured handoffs
- **Dev Terminal**: Implements features, writes tests, starts processes
- **QA Terminal**: Executes tests, validates quality, creates gate files

**Handoff Templates**: `.bmad-core/data/handoff-templates.md`

#### 4. BMad V6 Migration Analysis

**Analyzed**: Comprehensive evaluation of BMad V6 Alpha upgrade paths (2025-11-02)

**V6 Key Innovations**:
- Module System (core, bmb, bmm, cis)
- BMad Builder (BOMB) - Automated creation tools
- Update-Safe Customizations (`_cfg/` directory)
- Workflow-Centric (V4 tasks → V6 workflows)
- Web Bundle Support

**Migration Options**:
1. Option A: Full Migration to V6 (2-3 weeks, medium risk)
2. Option B: Hybrid Approach ⭐ RECOMMENDED (1-2 weeks, low risk)
3. Option C: V6 for New Projects Only (1 week, low risk)
4. Option D: Status Quo with Enhancements (1-2 days, very low risk)

**Status**: Analysis complete, decision pending
**Document**: `docs/planning/BMAD-V6-MIGRATION-OPTIONS.md`

### Critical Integration Rules

**File Location Facts**:
1. **testing-stack-guide.md**: `.bmad-core/data/testing-stack-guide.md` (NOT in docs/architecture/)
2. **Architecture Files**: `docs/architecture/` (coding-standards.md, tech-stack.md, unified-project-structure.md)
3. **Story Files**: `docs/stories/{epic}.{story}.story.md` (configured in core-config.yaml)

**For detailed optimization history**: See `docs/analysis/` and `docs/verification/`

## Session Management & Context Preservation

### Automatic Session Logging Workflow

**Trigger Point**: When context usage reaches **80-85% of usable context** (~124,000-132,000 / ~155,000 usable tokens)

**Note**: Total context window is 200,000 tokens, but Claude Code reserves ~45,000 tokens (22.5%) for conversation management. Calculate triggers based on usable context, not total.

**Action Required**:
1. **Create session log**: Save complete conversation to `docs/session-logs/SESSION-LOG-{TOPIC}-{YYYY-MM-DD}.md`
2. **Include in session log**: Complete conversation history, decisions, prompts, files created/modified, progress, next steps, configurations, user preferences
3. **Update this CLAUDE.md**: Add reference to session log in relevant section
4. **Inform user**: Session log created, ready to continue or compact conversation

**Session Log Template Location**: See existing logs in `docs/session-logs/` for format examples

**Why This Matters**:
- Preserves decisions across conversation compactions
- Enables seamless resumption after breaks
- Creates audit trail of project evolution
- Prevents loss of context and rationale

**For session log history**: See `docs/session-logs/README.md`

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

## Best Practices for Working with BMad

### Context Management

1. **Fresh Conversations**: Start new chats for each agent role to keep context clean
2. **Sequential Progress**: Work on one story at a time
3. **Load Minimal Context**: Only include relevant files for current task
4. **Reference Documents**: Always check sharded epics/stories before implementation

### Story Implementation Flow

1. Start new conversation with dev agent
2. Execute `/BMad/tasks/execute-checklist {story-path}`
3. Dev agent will load always-required context files, read story, execute tasks, run tests, mark complete
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
- **Architecture sections**: Split into focused documents

This keeps agent context manageable and focused.

## Common Commands for Development

### Start Story Development
```bash
/BMad/tasks/create-next-story
# Review and approve the generated story
/BMad/tasks/execute-checklist docs/stories/{story-file}.md
```

### Database Setup (Story 1.1 for Backend/Fullstack)
```bash
# SM creates Story 1.1 (auto-detects database, creates Database Setup story)
/BMad/tasks/create-next-story

# Dev implements database schema
/BMad/agents/dev
*develop-story docs/stories/1.1.story.md
# Dev loads database workflow guides automatically
# Dev uses Database MCP tools (Supabase/MongoDB)
```

### Frontend Development with shadcn/ui
```bash
# UX Expert creates component specifications
/BMad/agents/ux-expert
*create-front-end-spec

# Dev implements frontend story
/BMad/agents/dev
*develop-story docs/stories/{story-file}.md
# Dev installs: npx shadcn@latest add button form input
```

### QA Review Process
```bash
# For high-risk or brownfield stories:
/BMad/agents/qa
*risk {story}
*design {story}
*trace {story}
*nfr {story}
*review {story}  # Required
*gate {story}    # After fixes
```

## Key Resources

- **User Guide**: `.bmad-core/user-guide.md` - Complete BMad methodology
- **IDE Workflow**: `.bmad-core/enhanced-ide-development-workflow.md` - Step-by-step dev cycle
- **Brownfield Guide**: `.bmad-core/working-in-the-brownfield.md` - Existing project workflow
- **Testing Guide**: `.bmad-core/data/testing-stack-guide.md` - Comprehensive testing workflow
- **Knowledge Base**: `.bmad-core/data/bmad-kb.md` - Framework overview
- **Technical Preferences**: `.bmad-core/data/technical-preferences.md` - Team preferences

## Detailed Guides

**For detailed information, see these guides**:

- **MCP Setup & Usage**: `docs/guides/MCP-QUICK-START.md` - Comprehensive MCP guide
- **Workflow Reference**: `docs/guides/WORKFLOW-REFERENCE.md` - Detailed workflow examples
- **Session Logs**: `docs/session-logs/README.md` - Session log history
- **Analysis Documents**: `docs/analysis/` - System analysis and optimization history
- **Planning Documents**: `docs/planning/` - Strategic planning and decisions
- **Verification Reports**: `docs/verification/` - Validation and verification reports
