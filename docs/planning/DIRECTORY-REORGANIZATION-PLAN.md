# MyDevWF Directory Reorganization Plan

**Date**: 2025-11-14
**Purpose**: Organize root directory with hierarchical structure
**Status**: PROPOSED (Pending user approval)

---

## Current State Analysis

### **Root Directory Inventory**

**Framework Core** (Keep at root):
- `.bmad-core/` - BMad framework
- `.bmad-infrastructure-devops/` - Infrastructure configs
- `.claude/` - Claude Code configuration
- `.mcp.json` - MCP configuration
- `CLAUDE.md` - Main project instructions
- `package.json`, `README.md`, `SETUP-COMPLETE.md`

**Production Directories** (Keep at root):
- `docs/` - Documentation (analysis, planning, session-logs, guides)
- `projects/` - Generated projects (hdav2, etc.)
- `project-templates/` - 4 production templates
- `scripts/` - Automation scripts

**Projects** (Need organization):
- `bmad-ide/` - BMad IDE project (active development)
- `bmadv6/` - BMad V6 analysis (research/reference)
- `lifeplan-ai/` - LifePlan AI concept (user loves this)
- `marketing/` - Marketing materials (project or docs?)

**Research Materials** (Need organization):
- `langchain/` - LangChain GitHub clone (reference)
- `langgraph/` - LangGraph GitHub clone (reference)
- `superpowers/` - Claude Code plugin (reference)
- `claude-code-agents-wizard-v2/` - Agent patterns (reference)

**Reference Materials** (Need organization):
- `info/` - Mixed content (Playwright docs, hdav2docs)

### **Problems Identified**

1. ❌ **Flat root structure** - 20+ items at root level (overwhelming)
2. ❌ **Mixed purposes** - Projects, research, framework, references all mixed
3. ❌ **No clear categories** - Hard to find things quickly
4. ❌ **Future clutter** - Adding more items will worsen the problem

---

## Proposed Hierarchical Structure

### **Vision**: 3-tier hierarchy (Category → Subcategory → Item)

```
mydevwf/
├── 📁 FRAMEWORK (Root-level framework files)
│   ├── .bmad-core/
│   ├── .bmad-infrastructure-devops/
│   ├── .claude/
│   ├── .mcp.json
│   ├── CLAUDE.md
│   ├── package.json
│   ├── README.md
│   └── SETUP-COMPLETE.md
│
├── 📁 PRODUCTION (Core development)
│   ├── docs/
│   ├── projects/
│   ├── project-templates/
│   └── scripts/
│
├── 📁 EXPLORATIONS (Active projects/experiments)
│   ├── bmad-ide/               # BMad IDE (active development)
│   ├── lifeplan-ai/            # LifePlan AI concept
│   └── marketing/              # Marketing materials
│
├── 📁 RESEARCH (External references & analysis)
│   ├── frameworks/
│   │   ├── bmadv6/             # BMad V6 analysis
│   │   ├── langchain/          # LangChain reference
│   │   └── langgraph/          # LangGraph reference
│   ├── plugins/
│   │   ├── superpowers/        # Claude Code plugin
│   │   └── wizard-v2/          # Agent wizard patterns
│   └── references/
│       └── (info/ content - Playwright docs, etc.)
│
└── 📁 ARCHIVE (Inactive/completed items - future use)
```

---

## Detailed Reorganization Plan

### **Tier 1: Root-Level Framework Files** (NO CHANGE)

**Keep at root**:
- `.bmad-core/` (symlinked to projects)
- `.bmad-infrastructure-devops/`
- `.claude/` (symlinked commands to projects)
- `.git/`, `.gitignore`
- `.mcp.json`
- `CLAUDE.md`
- `package.json`
- `README.md`
- `SETUP-COMPLETE.md`

**Reason**: These are framework essentials that must stay at root

---

### **Tier 2: Production Directories** (NO CHANGE)

**Keep at root**:
- `docs/` - Documentation hub
- `projects/` - Generated projects
- `project-templates/` - 4 production templates
- `scripts/` - Automation scripts

