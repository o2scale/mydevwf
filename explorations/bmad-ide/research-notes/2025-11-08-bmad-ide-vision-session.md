# BMad IDE Vision Session

**Date**: 2025-11-08
**Participants**: User (Product Visionary), Claude (Technical Architect)
**Session Type**: Strategic Architecture & Product Vision
**Context**: Continuation from BMad V6 exploration and handoff optimization work

---

## Executive Summary

User conceived **BMad IDE** - a revolutionary agentic development environment that solves fundamental limitations of existing platforms (emergent.sh, Claude Code subagents, manual workflows). The vision combines local-first development, automated agent handoffs, context pollution monitoring, and full transparency for power users.

**Key Decision**: Two-stage architecture
1. **Stage 1** (Months 1-3): VS Code Extension MVP - validate core concept fast
2. **Stage 2** (Months 4-12): Pure Linux Terminal System - revolutionary power-user platform

**Critical Validation Requirement**: Prove agents can respond reliably to programmatic prompt injection within 2-3 weeks (MVD).

---

## Problem Statement

### Current Landscape Issues

**emergent.sh** (Primary Competitive Reference):
- ❌ Expensive: $10-167/month + 1-5 credits per app
- ❌ Cloud-only: No local development, download code after
- ❌ Black box: No visibility into agent decisions or intermediate states
- ❌ No real IDE: Web interface, not power-user friendly
- ❌ Stack locked: Platform defines tech choices
- ❌ No intervention: Can't peek mid-work or guide agents
- ❌ No audit trail: Missing handoff docs, decision logs

**User Quote**: "I don't see the code until I download it... I'm not able to have the freedom I want in changing things inside. Tinkering as a power user..."

**Claude Code Subagents**:
- ❌ Stateless: Clean slate each invocation
- ❌ 20k token overhead per invocation
- ❌ Lower quality: User's production experience - "don't get things done properly"
- ❌ No persistence: Feature request #7317 for session IDs (open/unimplemented)

