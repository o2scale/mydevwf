# Workflow Reference Guide

**Purpose**: Detailed workflow examples and step-by-step guides for MyDevWF development.

**Last Updated**: 2025-11-03

---

## Table of Contents

- [Database Architecture Workflow](#database-architecture-workflow)
- [Frontend Component Workflow](#frontend-component-workflow)
- [Testing Workflow](#testing-workflow)
- [Development Cycle](#development-cycle)
- [Brownfield Workflow](#brownfield-workflow)

---

## Database Architecture Workflow

**For backend/fullstack projects with databases (Supabase, MongoDB, PostgreSQL)**

### Story 1.1: Database Setup (Automatic)

When creating Story 1.1 for projects with a database, the SM agent automatically creates a Database Setup story as P0 BLOCKER.

**Flow**:
1. **SM creates Story 1.1**: `/BMad/tasks/create-next-story`
   - Detects database in `docs/architecture/tech-stack.md`
   - Finds schema in `docs/architecture/database-schema.md`
   - Creates Database Setup story (P0 BLOCKER, 2 SP)

2. **Dev implements database schema**: `/BMad/tasks/execute-checklist`
   - Loads generic guide: `.bmad-core/data/database-workflow-guide.md`
   - Loads database-specific guide: `docs/architecture/database-workflow-{database}.md`
   - Uses Database MCP tools (Supabase/MongoDB MCP)
   - Applies schema via migration tool (tracked in database)
   - Verifies 100% match with documentation

3. **All subsequent stories depend on database being ready**

### Key Principles
- ✅ **ALWAYS use Database MCP tools** for schema operations (never manual SQL/commands)
- ✅ **Schema as source of truth**: `docs/architecture/database-schema.md`
- ✅ **Migration tracking**: All changes tracked in database via MCP migration tools
- ✅ **Zero schema drift**: Verification confirms implemented = documented (100%)

### Database-Specific Guides
- **Generic workflow**: `.bmad-core/data/database-workflow-guide.md`
- **Supabase**: `project-templates/nextjs-nodejs-supabase/docs/architecture/database-workflow-supabase.md`
- **MongoDB**: `project-templates/nextjs-nodejs-mongodb/docs/architecture/database-workflow-mongodb.md`

### Example Flow
```
1. Architect creates database-schema.md (420 lines of perfect schema)
2. SM creates Story 1.1: Database Setup (auto-generated, P0 BLOCKER)
3. Dev loads schema + workflow guides
4. Dev uses Supabase MCP: apply_migration({ name: "001_initial_schema", sql: [schema] })
5. Dev verifies: list_tables(), list_extensions(), list_migrations()
6. Dev documents: "✅ 5 tables, 15 indexes, 8 foreign keys, 100% match"
7. Database ready → All other stories can proceed
```

---

## Frontend Component Workflow

**For frontend/fullstack projects using shadcn/ui**

**Tech Stack**: Next.js + Tailwind CSS + TypeScript + shadcn/ui (built on Radix UI)

**Philosophy**: shadcn/ui is NOT an npm package - it's copy-paste components you own and can customize.

### Workflow Overview

**1. UX Expert Creates Component Specifications**

UX Expert creates `docs/front-end-spec.md` with shadcn/ui component decisions:
- Uses **shadcn-ui MCP** to explore available components (`list_components`)
- Specifies EXACT shadcn components for each UI element
- Documents variants, states, and usage guidelines
- Groups by category (Forms, Navigation, Data Display, Feedback, Layout)

**Example**:
```markdown
## Component Library / Design System

### Forms Category

#### Button
**shadcn Component**: `<Button>`
**Variants Used**: default, destructive, outline, ghost, link
**States**: default, hover, active, focus, disabled, loading
**Usage Guidelines**:
- Use `default` for primary actions (limit to 1 per view)
- Use `destructive` + confirmation dialog for irreversible actions

**Reference**: [shadcn-ui MCP: get_component_demo("button")]
```

**2. Architect References UX Component Decisions**

Architect reads `front-end-spec.md` and documents technical architecture:
- Respects UX Expert's component choices
- Adds technical implementation details in `frontend-architecture.md`
- Documents shadcn/ui setup and configuration

**3. Dev Implements with shadcn Components**

Dev agent:
- Loads `docs/front-end-spec.md` (knows which components to use)
- Uses **shadcn-ui MCP** for implementation examples (`get_component_demo`)
- Installs components via CLI: `npx shadcn@latest add button form input`
- Components are copy-pasted (Dev owns code, can customize)
- Implements exactly as UX Expert specified

**Dev Workflow**:
```
1. Read story: "Build user registration form"
2. Load: docs/front-end-spec.md
3. See UX spec: "Use shadcn Form + Input + Button + Toast"
4. Install: npx shadcn@latest add form input button toast
5. Use shadcn-ui MCP: get_component_demo("form") for examples
6. Implement form with shadcn components
7. Customize styling via Tailwind if needed
```

**4. QA Tests with Consistent Selectors**

shadcn/ui components have predictable DOM structure:
- All components use proper ARIA attributes (built on Radix UI)
- Consistent selectors: `button`, `input[name="..."]`, `div[role="dialog"]`
- E2E tests are more reliable and maintainable

### Key Principles
- ✅ **Single source of truth**: UX Expert specifies components in front-end-spec.md
- ✅ **Copy-paste, not npm**: Components are added to your codebase (you own them)
- ✅ **Accessible by default**: Built on Radix UI (ARIA attributes included)
- ✅ **Customizable**: Modify components via Tailwind classes
- ✅ **Consistent testing**: Predictable DOM structure for E2E tests
- ✅ **No component unit tests**: Focus on testing YOUR business logic and workflows

---

## Testing Workflow

**Testing Stack**: Vitest + Playwright MCP Hybrid

### Strategy

**Vitest**: ONLY for complex logic with 10+ edge cases
- Tax calculations
- Algorithms
- Validation logic
- Pure functions

**Playwright MCP**: ALL user journeys via 26 interactive browser control tools
- Real-world testing with human observation
- No test code maintenance
- Manual execution via MCP tools

**Jest**: ELIMINATED ENTIRELY (replaced by Vitest)

### Test Scenarios Format

Dev writes: Markdown test scenarios (NOT `.spec.ts` files)

**Format**: `TC{AC}.{case}` (e.g., TC1.1, TC1.2)

**Location**: `docs/qa/e2e/sprint-N/epics/epic-N/story-N/`

**Execution**: QA uses Playwright MCP tools interactively

### Workflow

1. **Dev writes feature + Vitest tests (if complex) + E2E scenarios (markdown)**
2. **Dev starts background processes, outputs QA Handoff, HALTS** (does NOT run tests)
3. **QA runs Vitest FIRST** (`npm run test`), then E2E via Playwright MCP tools
4. **QA manually observes**, captures screenshots/console logs, decides PASS/FAIL

### Example E2E Scenario

```markdown
### TC1.1: Submit Registration Form

**Steps**:
1. Type "test@example.com" into input[name="email"]
2. Type "password123" into input[type="password"]
3. Click button[type="submit"]
4. Wait for toast notification

**Expected Result**:
- Toast shows "Registration successful!"
- User redirected to /dashboard

**Priority**: P0
**Test Data**: Valid email/password
```

**Reference**: `.bmad-core/data/testing-stack-guide.md`

---

## Development Cycle

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

### Two-Terminal Development Workflow

**Dev Terminal**: Implements features, writes tests, starts processes
**QA Terminal**: Executes tests, validates quality, creates gate files

**Handoff Templates** (in `.bmad-core/data/handoff-templates.md`):
- QA Handoff (Dev → QA)
- Developer Handoff (QA → Dev, if issues found)
- Completion Handoff (QA → SM, if PASS)

---

## Brownfield Workflow

**For existing codebases**

### Flow

1. **Document First**: `/BMad/tasks/document-project` - Architect analyzes and documents existing system
2. **Plan Enhancement**: Create brownfield PRD/epic/story
3. **Implement**: Follow standard dev cycle
4. **Test Rigorously**: QA is critical for brownfield to prevent regressions

**Critical Notes**:
- **Always run QA risk assessment** before touching legacy code
- **Document existing patterns** before implementing changes
- **Regression tests are mandatory** for all brownfield changes
- **Use feature flags** for risky changes
- **Plan rollback strategies** for data migrations

**Reference**: `.bmad-core/working-in-the-brownfield.md`

---

## Common Commands

### Start Story Development
```bash
/BMad/tasks/create-next-story
# Review and approve the generated story
/BMad/tasks/execute-checklist docs/stories/{story-file}.md
```

### Database Setup (Story 1.1)
```bash
# SM creates Story 1.1 (auto-detects database, creates Database Setup story)
/BMad/tasks/create-next-story

# Dev implements database schema
/BMad/agents/dev
*develop-story docs/stories/1.1.story.md

# Dev uses Database MCP tools automatically
```

### Frontend Development with shadcn/ui
```bash
# UX Expert creates component specifications
/BMad/agents/ux-expert
*create-front-end-spec

# Dev implements frontend story
/BMad/agents/dev
*develop-story docs/stories/{story-file}.md

# Dev installs shadcn components
npx shadcn@latest add button form input dialog toast
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

---

**For complete methodology, see**: `.bmad-core/user-guide.md`