**Reason**: Active production use, frequently accessed

---

### **Tier 3: Create `explorations/` Directory**

**Purpose**: Active projects and experiments (not production, but active work)

**Move**:
```bash
bmad-ide/          → explorations/bmad-ide/
lifeplan-ai/       → explorations/lifeplan-ai/
marketing/         → explorations/marketing/
```

**Why "explorations" not "projects"?**
- "projects" already exists for generated production projects
- These are experimental/concept projects
- Signals "active work, but not production"

**Characteristics**:
- ✅ Active development or iteration
- ✅ User has ownership and vision
- ✅ May become production later (e.g., bmad-ide)
- ✅ User explicitly mentioned: "LifePlan AI - I'm pretty much very happy with it"

---

### **Tier 4: Create `research/` Directory**

**Purpose**: External references, framework analysis, downloaded materials

**Structure**:
```
research/
├── frameworks/
│   ├── bmadv6/              # BMad V6 analysis
│   ├── langchain/           # LangChain GitHub clone
│   └── langgraph/           # LangGraph GitHub clone
├── plugins/
│   ├── superpowers/         # Claude Code Superpowers plugin
│   └── wizard-v2/           # claude-code-agents-wizard-v2
└── references/
    ├── playwright/          # From info/bmad-playwright-workflow.md
    └── hdav2/               # From info/hdav2docs/
```

**Move**:
```bash
bmadv6/                               → research/frameworks/bmadv6/
langchain/                            → research/frameworks/langchain/
langgraph/                            → research/frameworks/langgraph/
superpowers/                          → research/plugins/superpowers/
claude-code-agents-wizard-v2/         → research/plugins/wizard-v2/
info/bmad-playwright-workflow.md      → research/references/playwright/
info/playwright-mcp-tools-reference.md → research/references/playwright/
info/hdav2docs/                       → research/references/hdav2/
```

**Delete**: `info/` folder (empty after move)

**Why subcategories?**
- `frameworks/` - Other frameworks (BMad V6, LangChain, LangGraph)
- `plugins/` - Claude Code plugins and agent patterns
- `references/` - Documentation, guides, project-specific docs

**Characteristics**:
- ✅ External/downloaded materials
- ✅ Reference only (not active development)
- ✅ Can be deleted without losing your work
- ✅ Helps with learning/comparison

---

### **Tier 5: Create `archive/` Directory** (Future use)

**Purpose**: Completed/inactive items that might be referenced later

**Currently**: Empty (placeholder for future)

**Future Use**:
- Completed explorations that became production
- Deprecated research materials
- Old project versions

---

## Migration Commands

### **Option A: Manual Move** (Recommended - safer)

```powershell
# Create new directories
New-Item -Path "explorations" -ItemType Directory
New-Item -Path "research" -ItemType Directory
New-Item -Path "research\frameworks" -ItemType Directory
New-Item -Path "research\plugins" -ItemType Directory
New-Item -Path "research\references" -ItemType Directory
New-Item -Path "research\references\playwright" -ItemType Directory
New-Item -Path "research\references\hdav2" -ItemType Directory
New-Item -Path "archive" -ItemType Directory

# Move explorations
Move-Item -Path "bmad-ide" -Destination "explorations\bmad-ide"
Move-Item -Path "lifeplan-ai" -Destination "explorations\lifeplan-ai"
Move-Item -Path "marketing" -Destination "explorations\marketing"

# Move research - frameworks
Move-Item -Path "bmadv6" -Destination "research\frameworks\bmadv6"
Move-Item -Path "langchain" -Destination "research\frameworks\langchain"
Move-Item -Path "langgraph" -Destination "research\frameworks\langgraph"

# Move research - plugins
Move-Item -Path "superpowers" -Destination "research\plugins\superpowers"
Move-Item -Path "claude-code-agents-wizard-v2" -Destination "research\plugins\wizard-v2"

# Move research - references
Move-Item -Path "info\bmad-playwright-workflow.md" -Destination "research\references\playwright\"
Move-Item -Path "info\playwright-mcp-tools-reference.md" -Destination "research\references\playwright\"
Move-Item -Path "info\hdav2docs" -Destination "research\references\hdav2\"

# Delete empty info folder
Remove-Item -Path "info"

# Commit changes
git add .
git commit -m "chore: Reorganize root directory with hierarchical structure

- Created explorations/ for active projects (bmad-ide, lifeplan-ai, marketing)
- Created research/ with subcategories (frameworks, plugins, references)
- Moved external materials to research/ (bmadv6, langchain, langgraph, superpowers, wizard-v2)
- Moved reference docs to research/references/ (playwright, hdav2)
- Removed empty info/ folder
- Cleaner root directory (7 items vs 20+ items)

Benefits:
- Clear separation of concerns
- Easy navigation with categories
- Future-proof structure
- Hierarchical organization"
```