**Manual Three-Terminal Workflow** (User's Current Setup):
- ✅ Works VERY WELL in production
- ✅ High quality (full agent context)
- ❌ Manual handoff copy-paste (doesn't scale)
- ❌ Human bottleneck (can't run unattended)

### The Core Insight

**User Discovery**: "When a dev agent is loaded... That dev agent would probably retain quite a lot of its own personality... for 4 compactions. After the 4th compaction, the dev starts forgetting and hallucinating."

**User's Solution**: Reload agent every 4 stories (works VERY WELL)

**No competitor addresses this** - BMad IDE's unique differentiator.

---

## User's Vision

### The Ideal Experience

"I want to be able to agentically plan this for developers so that they can choose their stack and even in minute configurations of all these things. And moving back and forth between these terminals and solving the exact problem that sub-agents have right now. We just need to make sure that when their context is getting lost... the higher level agent is observing apart from the human in the loop and he is verifying that the context is being self-aware or the awareness or the context pollution has not happened."

**Key Requirements**:
1. **Automated Handoffs**: Terminals communicate programmatically, no manual copy-paste
2. **Context Monitoring**: Detect pollution (4-compaction threshold), auto-reload with memory
3. **Human in Loop Transparency**: Peek anytime, see state, intervene when needed
4. **Stack Agnostic**: User configures tech stack, not platform
5. **Local-First**: Code visible locally, full IDE control
6. **Audit Trail**: Complete documentation of decisions, handoffs, state changes
7. **Power User Focus**: Built for 40x/50x developers, not no-code users

### Architecture Options Considered

**Option A: VS Code/Cursor Extension**
```
VS Code IDE
├── Extension: BMad Orchestrator
├── Terminal 1: Claude Code (Orchestrator)
├── Terminal 2: Claude Code (Dev)
├── Terminal 3: Claude Code (QA)
└── File Watcher → Automated Handoffs
```

**Pros**: Fast to market (3 months), 100M+ users, familiar interface
**Cons**: Constrained by VS Code APIs, heavier resources

**Option B: Pure Linux Terminal System** (User's Strong Preference)
```
Ubuntu Docker Container
├── tmux multiplexer (3 panes)
├── Pane 1: Claude Code CLI (Orchestrator)
├── Pane 2: Claude Code CLI (Dev)
├── Pane 3: Claude Code CLI (QA)
├── BMad Orchestration Daemon
├── Terminal UI Dashboard
└── neovim/vim (editing)
```

**Pros**: Revolutionary, full control, lightweight, Linux-native, Docker-reproducible
**Cons**: Higher barrier to entry, 8-12 months to MVP, more dev effort

**User Quote on Linux Migration**: "Moving to Linux seems to be a core option at this point of time... I personally like the BMad [approach]... if I can improve my workflow while having an IDE open and talking to each other and seeing all of this."

---

## Recommended Architecture: Two-Stage Strategy

### Strategic Rationale

**Don't choose between Extension and Terminal System - build BOTH in stages**:

1. Extension validates concept fast (3 months)
2. User dogfoods Extension while building Terminal System
3. Terminal System learns from Extension's lessons
4. Both share orchestration backend eventually
5. Users choose frontend: IDE (easy) or Terminal (power)

### Stage 1: VS Code Extension MVP (Months 1-3)

**Goal**: Validate core assumption - can agents respond reliably to automated handoffs?

**Features**:
- File watcher (detects handoff document creation)
- Prompt injection (injects context into target terminal)
- Basic context monitoring (compaction counting)
- Simple dashboard (webview showing workflow state)

**Success Criteria**: Agents respond reliably 80%+ of time to injected prompts

**Why This First**:
- Fast validation (2-3 weeks for MVD, 3 months for MVP)
- 100M+ addressable market (VS Code users)
- Can dogfood immediately
- Lower barrier to entry
- Proves value before heavy investment
- Better funding story ("working product" vs "vision only")

### Stage 2: Pure Linux Terminal System (Months 4-12)

**Goal**: Revolutionary power-user platform aligned with user's Linux migration

**Features**:
- Docker container (Ubuntu + tmux + Claude Code CLI)
- Orchestration daemon (Go/Rust) - file watching, terminal control, state management
- Terminal UI dashboard (blessed.js or rust-tui)
- Context pollution monitoring (ML-based detection)
- Agent reload with memory preservation
- Multi-project workspace

**Success Criteria**: 1,000+ power users using terminal system exclusively

**Why This Second**:
- Revolutionary positioning (no competitor)
- Aligns with user's vision and Linux migration
- Learned from Extension what works/doesn't
- True differentiation for funding
- Serves power user market (smaller but higher value)

### Stage 3: Convergence (Year 2)

**Goal**: Unified platform with choice of frontend

**Architecture**:
```
┌─────────────────────────────────────┐
│   Shared Orchestration Backend     │
│   (File watching, state machine,    │
│    context monitoring, handoffs)    │
└────────────┬────────────────────────┘
             │
        ┌────┴────┐
        │         │
    ┌───▼───┐ ┌──▼────┐
    │  IDE  │ │Terminal│
    │Frontend│ │Frontend│
    └───────┘ └───────┘
```

**User Choice**: Extension = "easy mode", Terminal = "power mode"

---

## Technical Architecture Deep Dive

### Layer 1: Orchestration Service (Core Engine)

**Responsibilities**:
- File system watching (handoff document detection)
- Handoff routing (parse type, determine target terminal)
- Terminal control (inject prompts programmatically)
- State machine (workflow progression)
- Context monitoring (compaction tracking, health checks)

**Technology**:
- Extension: Node.js service (VS Code extension host)
- Terminal: Go or Rust daemon (performance, reliability)

**Key Code Path**:
```javascript
class OrchestrationService {
  watchHandoffs() {
    // Monitor docs/handoffs/sprint-{N}/epics/epic-{N}/
    watcher.on('add', (filePath) => {
      if (filePath.match(/qa-handoff\.md$/)) {
        this.routeToQA(filePath);
      } else if (filePath.match(/developer-handoff\.md$/)) {
        this.routeToDev(filePath);
      }
      // ... other handoff types
    });
  }

  routeToQA(handoffPath) {
    const qaTerminal = this.terminals.find(t => t.agent === 'qa');
    const prompt =
      `[AUTO-HANDOFF] QA Handoff received from Dev.\n` +
      `Document: ${handoffPath}\n` +
      `Load document and begin testing workflow.`;
    qaTerminal.sendText(prompt);
    this.updateState('testing-in-progress');
  }
}
```

### Layer 2: Context Pollution Monitor (Unique Innovation)

**Problem**: Dev agents degrade after 4 compactions (hallucinations, forgotten decisions)

**Solution**: Track compactions, warn at 3, auto-reload at 4 with context preservation

**Implementation**:
```javascript
class ContextHealthMonitor {
  constructor(terminalId, agentType) {
    this.terminalId = terminalId;
    this.agentType = agentType;
    this.compactionCount = 0;
    this.messageCount = 0;
    this.thresholds = {
      warning: 3,    // Warn user
      critical: 4,   // Auto-reload
      messages: 50   // ~50 messages per compaction
    };
  }

  trackMessage(message) {
    this.messageCount++;

    // Detect compaction (Claude Code adds tags when summarizing)
    if (this.detectCompaction(message)) {
      this.compactionCount++;
      this.checkHealth();
    }
  }

  async triggerReload() {
    // 1. Summarize conversation (key decisions, progress)
    const summary = await this.summarizeConversation();

    // 2. Extract story progress (tasks completed, current task)
    const progress = await this.extractStoryProgress();

    // 3. Close terminal, open fresh one
    const newTerminal = await this.openFreshTerminal();

    // 4. Inject context summary
    newTerminal.sendText(
      `[CONTEXT RELOAD] Previous session: ${this.compactionCount} compactions.\n` +
      `Summary: ${summary}\n` +
      `Progress: ${progress}\n` +
      `Continue from where you left off.`
    );
  }
}
```

**Key Innovation**: Preserves architectural memory
- UUID schema decisions
- Password hashing choices
- API design patterns
- Library selections

**User Insight**: "Sometimes it's pollution, sometimes it's actually useful context. That's the razor's edge."

### Layer 3: Workflow State Machine

**States**:
1. Project Created
2. Epic Planning (Orchestrator)
3. Story Creation (Orchestrator) → **Story Handoff**
4. Development (Dev) → **QA Handoff**
5. Testing (QA) → **Developer Handoff** (if issues) OR **Completion Handoff** (if pass)
6. Fixing (Dev) → Loop back to Testing
7. Commit & Close (Dev)

**Transitions**:
- File watcher detects handoff document creation
- Parse handoff type, route to target terminal
- Update state machine
- Notify user (optional, based on settings)

**Error Handling**:
- Agent doesn't respond in 30s → Notify user
- Agent gets stuck → Manual override button
- Agent refuses task → Escalate to user
- Infinite loop detected → Pause workflow, notify

### Layer 4: Dashboard & Human Control

**VS Code Webview** (Extension):
```
┌────────────────────────────────────────────────────┐
│  BMad IDE Dashboard                      [⚙️ Config]│
├────────────────────────────────────────────────────┤
│  Project: my-saas-app                              │
│  Sprint: 2   Epic: 2.3 - Authentication            │
│                                                     │
│  ┌──────────────┬──────────────┬─────────────┐    │
│  │ Orchestrator │      Dev     │     QA      │    │
│  ├──────────────┼──────────────┼─────────────┤    │
│  │ Status: Idle │ Status: Work │ Status: Wait│    │
│  │ Context: ●●●○│ Context: ●●○○│ Context: ●●●│    │
│  │ (3 compact)  │ (2 compact)  │ (0 compact) │    │
│  │              │              │             │    │
│  │ Last Action: │ Current Task:│ Waiting for:│    │
│  │ Created 2.3  │ Auth endpoints│ QA Handoff  │    │
│  │              │              │             │    │
│  │ [View Term]  │ [View Term]  │ [View Term] │    │
│  │ [Reload]     │ [Reload]     │ [Skip]      │    │
│  └──────────────┴──────────────┴─────────────┘    │
│                                                     │
│  Workflow: Development → Testing → Commit          │
│                  ▲                                 │
│              [You are here]                        │
│                                                     │
│  Recent Events:                                    │
│  ✅ 15:30 - Dev started Story 2.3                  │
│  ⚠️  15:45 - Dev context warning (3 compactions)  │
│  ✅ 15:50 - Dev created backend/routes/auth.js    │
└────────────────────────────────────────────────────┘
```

**Terminal UI** (Terminal System):
- tmux pane with blessed.js or rust-tui
- Same information, text-based interface
- Keyboard shortcuts for navigation
- Real-time updates

**Human Intervention Points**:
- Click terminal → Jump to that terminal
- Reload Agent → Trigger context refresh
- Pause Workflow → Stop automation
- Manual Override → Take control
- Skip Task → Move to next step

---

## Technical Feasibility Assessment

### ✅ Highly Feasible (Proven Tech)
1. Multiple persistent terminals - VS Code native
2. File watching - chokidar (Node.js), notify (Rust)
3. Document parsing - Markdown + YAML frontmatter
4. Terminal text injection - `terminal.sendText()` (VS Code API)
5. Process management - PID tracking via `terminal.processId`
6. MCP integration - Already working in user's setup
7. Project templates - File system operations

### ⚠️ Medium Complexity (Engineering Required)
1. Context pollution detection - Heuristics + message counting
2. Agent reload with context - Conversation summarization (LLM-based)
3. Workflow state machine - State management + event handling
4. Dashboard UI - VS Code Webview API or terminal UI library
5. Handoff routing logic - Pattern matching + conditional injection
6. Error handling - Agent failures, timeouts, stuck states

### ❌ High Risk (Unknown/Unvalidated)
1. **Agent cooperation** - Will agents reliably respond to injected prompts? ⚠️ CRITICAL
2. **Context preservation** - Can we summarize effectively for reload?
3. **Compaction detection** - How reliably can we detect compaction events?
4. **Multi-story context** - Does architectural memory actually persist after reload?

**Mitigation**: MVD (Minimum Viable Demo) must validate #1 in Week 1. If agents don't cooperate, entire concept fails.

---

## Development Roadmap

### Phase 0: MVD - Minimum Viable Demo (Weeks 1-2)

**Goal**: Validate CRITICAL assumption - agent cooperation

**Deliverables**:
1. Simple Node.js script with file watcher
2. Detect handoff document creation
3. Inject prompt into VS Code terminal (via extension or CLI)
4. Observe: Does agent respond reliably?

**Success Criteria**: Agent responds correctly 80%+ of time

**If FAIL**: Pivot immediately
- Option A: Explore hooks-based approach (if Claude Code adds hook support)
- Option B: Manual workflow with monitoring only (smaller product)
- Option C: Focus on BMad framework, abandon IDE concept

**If SUCCESS**: Proceed to Phase 1

---

### Phase 1: Extension MVP (Months 1-3)

**Goal**: Working VS Code extension that automates three-terminal workflow

**Week 1-2: Foundation**
- VS Code extension scaffolding
- File watcher integration
- Basic prompt injection

**Week 3-4: Handoff Automation**
- Parse all 5 handoff types (Story, QA, Developer, Completion, Test Review)
- Route to correct terminal
- State machine implementation

**Week 5-6: Context Monitoring**
- Message counting (estimate compactions)
- Warning notifications (3 compactions)
- Manual reload capability

**Week 7-8: Dashboard UI**
- Webview panel with workflow state
- Terminal status (context health)
- Quick-jump to terminals
- Recent events log

**Week 9-10: Polish & Testing**
- Error handling
- User testing (5-10 alpha users)
- Bug fixes
- Documentation

**Week 11-12: Launch**
- Publish to VS Code marketplace (free)
- Announcement (Twitter, Reddit, HN)
- Gather feedback
- Iterate based on usage

**Success Criteria**:
- 100+ active users
- 80%+ handoff automation success rate
- 90%+ user satisfaction
- 5+ community contributions

---

### Phase 2: Terminal System Architecture (Months 4-6)

**Goal**: Design and POC terminal-based system

**Month 4: Architecture Design**
- Document terminal system architecture
- Technology selection (Go vs Rust for daemon)
- Terminal UI design (blessed.js vs rust-tui)
- Docker container design

**Month 5: Orchestration Daemon POC**
- Build standalone daemon (not VS Code-dependent)
- File watcher
- tmux control (send-keys)
- State machine (reusable from Extension)

**Month 6: Terminal Control POC**
- Prove tmux automation works
- Inject prompts into tmux panes
- Test agent cooperation in terminal context
- Validate same reliability as Extension

**Decision Gate**: Does terminal system work as reliably as Extension?
- ✅ YES → Proceed to Phase 3
- ❌ NO → Improve Extension, delay Terminal System

---

### Phase 3: Terminal System MVP (Months 7-12)

**Month 7-8: Core Development**
- Complete orchestration daemon
- Docker container (Ubuntu + tmux + Claude Code CLI)
- Configuration system
- Project templates

**Month 9-10: Terminal UI & Monitoring**
- Terminal dashboard (blessed.js or rust-tui)
- Context monitoring (port from Extension)
- Agent reload capability
- Process management

**Month 11: Integration & Testing**
- Full workflow testing (10+ stories end-to-end)
- Error handling
- Performance optimization
- User testing (power users only)

**Month 12: Launch**
- Docker Hub publish
- Documentation (setup, usage, migration from Extension)
- Launch announcement (focus on power user communities)
- Gather feedback

**Success Criteria**:
- 500+ users (smaller market, higher engagement)
- 90%+ handoff automation success
- 95%+ user satisfaction (power users more tolerant of complexity)
- 10+ community Docker images (custom stacks)

---

### Phase 4: Convergence (Year 2)

**Shared Backend**:
- Extract orchestration logic into standalone service
- Extension and Terminal System both use same backend
- Handoff format standardization
- State machine unification

**Marketplace**:
- Template marketplace (30% platform fee)
- MCP integration library
- Custom agent store
- Workflow blueprints

**Enterprise Features**:
- Team collaboration
- Shared handoff documents
- Code review integration
- Analytics dashboard

---

## Competitive Analysis

### emergent.sh (Primary Competitor)

**What They Do Well**:
- Multi-agent orchestration (6 specialized agents)
- Seamless handoffs (opaque but functional)
- Fast (apps in <5 minutes)
- Ranked #1 on SWE-Bench (AI engineering benchmark)
- $30M funding (Series A)

**Critical Limitations** (BMad IDE's Opportunity):
1. ❌ Cloud-only (no local control)
2. ❌ Expensive ($10-167/mo + credits)
3. ❌ Black box (no visibility into decisions)
4. ❌ No real IDE (web interface only)
5. ❌ Stack locked (platform-defined)
6. ❌ No intervention (can't peek mid-work)
7. ❌ No audit trail (where are handoff docs?)

**Competitive Response Risk**: emergent.sh could add local IDE before BMad IDE launches

**Mitigation**: Speed matters - ship Extension in 3 months, establish first-mover advantage in "power-user agentic IDE" category

### Claude Code Subagents

**What They Do Well**:
- Isolated context (no pollution)
- Parallel execution (10 concurrent)
- Native Claude Code integration

**Limitations**:
1. ❌ Stateless by default
2. ❌ Resume feature exists but manual
3. ❌ 20k token overhead per invocation
4. ❌ Lower quality (user's experience)
5. ❌ No direct communication

**Feature Request #7317**: Resumable sessions (open, unimplemented)

**If Anthropic Implements**: Could reduce BMad IDE's value prop

**Mitigation**: BMad IDE offers more than persistence - full workflow automation, context monitoring, dashboard

### Cursor/Windsurf/VS Code + Copilot

**What They Do Well**:
- Mainstream adoption (100M+ users)
- Familiar interface
- Good code completion
- Local-first

**Limitations**:
1. ❌ No multi-agent workflow
2. ❌ No automated handoffs
3. ❌ No context monitoring
4. ❌ Single agent only (no Dev/QA separation)

**Competitive Positioning**: BMad IDE is LAYER ON TOP of these IDEs (Extension model), not replacement

---

## Positioning & Go-to-Market

### Target User Personas

**Persona 1: "40x Developer" (Primary)**
- Full-stack engineer, 5-15 years experience
- Values control, transparency, customization
- Willing to invest time in tools
- Uses terminal daily, comfortable with Linux
- Current pain: Context switching between terminals, manual handoffs
- Willing to pay: $29-49/month for productivity gains

**Persona 2: "Freelance Builder" (Secondary)**
- Consultant, agency owner, freelancer
- Builds 5-10 projects per year
- Needs fast project setup, reusable templates
- Values time savings over features
- Current pain: Project setup takes days, each project from scratch
- Willing to pay: $49/month for faster client delivery

**Persona 3: "Dev Team Lead" (Future)**
- Manages 5-50 engineers
- Needs standardized workflows, code quality
- Values transparency, audit trails
- Current pain: Inconsistent agent usage, no team workflows
- Willing to pay: $2K-10K/year for team (enterprise tier)

### Positioning Statement

**For** power developers who want agentic acceleration without giving up control,
**BMad IDE** is an agentic development environment
**That** automates multi-agent workflows with full transparency and local-first architecture.
**Unlike** emergent.sh which is expensive and cloud-only,
**BMad IDE** gives you complete control, visibility, and customization.

**Tagline Options**:
1. "Agentic development. Your code. Your control."
2. "Build with AI agents. Keep your power."
3. "The IDE for 40x developers."
4. "emergent.sh meets VS Code."
5. "Power user agentic development."

### Launch Strategy

**Phase 1 Launch** (Extension MVP):
- **Platform**: VS Code Marketplace (free tier)
- **Announcement**: Product Hunt, HackerNews, Reddit (r/vscode, r/programming)
- **Content**: Demo video (3 min showing automated handoff), blog post
- **Community**: Discord server, GitHub discussions
- **Influencers**: Reach out to dev tool YouTubers (ThePrimeagen, etc.)

**Phase 2 Launch** (Terminal System):
- **Platform**: Docker Hub + dedicated website
- **Announcement**: HackerNews (focused on "revolutionary" angle)
- **Content**: Comparison video (Extension vs Terminal), technical deep dive
- **Community**: Linux forums, terminal enthusiast communities
- **Press**: TechCrunch, The Verge (funding angle)

**Pricing Launch**:
- Start free (community adoption)
- Add Pro tier at 1,000+ users
- Add Enterprise at 5,000+ users
- Add Marketplace at 10,000+ users

---

## Business Model & Commercialization

### Revenue Streams

**1. Subscriptions** (Primary Revenue)

**Free Tier** (Open Source):
- BMad framework (agents, tasks, workflows)
- VS Code extension (basic automation)
- 4 starter templates (from project-templates/)
- Community support (GitHub discussions)
- BYO Claude API key

**Pro Tier** ($29-49/month):
- Advanced context monitoring (ML-based degradation detection)
- Multi-project workspace (manage 10+ projects simultaneously)
- Premium templates (20+ stacks beyond free tier)
- Priority support (24h response time)
- Dashboard analytics (time saved, story velocity)
- Custom agent fine-tuning

**Enterprise Tier** (Custom Pricing: $2K-10K/year per team):
- Team collaboration (shared workflows, code review integration)
- Private template marketplace
- Custom agent development (domain-specific agents)
- On-premise deployment (Docker Swarm/Kubernetes)
- SSO + enterprise security (SAML, LDAP)
- Dedicated support + training
- SLA guarantees

**2. Marketplace** (30% Platform Fee)

**Template Marketplace**:
- Users sell stack templates ($9-49 each)
- Example: "SaaS Starter (Next.js + Stripe + Auth + Email)" - $49
- Platform takes 30% ($15), creator gets 70% ($34)

**MCP Integration Library**:
- Premium MCPs ($4-19/month subscriptions)
- Example: "Advanced Supabase MCP with AI Query Builder" - $9/mo

**Custom Agent Store**:
- Specialized agents ($9-29 one-time)
- Example: "E-commerce Product Agent (inventory, orders, shipping)" - $29

**Workflow Blueprints**:
- Industry-specific workflows ($19-99 one-time)
- Example: "Fintech Compliance Workflow (KYC, AML, audit trails)" - $99

**3. Professional Services** (High-Touch Revenue)

**Custom Agent Development**: $5K-20K per agent
**Workflow Consulting**: $2K-5K per engagement
**Team Training**: $1K-3K per day
**Implementation Support**: $10K-50K for enterprise rollout

### Financial Projections (Conservative)

**Year 1**:
- Users: 5,000 (mostly free)
- Paid Users: 250 (5% conversion)
- MRR: $7,500 (250 × $30 avg)
- ARR: $90K
- Marketplace: $10K (early, low volume)
- **Total Revenue**: $100K

**Year 2**:
- Users: 25,000
- Paid Users: 2,000 (8% conversion, improving)
- MRR: $70K (2,000 × $35 avg)
- ARR: $840K
- Marketplace: $100K (growing ecosystem)
- Enterprise: $100K (5 teams × $20K)
- **Total Revenue**: $1M+

**Year 3** (Scale):
- Users: 100,000
- Paid Users: 10,000 (10% conversion)
- MRR: $450K (10,000 × $45 avg)
- ARR: $5.4M
- Marketplace: $500K (mature ecosystem)
- Enterprise: $500K (25 teams × $20K)
- **Total Revenue**: $6.4M

### Funding Strategy

**Bootstrap Phase** (Months 1-6):
- Self-funded or small angel round ($50K-100K)
- Validate product-market fit
- Build to 1,000+ users
- Prove unit economics

**Pre-Seed** (Month 7, Target: $500K-1M):
- **Traction**: Extension MVP launched, 1,000+ active users
- **Metrics**: 5% paying, $30 ARPU, <$50 CAC
- **Use of Funds**: Hire 2-3 engineers, marketing/growth
- **Valuation**: $4-6M post-money

**Seed** (Month 18, Target: $3-5M):
- **Traction**: Terminal System MVP, 10,000+ active users, $50K+ MRR
- **Metrics**: 8% paying, $35 ARPU, <$100 CAC, 5% MoM growth
- **Use of Funds**: Scale team to 10 (eng, product, marketing, sales)
- **Valuation**: $20-30M post-money

**Series A** (Year 3, Target: $15-25M):
- **Traction**: 50K+ users, $200K+ MRR, enterprise customers
- **Metrics**: 10% paying, profitable unit economics, 10% MoM growth
- **Use of Funds**: Enterprise sales team, international expansion
- **Valuation**: $100-150M post-money

### Investor Pitch Angles

**Problem/Market**:
- $100B+ developer tools market
- Agentic coding is exploding (emergent.sh raised $30M Series A)
- Power users underserved (emergent.sh targets no-code)

**Solution/Product**:
- Local-first agentic IDE (vs cloud-only)
- Automated multi-agent workflows (vs manual)
- Context pollution monitoring (unique IP)

**Traction/Evidence**:
- Working product (Extension MVP)
- User testimonials (power users)
- Growth metrics (users, revenue, retention)

**Team/Execution**:
- Founder is power user, building for self (authentic)
- Dogfooding from day 1 (product validation)
- Technical depth (BMad framework, MCP integration)

**Competition/Moat**:
- emergent.sh is cloud-only (can't pivot to local easily)
- Context monitoring is unique IP (4-compaction insight)
- Community-driven (templates, agents, workflows)

**Ask/Use of Funds**:
- Pre-Seed: $500K for team (2-3 engineers) + growth
- Seed: $3-5M for scaling team to 10 + enterprise sales
- Series A: $15-25M for category leadership

---

## Key Risks & Mitigations

### Risk 1: Agent Cooperation (CRITICAL)

**Risk**: Agents may not respond reliably to programmatic prompt injection

**Likelihood**: Medium (untested, core assumption)
**Impact**: Fatal (entire concept fails if <80% reliability)

**Mitigation**:
- MVD in Week 1-2 validates this immediately
- If fails, pivot to alternative architecture:
  - Option A: Hooks-based (if Claude Code adds support)
  - Option B: Manual workflow + monitoring only
  - Option C: Wait for Anthropic subagent session IDs (#7317)

**Contingency**: Budget 2 weeks for MVD, have pivot plan ready

---

### Risk 2: emergent.sh Competitive Response

**Risk**: emergent.sh adds local IDE before BMad IDE launches

**Likelihood**: Medium (they have $30M, can move fast)
**Impact**: High (reduces differentiation)

**Mitigation**:
- Speed matters - ship Extension in 3 months
- Focus on power users (emergent.sh targets no-code, different segment)
- Context monitoring is unique IP (defensible)
- Open source framework creates lock-in

**Contingency**: Emphasize context monitoring, transparency, customization (harder for emergent.sh to match)

---

### Risk 3: Anthropic Ships Subagent Sessions (#7317)

**Risk**: If Anthropic implements resumable subagent sessions, reduces BMad IDE value

**Likelihood**: Low-Medium (issue open since Sep 2025, no timeline)
**Impact**: Medium (makes automation easier, but BMad IDE offers more)

**Mitigation**:
- BMad IDE is full workflow system (not just persistence)
- Context monitoring, dashboard, templates still valuable
- Embrace it: Use as backend if shipped, add BMad layer on top

**Contingency**: Position as "workflow layer on Claude Code" regardless of subagent implementation

---

### Risk 4: Context Preservation Quality

**Risk**: Agent reloads don't preserve architectural memory well enough

**Likelihood**: Medium (summarization is lossy)
**Impact**: Medium (users frustrated by repeated decisions)

**Mitigation**:
- Test empirically with real projects
- Store key decisions explicitly in story file (UUID schema, auth patterns)
- Iterate on summarization prompts
- Allow manual context injection (user adds notes)

**Contingency**: If reloads aren't good enough, recommend manual reload with user-written summary

---

### Risk 5: User Bandwidth & Commitment

**Risk**: User has other projects (facebook-ads-workflow), may not have 20-40h/week

**Likelihood**: Medium (realistic constraint for most founders)
**Impact**: High (slows progress from 3 months to 6-12 months)

**Mitigation**:
- Be honest about time commitment upfront
- Start with MVD (2 weeks) before committing to full build
- Consider co-founder or technical hire at Pre-Seed
- Use community contributions (open source framework)

**Contingency**: If part-time, adjust timeline 2x (Extension MVP becomes 6 months instead of 3)

---

### Risk 6: Market Education Required

**Risk**: Developers don't know they need "agentic IDE with context monitoring"

**Likelihood**: High (new category)
**Impact**: Medium (slower adoption, higher CAC)

**Mitigation**:
- Show don't tell (demo video > explanation)
- Emphasize pain points (emergent.sh expensive, manual handoffs tedious)
- Free tier for viral adoption
- Community-driven growth (templates, agents)

**Contingency**: Pivot positioning to "better emergent.sh for local dev" (simpler message)

---

## Gap Analysis & Future Work

### Documented Gaps (User-Identified)

**1. Front-End Generation**:
- **Gap**: UI testing works (Playwright MCP), but UI GENERATION is manual
- **Current**: Dev manually writes React components
- **Future**: AI-assisted component generation with shadcn-ui MCP
- **Priority**: Stage 2 feature (after MVP validates core workflow)

**2. Planning/Documentation**:
- **Gap**: "Hierarchical architecture... none of those things have actually been documented"
- **Current**: BMad V4 optimizations are tribal knowledge
- **Future**: Full documentation in bmad-ide/docs/
- **Priority**: Ongoing (started in this session)

**3. Multi-Developer Collaboration**:
- **Gap**: How do 2+ devs work on same project with BMad IDE?
- **Current**: Single-developer workflow only
- **Future**: Git branch coordination, shared handoffs, code review integration
- **Priority**: Stage 3 (Enterprise feature)

**4. Error Recovery**:
- **Gap**: What happens when agent gets stuck/refuses/hallucinates?
- **Current**: No fallback mechanisms
- **Future**: Manual override, retry logic, escalation to user
- **Priority**: Phase 1 (must have for MVP)

### Technical Debt to Address

**1. BMad V4 Optimizations Not Codified**:
- Testing stack guide (Vitest + Playwright MCP)
- Three-terminal workflow patterns
- Handoff format standards
- Context monitoring discovery (4-compaction threshold)

**Action**: Document in bmad-ide/docs/research/

**2. MCP Integration Patterns**:
- Playwright MCP (26 tools)
- Database MCPs (Supabase, MongoDB)
- shadcn-ui MCP (component source)
- Context7 MCP (documentation)

**Action**: Create MCP integration guide in bmad-ide/docs/api/

**3. Agent Activation Instructions**:
- Dev agent handoff reading (STEP 3.8, 3.9) - recently added
- QA agent handoff reading (STEP 3.5) - existing
- Orchestrator agent handoff reading (STEP 3.5, 3.6) - recently added

**Action**: Validate in production, document patterns

---

## Success Metrics & KPIs

### Product Metrics (Leading Indicators)

**Engagement**:
- DAU/MAU ratio (target: >40% for power tools)
- Stories completed per user per week (target: 3-5)
- Handoff automation success rate (target: >85%)
- Agent reload frequency (track: should stabilize at 4 compactions)

**Efficiency**:
- Time saved per story (vs manual workflow, target: 30%+)
- Handoffs automated vs manual (target: >80%)
- Context pollution incidents (target: <5% after auto-reload)

**Quality**:
- Story completion rate (target: >90%)
- Defect rate (QA finding issues, target: <20% of stories)
- User satisfaction (NPS, target: >50)

### Business Metrics (Lagging Indicators)

**Adoption**:
- Total users (Extension + Terminal)
- Active users (used in last 7 days)
- Retention (Day 7, Day 30 - target: >50%, >30%)
- Conversion rate (free to paid, target: >5% by Month 6)

**Revenue**:
- MRR (monthly recurring revenue)
- ARPU (average revenue per user)
- CAC (customer acquisition cost, target: <$100)
- LTV (lifetime value, target: >$500, 5x CAC)
- Marketplace GMV (gross merchandise value)

**Growth**:
- MoM user growth (target: >10% by Month 6)
- MoM revenue growth (target: >15% by Month 12)
- Viral coefficient (users inviting others, target: >0.5)

---

## Next Steps & Action Items

### Immediate (Week 1-2): MVD Validation

**Critical Path**:
1. ✅ Create bmad-ide/ folder structure (DONE in this session)
2. ✅ Document vision (DONE - this document)
3. ⏳ Build MVD (Minimum Viable Demo):
   - File watcher detects handoff creation
   - Inject prompt into terminal
   - Observe agent response
   - **Success Criteria**: 80%+ reliability

**Deliverables**:
- [ ] Simple Node.js script with file watcher
- [ ] VS Code extension skeleton (optional, can use CLI)
- [ ] Test on 3 handoff cycles (QA Handoff → Developer Handoff → Completion Handoff)
- [ ] Document results (success rate, edge cases, issues)

**Decision Gate**: MVD succeeds → Commit to Phase 1. MVD fails → Pivot.

---

### Short-Term (Week 3-4): Architecture Documentation

**If MVD Succeeds**:
1. [ ] Write detailed system architecture document
2. [ ] Design workflow state machine (all states, transitions)
3. [ ] Spec handoff routing logic (parsing, routing rules)
4. [ ] Design context monitoring system (detection, reload logic)
5. [ ] Create dashboard UI mockups (Figma or paper)

**Deliverables**:
- [ ] docs/architecture/system-architecture.md
- [ ] docs/architecture/extension-architecture.md
- [ ] docs/design/workflow-state-machine.md
- [ ] docs/design/handoff-automation.md
- [ ] docs/design/dashboard-ui.md (mockups)

---

### Medium-Term (Month 2-3): Extension MVP Development

**If Architecture Approved**:
1. [ ] VS Code extension foundation (manifest, activation)
2. [ ] File watcher + handoff detection
3. [ ] Prompt injection + terminal routing
4. [ ] State machine implementation
5. [ ] Context monitoring (message counting)
6. [ ] Dashboard webview (basic)
7. [ ] Testing with 5-10 alpha users
8. [ ] Bug fixes + polish
9. [ ] Launch to VS Code Marketplace

**Deliverables**:
- [ ] Working VS Code extension (v0.1.0)
- [ ] User documentation (README, usage guide)
- [ ] Demo video (3 min, shows automation)
- [ ] Launch blog post + HN/Reddit posts

---

### Long-Term (Month 4-12): Terminal System Development

**If Extension MVP Validates**:
1. [ ] Terminal system architecture (detailed design)
2. [ ] Orchestration daemon (Go/Rust)
3. [ ] tmux control + prompt injection
4. [ ] Docker container (Ubuntu + tmux + Claude Code)
5. [ ] Terminal UI dashboard (blessed.js or rust-tui)
6. [ ] Context monitoring (port from Extension)
7. [ ] Testing with power users
8. [ ] Launch to Docker Hub

**Deliverables**:
- [ ] Docker image: bmad-ide/terminal-system
- [ ] Documentation (setup, migration guide)
- [ ] Launch announcement (HN, communities)
- [ ] Funding pitch deck (Pre-Seed)

---

## Conclusion

BMad IDE represents a revolutionary approach to agentic development - combining the automation of platforms like emergent.sh with the control and transparency power users demand.

**Key Innovations**:
1. **Automated Handoffs**: Programmatic terminal communication (no manual copy-paste)
2. **Context Pollution Monitoring**: 4-compaction insight (unique IP)
3. **Two-Stage Architecture**: Extension validates fast, Terminal System differentiates
4. **Local-First**: User's code, user's control, user's API key

**Critical Success Factor**: Agent cooperation (must validate in Week 1-2 MVD)

**Strategic Approach**: Build Extension first (3 months), then Terminal System (9 months). Don't choose - build both in stages.

**Market Opportunity**: Agentic development is exploding. emergent.sh raised $30M for no-code users. Power user market is underserved and higher value (willing to pay $30-50/month).

**Funding Potential**: Pre-Seed at $4-6M valuation ($500K raise) after Extension MVP with 1,000+ users. Seed at $20-30M valuation ($3-5M raise) after Terminal System with $50K+ MRR.

**User's Role**: Founder/Visionary building for self first (dogfooding). Authentic product, proven workflow, passionate about problem.

**Next Milestone**: MVD in 2 weeks - prove agents cooperate. Everything else depends on this.

---

**Session End**: 2025-11-08
**Status**: Vision documented, folder structure created, ready for MVD development
**Next Session**: MVD results review + Phase 1 planning (if MVD succeeds)

---

## Appendix: Key Quotes from Session

**On emergent.sh Limitations**:
> "I don't see the code until I download it... I'm not able to have the freedom I want in changing things inside. Tinkering as a power user, as a 40x or 50x developer, you would need to have your own system because your stacks it will be aligned towards your stacks."

**On Context Pollution Discovery**:
> "When a dev agent is loaded... That dev agent would probably retain quite a lot of its own personality... for 4 compactions. After the 4th compaction, the dev starts forgetting and hallucinating."

**On Subagent Experience**:
> "I've tried subagents inside Claude Code and in my personal opinion they are not so great. Use a lot of token limits but don't get things done properly. Quality is not yet there."

**On Vision**:
> "I want to be able to agentically plan this for developers so that they can choose their stack and even in minute configurations of all these things. And moving back and forth between these terminals and solving the exact problem that sub-agents have right now."

**On Linux Migration**:
> "Moving to Linux seems to be a core option at this point of time... ideally any developer can just load up a VM and load a Docker container with our operating system which has this particular setup set up completely."

**On Human in Loop**:
> "The human in the loop needs only, once I set up all these things... Anytime it breaks I get notified or I get only that when I need to actually peek into this. Peek and see what is happening, where is the current stage of it."

**On Product Vision**:
> "This is going to mature into an again, a no code coding platform, but I don't want it to be no code. I want it to be power user coded just like how cursor IDE is so good at this."
