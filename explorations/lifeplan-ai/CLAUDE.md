# CLAUDE.md - LifePlan AI Project

This file provides guidance to Claude Code when working on **LifePlan AI** - a Personal AI Operating System project.

---

## 🎯 Project Overview

**LifePlan AI** is a Personal AI Operating System that manages digital, emotional, and practical existence through structured files and AI-powered context management across all devices (terminal, mobile, wearables, AR/VR).

**Core Innovation:** "Copy-Tradeable Life Workflows" - Users can import and adapt proven productivity workflows (like copy-trading in finance), with AI personalizing execution to individual contexts.

**Think:** Notion templates × Zapier automation × AI coaching

**Status:** Concept & Analysis Phase (Critical analysis complete, decision pending on Phase 1 MVP)

---

## 📁 Repository Structure

```
lifeplan-ai/
├── CLAUDE.md                    # This file - project context for Claude
├── README.md                    # Project overview
├── .bmad-core/                  # BMad V4 Optimized Framework (for building LifePlan AI)
├── analysis/                    # Business analysis documents
│   └── PERSONAL-AI-OS-CRITICAL-ANALYSIS-2025-11-07.md (30+ pages)
├── concept/                     # Vision documents, architecture designs
├── prototypes/                  # Code experiments, MVPs
├── research/                    # Market research, competitive analysis
└── planning/                    # Strategic planning, roadmaps
```

---

## 🏗️ Meta-Level Context: Using BMad to Build LifePlan AI

**This is a meta-framework situation:**
- We're using **BMad framework** (development workflow methodology)
- To build **LifePlan AI** (life workflow platform)
- Using **Claude Code** (AI-powered development)

**Why this matters:**
1. ✅ **Dog-fooding** - Validates BMad methodology on a real project
2. ✅ **Case study** - LifePlan AI becomes proof that BMad works
3. ✅ **Best practices** - Apply everything we learned from BMad optimization
4. ✅ **Structured approach** - Use agents, workflows, handoffs for LifePlan AI development

---

## 📖 What is BMad Framework? (Essential Context)

**BMad Method** is an AI-driven agile development framework with specialized agents that guide you through the entire software development lifecycle.

### Core Concepts

**Agents** (Specialized AI personas):
- **PM** - Creates Product Requirements Documents (PRDs)
- **Architect** - Designs system architecture
- **UX Expert** - Creates UI/UX specifications
- **SM** (Scrum Master) - Creates stories from epics
- **Dev** - Implements features and writes tests
- **QA** - Reviews code quality, runs tests, validates
- **Orchestrator** - Coordinates multi-terminal workflows (planning + research)
- **PO** (Product Owner) - Validates documents, manages sharding

**Workflows** (Structured processes):
- Planning Phase: Product Brief → PRD → Architecture → UX Design
- Implementation Phase: Epic → Stories → Development → QA → Commit
- Quality Gates: Test design, NFR assessment, code review

**Key Files You'll See:**
- `.bmad-core/agents/` - Agent definitions
- `.bmad-core/workflows/` - Workflow templates
- `.bmad-core/data/` - Handoff templates, testing guides, standards
- `.bmad-core/checklists/` - Story DoD, QA checklists

### BMad Lifecycle for a Project

**Phase 1: Planning** (Web UI, large context)
1. Analyst → Product Brief
2. PM → PRD (Product Requirements Document)
3. Architect → Architecture Document
4. UX Expert → UX Design (if UI-heavy)
5. PO → Validates all documents

**Phase 2: Implementation** (IDE, focused context)
1. SM → Creates stories from epics
2. Dev → Implements story, writes tests
3. QA → Validates, creates quality gates
4. Repeat for each story

**Phase 3: Deployment**
- QA validates all quality gates
- Deploy to production

---

## 🚀 Our BMad V4 Optimizations (CRITICAL CONTEXT)

We've heavily customized BMad V4 with several innovative optimizations. **These should be applied to LifePlan AI development.**

### 1. Testing Strategy: Vitest + Playwright MCP Hybrid

**Decision:**
- ✅ **Vitest** - ONLY for complex logic with 10+ edge cases (algorithms, validation)
- ✅ **Playwright MCP** - ALL user journeys via 26 interactive browser control tools
- ❌ **Jest** - ELIMINATED (replaced by Vitest)

