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
- `.bmad-core/` - BMad framework (agents, tasks, workflows, checklists, data)
- `project-templates/` - 4 production-ready templates
- `scripts/` - Project creation automation
- `docs/` - Master repository documentation

**When you create a new project** using `npm run create-project`, you'll work in a separate directory with:
- BMad framework copied over
- Template-specific structure
- Project-specific MCP configuration
- Ready-to-code environment

### BMad IDE Sub-Project

**Location**: `bmad-ide/` - Agentic development environment automating three-terminal workflows with full transparency and control.

**Two-Stage Architecture**: VS Code Extension (Stage 1) → Linux Terminal System (Stage 2, Ubuntu + Hyprland + Go daemon)

**Innovation**: Hierarchical context management - each development thread has its own context file to prevent bloat.

**See**: `bmad-ide/README.md` for overview, `bmad-ide/.context/README.md` for architecture

## Core Architecture

### Directory Structure & Configuration

**Master Template Repository**:
- `.bmad-core/` - Core BMad framework
- `project-templates/` - 4 production templates
- `docs/` - Documentation

**Generated Project**:
- `.bmad-core/` - Copy of BMad framework
- `.mcp.json` - Project-specific MCP configuration
- `CLAUDE.md` - Project-specific instructions
- `docs/` - Project documentation (PRD, architecture, stories, QA, knowledge-base)

**Configuration**: `.bmad-core/core-config.yaml` - Critical configuration (document locations, dev agent context files, file naming patterns)

**Document Locations** (from core-config.yaml):
```yaml
PRD: docs/prd.md (sharded to: docs/prd/)
Architecture: docs/architecture.md (sharded to: docs/architecture/)
Stories: docs/stories/
QA Assessments: docs/qa/assessments/
QA Gates: docs/qa/gates/
```

**Dev Agent Context Files** (always loaded):
- `docs/architecture/coding-standards.md`
- `docs/architecture/tech-stack.md`
- `docs/architecture/unified-project-structure.md`
- `.bmad-core/data/testing-stack-guide.md`

### Knowledge Base

**Location**: `docs/knowledge-base/`

Living documentation system capturing reusable patterns, integrations, and solutions as your project evolves. KB entries are created by Dev agents during story implementation.

**When to Create KB Entries**:
1. **Integration Implementation** - Third-party services (Stripe, SendGrid, AWS S3)
2. **Reusable Pattern** - Architecture patterns used across stories
3. **Non-Obvious Solution** - Complex issues with non-trivial solutions
4. **Story Requirement** - Dev Notes explicitly request KB documentation

**Integration**: MANDATORY via story-dod-checklist.md section 10 (KB checkpoint before Story Completion Summary)

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

UX Expert and Dev agents will proactively ask for your GitHub token during activation if not configured.

1. Create token: https://github.com/settings/tokens/new (scope: `public_repo`)
2. Add to `.mcp.json`: `"GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token_here"`
3. Restart Claude Code

**Note**: `.mcp.json` is in `.gitignore` - your token stays private.

## Available Project Templates

**All web templates include**: Next.js 14+ (App Router) + Tailwind CSS + TypeScript + shadcn/ui components

1. **Next.js + Node.js + Supabase** - Frontend: Next.js + shadcn/ui | Backend: Node.js + Express | Database: Supabase
2. **Next.js + Node.js + MongoDB** - Frontend: Next.js + shadcn/ui | Backend: Node.js + Express | Database: MongoDB
3. **Next.js + FastAPI + Supabase** - Frontend: Next.js + shadcn/ui | Backend: Python + FastAPI | Database: Supabase
4. **React Native Mobile** - Stack: React Native (TypeScript) | Backend: Pair with one of the above templates

## Creating New Projects

```bash
# From mydevwf directory
npm run create-project <template> <project-name>

# Examples:
npm run create-project nextjs-nodejs-supabase my-saas-app
npm run create-project nextjs-fastapi-supabase my-ml-app
npm run create-project react-native-mobile my-mobile-app
```

## Available Agents & Commands

