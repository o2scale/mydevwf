# HDAV2 BMad V4 Integration Plan

**Document Purpose**: Comprehensive handoff for integrating optimized BMad V4 workflow into hdav2 project
**Target Audience**: New Claude Code terminal session working from mydevwf root
**Date Created**: 2025-11-03
**Project**: hdav2 (Next.js + Python/FastAPI + Supabase)
**Approach**: Brownfield integration (production app with existing code)

---

## 🎯 Mission Statement

**Your Task**: Analyze `projects/hdav2/` and integrate our fully optimized BMad V4 workflow into the existing production project, replacing outdated BMad version.

**Context**: You are a NEW terminal session opening in `mydevwf/` root directory. This document guides you through a comprehensive brownfield integration that will align hdav2 with our current BMad V4 optimizations.

**End Goal**: hdav2 project fully aligned with our workflow, ready for continued development using BMad V4 agents, MCPs, testing stack, and Knowledge Base.

---

## 📚 Required Reading (Read These First)

**Before starting, you MUST read these files in order**:

### 1. Root CLAUDE.md (Primary Context)
**File**: `D:/Dev/mydevwf/CLAUDE.md`

**What you'll learn**:
- Current BMad V4 state and all optimizations (Oct-Nov 2025)
- Testing strategy (Vitest + Playwright MCP hybrid)
- MCP integration patterns
- Knowledge Base system
- Frontend workflow (shadcn/ui)
- Database workflow (Supabase)
- Two-terminal Dev/QA workflow
- Session management protocols

**Critical sections**:
- "Recent System Optimizations (October 2024)" - Lines 723+
- "Knowledge Base" - Lines 76-111
- "Testing Strategy" - Lines 733-756
- "Database Architecture Workflow" - Search for this section
- "Frontend Component Library Workflow (shadcn/ui)" - Search for this section

### 2. Brownfield Workflow Guide
**File**: `.bmad-core/working-in-the-brownfield.md`

**What you'll learn**:
- How to document existing projects
- Reverse engineering approach
- Risk assessment for existing code
- Migration strategies

### 3. Project Template Reference
**File**: `project-templates/nextjs-fastapi-supabase/README.md`

**What you'll learn**:
- Reference architecture for Next.js + FastAPI + Supabase
- MCP configuration for this stack
- Folder structure expectations
- Key patterns to adopt

### 4. Key Data Files
**Files** (in `.bmad-core/data/`):
- `testing-stack-guide.md` - Testing workflow (Vitest + Playwright MCP)
- `database-workflow-guide.md` - Generic database principles
- `handoff-templates.md` - Dev/QA handoff formats

---

## 🔍 Project Analysis Phase

### Step 1: Explore hdav2 Structure

**Location**: `projects/hdav2/`

**What to analyze**:

```bash
# 1. Check package.json (understand dependencies)
Read: projects/hdav2/package.json

# 2. Identify framework structure
Find: Next.js app structure (app/ or pages/)
Find: FastAPI backend location
Find: Existing test setup

# 3. Check existing BMad installation
Explore: projects/hdav2/.bmad-core/ (if exists - OUTDATED)
Explore: projects/hdav2/docs/ (existing documentation)

# 4. Understand current state
Check: Is there .mcp.json? (MCP configuration)
Check: Is there CLAUDE.md? (project instructions)
Check: What testing framework? (Jest, Vitest, none?)
```

**Document your findings**: Create mental model of:
- Current folder structure
- What's working well (keep)
- What's outdated/missing (replace/add)
- Risks (production code, existing tests)

### Step 2: Compare with Template

**Reference**: `project-templates/nextjs-fastapi-supabase/`

**Key comparisons**:
- Folder structure differences
- MCP configuration (template has Supabase + Swagger + Context7 + shadcn-ui)
- Testing setup (template uses Vitest + Playwright MCP)
- Documentation structure (template has docs/architecture/, docs/stories/, etc.)

**Create alignment checklist**: What from template should be adopted?

---

## 🛠️ Integration Strategy (Brownfield Approach)

### Overview

**Principle**: hdav2 is a **production app** with existing code, tests, and documentation. We DO NOT rewrite - we integrate BMad V4 around existing functionality.

**Phases**:
1. **Backup & Safety** - Ensure we can rollback
2. **Document Existing** - Map current architecture
3. **Replace Framework** - Copy optimized `.bmad-core/` over
4. **Configure MCPs** - Set up Supabase, Swagger, Context7, shadcn-ui
5. **Align Structure** - Adopt template patterns where beneficial
6. **Create Docs** - Architecture, tech stack, project structure
7. **Create CLAUDE.md** - Project-specific instructions
8. **Validate** - Ensure nothing broke