**Why:** Vitest is fast for pure functions. Playwright MCP = real-world testing with human observation, no test code maintenance.

**Workflow:**
1. Dev writes feature + Vitest tests (if complex logic) + E2E scenarios (markdown)
2. Dev starts background processes, outputs QA Handoff, HALTS
3. QA runs Vitest FIRST, then E2E via Playwright MCP tools
4. QA manually observes, captures screenshots/console logs, decides PASS/FAIL

**Reference:** `.bmad-core/data/testing-stack-guide.md`

### 2. Dual-Format Handoff System

**Innovation:** All handoffs create TWO outputs:
1. **Detailed Document** - Permanent record with comprehensive context
   - Location: `docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-{type}-handoff.md`
2. **Compact Snippet** - Terminal output (10-15 lines) with document reference

**Five Handoff Types:**
- **Story Handoff** (Orchestrator → Dev) - Story path, scope, research, Context7 findings
- **QA Handoff** (Dev → QA) - Tasks done, files, tests, process URLs + PIDs
- **Developer Handoff** (QA → Dev) - Issues found, evidence, fixes
- **Completion Handoff** (QA → Dev) - Test results, approval, commit message
- **Test Review Handoff** (Orchestrator → QA/Dev) - Coverage status

**Reference:** `.bmad-core/data/handoff-templates.md`

### 3. Three-Terminal Workflow (Advanced)

**Separates work across three specialized terminals:**
- **Orchestrator Terminal** - Epic planning, Context7 research, story creation, test vetting
- **Dev Terminal** - Story implementation, test writing, background processes
- **QA Terminal** - Test execution, quality gates, evidence collection

**When to use:**
- Complex features requiring research
- High-stakes features (payment, auth, data integrity)
- Learning phase (establish quality standards)

**Reference:** `.bmad-core/data/three-terminal-workflow.md`

### 4. Context7 MCP Integration

**All planning agents use Context7 MCP for real-time documentation:**
- Prevents deprecated code patterns
- Ensures current best practices
- Usage: Add "use context7 - {question}" to prompts when researching

**Critical for LifePlan AI:** Always check latest library docs before implementing.

### 5. Hierarchical Folder Structures

**We don't shard PRD/Architecture anymore** (200k context models can handle full docs):
- ✅ Single `docs/PRD.md` with Epic sections
- ✅ Single `docs/Architecture.md` with clear sections
- ✅ Separate story files: `docs/stories/{epic}.{story}.story.md`

**Why:** Continuity is critical for planning documents. Cross-epic references need unified context.

### 6. Document Locations (from core-config.yaml)

```yaml
PRD: docs/prd.md
Architecture: docs/architecture.md
Stories: docs/stories/
QA Assessments: docs/qa/assessments/
QA Gates: docs/qa/gates/
Handoffs: docs/handoffs/
E2E Test Scenarios: docs/qa/e2e/
```

---

## 🔍 BMad V6 Insights (Reference Available)

**BMad V6 Alpha** was explored and analyzed. Key learnings are in `../bmadv6/` (parent directory).

**You can reference V6 for:**
- Module system architecture
- Workflow-first paradigm (vs agent-first)
- BMad Builder (self-extensible framework)
- Scale-adaptive system (Quick Flow / BMad Method / Enterprise tracks)
- Fresh chats approach

**BUT - We're building LifePlan AI with V4 Optimized because:**
- ✅ V4 is stable, production-ready
- ✅ Our optimizations are proven (handoffs, Playwright MCP, three-terminal)
- ✅ V6 is alpha (6.0.0-alpha.6)
- ✅ V4 works for our stack (Next.js, TypeScript, Node.js)

**If you need V6 insights:** Read `../bmadv6/bmad/bmm/README.md` or other files in that directory.

---

## 📊 Critical Analysis Available

**MUST READ FIRST:** `analysis/PERSONAL-AI-OS-CRITICAL-ANALYSIS-2025-11-07.md`

**This 30+ page document contains:**
1. ✅ Original concept (vision, architecture, philosophy)
2. ✅ What's genuinely brilliant (timing, copy-tradeable workflows)
3. ✅ 6 critical problems (power user trap, execution complexity, market validation)
4. ✅ Market analysis (TAM/SAM/SOM, competitive landscape)
5. ✅ Technical assessment (architecture, risks, stack recommendations)
6. ✅ Business model analysis (revenue streams, unit economics)
7. ✅ 3-phase execution plan (proof → beta → scale)
8. ✅ Critical questions (goal, unfair advantage, commitment)