### **Option B: Automated Script** (Create migration script)

**File**: `scripts/reorganize-directory.ps1`

Benefits:
- ✅ Idempotent (can run multiple times safely)
- ✅ Verification before execution
- ✅ Rollback capability
- ✅ Detailed logging

*(Script content can be created if user prefers this approach)*

---

## Before/After Comparison

### **BEFORE** (Current - 20+ items at root)
```
mydevwf/
├── .bmad-core/
├── .bmad-infrastructure-devops/
├── .claude/
├── .git/
├── .gitignore
├── .mcp.json
├── bmad-ide/                      ← Exploration
├── bmadv6/                        ← Research
├── CLAUDE.md
├── CLAUDE.md.backup
├── claude-code-agents-wizard-v2/  ← Research
├── docs/
├── info/                          ← Mixed
├── langchain/                     ← Research
├── langgraph/                     ← Research
├── lifeplan-ai/                   ← Exploration
├── marketing/                     ← Exploration
├── package.json
├── projects/
├── project-templates/
├── README.md
├── scripts/
├── SETUP-COMPLETE.md
└── superpowers/                   ← Research
```

**Issues**:
- 20+ items at root (overwhelming)
- Mixed purposes (framework + projects + research)
- Hard to find things
- Will get worse as you add more

---

### **AFTER** (Proposed - 7 categories at root)
```
mydevwf/
├── 📁 FRAMEWORK FILES (at root)
│   ├── .bmad-core/
│   ├── .bmad-infrastructure-devops/
│   ├── .claude/
│   ├── .git/, .gitignore
│   ├── .mcp.json
│   ├── CLAUDE.md
│   ├── package.json
│   ├── README.md
│   └── SETUP-COMPLETE.md
│
├── 📁 docs/                       # Documentation hub
├── 📁 projects/                   # Generated projects (hdav2, etc.)
├── 📁 project-templates/          # 4 production templates
├── 📁 scripts/                    # Automation scripts
│
├── 📁 explorations/               # ⭐ NEW
│   ├── bmad-ide/                  # Active development
│   ├── lifeplan-ai/               # Concept project
│   └── marketing/                 # Marketing materials
│
├── 📁 research/                   # ⭐ NEW
│   ├── frameworks/
│   │   ├── bmadv6/
│   │   ├── langchain/
│   │   └── langgraph/
│   ├── plugins/
│   │   ├── superpowers/
│   │   └── wizard-v2/
│   └── references/
│       ├── playwright/
│       └── hdav2/
│
└── 📁 archive/                    # ⭐ NEW (empty, future use)
```

**Benefits**:
- ✅ 7 clear categories (vs 20+ items)
- ✅ Easy navigation (purpose-based grouping)
- ✅ Clear separation (framework, production, explorations, research)
- ✅ Future-proof (can add items without clutter)
- ✅ Hierarchical (category → subcategory → item)

---

## Impact Analysis

### **What STAYS at Root** ✅
- Framework essentials (`.bmad-core/`, `.claude/`, `CLAUDE.md`, `package.json`)
- Production directories (`docs/`, `projects/`, `project-templates/`, `scripts/`)
- Git configuration (`.git/`, `.gitignore`)

