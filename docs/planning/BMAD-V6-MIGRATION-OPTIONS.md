# BMad V6 Migration Options Analysis

**Document Purpose**: Evaluate upgrade paths from current V4/V5 implementation to BMad V6 Alpha
**Date Created**: 2025-11-02
**Current State**: MyDevWF using `.bmad-core/` (V4/V5 structure)
**Target State**: Align with BMad V6 philosophy and architecture

---

## Executive Summary

After analyzing the BMad V6 Alpha installation in `facebook-ads-workflow/bmad/`, this document presents **4 migration options** with detailed pros/cons, effort estimates, and risk assessments.

### Quick Comparison

| Option | Timeline | Risk | Impact | Best For |
|--------|----------|------|--------|----------|
| **A. Full Migration** | 2-3 weeks | Medium | High | Long-term alignment |
| **B. Hybrid Approach** | 1-2 weeks | Low | Medium | Gradual transition |
| **C. V6 for New Only** | 1 week | Low | Low | Zero disruption |
| **D. Status Quo Enhanced** | 1-2 days | Very Low | Minimal | Immediate productivity |

**Recommended**: **Option B (Hybrid Approach)** - Best balance of modernization and stability.

---

## Current State Analysis

### V4/V5 Architecture (.bmad-core/)

**Structure**:
```
.bmad-core/
├── agents/              # Markdown files with YAML blocks (10 agents)
├── tasks/               # Markdown execution workflows (23 tasks)
├── templates/           # YAML document generators (13 templates)
├── checklists/          # Validation checklists (6 checklists)
├── data/                # Reference data (9 data files)
└── workflows/           # High-level workflow docs
```

**Agent Format** (V4):
```yaml
# agents/dev.md
agent:
  name: James
  id: dev
  title: Full Stack Developer
  icon: 💻

persona:
  role: Expert Senior Software Engineer
  style: Pragmatic, detail-oriented

commands:
  - help: Show command list
  - develop-story: Implement story tasks
  - explain: Teach what and why

dependencies:
  tasks:
    - apply-qa-fixes.md
    - execute-checklist.md
```

**Strengths**:
- ✅ **Proven workflow** - Validated across multiple projects
- ✅ **MCP integration** - Context7, shadcn-ui, Supabase/MongoDB, Swagger
- ✅ **Knowledge Base** - Recently implemented living documentation
- ✅ **Testing Stack** - Optimized Vitest + Playwright MCP hybrid
- ✅ **Complete documentation** - CLAUDE.md, session logs, architecture
- ✅ **Working project templates** - 4 production-ready stacks

**Limitations**:
- ❌ **Not modular** - Single `.bmad-core/` folder, hard to extend
- ❌ **Update challenges** - Framework updates require careful merging
- ❌ **No separation** - Core vs customizations mixed
- ❌ **Legacy format** - YAML-in-markdown vs V6 XML

---

## V6 Architecture Analysis

### V6 Structure (bmad/)

**Structure**:
```
bmad/
├── core/                # Core framework (agents, tasks, tools)
├── bmb/                 # BMad Builder (BOMB) - creation tools
├── bmm/                 # BMad Method - agile workflows
├── cis/                 # Creative Intelligence Suite
├── _cfg/                # Update-safe customizations
│   ├── agents/          # Custom agent overrides
│   ├── ides/            # IDE-specific configs
│   └── manifest.yaml    # Customization registry
└── {custom-modules}/    # User-created modules
```

**Agent Format** (V6):
```yaml
# Source: agents/dev.agent.yaml
agent:
  metadata:
    name: James
    id: bmad/bmm/agents/dev
    title: Full Stack Developer
    icon: 💻
    module: bmm

  persona:
    role: Expert Senior Software Engineer
    communication_style: Pragmatic, detail-oriented
    identity: Expert who implements stories
    principles:
      - Follow story requirements exactly
      - Update only Dev Agent Record sections

  menu:
    - trigger: help
      description: Show command list
      action: "#show-commands"

    - trigger: develop-story
      description: Implement story tasks
      workflow: "{project-root}/bmad/bmm/workflows/4-implementation/dev-story/workflow.yaml"

  prompts:
    - id: show-commands
      content: "Display numbered list of available commands..."
```

**Compiled Output**: `dev.agent.xml` (built from .agent.yaml)

**Key V6 Innovations**:

1. **Module System**: Core framework separate from extensions, each module self-contained
2. **Update-Safe Customizations**: `_cfg/` directory isolates customizations from core
3. **Workflow-Centric**: V4 Tasks → V6 Workflows (folder structure)
4. **BMad Builder (BOMB)**: Automated creation tools (`create-agent`, `create-workflow`, `convert-legacy`)
5. **Web Bundle Support**: Agents as portable XML bundles for web UI

---

## Migration Option A: Full Migration to V6

### Approach

Execute automated V4→V6 conversion using BMad Builder's `convert-legacy` workflow.

### Timeline: 2-3 weeks