**Current Status:** Concept phase, awaiting decision on Phase 1 MVP.

---

## 🎯 How to Use BMad to Build LifePlan AI

When user wants to develop LifePlan AI, follow BMad methodology:

### Phase 1: Create Planning Documents

**Step 1: Product Brief** (Optional but recommended)
```
Load: .bmad-core/agents/analyst.md
Command: *create-product-brief
Output: docs/product-brief.md
```

**Step 2: PRD (Required)**
```
Load: .bmad-core/agents/pm.md
Command: *create-prd
Output: docs/PRD.md (with Epic sections)
```

**Step 3: Architecture (Required for complex projects)**
```
Load: .bmad-core/agents/architect.md
Command: *create-architecture
Output: docs/Architecture.md
```

**Step 4: UX Design** (If LifePlan AI has UI)
```
Load: .bmad-core/agents/ux-expert.md
Command: *create-ux-design
Output: docs/UX-Design.md
```

### Phase 2: Story Creation & Implementation

**Step 1: Create Story from Epic**
```
Load: .bmad-core/agents/sm.md
Command: *create-story
Input: docs/PRD.md (Epic section)
Output: docs/stories/{epic}.{story}.story.md
```

**Step 2: Implement Story**
```
Load: .bmad-core/agents/dev.md
Command: *develop-story docs/stories/{epic}.{story}.story.md
Process:
  - Reads story ACs
  - Implements feature
  - Writes tests (Vitest for logic, markdown scenarios for E2E)
  - Starts background processes
  - Creates QA Handoff (document + snippet)
  - HALTS (does NOT run tests)
```

**Step 3: QA Validation**
```
Load: .bmad-core/agents/qa.md
Input: QA Handoff snippet from Dev
Process:
  - Reads full QA Handoff document
  - Runs Vitest tests: npm run test
  - Executes E2E scenarios via Playwright MCP
  - Observes, captures evidence
  - Creates Developer Handoff (issues) OR Completion Handoff (approval)
```

**Step 4: Address Issues or Commit**
- If issues: Dev fixes based on Developer Handoff
- If approved: Dev commits with suggested message from Completion Handoff

### Phase 3: Quality Gates & Deployment

**QA creates quality gate:**
```
Output: docs/qa/gates/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}.yml
```

**Once all stories in sprint complete:**
- Review all quality gates
- Deploy to production

---

## 🛠️ Technology Stack for LifePlan AI

**Based on critical analysis recommendations:**

### Backend
- **Language:** TypeScript (Node.js) or Python (FastAPI)
- **Database:** PostgreSQL (structured) + Vector DB (embeddings)
- **Vector DB:** Pinecone (managed) or Qdrant (self-hosted)
- **Queue:** BullMQ (job processing)
- **Storage:** S3-compatible (encrypted)

### AI Layer
- **LLM:** Claude 3.5 Sonnet (summarization) via API
- **Embeddings:** OpenAI text-embedding-3 or Cohere
- **Fallback:** Local models (Llama, Mistral) for privacy mode

### Frontend
- **Web:** Next.js + Tailwind CSS + shadcn/ui
- **Mobile:** React Native (cross-platform) OR Swift + Kotlin (native)
- **Terminal:** Rust CLI (fast) OR Node.js (easier iteration)

### Sync
- **Protocol:** CRDTs (Automerge) or OT (Operational Transform)
- **Transport:** WebSockets (real-time) + REST (sync)
- **Offline:** IndexedDB (web), SQLite (mobile)

### Infrastructure
- **Hosting:** Vercel (frontend), Railway/Render (backend)
- **CDN:** Cloudflare
- **Monitoring:** Sentry (errors), Posthog (analytics)

---

## 🚦 Project Phases (From Critical Analysis)

### Phase 1: Prove the Concept (Months 0-6)

**Goal:** Validate core mechanics work for originator

**Build:**
1. Terminal-based vault system
2. AI summarization + retrieval (Claude API)
3. Basic automation (n8n workflows)
4. Personal use case (growth consultancy organization)

**Success:** Daily active use for 30+ days, measurable productivity gain

**Investment:** Time + $500/mo (API costs)

### Phase 2: Productize for 100 Users (Months 6-18)

