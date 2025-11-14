# BMad IDE Product Roadmap

**Last Updated**: 2025-11-08
**Vision**: Agentic development environment for power users - automated workflows with full transparency and control

---

## Strategy: Two-Stage Architecture

### Stage 1: VS Code Extension (Months 1-3)
**Goal**: Validate core concept fast
**Market**: 100M+ VS Code users

### Stage 2: Pure Linux Terminal System (Months 4-12)
**Goal**: Revolutionary power-user platform
**Market**: Terminal power users, Linux enthusiasts

**Rationale**: Extension validates concept and generates revenue while we build Terminal System. Both share backend eventually.

---

## Phase 0: MVD - Minimum Viable Demo

**Timeline**: Weeks 1-2
**Status**: ⏳ CURRENT PHASE

### Critical Validation

**Goal**: Prove agents respond reliably to programmatic prompt injection

**Why Critical**: Entire concept depends on this. If agents ignore injections >20% of time, system fails.

### Deliverables

- [ ] Node.js script with file watcher
- [ ] Detect handoff document creation
- [ ] Inject prompt into VS Code terminal
- [ ] Test on 3 handoff cycles
- [ ] Measure success rate

### Success Criteria

**PASS**: Agents respond correctly ≥80% of time → Proceed to Phase 1
**FAIL**: <80% reliability → Pivot immediately

### Pivot Options (If MVD Fails)

**Option A**: Hooks-based system (wait for Claude Code hook support)
**Option B**: Manual workflow + monitoring only (smaller product)
**Option C**: Focus on BMad framework, abandon IDE

---

## Phase 1: Extension MVP

**Timeline**: Months 1-3
**Status**: ⏸️ Pending MVD Success
**Budget**: Self-funded or small angel ($50K-100K)

### Month 1: Foundation & Automation

**Weeks 1-2**: Extension Foundation
- [ ] VS Code extension scaffolding (manifest, activation)
- [ ] File watcher integration (chokidar)
- [ ] Basic prompt injection

**Weeks 3-4**: Handoff Automation
- [ ] Parse all 5 handoff types (Story, QA, Developer, Completion, Test Review)
- [ ] Route to correct terminal
- [ ] Workflow state machine

### Month 2: Monitoring & UI

**Weeks 5-6**: Context Monitoring
- [ ] Message counting (estimate compactions)
- [ ] Warning notifications (3 compactions)
- [ ] Manual reload capability
- [ ] Context preservation (summarization)

**Weeks 7-8**: Dashboard UI
- [ ] Webview panel with workflow state
- [ ] Terminal status (context health indicators)
- [ ] Quick-jump to terminals
- [ ] Recent events log
- [ ] Manual override controls

### Month 3: Polish & Launch

**Weeks 9-10**: Testing & Refinement
- [ ] Error handling (agent stuck, timeout, refuses)
- [ ] User testing (5-10 alpha testers)
- [ ] Bug fixes from feedback
- [ ] Performance optimization

**Weeks 11-12**: Launch
- [ ] Documentation (README, usage guide, video demo)
- [ ] Publish to VS Code Marketplace (free tier)
- [ ] Launch announcement (HN, Reddit, Twitter, Product Hunt)
- [ ] Community setup (Discord, GitHub Discussions)

### Success Metrics (End of Phase 1)

**Adoption**:
- 100+ active users (realistic for niche tool)
- 80%+ handoff automation success rate
- 50%+ Day-7 retention

**Quality**:
- 90%+ user satisfaction (NPS >50)
- <5% critical bugs reported
- 5+ community contributions (issues, PRs)

**Revenue**:
- $0 (all free tier, focus on validation)

### Go/No-Go Decision

**GO → Phase 2** (Terminal System):
- ✅ >100 active users
- ✅ >80% automation success
- ✅ >90% user satisfaction
- ✅ Clear demand for Terminal System from users

**NO-GO** (Iterate on Extension):
- ❌ <50 active users
- ❌ <70% automation success
- ❌ Low satisfaction / many complaints
- → Fix issues, iterate, delay Phase 2

---

