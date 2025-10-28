# MyDevWF - Professional Development Workflow Templates

> Production-ready project templates with BMad Method and Claude Code MCP integration

## Overview

**MyDevWF** is a comprehensive workflow system that combines:
- ✅ **BMad Method**: AI-driven agile development framework
- ✅ **Claude Code MCPs**: Model Context Protocol for enhanced productivity
- ✅ **Production Templates**: Battle-tested stack configurations
- ✅ **Full Automation**: From planning to deployment

## What's Inside?

### 🎯 4 Production-Ready Templates

| Template | Frontend | Backend | Database | MCPs |
|----------|----------|---------|----------|------|
| **python-fastapi-postgres** | Next.js + TypeScript | Python/FastAPI | PostgreSQL | Playwright + Swagger |
| **nodejs-supabase** | Next.js + TypeScript | Node.js/Supabase | Supabase (PostgreSQL) | Playwright + Supabase + Swagger |
| **nodejs-mongodb** | Next.js + TypeScript | Node.js/Express | MongoDB | Playwright + MongoDB + Swagger |
| **react-native** | React Native (TypeScript) | Backend agnostic | Configurable | Playwright + Backend-specific |

### 🚀 Quick Start

#### 1. Initial Setup (One-time)

```bash
# Install dependencies
npm install

# Verify Playwright MCP is installed globally
npm run mcp:verify
```

#### 2. Create Your First Project

```bash
# Create a new project from template
npm run create-project <template> <project-name>

# Examples:
npm run create-project nodejs-supabase my-saas-app
npm run create-project python-fastapi-postgres my-api-backend
npm run create-project nodejs-mongodb my-document-app
npm run create-project react-native my-mobile-app
```

#### 3. Set Up Your New Project

```bash
cd ../my-new-project
npm install
# Follow template-specific README for additional setup
npm run dev
```

#### 4. Verify MCPs in Claude Code

```bash
# In Claude Code
/mcp

# Should show:
# ✅ playwright (global) - Available in all projects
# ✅ project-specific MCPs (swagger, supabase, or mongodb)
```

## What Are MCPs?

**Model Context Protocol (MCP)** = Superpowers for Claude Code

MCPs let Claude Code directly interact with:
- 🌐 **APIs** (via Swagger MCP) - Test endpoints without Postman
- 🗄️ **Databases** (via Supabase/MongoDB MCP) - Query and manage data
- 🧪 **Testing** (via Playwright MCP) - Generate E2E tests automatically

### Time Savings with MCPs

**Traditional Development** (per story):
1. Write code (10 min)
2. Manual API testing in Postman (5 min)
3. Manual database checks (3 min)
4. Write E2E tests (8 min)
5. Debug and iterate (4 min)
**Total: ~30 min per story**

**MCP-Enhanced Development** (per story):
1. Write code (10 min)
2. **Swagger MCP auto-tests API** (30 sec)
3. **DB MCP auto-verifies data** (30 sec)
4. **Playwright MCP generates tests** (2 min)
**Total: ~13 min per story**

**⚡ 55% faster development per story**

## MCP Configuration Matrix

### Global MCPs (All Projects)
- ✅ **Playwright MCP** - Installed once, available everywhere

### Project-Specific MCPs

#### Python/FastAPI + PostgreSQL
```json
{
  "swagger-api": "http://localhost:8000/openapi.json"
}
```

#### Node.js + Supabase
```json
{
  "supabase-local": "http://localhost:54321/mcp",
  "swagger-api": "http://localhost:3000/api-docs"
}
```

#### Node.js + MongoDB
```json
{
  "mongodb-local": "mongodb://localhost:27017/myapp_dev",
  "swagger-api": "http://localhost:4000/api-docs"
}
```

## BMad Method Integration

### What is BMad?

**BMad** (Breakthrough Method of Agile AI-driven Development) is a framework that transforms you into a "Vibe CEO" - you direct specialized AI agents through structured workflows:

- **Analyst**: Market research, brainstorming, project briefs
- **PM**: PRD creation, requirements management
- **Architect**: System design, technical decisions
- **SM**: Story creation from epics
- **Dev**: Implementation, coding, testing
- **QA**: Test architecture, quality gates
- **PO**: Document validation, sharding

### BMad + MCP = Productivity Boost

**Traditional BMad** (Good):
- AI agents handle planning and development
- Structured workflows ensure quality
- Clear handoffs between phases

**BMad + MCPs** (Better):
- AI agents can test APIs automatically
- AI agents can query databases directly
- AI agents can generate E2E tests on demand
- **50-60% faster development cycle**

