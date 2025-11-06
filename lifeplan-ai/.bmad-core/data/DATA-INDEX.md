# Data Directory Index

**Last Updated**: 2025-10-28
**Purpose**: Quick reference guide for all files in `.bmad-core/data/`
**Total Files**: 9

---

## File Overview

| File | Size | Purpose | Primary Users |
|------|------|---------|---------------|
| bmad-kb.md | 32K | Complete BMad knowledge base | All agents, all workflows |
| brainstorming-techniques.md | 1.9K | 20 brainstorming techniques | analyst, bmad-master |
| documentation-standards.md | 13K | Documentation quality standards | sm, qa, dev |
| elicitation-methods.md | 5.0K | Content refinement methods | bmad-master, bmad-orchestrator |
| handoff-templates.md | 20K | QA/Dev/Completion handoff formats | dev, qa (implicit) |
| technical-preferences.md | 97B | User's custom tech stack preferences | architect, pm, ux-expert, qa |
| testing-stack-guide.md | 28K | Vitest + Playwright MCP testing workflow | dev, qa, sm (via create-next-story) |
| test-levels-framework.md | 9.5K | Testing framework selection guide | qa (via test-design) |
| test-priorities-matrix.md | 3.9K | Test scenario prioritization (P0-P3) | qa (via test-design) |

---

## Detailed File Documentation

### 1. bmad-kb.md

**Size**: 32K (810 lines)
**Purpose**: Complete BMad knowledge base and system overview

**Content**:
- BMad framework overview and philosophy
- Getting started guide (Web UI + IDE installation)
- Core configuration (core-config.yaml) documentation
- All 10 agents descriptions and usage
- Complete development workflows (greenfield/brownfield)
- Vibe CEO philosophy and core principles
- Document creation best practices
- Expansion packs documentation

**Used By**:
- **Agents**: analyst, bmad-master, bmad-orchestrator
- **Workflows**: All 6 workflows (greenfield-fullstack, greenfield-service, greenfield-ui, brownfield-fullstack, brownfield-service, brownfield-ui)

**When Loaded**: Planning phase, system orientation, workflow guidance

**Key Sections**:
- How BMad Works (Two-Phase Approach: Web UI → IDE)
- SM → Dev → QA development loop
- Agent system overview and selection
- Team configurations
- Complete workflow sequences

---

### 2. brainstorming-techniques.md

**Size**: 1.9K (39 lines)
**Purpose**: 20 interactive brainstorming techniques for creative exploration

**Content**:
- Creative Expansion (What If, Analogical Thinking, Reversal, First Principles)
- Structured Frameworks (SCAMPER, Six Thinking Hats, Mind Mapping)
- Collaborative Techniques (Yes And, Brainwriting, Random Stimulation)
- Deep Exploration (Five Whys, Morphological Analysis, Provocation)
- Advanced Techniques (Forced Relationships, Assumption Reversal, Role Playing, Time Shifting, Resource Constraints, Metaphor Mapping, Question Storming)

**Used By**:
- **Agents**: analyst, bmad-master
- **Tasks**: Implicitly used during brainstorming and ideation phases

**When Loaded**: Requirements gathering, feature brainstorming, problem-solving sessions

**Usage Pattern**: Agent presents one technique at a time, waits for user response, then iterates

---

### 3. documentation-standards.md

**Size**: 13K (488 lines)
**Purpose**: Documentation quality standards and best practices for all BMad agents

**Content**:
- Core documentation principles (clarity, completeness, accuracy, maintainability)
- Technical writing style guide
- Code documentation standards
- PRD and architecture documentation guidelines
- User story documentation format
- Testing documentation requirements
- Technical preferences integration
- Version control and maintenance guidelines

**Used By**:
- **Agents**: sm (story creation), qa (review), dev (implementation)
- **Referenced By**: All planning agents implicitly

**When Loaded**: Story creation, documentation review, quality gates

**Key Standards**:
- Story timestamp protocol (YYYY-MM-DD HH:MM:SS)
- Story file naming (v3: `docs/stories/{epic}.{story}.story.md`)
- Testing documentation format (E2E scenarios in markdown)
- QA Handoff template structure
- Developer Handoff format

---

### 4. elicitation-methods.md

