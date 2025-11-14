# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **BMad Method v6 Alpha** framework - a modular AI-driven development system providing specialized agents, workflows, and tools for software development.

**Version**: 6.0.0-alpha.6
**Architecture**: Modular framework with four core modules (Core, BMM, BMB, CIS)

### Directory Structure

```
bmadv6/
├── bmad/                    # Framework root
│   ├── core/               # Core module (party-mode, brainstorming, base config)
│   ├── bmm/                # BMad Method Module (12 agents, 52 workflows)
│   ├── bmb/                # BMad Builder Module (agent/workflow/module creation)
│   ├── cis/                # Creative Intelligence Suite (5 creative agents)
│   ├── _cfg/               # Customization layer (update-safe modifications)
│   └── docs/               # Framework documentation
├── .claude/
│   ├── agents/             # (Reserved for future use)
│   └── commands/bmad/      # 67 slash commands (agents + workflows)
└── docs/
    └── stories/            # Project stories (if initialized)
```

## Core Architecture

### Module System

BMad v6 uses a **modular architecture** where each module provides:

- **Agents** (`.md` files in `.claude/commands/bmad/{module}/agents/`)
- **Workflows** (`workflow.yaml` + instructions.md + templates)
- **Configuration** (`config.yaml` in module root)
- **Customization** (`_cfg/` directory for update-safe modifications)

**Four Modules:**

1. **Core** - Base framework (party-mode, brainstorming, orchestration)
2. **BMM (BMad Method Module)** - Full development lifecycle (PM, Architect, DEV, TEA, SM, etc.)
3. **BMB (BMad Builder)** - Create/edit agents, workflows, and modules
4. **CIS (Creative Intelligence Suite)** - Creative facilitation (storytelling, design thinking, problem solving)

### Agent Activation System

Agents are activated via **slash commands** in Claude Code:

```
/bmad:bmm:agents:dev           # Developer agent
/bmad:bmm:agents:architect     # Architect agent
/bmad:bmm:workflows:dev-story  # Dev-story workflow
/bmad:bmb:agents:bmad-builder  # BMad Builder agent
```

**Agent Structure:**
- Frontmatter with name/description
- XML-based persona with activation steps
- Menu system with numbered items
- Workflow integration via `workflow.yaml` paths

### Workflow Execution Engine

Workflows are executed through `bmad/core/tasks/workflow.xml` (the "workflow OS"):

1. Agent menu item triggers workflow via `workflow="path/to/workflow.yaml"`
2. Workflow handler loads `workflow.xml`
3. Workflow engine reads `workflow.yaml` configuration
4. Engine executes steps from `instructions.md`
5. Uses templates from `template.md` (if present)

**Workflow Components:**
- `workflow.yaml` - Configuration, variables, step definitions
- `instructions.md` - Step-by-step execution logic
- `template.md` - Output templates (optional)
- `checklist.md` - Validation checklists (optional)

## Configuration System

### Module Configurations

**Core Config** (`bmad/core/config.yaml`):
```yaml
user_name: Anjai
communication_language: English
document_output_language: English
output_folder: '{project-root}/docs'
```

**BMM Config** (`bmad/bmm/config.yaml`):
```yaml
project_name: bmadv6
include_game_planning: true
user_skill_level: intermediate
tech_docs: '{project-root}/docs'
dev_story_location: '{project-root}/docs/stories'
tea_use_mcp_enhancements: true
```

**Configuration Priority:**
1. Module config inherits from Core config
2. Module-specific settings override core settings
3. `_cfg/` customizations override defaults

### Variable Interpolation

All configs support variable interpolation:
- `{project-root}` - Absolute project path
- `{user_name}` - From config
- `{communication_language}` - From config

## Key Agents (BMM Module)

### Development Lifecycle Agents

- **Analyst (Mary)** - Workflow initialization, brainstorming, product briefs
- **PM (John)** - PRD creation, tech-specs, epic breakdown
- **Architect (Sarah)** - System architecture, technical decisions
- **UX Designer (Elena)** - UX specifications, design artifacts
- **SM (Bob)** - Sprint planning, story creation, retrospectives
- **DEV (Amelia)** - Story implementation, code review
- **TEA (Quinn)** - Test architecture, quality gates, validation

