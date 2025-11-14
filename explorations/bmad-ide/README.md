# BMad IDE

**Agentic Development Environment for Power Users**

> "emergent.sh meets VS Code - for developers who want control, transparency, and local-first development"

---

## Vision

BMad IDE is a revolutionary development environment that automates agentic workflows while maintaining full transparency and control for power users. Unlike cloud-based platforms (emergent.sh, Bolt.new), BMad IDE runs locally with persistent agents, automated handoffs, and context pollution monitoring.

## The Problem

**Current Agentic Dev Platforms**:
- ❌ emergent.sh: Expensive ($10-167/mo + credits), cloud-only, black box
- ❌ Claude Code Subagents: Stateless, 20k token overhead, lower quality
- ❌ Manual Three-Terminal Workflow: Works but requires constant human copy-paste

**Key Pain Point**: Terminals cannot communicate programmatically. Developers manually copy handoffs between Dev/QA terminals, wasting time and breaking flow.

## The Solution

BMad IDE provides:
- ✅ **Automated Handoff System**: File watcher detects handoffs, injects prompts into target terminals
- ✅ **Context Pollution Monitoring**: Tracks compactions (4-compaction threshold), auto-reloads agents with context preservation
- ✅ **Persistent Agents**: Three terminals (Orchestrator, Dev, QA) maintain context across stories
- ✅ **Transparency Dashboard**: Real-time visibility into workflow state, agent health, process status
- ✅ **Local-First**: Your code, your control, BYO Claude API key
- ✅ **Stack Agnostic**: Configure any tech stack, not platform-defined

## Architecture Stages

### Stage 1: VS Code Extension (Months 1-3)
- File watcher + automated handoff injection
- Context health monitoring
- Dashboard webview
- **Goal**: Validate core concept, fast iteration

### Stage 2: Pure Linux Terminal System (Months 4-12)
- Ubuntu Docker container with tmux
- Orchestration daemon (Go/Rust)
- Terminal UI dashboard
- **Goal**: Revolutionary power-user platform

### Stage 3: Convergence (Year 2)
- Shared orchestration backend
- Choose frontend: IDE or Terminal
- Extension = "easy mode", Terminal = "power mode"

## Project Status

**Current Phase**: Documentation & POC Planning
**Last Updated**: 2025-11-07
**Next Milestone**: MVD (Minimum Viable Demo) - File watcher + prompt injection test

## Repository Structure

```
bmad-ide/
├── docs/
│   ├── architecture/         # System design documents
│   ├── research/             # Market analysis, competitive research
│   ├── planning/             # Roadmap, feature backlog
│   ├── design/               # UI mockups, workflow diagrams
│   └── api/                  # API specifications
├── poc/
│   ├── extension-poc/        # VS Code extension POC code
│   └── terminal-poc/         # Terminal system POC code
├── research-notes/           # Session logs, research findings
└── assets/                   # Diagrams, mockups, presentations
```

## Key Documents

- [System Architecture](docs/architecture/system-architecture.md) - Overall platform design
- [Vision Session (2025-11-07)](research-notes/2025-11-07-vision-session.md) - Original conception conversation
- [Product Roadmap](docs/planning/product-roadmap.md) - Stage 1-3 timeline
- [emergent.sh Analysis](docs/research/emergent-analysis.md) - Competitive analysis

## Core Innovation: Context Pollution Solution

**Discovery**: Dev agents retain quality for ~4 compactions, then degrade (hallucinations, forgetting architectural decisions).

**Solution**:
1. Track compaction count via message monitoring
2. Warn at compaction 3
3. Auto-reload at compaction 4 with context summary
4. Preserve architectural memory (UUIDs, schema decisions, patterns)

**No competitor addresses this** - unique differentiator.

## Target Users

1. **Power Users (40x Developers)**: Want agentic acceleration without giving up control
2. **Freelancers/Consultants**: Need fast project setup with full customization
3. **Dev Teams (5-50 engineers)**: Want transparent agentic workflows for production code

## Competitive Positioning

| Platform | Target | Control | Location | Cost |
|----------|--------|---------|----------|------|
| **emergent.sh** | No-code users | Low | Cloud-only | $10-167/mo + credits |
| **BMad IDE** | Power devs | High | Local-first | Free (BYO API) or $29-49/mo |
| **Cursor/Claude Code** | General devs | Medium | Local | Free (BYO API) |

**Positioning**: "emergent.sh for power users who want control, transparency, and local-first development"

## Technology Stack

**Extension (Stage 1)**:
- TypeScript
- VS Code Extension API
- Node.js (file watching, orchestration)
- chokidar (file watcher)

**Terminal System (Stage 2)**:
- Go or Rust (orchestration daemon)
- tmux (terminal multiplexer)
- Docker (containerization)
- blessed.js or rust-tui (terminal UI)

**Shared**:
- BMad Framework (agents, tasks, workflows)
- Claude Code CLI (agent runtime)
- MCP Ecosystem (Playwright, Database, shadcn, Context7)

## Getting Started

**For Development**:
1. Clone repository
2. Read [System Architecture](docs/architecture/system-architecture.md)
3. Review [Vision Session](research-notes/2025-11-07-vision-session.md)
4. Set up POC: `cd poc/extension-poc && npm install`

**For Usage** (Future):
- Stage 1: Install VS Code extension from marketplace
- Stage 2: `docker run -it bmad-ide/terminal-system`

## Commercialization Strategy

**Free Tier** (Open Source):
- BMad framework
- VS Code extension (basic features)
- Community templates

**Pro Tier** ($29-49/month):
- Advanced context monitoring (ML-based)
- Multi-project workspace
- Priority support
- Premium templates

**Enterprise Tier** (Custom):
- Team collaboration
- Custom agent development
- On-premise deployment
- SSO + enterprise security

**Marketplace** (30% platform fee):
- Template marketplace
- MCP integration library
- Custom agent store

## Funding Strategy

**Pre-Seed** (Target: $500K-1M):
- Extension MVP complete
- 1,000+ active users
- Proven unit economics
- Use: Hire 2-3 engineers, marketing

**Seed** (Target: $3-5M):
- Terminal System MVP complete
- 10,000+ active users
- $50K+ MRR
- Use: Scale team to 10, expand platform

## Contributing

**Current Status**: Private development, documentation phase
**Future**: Open source framework, contributions welcome
**Contact**: [To be added]

## License

[To be determined - likely MIT for framework, commercial for platform]

---

**Last Updated**: 2025-11-07
**Status**: Documentation & POC Planning Phase
**Next Milestone**: MVD (Week 1-2)