**Size**: 5.0K (157 lines)
**Purpose**: Advanced methods for refining and improving content through structured interaction

**Content**:
- **Core Reflective Methods**: Expand/Contract, Explain Reasoning (CoT), Critique & Refine
- **Structural Analysis**: Logical Flow, Goal Alignment
- **Risk and Challenge**: Risk Identification, Critical Perspective, YAGNI
- **Creative Exploration**: Tree of Thoughts, Hindsight Reflection
- **Multi-Persona Collaboration**: Agile Team Perspective, Stakeholder Round Table, Meta-Prompting
- **Advanced 2025 Techniques**: Self-Consistency, ReWOO, Persona-Pattern Hybrid, Emergent Collaboration
- **Game-Based Methods**: Red Team vs Blue Team, Innovation Tournament, Escape Room Challenge

**Used By**:
- **Agents**: bmad-master, bmad-orchestrator
- **Tasks**: Referenced in advanced-elicitation.md task (if implemented)

**When Loaded**: Document refinement, quality assurance, multi-perspective analysis

**Usage Pattern**: Select method based on refinement goal, apply interactively with user

---

### 5. handoff-templates.md

**Size**: 20K (688 lines)
**Purpose**: Structured handoff templates for Dev→QA and QA→Completion transitions

**Content**:

**QA Handoff Template**:
- Story reference and completion summary
- File list (all changed files)
- Background processes (ports, URLs, credentials)
- Testing scope (unit tests, E2E scenarios locations)
- Known issues and caveats
- Next steps for QA

**Developer Handoff Template**:
- QA findings summary
- Issues found (severity, location, description)
- Refactoring performed
- Files modified by QA
- Re-test instructions
- Next steps for Dev

**Completion Handoff Template**:
- Story completion confirmation
- Test results summary (Vitest + E2E)
- Quality metrics and evidence
- Production readiness checklist
- Deployment considerations

**Used By**:
- **Agents**: dev (creates QA Handoff), qa (creates Developer Handoff or Completion Handoff)
- **Tasks**: Implicitly used in review-story.md workflow

**When Loaded**: End of Dev implementation, end of QA review

**⚠️ NOTE**: No direct references found in agent files - should be explicitly referenced by dev and qa agents

---

### 6. technical-preferences.md

**Size**: 97 bytes (6 lines)
**Purpose**: User's custom technical preferences and tech stack patterns

**Content**: Currently empty ("None Listed")

**Used By**:
- **Agents**: architect, pm, ux-expert, qa, bmad-master
- **Tasks**: review-story, nfr-assess
- **Referenced In**: documentation-standards.md, bmad-kb.md

**When Loaded**: Architecture design, technology selection, tech stack validation

**Purpose**:
- Ensures consistency across all agents and projects
- Eliminates repetitive technology specification
- Provides personalized recommendations aligned with user preferences
- Evolves over time with lessons learned

**Expected Content Examples**:
```yaml
frontend:
  framework: Next.js 14 (App Router)
  styling: Tailwind CSS + shadcn/ui
  state: Zustand

backend:
  framework: Node.js + Express
  database: PostgreSQL
  orm: Prisma

testing:
  unit: Vitest
  e2e: Playwright MCP
```

---

### 7. testing-stack-guide.md

**Size**: 28K (865 lines)
**Purpose**: Comprehensive testing workflow with Vitest + Playwright MCP hybrid approach

**Content**:

**Testing Strategy**:
- Vitest: ONLY for complex logic with 10+ edge cases
- Playwright MCP: ALL user journeys via 26 interactive browser control tools
- Jest: ELIMINATED ENTIRELY
- Two-Terminal Workflow: Dev implements → QA executes

**Test Scenario Format**:
- Markdown format with TC{AC}.{case} numbering
- Location: `docs/qa/e2e/sprint-N/epics/epic-N/story-N/`
- Priority levels: P0 (critical) → P3 (low)

**Playwright MCP Workflow**:
- 26 interactive browser control tools
- Navigation: browser_navigate, browser_navigate_back/forward
- Inspection: browser_snapshot, browser_console_messages, browser_take_screenshot
- Interaction: browser_click, browser_type, browser_fill_form, etc.