### Game Development Agents

- **Game Designer** - Game mechanics, GDD creation
- **Game Developer** - Game implementation
- **Game Architect** - Game system architecture

### Meta Agent

- **BMad Master** (from Core) - Multi-role orchestrator

## Development Workflows (BMM)

### Phase 1: Analysis (Optional)
- `workflow-init` - Initialize workflow tracking
- `brainstorm-project` / `brainstorm-game` - Creative ideation
- `research` - Market/technical research
- `product-brief` / `game-brief` - Strategic planning

### Phase 2: Planning (Required)
- `prd` - Product Requirements Document (BMad Method/Enterprise tracks)
- `tech-spec` - Technical specification (Quick Flow track)
- `gdd` / `narrative` - Game design documents
- `create-ux-design` - UX specifications
- `create-epics-and-stories` - Break down requirements

### Phase 3: Solutioning (Track-Dependent)
- `architecture` - System design
- `solutioning-gate-check` - Validate planning cohesion

### Phase 4: Implementation (Iterative)
- `sprint-planning` - Initialize sprint tracking
- `epic-tech-context` - Epic-level technical context
- `create-story` - Draft next story
- `story-context` - Story-level technical context
- `dev-story` - Implement story
- `code-review` - Quality validation
- `story-ready` / `story-done` - Status updates
- `retrospective` - Epic completion review
- `correct-course` - Handle scope changes

### Testing Workflows
- `test-design` - Test strategy
- `trace` - Coverage validation
- `nfr-assess` - Non-functional requirements
- `atdd` - Acceptance test planning
- `framework` / `automate` / `ci` - Test infrastructure

## Builder Workflows (BMB)

### Creation
- `create-agent` - Build new agents with persona development
- `create-workflow` - Design multi-step workflows
- `create-module` - Complete module infrastructure
- `module-brief` - Strategic module planning

### Editing
- `edit-agent` - Modify existing agents
- `edit-workflow` - Update workflows
- `edit-module` - Module enhancement

### Maintenance
- `convert-legacy` - Migrate v4 to v6 format
- `audit-workflow` - Quality validation
- `redoc` - Auto-documentation generation

## Creative Workflows (CIS)

- `brainstorming` - 36 ideation techniques
- `design-thinking` - 5-phase human-centered design
- `problem-solving` - Root cause analysis
- `innovation-strategy` - Business model disruption
- `storytelling` - 25 narrative frameworks

## Customization System

### Update-Safe Customization

Edit files in `bmad/_cfg/` to override defaults:

**Agent Customization:**
- `bmad/_cfg/agents/{agent-name}.customize.yaml` - Override persona, commands, workflows

**IDE Customization:**
- `bmad/_cfg/ides/{ide-name}/` - IDE-specific configurations

**Manifests:**
- `agent-manifest.csv` - Agent registry
- `workflow-manifest.csv` - Workflow registry
- `files-manifest.csv` - File tracking

### Custom Slash Commands

To add custom commands:
1. Create `.md` file in `.claude/commands/bmad/{module}/{type}/`
2. Follow agent/workflow structure conventions
3. Update `_cfg/` manifests if needed

## Common Development Tasks

### Working on the Framework

**Edit an existing agent:**
```bash
# Load BMad Builder agent
/bmad:bmb:agents:bmad-builder

# Then tell it:
*edit-agent
```

**Create a new workflow:**
```bash
# Load BMad Builder agent
/bmad:bmb:agents:bmad-builder

# Then tell it:
*create-workflow
```

**Generate documentation:**
```bash
# Load BMad Builder agent
/bmad:bmb:agents:bmad-builder

# Then tell it:
*redoc
```

### Testing Changes

After modifying agents/workflows:

1. **Reload slash commands** - Restart Claude Code or refresh command palette
2. **Test activation** - Load agent via slash command
3. **Verify menu** - Check numbered menu displays correctly
4. **Test workflow** - Execute workflow and validate output
5. **Check config loading** - Ensure config.yaml loads at startup

### Manifest Updates

When adding/removing components:

1. **Update CSV manifests** in `bmad/_cfg/`
   - `agent-manifest.csv` - Agent changes
   - `workflow-manifest.csv` - Workflow changes
   - `files-manifest.csv` - File additions/removals
2. **Update `manifest.yaml`** - Version and timestamp

## File Naming Conventions

### Agents
- Source: `bmad/{module}/agents/{name}.yaml` (YAML source, compiled to .md)
- Compiled: `.claude/commands/bmad/{module}/agents/{name}.md`
- Customization: `bmad/_cfg/agents/{module}-{name}.customize.yaml`

### Workflows
- Config: `bmad/{module}/workflows/{category}/{name}/workflow.yaml`
- Instructions: `bmad/{module}/workflows/{category}/{name}/instructions.md`
- Template: `bmad/{module}/workflows/{category}/{name}/template.md`
- Compiled: `.claude/commands/bmad/{module}/workflows/{name}.md`

### Documentation
- Module docs: `bmad/{module}/docs/`
- Framework docs: `bmad/docs/`
- Project docs: `docs/` (when framework is used in a project)

## Important Notes

1. **Never modify compiled files** in `.claude/commands/` - edit YAML sources instead
2. **Always load config.yaml** - Agents expect config at startup (step 2 of activation)
3. **Use workflow.xml** - All workflows execute through `bmad/core/tasks/workflow.xml`
4. **Respect customization layer** - User modifications go in `_cfg/`, not module files
5. **Follow XML structure** - Agents use XML-based persona/activation format
6. **Menu triggers use asterisks** - Display `*develop` not `develop` in menus
7. **Fresh chats for workflows** - Context-intensive workflows need clean slate

## Key Resources

- **BMM User Guide**: `bmad/bmm/docs/README.md` - Complete BMM documentation
- **Quick Start**: `bmad/bmm/docs/quick-start.md` - New user onboarding
- **Agents Guide**: `bmad/bmm/docs/agents-guide.md` - All agent roles and workflows
- **Scale Adaptive System**: `bmad/bmm/docs/scale-adaptive-system.md` - Planning tracks
- **Brownfield Guide**: `bmad/bmm/docs/brownfield-guide.md` - Existing project workflow
- **Builder Docs**: `bmad/bmb/README.md` - Agent/workflow creation
- **CIS Docs**: `bmad/cis/README.md` - Creative facilitation

## Best Practices

### For Framework Development

1. **Study existing patterns** - Review BMM implementations before creating new components
2. **Follow v6 conventions** - Use YAML configs, workflow.xml integration, _cfg customization
3. **Test iteratively** - Validate after each change
4. **Document thoroughly** - Update README files in workflow directories
5. **Use BMad Builder** - Leverage existing creation workflows instead of manual editing

### For Framework Usage

1. **Use workflow-status** - Load any agent and ask "what's next?"
2. **Fresh chats per workflow** - Avoid context exhaustion
3. **Let agents guide** - They know the workflow steps
4. **Track progress** - Status files update automatically
5. **Customize via _cfg** - Don't modify core module files

## Architecture Highlights

### Scale Adaptive System

BMM adapts to project complexity with **three planning tracks**:

- **Quick Flow** - Tech-spec only (bug fixes, simple features)
- **BMad Method** - PRD + Architecture (products, platforms)
- **Enterprise Method** - Extended planning (compliance, security, multi-tenant)

### Story Lifecycle

Stories progress through defined states:
`backlog → drafted → ready → in-progress → review → done`

### Multi-Agent Collaboration

**Party Mode** orchestrates group discussions between all 19+ agents from all modules for strategic decisions and creative brainstorming.

### Context Management

- **Story Context** - Just-in-time implementation context
- **Epic Context** - Technical specification per epic
- **Knowledge Base** - Reusable patterns and integrations

## Community

- **Discord**: https://discord.gg/gk8jAdXWmj (#general-dev, #bugs-issues)
- **GitHub**: https://github.com/bmad-code-org/BMAD-METHOD
- **YouTube**: https://www.youtube.com/@BMadCode

---

**This is a development framework, not a user project.** If you're building software WITH BMad, you'll have a different CLAUDE.md in your project directory with project-specific instructions.