**Goal:** Validate others will pay

**Build:**
1. Web PWA (dashboard, editing, chat)
2. Mobile app (iOS MVP - quick capture)
3. Sync infrastructure (CRDT-based)
4. 10 pre-built workflows
5. Payment system (Stripe)
6. Documentation + onboarding

**Success:** 100 paying users ($10/mo), 70%+ retention, NPS 50+

**Investment:** $156k (team + infrastructure) OR bootstrap with revenue

### Phase 3: Scale or Pivot (Months 18-36)

**Decision point:**
- **Path A:** Bootstrap to profitability (lifestyle business, $1M-10M/year)
- **Path B:** Raise VC ($2M-5M seed) and go for category dominance
- **Path C:** Pivot based on learnings

---

## 💡 Key Architectural Decisions for LifePlan AI

### 1. File-First Architecture (Core Principle)

```
/vault
 ├── /daily/2025-11-06.md
 ├── /projects/real_realtors/
 ├── /goals/2025.md
 ├── /tasks/
 │    ├── inbox.md
 │    └── next.md
 ├── /journal/
 └── /knowledge/
```

**Every file is Markdown** - readable, portable, versionable.

### 2. Context Engine Design

**Compaction:** Daily → Weekly → Monthly → Quarterly summaries
**Retrieval:** Vector embeddings for semantic search
**Context Control:** Selective memory surface during conversations

### 3. Cross-Device Sync Strategy

**Challenge:** Real-time sync without data loss
**Solution:** CRDTs (Conflict-free Replicated Data Types)
**Tools:** Automerge or Yjs
**Offline:** Full offline support with eventual consistency

### 4. Privacy-First Design

**Principles:**
- Data ownership (user owns vault)
- Encryption (end-to-end for cloud sync)
- Local-first (works offline)
- Optional sync (user decides)

### 5. Copy-Tradeable Workflows (The Moat)

**This is the defensible innovation.**

**Workflow Structure:**
```yaml
workflow_id: startup-founder-workflow
name: "Startup Founder Daily System"
author: "Anjai Jacob"
description: "Proven workflow for early-stage founders"
vault_structure:
  - /daily/
  - /projects/startup/
  - /goals/quarterly.md
  - /tasks/
  - /journal/founder-reflections/
automation:
  - daily_template_generation
  - weekly_review_prompt
  - monthly_goal_tracking
ai_prompts:
  - morning_planning: "Review yesterday's progress, plan today's focus..."
  - evening_reflection: "What went well? What could improve?"
```

**Users can:**
1. Import workflow (one-click)
2. AI adapts to their context
3. Track results over time
4. Share modifications back to community

---

## 🎨 How Claude Should Help

### When User Asks About LifePlan AI Development:

**1. Use BMad Methodology**
- Suggest appropriate agent for task (PM, Architect, Dev, QA)
- Follow structured workflows
- Create proper documentation

**2. Apply Our V4 Optimizations**
- Use Vitest + Playwright MCP testing approach
- Create dual-format handoffs
- Use Context7 for research
- Maintain hierarchical folder structures

**3. Reference Critical Analysis**
- Remind user of market insights
- Consider execution complexity
- Validate against business model
- Check alignment with phase goals

**4. Think Meta-Level**
- This is using framework to build framework
- Decisions here validate BMad methodology
- LifePlan AI becomes BMad case study

### When User Asks "What Should I Do Next?"

**Check current phase:**
- **Concept Phase:** "Have you answered the critical questions? (analysis/PERSONAL-AI-OS-CRITICAL-ANALYSIS-2025-11-07.md, sections: Critical Questions)"
- **Phase 1:** "Let's create terminal MVP. Should we start with PRD using PM agent?"
- **Phase 2:** "Let's productize. Have we validated Phase 1 success metrics?"
- **Phase 3:** "Scale or pivot decision. What do metrics say?"

### When User Asks Technical Questions:

**1. Check if it's documented:**
- Critical analysis (architecture recommendations)
- BMad guides (.bmad-core/data/)
- Reference docs

**2. Use Context7 MCP:**
- For current best practices
- For library documentation
- For technology decisions

**3. Prototype First:**
- Save to prototypes/ folder
- Iterate quickly
- Validate assumptions

---

## ⚠️ Critical Reminders

### 1. This is NOT a Side Project