**Dev Workflow**:
1. Implements feature
2. IF complex logic (10+ edge cases) → Writes Vitest tests
3. Writes E2E test scenarios (markdown)
4. Starts background processes
5. Outputs QA Handoff
6. HALT (does NOT run tests)

**QA Workflow**:
1. Reads QA Handoff
2. IF Vitest exists → Runs `npm run test` FIRST
3. Reads E2E scenarios from markdown
4. Executes scenarios using Playwright MCP tools interactively
5. Observes results, decides PASS/FAIL manually

**Used By**:
- **Agents**: dev, qa
- **Tasks**: create-next-story (line 51), review-story (section 4), test-design (section 2.5)
- **Templates**: All 4 architecture templates (fullstack, backend, frontend, brownfield)
- **Configuration**: core-config.yaml devLoadAlwaysFiles

**When Loaded**: Dev agent activation (always), story creation, test planning, architecture design

**Critical Rules**:
- Dev writes tests but does NOT run them (QA's responsibility)
- E2E tests are markdown scenarios, NOT .spec.ts files
- QA runs Vitest FIRST, then E2E
- Context7 usage: Add "use context7" for latest Vitest/Playwright patterns

---

### 8. test-levels-framework.md

**Size**: 9.5K (257 lines)
**Purpose**: Testing framework selection guide by platform and requirements

**Content**:

**Framework Selection by Platform**:
- **Web Applications**: Vitest (selective) + Playwright MCP (E2E)
- **Mobile Applications**: Jest + Detox (React Native)
- **Desktop Applications**: Vitest + Playwright
- **Backend APIs**: Vitest + Supertest
- **Microservices**: Vitest + Contract Testing (Pact)

**Test Levels**:
- **Unit Tests**: Pure functions, business logic, utilities
- **Integration Tests**: Database, APIs, external services
- **E2E Tests**: Complete user journeys, workflows
- **Contract Tests**: API contracts, service boundaries

**Tool Recommendations**:
- Unit: Vitest (web), Jest (mobile)
- Integration: Vitest + testing libraries, Docker Compose
- E2E: Playwright MCP (web), Detox (mobile), Playwright (desktop)
- Contract: Pact, OpenAPI validation

**Decision Matrix**:
- Use Vitest: Complex logic with 10+ edge cases
- Use E2E only: Simple CRUD, UI components, < 10 edge cases
- Use Both: Complex calculations (Vitest) + workflow (E2E)

**MCP-Enhanced Testing Workflow**:
- Playwright MCP: 26 interactive browser control tools
- Dev writes markdown scenarios
- QA executes interactively
- Manual observation and validation

**Used By**:
- **Agents**: qa
- **Tasks**: test-design.md (section 2.5)

**When Loaded**: Test planning, test design phase, testing strategy definition

---

### 9. test-priorities-matrix.md

**Size**: 3.9K (175 lines)
**Purpose**: Priority matrix for test scenario prioritization (P0-P3)

**Content**:

**Priority Levels**:
- **P0 - Critical (Must Test)**: Revenue-impacting, security-critical, data integrity, compliance, regression prevention
- **P1 - High (Should Test)**: Core user journeys, frequently used features, complex logic, integration points
- **P2 - Medium (Nice to Test)**: Secondary features, admin functionality, reporting, configuration
- **P3 - Low (Test if Time Permits)**: Rarely used features, nice-to-have, cosmetic issues

**Test Coverage by Priority**:
| Priority | Unit Coverage | Integration Coverage | E2E Coverage |
|----------|---------------|---------------------|--------------|
| P0 | >90% | >80% | All critical paths |
| P1 | >80% | >60% | Main happy paths |
| P2 | >60% | >40% | Smoke tests |
| P3 | Best effort | Best effort | Manual only |

**Priority Assignment Rules**:
1. Start with business impact (What happens if this fails?)
2. Consider probability (How likely is failure?)
3. Factor in detectability (Would we know if it failed?)
4. Account for recoverability (Can we fix it quickly?)

**Risk-Based Adjustments**:
- **Increase Priority**: High user impact, financial impact, security vulnerability, compliance requirements, complex implementation
- **Decrease Priority**: Feature flag protected, gradual rollout, strong monitoring, easy rollback

**Test Execution Order**:
1. Execute P0 tests first (fail fast on critical issues)
2. Execute P1 tests second (core functionality)
3. Execute P2 tests if time permits
4. P3 tests only in full regression cycles

**Used By**:
- **Agents**: qa
- **Tasks**: test-design.md (section 3)

**When Loaded**: Test planning, test scenario prioritization, test execution planning

---

## Usage Patterns

### By Agent

**Analyst**: bmad-kb.md, brainstorming-techniques.md
**PM**: bmad-kb.md, technical-preferences.md
**Architect**: bmad-kb.md, technical-preferences.md
**UX Expert**: technical-preferences.md
**PO**: (none directly referenced)
**SM**: documentation-standards.md, testing-stack-guide.md (via create-next-story)
**Dev**: documentation-standards.md, testing-stack-guide.md, handoff-templates.md (implicit)
**QA**: documentation-standards.md, technical-preferences.md, testing-stack-guide.md, handoff-templates.md (implicit), test-levels-framework.md, test-priorities-matrix.md
**bmad-master**: bmad-kb.md, brainstorming-techniques.md, elicitation-methods.md, technical-preferences.md
**bmad-orchestrator**: bmad-kb.md, elicitation-methods.md

### By Task

**create-next-story.md**: testing-stack-guide.md
**review-story.md**: technical-preferences.md, testing-stack-guide.md
**test-design.md**: testing-stack-guide.md, test-levels-framework.md, test-priorities-matrix.md
**nfr-assess.md**: technical-preferences.md

### By Workflow Phase

**Planning Phase**: bmad-kb.md, brainstorming-techniques.md, technical-preferences.md, elicitation-methods.md
**Architecture Phase**: technical-preferences.md, testing-stack-guide.md (via templates)
**Story Creation Phase**: documentation-standards.md, testing-stack-guide.md
**Implementation Phase**: documentation-standards.md, testing-stack-guide.md, handoff-templates.md
**Testing Phase**: testing-stack-guide.md, test-levels-framework.md, test-priorities-matrix.md, handoff-templates.md

---

## Integration Points

### Core Configuration
- **testing-stack-guide.md**: Included in `core-config.yaml` devLoadAlwaysFiles (Dev agent loads automatically)
- **technical-preferences.md**: Referenced by multiple agents for tech stack consistency

### Architecture Templates
All 4 architecture templates reference **testing-stack-guide.md**:
- fullstack-architecture-tmpl.yaml
- architecture-tmpl.yaml (backend)
- front-end-architecture-tmpl.yaml
- brownfield-architecture-tmpl.yaml

### Critical Workflows
- **SM → Create Story**: Loads testing-stack-guide.md via create-next-story task
- **Dev → Implement**: Loads testing-stack-guide.md from core-config.yaml, uses handoff-templates.md
- **QA → Review**: Uses testing-stack-guide.md, test-levels-framework.md, test-priorities-matrix.md, handoff-templates.md

---

## Maintenance Notes

### Recently Updated Files (Phase 1 & 2 Optimizations)
- ✅ **testing-stack-guide.md**: Updated with Vitest + Playwright MCP hybrid workflow (2025-10-28)
- ✅ **test-levels-framework.md**: Added comprehensive framework selection and MCP workflow (2025-10-28)
- ✅ **handoff-templates.md**: Added during workflow optimization (2025-10-28)
- ✅ **documentation-standards.md**: Enhanced with testing documentation requirements (2025-10-28)

### Files Needing Attention
- ⚠️ **handoff-templates.md**: No direct references found - should be explicitly referenced by dev.md and qa.md
- ⚠️ **technical-preferences.md**: Currently empty - should be populated with user's tech stack preferences

### Orphaned References
None found. All data files are properly integrated into the system.

---

## Quick Reference Commands

**View all data files**:
```bash
ls -lh .bmad-core/data/
```

**Search for data file references**:
```bash
grep -r "filename.md" .bmad-core/
```

**Check which agents use a data file**:
```bash
grep -l "filename.md" .bmad-core/agents/*.md
```

**Verify data file exists before referencing**:
```bash
test -f .bmad-core/data/filename.md && echo "EXISTS" || echo "MISSING"
```

---

**Phase 3 Data Directory Audit: COMPLETE ✅**
**System Status**: All 9 data files verified and documented
**Next Phase**: Phase 4 - Integration Testing