### BMad Workflow Example

#### Planning Phase (Web UI - Large Context)
```
1. @analyst - Create project brief
2. @pm - Generate PRD with epics/stories
3. @architect - Design system architecture
4. @po - Validate alignment, shard documents
```

#### Development Phase (Claude Code + MCPs)
```
1. /BMad/agents/sm - Create next story
2. /BMad/agents/dev - Implement story
   → Dev uses Swagger MCP to test API ✅
   → Dev uses DB MCP to verify data ✅
   → Dev uses Playwright MCP for E2E tests ✅
3. /BMad/agents/qa - Review and validate
4. Commit and repeat
```

## Project Structure

```
mydevwf/
├── .bmad-core/                         # BMad framework (installed)
│   ├── agents/                         # Agent definitions
│   ├── tasks/                          # Task definitions
│   ├── templates/                      # Document templates
│   └── user-guide.md                   # Complete BMad guide
├── .bmad-infrastructure-devops/        # DevOps expansion pack
├── .claude/                            # Claude Code configuration
│   └── commands/                       # Slash commands for agents
├── project-templates/                  # Template library
│   ├── python-fastapi-postgres/        # Python + FastAPI template
│   ├── nodejs-supabase/                # Node.js + Supabase template
│   ├── nodejs-mongodb/                 # Node.js + MongoDB template
│   └── react-native/                   # React Native template
├── docs/
│   └── templates/
│       ├── MASTER-TEMPLATE-GUIDE.md    # This guide
│       └── MCP-INTEGRATION-GUIDE.md    # MCP details
├── scripts/
│   ├── create-project.js               # Project creation script
│   └── help.js                         # Help command
├── package.json                        # NPM scripts
├── CLAUDE.md                           # Claude Code guidance
└── README.md                           # This file
```

## Available Commands

```bash
# Create new project
npm run create-project <template> <project-name>

# Verify MCP setup
npm run mcp:verify

# List all MCPs
npm run mcp:list

# Show help
npm run help
```

## Template Details

### 1. Python/FastAPI + PostgreSQL

**When to use**:
- API-first backends
- Data-intensive applications
- ML/AI pipelines
- Mature Python ecosystem needed

**Key Features**:
- FastAPI auto-generates OpenAPI/Swagger docs
- SQLAlchemy ORM with Alembic migrations
- Async/await support
- Type hints with Pydantic validation