## Phase 2: Terminal System Architecture

**Timeline**: Months 4-6
**Status**: ⏸️ Pending Phase 1 Success
**Budget**: Bootstrap or Pre-Seed raise ($500K-1M)

### Month 4: Design & Planning

**Architecture Design**:
- [ ] Document full terminal system architecture
- [ ] Technology selection (Go vs Rust for daemon)
- [ ] Terminal UI design (blessed.js vs rust-tui vs Bubble Tea)
- [ ] Docker container architecture
- [ ] Installation & setup flow

**Technical Research**:
- [ ] tmux control API investigation
- [ ] Claude Code CLI capabilities
- [ ] neovim/vim integration options
- [ ] Linux distribution selection (Ubuntu vs Alpine)

### Month 5: Orchestration Daemon POC

**Core Daemon**:
- [ ] Build standalone orchestration daemon (not VS Code-dependent)
- [ ] File watcher (portable from Extension)
- [ ] tmux control (send-keys, pane management)
- [ ] State machine (reusable from Extension)
- [ ] Configuration system (YAML-based)

**Testing**:
- [ ] Validate daemon works independently
- [ ] Test tmux automation reliability
- [ ] Measure overhead vs Extension

### Month 6: Terminal Control POC

**Integration**:
- [ ] Inject prompts into tmux panes
- [ ] Test agent cooperation in terminal context
- [ ] Compare reliability to Extension (should be ≥Extension rate)
- [ ] Docker container prototype

**Decision Gate**:
- ✅ Terminal system ≥80% reliable → Proceed to Phase 3
- ❌ <80% reliable → Iterate, improve, re-test

---

## Phase 3: Terminal System MVP

**Timeline**: Months 7-12
**Status**: ⏸️ Pending Phase 2 Validation
**Budget**: Pre-Seed ($500K-1M) for team expansion

### Months 7-8: Core Development

**System Components**:
- [ ] Complete orchestration daemon (all features from Extension)
- [ ] Docker container (Ubuntu + tmux + Claude Code CLI)
- [ ] Configuration system (stack selection, MCP config)
- [ ] Project template support (4 stacks + custom)
- [ ] neovim/vim integration

**Workflow Automation**:
- [ ] All 5 handoff types supported
- [ ] Context monitoring (port from Extension)
- [ ] Agent reload with context preservation
- [ ] Process management (PID tracking, logs)

### Months 9-10: UI & Polish

**Terminal Dashboard**:
- [ ] Terminal UI (blessed.js or Bubble Tea)
- [ ] Workflow state visualization
- [ ] Context health indicators
- [ ] Recent events log
- [ ] Manual controls (pause, reload, override)

**User Experience**:
- [ ] Installation script (one-command setup)
- [ ] Configuration wizard (interactive setup)
- [ ] Documentation (comprehensive guides)
- [ ] Migration guide (Extension → Terminal)

### Month 11: Testing & Iteration

**Quality Assurance**:
- [ ] Full workflow testing (10+ stories end-to-end)
- [ ] Edge case handling
- [ ] Performance optimization (minimize latency)
- [ ] Resource usage optimization (Docker size, CPU, memory)

**User Testing**:
- [ ] Beta program with 20-30 power users
- [ ] Gather feedback
- [ ] Iterate based on usage patterns
- [ ] Fix critical bugs

### Month 12: Launch

**Release**:
- [ ] Docker Hub publish (official image)
- [ ] Documentation site (setup, usage, troubleshooting)
- [ ] Launch video (technical deep dive)
- [ ] Launch announcement (HN focus, Linux communities)

**Community**:
- [ ] Template contribution guide
- [ ] Custom stack documentation
- [ ] Contributing guide (daemon, UI improvements)

### Success Metrics (End of Phase 3)

**Adoption**:
- 500+ users (smaller market, but engaged)
- 90%+ handoff automation success
- 60%+ Day-30 retention (power users stick longer)

**Quality**:
- 95%+ user satisfaction
- <3% critical bugs
- 10+ community Docker images (custom stacks)

**Revenue**:
- Begin charging for Pro tier
- Target: 50 paying users × $40/mo = $2K MRR