---

## 📋 Detailed Execution Plan

### Phase 1: Backup & Safety (15 min)

**Goal**: Ensure we can rollback if something goes wrong

**Tasks**:
```bash
# 1. Check git status
cd projects/hdav2
git status

# 2. Create safety branch
git checkout -b bmad-v4-integration
git add .
git commit -m "Checkpoint before BMad V4 integration"

# 3. Document current state
# Take note of:
# - Current .bmad-core/ version (if exists)
# - Current scripts in package.json
# - Current folder structure
```

**Success Criteria**:
- [ ] Clean git branch created
- [ ] Current state committed
- [ ] Can rollback with `git checkout main` if needed

---

### Phase 2: Document Existing Project (30-45 min)

**Goal**: Create architecture documentation for existing hdav2 codebase

**Reference**: `.bmad-core/tasks/document-project.md`

**Tasks**:

**2.1. Create docs structure** (if doesn't exist):
```bash
cd projects/hdav2
mkdir -p docs/architecture
mkdir -p docs/stories
mkdir -p docs/qa/{assessments,gates}
mkdir -p docs/knowledge-base/{backend-patterns,ui-patterns,integrations,common-issues}
```

**2.2. Document architecture**:

Create these files in `projects/hdav2/docs/architecture/`:

**a) `tech-stack.md`**:
```markdown
# Tech Stack

**Frontend**: Next.js 14+ (App Router), TypeScript, Tailwind CSS, shadcn/ui
**Backend**: Python 3.x, FastAPI
**Database**: Supabase (PostgreSQL + Auth + Storage + Real-time)
**Testing**: [Document current setup - Jest? Vitest? Playwright?]
**Deployment**: [Document current deployment]

[Include versions, key dependencies, etc.]
```

**b) `unified-project-structure.md`**:
```markdown
# Project Structure

[Document actual hdav2 folder structure]
[Explain purpose of each major folder]
[Note any non-standard patterns]
```

**c) `coding-standards.md`**:
```markdown
# Coding Standards

[Document existing code style]
[TypeScript/Python patterns used]
[Naming conventions]
[File organization rules]
```

**d) `database-schema.md`**:
```markdown
# Database Schema

[Document existing Supabase tables, relationships, RLS policies]
[Include migrations history if available]
```

**e) `frontend-architecture.md`**:
```markdown
# Frontend Architecture

[Document Next.js routing structure]
[State management approach]
[Component patterns]
```

**f) `backend-architecture.md`**:
```markdown
# Backend Architecture

[Document FastAPI route structure]
[Authentication/authorization]
[API design patterns]
```

**2.3. Identify existing features**:

Create `docs/existing-features.md`:
```markdown
# Existing Features

## Core Features
1. [Feature 1] - [Brief description]
2. [Feature 2] - [Brief description]
...

## Supporting Features
- [Feature]
- [Feature]

## Integrations
- Supabase Auth
- Supabase Storage
- [Any other third-party services]
```

**Success Criteria**:
- [ ] All 6 architecture files created in `docs/architecture/`
- [ ] `existing-features.md` lists all major features
- [ ] You understand the codebase structure
- [ ] No code changes yet (documentation only)

---

### Phase 3: Replace BMad Framework (20-30 min)

**Goal**: Replace outdated `.bmad-core/` with our optimized V4 version

**Tasks**:

**3.1. Backup old BMad** (if exists):
```bash
cd projects/hdav2

# If .bmad-core/ exists
if [ -d ".bmad-core" ]; then
  mv .bmad-core .bmad-core-old-backup
  echo "✓ Backed up old .bmad-core/"
fi
```

**3.2. Copy optimized BMad V4**:
```bash
# Copy from mydevwf root to hdav2
cp -r ../../.bmad-core .bmad-core

echo "✓ Copied optimized BMad V4 framework"
```

**3.3. Verify copy**:
```bash
# Check key files exist
ls -la .bmad-core/agents/
ls -la .bmad-core/tasks/
ls -la .bmad-core/data/testing-stack-guide.md
ls -la .bmad-core/data/database-workflow-guide.md

echo "✓ BMad V4 framework verified"
```

**Success Criteria**:
- [ ] Old `.bmad-core/` backed up (if existed)
- [ ] New optimized `.bmad-core/` copied successfully
- [ ] All agents, tasks, templates, data files present
- [ ] `testing-stack-guide.md` exists (critical for V4)

---

### Phase 4: Configure MCPs (25-35 min)

**Goal**: Set up MCP configuration for Next.js + FastAPI + Supabase stack