### Core BMad Agents (`/BMad/agents/*`)
- `pm` - PRD creation, requirements management
- `architect` - System architecture design, technical decisions
- `ux-expert` - UX specifications, UI design
- `po` - Product ownership, document validation, sharding
- `sm` - Story creation from epics (two-terminal workflow)
- `dev` - Story implementation, coding, testing
- `qa` - Test architecture, quality gates, code review
- `analyst` - Market research, brainstorming, project brief creation
- `orchestrator` - Three-terminal workflow coordination, story creation with Context7 research, test vetting
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
   - Dev: Implement story (`*develop-story docs/stories/{story-file}.md`)
   - QA: Review and validate (`*review {story}`)
   - Commit and repeat

### Brownfield Workflow (Existing Projects)

1. **Document First**: `/BMad/tasks/document-project` - Architect analyzes and documents existing system
2. **Plan Enhancement**: Create brownfield PRD/epic/story
3. **Implement**: Follow standard dev cycle
4. **Test Rigorously**: QA is critical for brownfield to prevent regressions

**See**: `.bmad-core/working-in-the-brownfield.md` for complete brownfield guide

### Three-Terminal Workflow (Advanced)

Separates planning, development, and QA across three specialized terminals for improved focus and parallel work.

**Terminals**:
- **Orchestrator Terminal**: Epic planning, Context7 research, story creation, test vetting
- **Dev Terminal**: Story implementation, test writing, background process management
- **QA Terminal**: Test execution, quality gates, evidence collection

**When to Use**: Complex features requiring research, high-stakes features (payment, auth, data integrity), learning phase

**Key Orchestrator Commands**:
- `*create-story` - Create next story from epic with Context7 research, output Story Handoff
- `*vet-tests {story}` - Review test scenarios for coverage, output Test Review Handoff

**Workflow Patterns**:
1. **Standard Flow**: Orchestrator creates story → Dev implements + tests → QA validates
2. **With Vetting**: Orchestrator creates story → Dev implements + writes tests → Orchestrator vets tests → QA validates
3. **Research-Heavy**: Orchestrator researches → Creates story with findings → Dev implements → QA validates

**Handoffs** (Dual-Format System):

All handoffs create TWO outputs:
1. **Detailed Document**: Permanent record with comprehensive context (`docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-{type}-handoff.md`)
2. **Compact Snippet**: Terminal output (10-15 lines) with document reference

**Six Handoff Types**:
- **Story Handoff** (Orchestrator → Dev): Story path, scope, research, guidance, Context7 findings
- **QA Handoff** (Dev → QA): Tasks done, files, tests, process URLs + PIDs, focus areas
- **Developer Handoff** (QA → Dev): Issues found, evidence, suggested fixes, root cause analysis
- **Completion Handoff** (QA → Dev): Test results, approval, suggested commit message
- **Test Review Handoff** (Orchestrator → QA/Dev): Coverage status, APPROVE or REVISE
- **Story Completion Summary** (Dev → Orchestrator): Story outcome, KB entries, process cleanup, next story dependencies

**See**: `.bmad-core/data/three-terminal-workflow.md` and `.bmad-core/data/handoff-templates.md` for complete guide

**Migration**: Two-terminal workflow (SM + Dev + QA) still works. Adopt three-terminal gradually for complex stories only.

## QA/Test Architect Integration

The QA agent (Quinn) provides comprehensive quality assurance throughout the development lifecycle.

**QA Command Shortcuts**:
- `*risk` - Identify integration and regression risks
- `*design` - Create test strategy
- `*trace` - Verify test coverage of all acceptance criteria
- `*nfr` - Validate non-functional requirements
- `*review` - Comprehensive assessment + active refactoring (REQUIRED)
- `*gate` - Update quality gate status after addressing issues

**When to Use**:
- **Before Development**: `*risk`, `*design`
- **During Development**: `*trace`, `*nfr`
- **After Development**: `*review` (REQUIRED), `*gate`

**QA Output Locations**:
```
docs/qa/assessments/{epic}.{story}-{type}-{YYYYMMDD}.md
docs/qa/gates/sprint-{sprint}/epics/epic-{epic}/{epic}.{story}-{slug}.yml
```

## Current Production Features (November 2025)

**Status**: PRODUCTION READY ✅
**Last Updated**: 2025-11-24

### 1. Testing Strategy: Vitest + Playwright MCP Hybrid