From critical analysis: **This requires 3-5 year commitment** if done seriously.

**Before proceeding, user must answer:**
- What's your REAL goal? (Billion-dollar company OR lifestyle business OR solve own problem?)
- Are you prepared for 60-80 hour weeks?
- What are you willing to sacrifice?
- What's your unfair advantage?

### 2. Power User Trap

**Current vision requires:**
- Understanding file systems
- Markdown fluency
- Terminal comfort
- Context management

**This limits TAM to 50M-100M power users.**

**To reach mass market (1B+):**
- Must remove Markdown requirement
- Must hide file system complexity
- Must remove terminal dependency
- Must simplify workflow import

**Remind user of this trade-off when making UX decisions.**

### 3. Copy-Tradeable Workflows = The Moat

**This is the NOVEL insight that makes LifePlan AI defensible.**

**Prioritize:**
1. Workflow format design
2. Import/export mechanism
3. AI adaptation layer
4. Marketplace infrastructure

**Everything else is table stakes.**

### 4. Privacy vs Convenience Tension

**User values:**
- Data ownership
- Local-first
- Privacy by default

**But users want:**
- Cloud sync
- Cross-device
- "It just works"

**Solution:** Hybrid approach
- Free tier: Local-only
- Paid tier: Encrypted cloud sync (user owns keys)
- Enterprise: Self-hosted option

**Remind user to maintain this balance.**

---

## 📚 Key Documents to Reference

**In This Project:**
- `README.md` - Project overview
- `analysis/PERSONAL-AI-OS-CRITICAL-ANALYSIS-2025-11-07.md` - **MUST READ**

**In .bmad-core/:**
- `user-guide.md` - Complete BMad methodology
- `enhanced-ide-development-workflow.md` - Step-by-step dev cycle
- `working-in-the-brownfield.md` - Existing project workflow
- `data/testing-stack-guide.md` - Testing workflow (Vitest + Playwright MCP)
- `data/handoff-templates.md` - Dual-format handoff system
- `data/three-terminal-workflow.md` - Advanced workflow patterns
- `data/documentation-standards.md` - File naming, folder structure

**In Parent Directory (../bmadv6/):**
- `bmad/bmm/README.md` - BMad V6 overview
- `bmad/bmm/docs/quick-start.md` - V6 quick start
- `bmad/bmm/docs/scale-adaptive-system.md` - V6 scale-adaptive approach
- `bmad/bmb/README.md` - BMad Builder (self-extensible framework)

---

## 🎯 First Steps When Starting Fresh

**If user opens this folder in new terminal:**

1. **Read the critical analysis**
   ```
   "Please read analysis/PERSONAL-AI-OS-CRITICAL-ANALYSIS-2025-11-07.md to understand the full context."
   ```

2. **Ask about commitment**
   ```
   "Have you decided to move forward with Phase 1 (terminal MVP)?
   This requires answering the critical questions first."
   ```

3. **If yes, start with BMad PM agent**
   ```
   "Let's create a PRD for LifePlan AI using BMad methodology.
   Load: .bmad-core/agents/pm.md
   This will structure our thinking and create comprehensive requirements."
   ```

4. **If no, explore the concept**
   ```
   "What aspect of LifePlan AI would you like to explore?
   - Market opportunity?
   - Technical architecture?
   - Business model?
   - Execution plan?"
   ```

---

## 🚀 Current Status

**Phase:** Concept & Analysis
**Decision:** Pending (awaiting user commitment)
**Next Step:** Answer critical questions → Build Phase 1 MVP OR table for later
**Timeline:** TBD based on user decision

**This project is:**
- ✅ Well-analyzed (30+ page critical analysis)
- ✅ Properly structured (BMad framework in place)
- ✅ Ready for development (if user commits)
- ⏸️ Awaiting decision (Phase 1 or table)

---

## 💬 Communication Style

**When working on LifePlan AI:**
- Be **critical** - This is a 3-5 year commitment, stakes are high
- Be **honest** - Point out risks, challenges, trade-offs
- Be **structured** - Use BMad methodology consistently
- Be **meta-aware** - Remember we're using framework to build framework
- Be **supportive** - This is an ambitious vision worth pursuing

**Remember:** LifePlan AI could be category-defining, but execution is everything.

---

**Ready to build the future of personal intelligence?** 🚀

Let's use BMad to make it happen.