**Reference**: `project-templates/nextjs-fastapi-supabase/.mcp.json`

**Tasks**:

**4.1. Create `.mcp.json`** (if doesn't exist):

```json
{
  "mcpServers": {
    "context7": {
      "transport": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "description": "Context7 MCP - Real-time library documentation and patterns"
    },
    "shadcn-ui": {
      "transport": "stdio",
      "command": "npx",
      "args": ["-y", "@jpisnice/shadcn-ui-mcp-server"],
      "description": "shadcn/ui component library access",
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": ""
      }
    },
    "supabase": {
      "transport": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-supabase"],
      "description": "Supabase database operations, migrations, logs",
      "env": {
        "SUPABASE_URL": "http://localhost:54321",
        "SUPABASE_SERVICE_ROLE_KEY": ""
      }
    }
  }
}
```

**Note**: Swagger MCP for FastAPI can be added later once OpenAPI spec exists.

**4.2. Update `.gitignore`**:
```bash
# Ensure .mcp.json is gitignored (contains tokens)
echo "" >> .gitignore
echo "# MCP Configuration (tokens)" >> .gitignore
echo ".mcp.json" >> .gitignore
```

**4.3. Create `.mcp.json.example`**:
```bash
# Copy .mcp.json to .mcp.json.example (without tokens)
cp .mcp.json .mcp.json.example

# Remove sensitive values from example
sed -i 's/"GITHUB_PERSONAL_ACCESS_TOKEN": ".*"/"GITHUB_PERSONAL_ACCESS_TOKEN": ""/' .mcp.json.example
sed -i 's/"SUPABASE_SERVICE_ROLE_KEY": ".*"/"SUPABASE_SERVICE_ROLE_KEY": ""/' .mcp.json.example
```

**Success Criteria**:
- [ ] `.mcp.json` created with all MCPs (Context7, shadcn-ui, Supabase)
- [ ] `.gitignore` updated to exclude `.mcp.json`
- [ ] `.mcp.json.example` created for team reference
- [ ] Tokens placeholders in example (empty strings)

---

### Phase 5: Align Structure with Template (30-45 min)

**Goal**: Adopt beneficial patterns from `nextjs-fastapi-supabase` template

**Reference**: `project-templates/nextjs-fastapi-supabase/`

**Tasks**:

**5.1. Create Knowledge Base** (if doesn't exist):
```bash
cd projects/hdav2

# Copy knowledge-base structure from mydevwf
cp -r ../../docs/knowledge-base docs/knowledge-base

echo "✓ Knowledge Base structure created"
```

**5.2. Update `package.json` scripts** (if needed):

Check if hdav2 `package.json` has these scripts, add if missing:
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "test": "vitest",
    "test:coverage": "vitest --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui"
  }
}
```

**5.3. Check testing setup**:

**Current setup**: Document what hdav2 currently uses (Jest? Vitest? None?)

**Target setup** (from our optimizations):
- **Vitest**: For unit tests (complex logic with 10+ edge cases)
- **Playwright MCP**: For E2E tests (via interactive browser tools, NOT .spec.ts files)

**Decision**:
- If hdav2 uses Jest → Plan migration to Vitest (don't do it now, just document)
- If hdav2 uses Playwright .spec.ts files → Plan migration to MCP approach (document)
- If no tests → Note that testing stack setup needed

**5.4. Check database workflow files**:

Verify `docs/architecture/` has database-specific workflow:
```bash
# Check if exists
ls docs/architecture/database-workflow-supabase.md

# If not, create from template
cp ../../project-templates/nextjs-fastapi-supabase/docs/architecture/database-workflow-supabase.md \
   docs/architecture/database-workflow-supabase.md
```

**Success Criteria**:
- [ ] Knowledge Base structure exists
- [ ] package.json has recommended scripts
- [ ] Testing approach documented (current vs target)
- [ ] Database workflow guide exists for Supabase

---

### Phase 6: Create Project CLAUDE.md (45-60 min)

**Goal**: Create hdav2-specific `CLAUDE.md` for future terminal sessions

**Location**: `projects/hdav2/CLAUDE.md`

**Tasks**:

**6.1. Start with template**:
```bash
# Use nextjs-fastapi-supabase README as reference
# Create comprehensive CLAUDE.md for hdav2
```

**6.2. CLAUDE.md Structure**:

```markdown
# CLAUDE.md

This file provides guidance to Claude Code when working in the hdav2 project.

## Project Overview

hdav2 is a [description of what hdav2 does] built with:
- **Frontend**: Next.js 14+ (App Router) + TypeScript + Tailwind CSS + shadcn/ui
- **Backend**: Python + FastAPI
- **Database**: Supabase (PostgreSQL + Auth + Storage + Real-time)
- **Workflow**: BMad V4 (optimized framework)