**Stack**:
- ✅ **Vitest**: ONLY for complex logic with 10+ edge cases (tax calculations, algorithms, validation)
- ✅ **Playwright MCP**: ALL user journeys via 26 interactive browser control tools
- ❌ **Jest**: ELIMINATED ENTIRELY (replaced by Vitest)

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

### 2. Context7 MCP Integration

All planning agents use Context7 MCP for real-time documentation:
- ✅ Analyst, PM, Architect (MOST CRITICAL), UX Expert, Dev, QA

**Usage**: Add "use context7 - {question}" to prompts when researching technical solutions

**Why**: Prevents deprecated code patterns, ensures current best practices

### 3. Git Workflow Integration

Three commit points integrated into BMad workflow:

1. **Commit Point 1: After Dev Implementation** (Before QA)
   - Format: `feat(story-X.Y): Implementation complete` with task list, test counts, file counts
   - Footer: `Authored by O2Scale`

2. **Commit Point 2: After QA Fixes** (If QA FAIL/CONCERNS)
   - Format: `fix(story-X.Y): Address QA findings` with issue list, test counts, quality gate status
   - Footer: `Authored by O2Scale`

3. **Commit Point 3: After QA PASS** (Story Complete)
   - Format: `chore(story-X.Y): Story complete - QA approved` with AC validation, evidence reference
   - Footer: `Authored by O2Scale`

**Branch Strategy**:
- **Main/Master**: Production-ready code (protected)
- **Develop/Devwf**: Integration branch for features
- **Story Branches**: `story/{epic}.{story}-{slug}`

**Reference**: `.bmad-core/data/git-workflow-guide.md`

### 4. Knowledge Base Integration (November 2025)

**MANDATORY KB creation enforced at 5 layers**:

1. **Story DoD Checklist** - Section 10: KB Documentation (mandatory checkpoint)
2. **Dev Agent** - KB checkpoint in `*complete-story` command (blocks Story Completion Summary if trigger matched)
3. **Dev Agent** - Proactive KB sourcing (check KB FIRST before external research)
4. **QA Agent** - KB validation in review (verifies KB completeness)
5. **Orchestrator Agent** - Anticipates KB needs in Story Handoff (tells Dev upfront)

**KB Triggers** (MANDATORY creation):
- Third-party integration (Stripe, S3, Supabase, Vertex AI, SendGrid, etc.)
- Reusable pattern (pagination, auth, error handling, batch processing, etc.)
- Complex/non-obvious solution (race conditions, performance optimization, data integrity, etc.)
- Dev Notes explicitly request KB documentation

**Location**: `docs/knowledge-base/` (integrations/, backend-patterns/, ui-patterns/, common-issues/)

**Integration Files**:
- `.bmad-core/checklists/story-dod-checklist.md` (section 10)
- `.bmad-core/agents/dev.md` (KB 4-Step Workflow, KB checkpoint in complete-story)
- `.bmad-core/agents/qa.md` (KB validation in review)
- `.bmad-core/agents/bmad-orchestrator.md` (KB anticipation in story creation)

### 5. Navigation Integration (November 2025)

**4-Layer Defense System** preventing missing menu items:

1. **Story Template** - Navigation Notes MANDATORY for user-facing features
2. **UX Expert Agent** - Must design complete navigation integration
3. **Story DoD Checklist** - Section 10: Navigation Integration (9 mandatory checks)
4. **QA Review Task** - Section 2H: Navigation verification via Playwright MCP
5. **Test Scenarios** - TC.nav test scenarios mandatory for all user-facing features

**Navigation Requirements** (MANDATORY):
- Menu placement (which menu, exact label, icon, position)
- Breadcrumbs (page hierarchy)
- User journey (minimum 2-3 entry points)
- Contextual links (related pages that link to feature)

**Integration Files**:
- `.bmad-core/templates/story-tmpl.yaml` (Navigation Notes mandatory)
- `.bmad-core/agents/ux-expert.md` (navigation design principle)
- `.bmad-core/checklists/story-dod-checklist.md` (section 10)
- `.bmad-core/tasks/review-story.md` (section 2H)
- `.bmad-core/data/testing-stack-guide.md` (TC.nav template)

### 6. Authentication Test Credentials (November 2025)

**Structured test data management** for authentication testing:

**Location**: `test-data/auth/creds.txt` (standard credential format)

**Dev Responsibilities**:
- Create `test-data/auth/creds.txt` from template (if missing)
- Create seed script matching creds.txt EXACTLY (database/seeds/ OR backend/scripts/)
- Run seed script to populate development database with test users
- Verify test users exist in database
- Include Test Data Setup in QA Handoff (credentials file, seed script, test users created)

**QA Responsibilities**:
- ALWAYS use test-data/auth/creds.txt for authentication testing (do NOT make up random credentials)
- Reference creds.txt explicitly in E2E test scenarios
- If creds.txt missing: FLAG as blocking issue in Developer Handoff

**Integration Files**:
- `.bmad-core/templates/auth-creds-README.md` (comprehensive template)
- `.bmad-core/templates/creds-template.txt` (standard format)
- `.bmad-core/data/testing-stack-guide.md` (Dev + QA auth sections)
- `.bmad-core/agents/dev.md` (auth test data principle)
- `.bmad-core/agents/qa.md` (auth testing principle)
- `.bmad-core/checklists/story-dod-checklist.md` (section 4)

### 7. Background Process Management (November 2025)

**Comprehensive process lifecycle management** preventing resource exhaustion:

**Process Cleanup on Story Completion** (MANDATORY):
- After Dev receives QA Completion Handoff → Kill all processes (frontend, backend, workers - NOT database) → Create Story Completion Summary
- 5 second delay for graceful shutdown + port release
- Port verification fallback (max 3 retries = 15 sec total)
- Record cleanup in Story Completion Summary (PIDs killed, timestamp, ports released)

**Backend Restart Protocol** (Enhanced with 5 sec delay):
- When backend files modified during story implementation
- Kill backend → WAIT 5 SECONDS → Verify port released → Restart backend
- Fallback: If port still bound after 5 sec, retry with 2 sec delay (max 3 retries)
- Record new PID + timestamp in QA Handoff

**Process Startup Check** (Auto-detect existing processes):
- At beginning of `*develop-story` command, check if processes already running
- If YES: Ask user "Processes detected on ports X, Y. Restart for fresh environment?"
- If NO: Auto-start fresh processes (frontend, backend, workers)

**Integration Files**:
- `.bmad-core/agents/dev.md` (process cleanup in complete-story, Backend Restart Protocol with 5 sec delay, process startup check)
- `.bmad-core/data/handoff-templates.md` (Story Completion Summary includes process cleanup section)

### 8. Framework Synchronization

**Symlink approach** for rapid iteration (PRODUCTION):
- `.bmad-core/` - Symlinked from master to all projects
- `.claude/commands/` - Symlinked from master to all projects
- Setup: Run `.\scripts\setup-symlinks.ps1` (requires Administrator on Windows)
- Future: Migrate to Git submodules when framework stabilizes

**Reference**: `scripts/README-SYMLINKS.md`

### 9. Timestamp Protocol

**Linux-First Approach**:
- Primary: `date +%Y-%m-%d %H:%M:%S` (bash/WSL)
- Fallback: `Get-Date -Format "yyyy-MM-dd HH:mm:ss"` (PowerShell)
- ALL documentation updates MUST include timestamp

### Analysis & Migration

**BMad V6 Migration**: Analyzed (2025-11-02), decision deferred. See `docs/planning/BMAD-V6-MIGRATION-OPTIONS.md`

**Optimization History**: See `docs/analysis/`, `docs/verification/`, `docs/session-logs/`

## Session Management & Context Preservation

### Automatic Session Logging Workflow

**Trigger Point**: When context usage reaches **80-85% of usable context** (~124,000-132,000 / ~155,000 usable tokens)

**Note**: Total context window is 200,000 tokens, but Claude Code reserves ~45,000 tokens (22.5%) for conversation management.

**Action Required**:
1. **Create session log**: Save complete conversation to `docs/session-logs/SESSION-LOG-{TOPIC}-{YYYY-MM-DD}.md`
2. **Include**: Complete conversation history, decisions, prompts, files created/modified, progress, next steps
3. **Update CLAUDE.md**: Add reference to session log in relevant section
4. **Inform user**: Session log created, ready to continue or compact conversation