### **What MOVES** 📦
- **To `explorations/`**: bmad-ide, lifeplan-ai, marketing (3 items)
- **To `research/`**: bmadv6, langchain, langgraph, superpowers, wizard-v2, info content (8 items)

### **What GETS DELETED** 🗑️
- `info/` folder (after moving content to research/references/)
- `CLAUDE.md.backup` (optional - can move to archive/ if you want)

### **Git Impact**
- ✅ Symlinks NOT affected (`.bmad-core/` and `.claude/commands/` stay at root)
- ✅ Projects NOT affected (still in `projects/`)
- ✅ Scripts NOT affected (still in `scripts/`)
- ✅ Git tracks moves (preserves history with `git mv`)

### **Workflow Impact**
- ✅ **Zero impact** on active development (framework files stay at root)
- ✅ **Easier navigation** (grouped by purpose)
- ✅ **Cleaner mental model** (know where to put new items)

---

## Rollback Plan

**If you don't like the new structure**, easy rollback:

```powershell
# Move everything back
Move-Item -Path "explorations\*" -Destination "."
Move-Item -Path "research\frameworks\*" -Destination "."
Move-Item -Path "research\plugins\*" -Destination "."

# Recreate info folder
New-Item -Path "info" -ItemType Directory
Move-Item -Path "research\references\playwright\*" -Destination "info\"
Move-Item -Path "research\references\hdav2\hdav2docs" -Destination "info\"

# Remove new directories
Remove-Item -Path "explorations", "research", "archive" -Recurse

# Git rollback
git reset --hard HEAD~1
```

---

## Recommendations

### **Phase 1: Immediate** (This session)
1. ✅ Review this plan
2. ✅ Approve or request modifications
3. ✅ Execute migration (manual or script)
4. ✅ Verify everything works
5. ✅ Commit with descriptive message

### **Phase 2: Validate** (Next 1-2 days)
1. ⏳ Work with new structure for a few days
2. ⏳ Adjust if needed (easy to move items between categories)
3. ⏳ Update CLAUDE.md if referencing specific paths

### **Phase 3: Maintain** (Ongoing)
- **New explorations** → `explorations/`
- **New research materials** → `research/` (appropriate subcategory)
- **Completed explorations** → Either promote to production OR archive
- **Deprecated research** → `archive/`

---

## Questions for User

1. **Category Names**: Do you like "explorations" or prefer different name? (e.g., "labs", "experiments", "incubator")
2. **Marketing Placement**: Is `marketing/` an exploration (active work) or should it go elsewhere?
3. **LifePlan AI**: You mentioned being "very happy with it" - should it stay in explorations or get promoted somewhere special?
4. **CLAUDE.md.backup**: Keep or delete? (backup exists, main file is up-to-date)
5. **Migration Timing**: Execute now or wait?
6. **Script vs Manual**: Prefer automated script or manual commands?

---

## Alternative Structures (If you prefer different naming)

### **Option 2: Simple Categories**
```
mydevwf/
├── _core/              # Framework files (move .bmad-core, .claude here)
├── _production/        # docs, projects, templates, scripts
├── _active/            # bmad-ide, lifeplan-ai, marketing
├── _research/          # All research materials
└── _archive/           # Completed/inactive
```

### **Option 3: Prefix-Based** (Single-level)
```
mydevwf/
├── 00-framework/       # .bmad-core, .claude, configs
├── 01-production/      # docs, projects, templates
├── 02-explorations/    # Active projects
├── 03-research/        # Reference materials
└── 99-archive/         # Inactive
```

---

## Decision Required

**Please indicate**:
1. ✅ **Approve** proposed structure (proceed with migration)
2. 🔄 **Modify** (suggest changes to category names or grouping)
3. ⏸️ **Defer** (wait for better time)
4. ❌ **Reject** (stay with current structure)

If approved, I can execute the migration immediately (manual commands or automated script).

---

**Document Status**: ✅ READY FOR REVIEW
**Created**: 2025-11-14
**Next Step**: Await user decision