**Phase 1**: Setup V6 Installation (2-3 days)
**Phase 2**: Convert Agents (3-4 days) - 10 agents
**Phase 3**: Convert Tasks to Workflows (5-7 days) - 23 tasks
**Phase 4**: Convert Templates to Workflows (3-4 days) - 13 templates
**Phase 5**: Migrate Data and Checklists (1-2 days)
**Phase 6**: Update Project Templates (3-4 days) - 4 templates
**Phase 7**: Update Documentation (2-3 days)
**Phase 8**: Migration Testing (3-5 days)

### Pros

✅ **Full V6 Alignment**: Benefit from all V6 innovations (modules, _cfg/, BOMB tools), future-proof
✅ **Automated Conversion**: `convert-legacy` workflow handles heavy lifting, reduces errors
✅ **Better Organization**: Module system cleaner than flat structure, clear separation
✅ **Builder Tools**: `create-agent`, `create-workflow`, `audit-workflow` for future work

### Cons

❌ **High Disruption**: All agents/tasks/templates change format, docs rewrite required
❌ **Learning Curve**: Team needs to learn V6 conventions, menu system changes
❌ **Risk of Issues**: Conversion may not be 100% perfect, extensive testing needed
❌ **MCP Integration Unknown**: V6 MCP compatibility not validated
❌ **Time Investment**: 2-3 weeks of dedicated work, delays other projects

---

## Migration Option B: Hybrid Approach ⭐ RECOMMENDED

### Approach

Selectively adopt V6 features while keeping core V4/V5 workflow stable.

### What to Adopt

**1. BMad Builder Tools** (Immediate - 2 days)

Install BMB workflows in `.bmad-core/`:
- Copy `facebook-ads-workflow/bmad/bmb/workflows/` to `.bmad-core/bmb-workflows/`
- Use `create-agent`, `create-workflow`, `create-module` for new items
- Use `audit-workflow` for quality checks

**2. Update-Safe Customizations** (3-4 days)

Create `_cfg/` structure in mydevwf:
```
.bmad-customizations/
├── agents/          # Project-specific agent overrides
├── workflows/       # Custom workflows
├── data/            # Project-specific data
└── manifest.yaml    # Customization registry
```

**3. Workflow Folder Structure for New Items** (Ongoing)

For new tasks: Use V6 workflow structure (workflow.yaml + instructions.md + template.md)
For existing tasks: Keep as-is, gradually convert high-use tasks

### What to Keep (V4/V5)

- Agent Format: Markdown with YAML blocks (works perfectly)
- Existing Tasks/Templates: Current 23 tasks, 13 templates (proven)
- Project Templates: Current template structure (working, low risk)

### Timeline: 1-2 weeks

**Week 1** (3-4 days): Copy BMB workflows, create slash commands, test builder tools
**Week 2** (3-4 days): Create `.bmad-customizations/`, document separation
**Week 3+** (Ongoing): Use V6 workflow structure for new items, gradual conversion

### Pros

✅ **Low Risk**: Core workflow unchanged, only additions, fallback always available
✅ **Immediate Value**: Builder tools improve productivity now, no waiting
✅ **Gradual Learning**: Team learns V6 incrementally, can pause/adjust anytime
✅ **Best of Both**: Keep proven V4 stability, gain V6 builder tools
✅ **MCP Safe**: No changes to MCP integration, Knowledge Base, testing stack

### Cons

❌ **Dual Maintenance**: Both V4 and V6 patterns in codebase, slight cognitive overhead
❌ **Not Full V6**: Don't get module system, web bundle support
❌ **Eventual Conversion**: If full V6 desired later, still need migration

---

## Migration Option C: V6 for New Projects Only

### Approach

Use V4/V5 for existing mydevwf templates, adopt V6 for new project types.

### Strategy

**Keep Current Templates V4**: All 4 existing templates (proven, working)
**Create New V6 Template**: `nextjs-nodejs-supabase-v6` with full V6 architecture
**Facebook Ads Workflow Uses V6**: Already has V6 installation (perfect testing ground)

### Timeline: 1 week

**Week 1** (4-5 days): Create V6 template, configure for Next.js + Supabase, test

### Pros

✅ **Zero Disruption**: Existing templates untouched, current workflow continues
✅ **Safe Experimentation**: Learn V6 in isolated environment, can abandon if problematic
✅ **Future Option**: V6 template available when confident, migration path proven
✅ **Lowest Risk**: Nothing breaks, nothing changes for current work

### Cons

❌ **Fragmentation**: Multiple template versions, confusion about which to use
❌ **No V6 Benefits for Current Work**: Existing projects stay V4
❌ **Learning Delayed**: Team doesn't learn V6 immediately
❌ **Duplicate Effort**: Maintain both V4 and V6 templates

---

## Migration Option D: Status Quo with Enhancements

### Approach

Keep V4/V5 architecture, add targeted improvements from V6 concepts.

### Enhancements

**1. Add Customization Separation** (1-2 days)

Create `.bmad-project/` for project-specific items (similar to V6 `_cfg/`)

**2. Document Builder Patterns** (1 day)