**Why This Matters**:
- Preserves decisions across conversation compactions
- Enables seamless resumption after breaks
- Creates audit trail of project evolution
- Prevents loss of context and rationale

**For session log history**: See `docs/session-logs/README.md`

## Best Practices & Important Notes

### Core Principles

1. **Never modify `.bmad-core/` files** unless intentionally customizing the framework
2. **Always check `core-config.yaml`** to understand project structure and document locations
3. **Use appropriate agent for task** - don't use dev agent for planning tasks
4. **Keep conversations focused** - one agent, one task per conversation
5. **Commit regularly** - especially after completing stories (3 commit points: implementation, fixes, completion)
6. **QA review is not optional** for production code
7. **Create session logs at 80-85% context** - preserve long-term work decisions

### Context Management

1. **Fresh Conversations**: Start new chats for each agent role to keep context clean
2. **Sequential Progress**: Work on one story at a time
3. **Load Minimal Context**: Only include relevant files for current task
4. **Reference Documents**: Always check sharded epics/stories before implementation

### Story Implementation Flow

1. Start new conversation with dev agent (`/BMad/agents/dev`)
2. Execute `*develop-story docs/stories/{story-file}.md`
3. Dev agent will load always-required context files, read story, execute tasks, write tests, create QA Handoff
4. Switch to QA terminal, paste QA Handoff, execute tests, create Completion Handoff OR Developer Handoff
5. If PASS: Dev creates Story Completion Summary, story complete
6. If FAIL/CONCERNS: Dev addresses issues, creates fixes commit, returns to QA

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

## Common Development Commands

### Start Story Development
```bash
# SM creates next story
/BMad/tasks/create-next-story

# Dev implements story
/BMad/agents/dev
*develop-story docs/stories/{story-file}.md
```

### Database Setup (Story 1.1)
```bash
# SM creates Story 1.1 (auto-detects database)
/BMad/tasks/create-next-story

# Dev implements database schema using Database MCP
/BMad/agents/dev
*develop-story docs/stories/1.1.story.md
```

### Frontend Development
```bash
# UX Expert creates component specifications
/BMad/agents/ux-expert
*create-front-end-spec

# Dev implements frontend story
/BMad/agents/dev
*develop-story docs/stories/{story-file}.md
# Dev installs shadcn components: npx shadcn@latest add button form input
```

### QA Review Process
```bash
# For high-risk or brownfield stories
/BMad/agents/qa
*risk {story}        # Before development
*design {story}      # Before development
*review {story}      # After development (REQUIRED)
*gate {story}        # After fixes
```

## Key Resources & Guides

### Framework Documentation
- **User Guide**: `.bmad-core/user-guide.md` - Complete BMad methodology
- **IDE Workflow**: `.bmad-core/enhanced-ide-development-workflow.md` - Step-by-step dev cycle
- **Brownfield Guide**: `.bmad-core/working-in-the-brownfield.md` - Existing project workflow
- **Testing Guide**: `.bmad-core/data/testing-stack-guide.md` - Comprehensive testing workflow (Vitest + Playwright MCP)
- **Git Workflow**: `.bmad-core/data/git-workflow-guide.md` - 3 commit points, branch strategy, O2Scale branding
- **Knowledge Base**: `.bmad-core/data/bmad-kb.md` - Framework overview
- **Technical Preferences**: `.bmad-core/data/technical-preferences.md` - Team preferences

### Workflow Guides
- **MCP Setup & Usage**: `docs/guides/MCP-QUICK-START.md` - Comprehensive MCP guide
- **Workflow Reference**: `docs/guides/WORKFLOW-REFERENCE.md` - Detailed workflow examples
- **Terminal Isolation**: `docs/guides/TERMINAL-ISOLATION-WORKFLOW.md` - Fresh Dev terminals per story, context isolation
- **Framework Maintenance**: `docs/guides/FRAMEWORK-MAINTENANCE.md` - Agent sync procedures, symlink management

### Documentation & History
- **Session Logs**: `docs/session-logs/README.md` - Session log history
- **Analysis Documents**: `docs/analysis/` - System analysis and optimization history
- **Planning Documents**: `docs/planning/` - Strategic planning and decisions
- **Verification Reports**: `docs/verification/` - Validation and verification reports