**MCPs**:
- Playwright (E2E testing)
- Swagger (API testing via FastAPI's `/openapi.json`)

**Setup Time**: 5 minutes

---

### 2. Node.js + Supabase

**When to use**:
- Rapid prototyping
- Real-time applications
- Serverless backends
- Built-in auth & storage needed

**Key Features**:
- Supabase Auth (email, OAuth, magic link)
- Real-time subscriptions
- Row Level Security (RLS)
- Edge Functions (Deno)
- File uploads to Supabase Storage

**MCPs**:
- Playwright (E2E testing)
- Supabase (database operations, migrations, logs)
- Swagger (API testing)

**Setup Time**: 3 minutes

---

### 3. Node.js + MongoDB

**When to use**:
- Document-heavy applications
- Flexible/evolving schemas
- High write throughput
- Complex aggregations

**Key Features**:
- Mongoose ODM with schema validation
- Aggregation pipelines
- Performance Advisor integration
- Atlas cloud deployment ready

**MCPs**:
- Playwright (E2E testing)
- MongoDB (database queries, indexes, optimization)
- Swagger (API testing)

**Setup Time**: 5 minutes

---

### 4. React Native (Mobile)

**When to use**:
- Cross-platform mobile apps (iOS + Android)
- Native performance required
- Shared codebase for mobile platforms

**Key Features**:
- TypeScript for type safety
- React Native navigation
- Backend agnostic (choose any backend template)
- Platform-specific code support

**MCPs**:
- Playwright (web components, OAuth flows)
- Backend-specific MCP (Supabase or MongoDB)
- Swagger (mobile API testing)

**Setup Time**: 5 minutes

---

## Documentation

### Quick References
- **Master Guide**: `docs/templates/MASTER-TEMPLATE-GUIDE.md`
- **MCP Integration**: `docs/templates/MCP-INTEGRATION-GUIDE.md`
- **Claude Code Guide**: `CLAUDE.md`

### BMad Resources
- **User Guide**: `.bmad-core/user-guide.md`
- **IDE Workflow**: `.bmad-core/enhanced-ide-development-workflow.md`
- **Brownfield Guide**: `.bmad-core/working-in-the-brownfield.md`

### Template-Specific
Each template has its own detailed README:
- `project-templates/python-fastapi-postgres/README.md`
- `project-templates/nodejs-supabase/README.md`
- `project-templates/nodejs-mongodb/README.md`
- `project-templates/react-native/README.md`

## Common Workflows

### Starting a New SaaS App

```bash
# 1. Create project
npm run create-project nodejs-supabase my-saas-app
cd ../my-saas-app

# 2. Setup
npm install
supabase init
supabase start

# 3. Configure
# Edit .env.local with Supabase credentials

# 4. Start BMad planning (Web UI)
# Use PM agent to create PRD
# Use Architect agent to design system

# 5. Develop in Claude Code
/BMad/agents/sm  # Create stories
/BMad/agents/dev # Implement with Supabase MCP
/BMad/agents/qa  # Review with quality gates
```

### Building a REST API

```bash
# 1. Create project
npm run create-project python-fastapi-postgres my-api
cd ../my-api

# 2. Setup
pip install -r backend/requirements.txt
docker-compose up -d postgres

# 3. Configure
# Edit backend/.env with database credentials

# 4. Develop
/BMad/agents/dev # Implement endpoints
# Swagger MCP auto-tests via /openapi.json
# Playwright MCP generates E2E tests

# 5. Verify
curl http://localhost:8000/docs  # Swagger UI
```

### Creating a Mobile App

```bash
# 1. Create project
npm run create-project react-native my-mobile-app
cd ../my-mobile-app

# 2. Choose backend (e.g., Supabase)
# Add Supabase MCP to .mcp.json

# 3. Setup
npm install
npx expo install

# 4. Develop
/BMad/agents/dev # Build features
# Use backend MCP for data operations
# Use Playwright MCP for web-view tests

# 5. Run
npm run ios      # iOS simulator
npm run android  # Android emulator
```

## Troubleshooting

### MCP Not Showing Up

**Issue**: `/mcp` in Claude Code doesn't show expected MCPs

**Solutions**:
1. Check `.mcp.json` syntax (valid JSON, no trailing commas)
2. Restart Claude Code
3. Verify services are running (database, API server)
4. Run `claude mcp list` to see all configured MCPs

### Template Creation Fails

**Issue**: `npm run create-project` errors

**Solutions**:
1. Ensure you're in the `mydevwf` directory
2. Check template name is correct (use `npm run help`)
3. Verify project name uses only lowercase, numbers, hyphens
4. Check destination doesn't already exist

### Database Connection Errors

**Supabase**:
```bash
supabase status  # Check if running
supabase start   # Start if stopped
```

**MongoDB**:
```bash
mongod --version  # Check installation
mongod            # Start MongoDB
```

**PostgreSQL**:
```bash
pg_isready        # Check if running
docker-compose up postgres  # Start via Docker
```

## Best Practices

### 1. Security
- ✅ Never commit `.env` or `.env.local` files
- ✅ Use `read_only=true` for Supabase MCP on remote instances
- ✅ Keep `.claude/settings.local.json` in `.gitignore`
- ✅ Separate dev/staging/prod configurations

### 2. Team Collaboration
- ✅ Commit `.mcp.json` (team-shared MCP config)
- ✅ Provide `.claude/settings.local.json.example` for team reference
- ✅ Document MCP usage in project README
- ✅ Keep BMad documents in version control

### 3. Development Workflow
- ✅ Use BMad planning phase in web UI (cost-effective large context)
- ✅ Use BMad development phase in Claude Code (file operations + MCPs)
- ✅ Start new conversations for each agent (clean context)
- ✅ Commit regularly (after each story completion)

### 4. MCP Usage
- ✅ Let Claude Code use MCPs automatically during development
- ✅ Verify MCP connections with `/mcp` command
- ✅ Update MCP URLs when switching environments
- ✅ Test MCPs individually before full development

## Roadmap

- [ ] GitHub Actions CI/CD templates
- [ ] Kubernetes deployment configurations
- [ ] Additional backend templates (Go, Rust)
- [ ] Mobile testing MCP integration (Appium)
- [ ] Monitoring and observability setup

## Contributing

This is a personal workflow system. Feel free to fork and customize for your needs.

## License

MIT

## Support

- **BMad Community**: [Discord](https://discord.gg/gk8jAdXWmj)
- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code
- **MCP Documentation**: https://docs.claude.com/en/docs/mcp

---

**Built with**:
- 🧠 BMad Method v4
- 🤖 Claude Code
- 🔌 Model Context Protocol
- 💙 TypeScript, Python, React, Next.js

**Happy Building! 🚀**