Create guides: `HOW-TO-CREATE-AGENT.md`, `HOW-TO-CREATE-TASK.md`, `HOW-TO-CREATE-TEMPLATE.md`

**3. Improve Knowledge Base Integration** (1 day)

Add `integrations/bmad-patterns/` for workflow patterns

### Timeline: 1-2 days

### Pros

✅ **Minimal Effort**: Few days of work, low complexity, immediate completion
✅ **Zero Risk**: No migration needed, no format changes, nothing breaks
✅ **Keeps Focus**: No distraction from actual work, productivity maintained
✅ **Already Proven**: Current system works, team comfortable

### Cons

❌ **No V6 Benefits**: Miss out on builder tools, module system, web bundles
❌ **Technical Debt**: Legacy format stays legacy, harder to adopt V6 later
❌ **Limited Innovation**: No new capabilities, just organizational tweaks
❌ **Update Challenges Persist**: Framework updates still manual

---

## Recommendation: Option B (Hybrid Approach)

### Rationale

1. **Balanced Risk/Reward**: Gain V6 builder tools (immediate value) + Keep proven V4 stability (low risk)
2. **Addresses Real Pains**: Update-safe customizations solve current problem, builder tools improve productivity
3. **Future-Proof**: Can complete V6 migration later, can stay hybrid indefinitely
4. **Team-Friendly**: Minimal disruption, learn V6 incrementally, no big-bang change

### Implementation Plan

**Phase 1: Builder Tools** (Week 1)
```bash
# 1. Copy BMB workflows
mkdir -p .bmad-core/bmb-workflows
cp -r facebook-ads-workflow/bmad/bmb/workflows/* .bmad-core/bmb-workflows/

# 2. Create slash commands
# /BMad/builder/create-agent
# /BMad/builder/create-workflow
# /BMad/builder/audit-workflow

# 3. Test builder workflows
```

**Phase 2: Customization Structure** (Week 2)
```bash
# 1. Create customization directory
mkdir -p .bmad-customizations/{agents,workflows,data}

# 2. Create manifest
# Document customization tracking

# 3. Update CLAUDE.md with hybrid approach
```

**Phase 3: Incremental Adoption** (Ongoing)
- Use V6 workflow structure for new workflows
- Convert high-use tasks when modifying
- Document patterns in Knowledge Base

---

## Decision Criteria

### Choose Option A (Full V6) If:
- [ ] Long-term V6 alignment is strategic priority
- [ ] Team has 2-3 weeks for focused migration
- [ ] Willing to accept medium-risk conversion
- [ ] Want full V6 benefits (modules, web bundles, BOMB)

### Choose Option B (Hybrid) If:
- [x] **Want V6 benefits without disruption** ← **RECOMMENDED**
- [x] Prefer gradual migration over big-bang
- [x] Need to maintain productivity during transition
- [x] Want to learn V6 incrementally

### Choose Option C (New Only) If:
- [ ] Want to experiment with V6 safely
- [ ] Creating new project type anyway
- [ ] Need V4 stability for existing work
- [ ] Willing to maintain dual systems

### Choose Option D (Enhanced) If:
- [ ] In critical feature sprint (no time for migration)
- [ ] V4 perfectly meets all needs
- [ ] Team extremely limited bandwidth
- [ ] Zero tolerance for any disruption

---

## Next Steps

### For Option B (Hybrid - Recommended)

**Immediate Actions** (Next 2 hours):
1. ✅ Review this document with team/stakeholders
2. ⬜ Decide: Proceed with Hybrid?
3. ⬜ Schedule: Week 1 (Builder Tools), Week 2 (Customizations)

**Week 1 Kickoff** (Day 1):
```bash
# Create branch for hybrid migration
git checkout -b bmad-hybrid-migration

# Copy BMB workflows
mkdir -p .bmad-core/bmb-workflows
cp -r facebook-ads-workflow/bmad/bmb/workflows/* .bmad-core/bmb-workflows/

# Commit
git add .bmad-core/bmb-workflows/
git commit -m "Add BMad Builder (BMB) workflows for hybrid approach"
```

**Success Metrics**:
- [ ] Builder tools functional in 1 week
- [ ] Customization structure documented in 2 weeks
- [ ] First V6 workflow created using builder
- [ ] Team comfortable with hybrid approach

---

## Appendix: Key V6 Concepts

### Agent Architecture
- **Source**: `.agent.yaml` (YAML format, human-editable)
- **Built**: `.agent.xml` (compiled for execution)
- **Menu**: Commands with handlers (workflow, exec, action, etc.)

### Workflow Structure
- `workflow.yaml` - Config, variables, validation
- `instructions.md` - Execution steps (XML tags)
- `template.md` - Document template (optional)

### Module System
- Self-contained functionality
- Own config.yaml
- Agents, workflows, tasks, data
- Can depend on other modules

### Update-Safe Customizations
- `_cfg/` directory
- Manifests track customizations
- Framework updates preserve custom items

---

**Document Status**: ✅ Ready for Review
**Recommendation**: Option B (Hybrid Approach)
**Next Action**: Team decision + Week 1 kickoff