## Directory Structure

[Document hdav2-specific structure]

## Configuration Files

- `.bmad-core/core-config.yaml` - BMad configuration
- `.mcp.json` - MCP server configuration (gitignored)
- `docs/architecture/` - Architecture documentation

## Development Workflow

### BMad Agents

Use BMad agents for development:
- `/BMad/agents/dev` - Story implementation
- `/BMad/agents/qa` - Quality assurance
- `/BMad/agents/pm` - Product management
- `/BMad/agents/architect` - Architecture decisions
- `/BMad/agents/ux-expert` - UX specifications

### MCP Integration

**Available MCPs**:
- **Context7**: Up-to-date library documentation
- **shadcn-ui**: Component library access (requires GitHub token)
- **Supabase**: Database operations, migrations, logs

### Testing Strategy

**Vitest**: Unit tests for complex logic (10+ edge cases)
**Playwright MCP**: E2E tests via interactive browser tools

[Reference: .bmad-core/data/testing-stack-guide.md]

### Database Workflow

[Reference: docs/architecture/database-workflow-supabase.md]

Use Supabase MCP tools for all schema operations.

### Frontend Development

**Component Library**: shadcn/ui (copy-paste components)

[Reference: docs/front-end-spec.md when created]

Install components: `npx shadcn@latest add [component]`

## Knowledge Base

**Location**: `docs/knowledge-base/`

Create KB entries for:
- Third-party integrations
- Reusable patterns
- Non-obvious solutions

[Reference: docs/knowledge-base/README.md]

## Existing Features

[Reference list from docs/existing-features.md]

## Tech Stack Details

[Reference: docs/architecture/tech-stack.md]

## Architecture

[Reference: docs/architecture/unified-project-structure.md]

## Important Notes

1. **Production app**: Be careful with changes, test thoroughly
2. **Existing tests**: Understand before modifying
3. **Brownfield approach**: Document before changing
4. **Knowledge Base**: Reference existing patterns
5. **MCP tools**: Use for database, API testing, E2E tests
```

**Success Criteria**:
- [ ] `projects/hdav2/CLAUDE.md` created
- [ ] Contains hdav2-specific context
- [ ] References key architecture docs
- [ ] Explains BMad V4 workflow
- [ ] Documents MCP usage
- [ ] Production safety notes included

---

### Phase 7: Create Initial Stories (Optional - 30-45 min)

**Goal**: Create stories for future development OR document existing features as completed stories

**Approach A: Future Development**
- Use `/BMad/agents/sm` to create new stories
- Reference `docs/existing-features.md` for context
- Create stories in `docs/stories/`

**Approach B: Document Existing** (Recommended for brownfield)
- Create "Story 0.x" files documenting existing features
- Mark as "Completed" (historical record)
- Helps new developers understand feature history

**Example**: `docs/stories/0.1.authentication.story.md`
```markdown
# Story 0.1: User Authentication (COMPLETED)

**Epic**: 0 - Existing Features
**Status**: Completed (Pre-BMad)
**Story Points**: N/A (Existing)

## Story
As a user, I can register and log in using Supabase Auth.

## Acceptance Criteria
- [x] User registration via email/password
- [x] User login with Supabase
- [x] Session management
- [x] Protected routes

## Implementation Notes
[Document how authentication currently works in hdav2]

## Files
- [List relevant files]
```

**Success Criteria** (if you do this phase):
- [ ] Existing features documented as Story 0.x
- [ ] OR future stories created in docs/stories/
- [ ] Stories follow BMad format

---

### Phase 8: Validation & Testing (20-30 min)

**Goal**: Ensure integration didn't break anything

**Tasks**:

**8.1. Run existing tests**:
```bash
cd projects/hdav2

# Run whatever tests exist
npm test  # or pytest, or current test command

# Expected: All tests still pass
```

**8.2. Start development servers**:
```bash
# Start Next.js
npm run dev  # Expected: Starts on port 3000 (or configured port)

# Start FastAPI (separate terminal)
cd backend  # or wherever FastAPI is
uvicorn main:app --reload  # Expected: Starts on port 8000
```

**8.3. Verify MCPs** (after restarting Claude Code):
```bash
# In NEW Claude Code terminal opened in projects/hdav2/
/mcp