---

## Phase 4: Convergence & Scale

**Timeline**: Year 2 (Months 13-24)
**Status**: ⏸️ Future Planning
**Budget**: Seed ($3-5M) for team scaling

### Months 13-15: Shared Backend

**Architecture Refactor**:
- [ ] Extract orchestration logic into standalone service
- [ ] Extension and Terminal both use same backend
- [ ] Handoff format standardization
- [ ] State machine unification
- [ ] API layer (REST or gRPC)

**Benefits**:
- Single codebase for core logic
- Consistent behavior across frontends
- Easier to add new frontends (web, mobile)

### Months 16-18: Marketplace Foundation

**Platform Features**:
- [ ] Template marketplace (creators upload, users purchase)
- [ ] Payment processing (Stripe integration)
- [ ] Revenue sharing (70/30 split)
- [ ] Review system (ratings, comments)

**Initial Content**:
- [ ] 20+ official templates (free + paid)
- [ ] 5+ premium MCPs
- [ ] 10+ custom agents
- [ ] 5+ workflow blueprints

### Months 19-21: Enterprise Features

**Team Collaboration**:
- [ ] Shared handoff documents (team visibility)
- [ ] Code review integration (GitHub, GitLab)
- [ ] Analytics dashboard (team velocity, quality metrics)
- [ ] Role-based access control

**Deployment**:
- [ ] On-premise deployment guide (Docker Swarm, K8s)
- [ ] SSO integration (SAML, LDAP, OAuth)
- [ ] Enterprise security (audit logs, compliance)

### Months 22-24: Scale & Expansion

**Growth Initiatives**:
- [ ] Expand to 10,000+ users
- [ ] $100K+ MRR
- [ ] International expansion (localization)
- [ ] Strategic partnerships (Anthropic, VS Code team)

**Product**:
- [ ] Web-based dashboard (access from anywhere)
- [ ] Mobile monitoring app (check workflow status)
- [ ] AI-powered insights (suggest optimizations)

### Success Metrics (End of Year 2)

**Adoption**:
- 10,000+ total users
- 1,000+ paying users (10% conversion)
- 70%+ Day-30 retention

**Revenue**:
- $50K+ MRR ($600K+ ARR)
- $10K+ marketplace GMV/month
- 5+ enterprise customers ($20K+ each)

**Market**:
- Category leader in "power-user agentic IDE"
- Press coverage (TechCrunch, The Verge)
- Conference talks (by founder or users)

---

## Feature Backlog

### High Priority (Phase 1-2)

- [x] Automated handoff detection
- [x] Prompt injection into terminals
- [x] Context pollution monitoring
- [x] Agent reload with context
- [ ] Error recovery (agent stuck, timeout)
- [ ] Dashboard UI (workflow state, events)
- [ ] Manual override controls
- [ ] Background process management
- [ ] Handoff document creation (auto-generate)

### Medium Priority (Phase 3-4)

- [ ] Multi-project workspace
- [ ] Advanced context monitoring (ML-based)
- [ ] Template marketplace
- [ ] Custom agent creation wizard
- [ ] Workflow customization (enable/disable steps)
- [ ] Performance analytics (time saved, story velocity)
- [ ] Git branch coordination (multi-developer)
- [ ] Code review integration

### Low Priority (Year 2+)

- [ ] Web-based dashboard
- [ ] Mobile monitoring app
- [ ] Front-end generation (AI-assisted components)
- [ ] AI-powered insights (optimization suggestions)
- [ ] Voice control (experimental)
- [ ] Team collaboration features
- [ ] Enterprise SSO, audit logs
- [ ] Internationalization (localization)

---

## Funding Roadmap

### Bootstrap (Months 1-6)

**Funding**: Self-funded or small angel ($50K-100K)
**Milestone**: Extension MVP launched
**Use**: Living expenses, infrastructure, tools

### Pre-Seed (Month 7)

**Target**: $500K-1M
**Valuation**: $4-6M post-money
**Milestone**: 1,000+ users, 5% paying, $5K+ MRR
**Use**: Hire 2-3 engineers, marketing/growth
**Investors**: Angels, pre-seed funds (e.g., Y Combinator, Entrepreneur First)

### Seed (Month 18)

**Target**: $3-5M
**Valuation**: $20-30M post-money
**Milestone**: 10,000+ users, 8% paying, $50K+ MRR
**Use**: Scale team to 10 (eng, product, marketing, sales)
**Investors**: Seed funds (e.g., Accel, Greylock, Sequoia)

### Series A (Year 3)

**Target**: $15-25M
**Valuation**: $100-150M post-money
**Milestone**: 50K+ users, $200K+ MRR, profitable unit economics
**Use**: Enterprise sales team, international expansion, category leadership
**Investors**: Growth VCs (e.g., Andreessen Horowitz, General Catalyst)

---

## Risk Management

### Critical Risks

**Risk 1: Agent Cooperation** (HIGHEST PRIORITY)
- **Status**: Unvalidated, testing in Week 1-2 MVD
- **Mitigation**: Fast validation, pivot plan ready
- **Impact**: Fatal if <80% reliability

**Risk 2: emergent.sh Competitive Response**
- **Status**: Monitoring, no signs yet
- **Mitigation**: Speed (3 mo Extension launch), differentiation (context monitoring)
- **Impact**: High if they add local IDE

**Risk 3: Anthropic Ships Subagent Sessions (#7317)**
- **Status**: Issue open since Sep 2025, no timeline
- **Mitigation**: Position as workflow layer regardless
- **Impact**: Medium (reduces differentiation, but BMad IDE offers more)

**Risk 4: User Bandwidth**
- **Status**: Unknown (user has other projects)
- **Mitigation**: Honest time commitment assessment, consider co-founder
- **Impact**: High (slows timeline 2x if part-time)

### Mitigation Strategies

1. **MVD Fast Fail**: Test core assumption in 2 weeks, pivot if needed
2. **Community-Driven**: Open source framework, leverage contributions
3. **Staged Rollout**: Extension first (faster), Terminal second (lower risk)
4. **Clear Differentiation**: Context monitoring is unique IP, hard to copy
5. **Funding Early**: Pre-Seed at Month 7 enables hiring, accelerates development

---

## Success Definition

### Phase 1 Success (Extension MVP)
- ✅ 100+ active users
- ✅ 80%+ automation success rate
- ✅ 90%+ user satisfaction
- ✅ Clear demand for Terminal System

### Phase 3 Success (Terminal System MVP)
- ✅ 500+ users on Terminal System
- ✅ 90%+ automation success rate
- ✅ $2K+ MRR
- ✅ 10+ community contributions (templates, agents)

### Year 2 Success (Convergence & Scale)
- ✅ 10,000+ users
- ✅ $50K+ MRR
- ✅ 5+ enterprise customers
- ✅ Category leader positioning

### Long-Term Success (3-5 Years)
- ✅ 100,000+ users
- ✅ $1M+ MRR
- ✅ Profitable (or clear path to profitability)
- ✅ Industry standard for power-user agentic development

---

## Next Actions

### This Week (Week 1)

1. ✅ Create bmad-ide/ folder structure (DONE)
2. ✅ Document vision (DONE - see research-notes/2025-11-08-bmad-ide-vision-session.md)
3. ⏳ Plan MVD implementation
4. ⏳ Set up development environment
5. ⏳ Begin MVD coding (file watcher + prompt injection)

### Next Week (Week 2)

1. ⏳ Complete MVD implementation
2. ⏳ Test on 3 handoff cycles
3. ⏳ Measure success rate
4. ⏳ Document results
5. ⏳ Make GO/NO-GO decision

### Month 1 (If MVD Succeeds)

1. ⏳ Write detailed architecture documents
2. ⏳ Begin Phase 1 development (Extension MVP)
3. ⏳ Set up alpha tester program
4. ⏳ Create demo assets (video script, screenshots)

---

**Document Version**: 1.0
**Last Updated**: 2025-11-08
**Owner**: [User Name]
**Status**: Planning Phase - MVD in Progress