# Expected: Shows Context7, shadcn-ui, Supabase MCPs
```

**8.4. Verify docs structure**:
```bash
ls -la docs/architecture/  # Should have 6+ files
ls -la docs/knowledge-base/  # Should have README + 4 folders
ls -la .bmad-core/  # Should have agents, tasks, templates, data
```

**Success Criteria**:
- [ ] All existing tests pass
- [ ] Development servers start successfully
- [ ] MCPs configured correctly (verify in new terminal)
- [ ] Documentation structure complete
- [ ] No regressions (app still works)

---

## 🎯 Success Criteria (Overall)

**When you've completed this integration, hdav2 should have**:

### Files & Folders
- [x] `.bmad-core/` - Optimized V4 framework
- [x] `.mcp.json` - MCP configuration (Context7, shadcn-ui, Supabase)
- [x] `CLAUDE.md` - Project-specific instructions
- [x] `docs/architecture/` - 6+ architecture files
- [x] `docs/knowledge-base/` - KB structure with README
- [x] `docs/stories/` - Story files (existing or future)
- [x] `docs/qa/` - QA assessments/gates folders

### Configuration
- [x] BMad V4 agents available (`/BMad/agents/*`)
- [x] MCPs working (Context7, shadcn-ui, Supabase)
- [x] Testing approach documented (Vitest + Playwright MCP)
- [x] Database workflow documented (Supabase-specific)

### Documentation
- [x] Architecture documented (tech-stack, structure, standards)
- [x] Existing features catalogued
- [x] CLAUDE.md comprehensive
- [x] Knowledge Base ready for use

### Validation
- [x] No regressions (existing tests pass)
- [x] Development servers start
- [x] Ready for continued development with BMad V4

---

## 📝 Handoff Notes

**After completing this integration**:

1. **Commit changes**:
   ```bash
   cd projects/hdav2
   git add .
   git commit -m "Integrate optimized BMad V4 workflow

   - Replaced outdated .bmad-core/ with optimized V4
   - Configured MCPs (Context7, shadcn-ui, Supabase)
   - Documented architecture in docs/architecture/
   - Created project-specific CLAUDE.md
   - Set up Knowledge Base structure
   - Aligned with nextjs-fastapi-supabase template patterns

   Ready for continued development with BMad V4 workflow."
   ```

2. **Inform user**:
   - Integration complete
   - hdav2 now uses optimized BMad V4
   - Future terminals in `projects/hdav2/` will read `hdav2/CLAUDE.md`
   - Ready for development using BMad agents

3. **Next steps for user**:
   - Open new terminal in `projects/hdav2/`
   - Use `/BMad/agents/dev` for feature development
   - Use `/BMad/agents/qa` for quality assurance
   - Leverage MCPs (Supabase for DB, Playwright for E2E)
   - Reference Knowledge Base for patterns

---

## 🚨 Troubleshooting

### Issue: Old .bmad-core/ conflicts

**Solution**: Ensure old version backed up before copying new one
```bash
mv .bmad-core .bmad-core-old-backup
cp -r ../../.bmad-core .bmad-core
```

### Issue: MCP not detected

**Solution**:
1. Ensure `.mcp.json` in root of hdav2
2. Restart Claude Code
3. Check `/mcp` command

### Issue: Tests fail after integration

**Solution**:
1. Check if test configuration changed
2. Verify dependencies still installed
3. Review what files were modified
4. Rollback: `git checkout main` (if needed)

### Issue: Don't understand hdav2 codebase

**Solution**:
1. Use `/BMad/tasks/document-project` workflow
2. Read existing documentation in `docs/` (if any)
3. Explore incrementally (don't change until you understand)
4. Ask user for clarification on complex areas

---

## 📚 Reference Materials

**Key Files to Reference**:
- `D:/Dev/mydevwf/CLAUDE.md` - Master workflow documentation
- `.bmad-core/working-in-the-brownfield.md` - Brownfield approach
- `.bmad-core/data/testing-stack-guide.md` - Testing workflow
- `.bmad-core/data/database-workflow-guide.md` - Database principles
- `project-templates/nextjs-fastapi-supabase/README.md` - Stack reference

**Template Files**:
- `project-templates/nextjs-fastapi-supabase/.mcp.json` - MCP config example
- `project-templates/nextjs-fastapi-supabase/docs/architecture/` - Architecture examples

**BMad Workflows**:
- `/BMad/tasks/document-project` - Document existing codebase
- `/BMad/agents/architect` - Architecture decisions
- `/BMad/agents/sm` - Story creation

---

**Document Status**: ✅ Ready for use
**Target Terminal**: New session in `mydevwf/` root
**Expected Duration**: 3-5 hours total (all phases)
**Complexity**: Medium-High (brownfield integration)
**Risk Level**: Low (backup created, can rollback)

Good luck! 🚀
