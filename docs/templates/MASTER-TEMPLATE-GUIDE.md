# Master Template Guide - MyDevWF

## Overview

This workflow system provides production-ready project templates for all your development scenarios, fully integrated with BMad Method and Claude Code MCPs.

## Available Templates

### 1. Python/FastAPI + PostgreSQL
- **Path**: `project-templates/python-fastapi-postgres/`
- **Stack**: React/Next.js (TypeScript) + Python/FastAPI + PostgreSQL
- **MCPs**: Playwright (global) + Swagger
- **Use Cases**: API-first backends, data-intensive applications, ML pipelines

### 2. Node.js + Supabase
- **Path**: `project-templates/nodejs-supabase/`
- **Stack**: React/Next.js (TypeScript) + Node.js + Supabase (PostgreSQL)
- **MCPs**: Playwright (global) + Supabase + Swagger
- **Use Cases**: Rapid prototyping, real-time apps, serverless backends

### 3. Node.js + MongoDB
- **Path**: `project-templates/nodejs-mongodb/`
- **Stack**: React/Next.js (TypeScript) + Node.js + MongoDB
- **MCPs**: Playwright (global) + MongoDB + Swagger
- **Use Cases**: Document-heavy apps, flexible schemas, scalable APIs

### 4. React Native (Mobile)
- **Path**: `project-templates/react-native/`
- **Stack**: React Native (TypeScript) + Backend agnostic
- **MCPs**: Playwright (global) + Backend-specific MCP
- **Use Cases**: Cross-platform mobile apps (iOS + Android)

## Global Configuration

### Playwright MCP (User Scope)
Already installed globally and available across all projects:
```bash
# Verify installation
claude mcp list
```

## Quick Start

### Creating a New Project

1. **Choose your stack template**:
   ```bash
   # Python/FastAPI
   npm run create-project python-fastapi my-new-api

   # Node.js/Supabase
   npm run create-project nodejs-supabase my-new-app

   # Node.js/MongoDB
   npm run create-project nodejs-mongodb my-new-service

   # React Native
   npm run create-project react-native my-mobile-app
   ```

2. **Navigate to your project**:
   ```bash
   cd my-new-project
   ```

3. **Install dependencies**:
   ```bash
   npm run setup
   ```

4. **Configure MCPs**:
   ```bash
   # MCPs are auto-configured from template
   # Update environment-specific values in .mcp.json
   ```

5. **Start BMad workflow**:
   - Follow `.bmad-core/enhanced-ide-development-workflow.md`
   - Use appropriate agents for your phase

## Template Structure

Each template includes:

```
template-name/
├── .mcp.json                          # Project-specific MCP configuration
├── .claude/
│   └── settings.local.json.example    # Example local settings
├── .gitignore                         # Includes .claude/settings.local.json
├── docs/
│   ├── prd.md.template                # PRD template
│   ├── architecture/
│   │   ├── coding-standards.md.template
│   │   ├── tech-stack.md              # Pre-filled for this stack
│   │   ├── source-tree.md.template
│   │   └── mcp-integration.md         # MCP usage guide for this stack
│   ├── epics/                         # Empty, populated during planning
│   ├── stories/                       # Empty, populated during dev
│   └── qa/
│       ├── assessments/               # Empty, populated by QA agent
│       └── gates/                     # Empty, populated by QA agent
├── frontend/                          # Frontend structure (React/Next.js/React Native)
├── backend/                           # Backend structure (stack-specific)
├── tests/
│   ├── e2e/                          # Playwright tests
│   ├── integration/                   # Integration tests
│   └── unit/                         # Unit tests
├── package.json                       # Node.js dependencies + scripts
├── pyproject.toml (if Python)         # Python dependencies
├── docker-compose.yml                 # Local development stack
└── README.md                          # Stack-specific setup guide
```

## MCP Configuration Matrix

| Template | Playwright | Swagger | Supabase | MongoDB |
|----------|-----------|---------|----------|---------|
| Python/FastAPI | ✅ Global | ✅ Project | ❌ | ❌ |
| Node.js/Supabase | ✅ Global | ✅ Project | ✅ Project | ❌ |
| Node.js/MongoDB | ✅ Global | ✅ Project | ❌ | ✅ Project |
| React Native | ✅ Global | ✅ Project* | ✅/❌ Backend† | ✅/❌ Backend† |

*Swagger MCP points to backend API
†Depends on chosen backend stack

## BMad Integration

### Planning Phase (Recommended: Web UI)
1. Use web agents (Gemini/Claude web) with large context
2. Generate PRD and Architecture documents
3. Validate with PO agent
4. Save documents to `docs/` in your project

### Development Phase (IDE: Claude Code)
1. Open project in Claude Code
2. MCPs automatically available (configured in `.mcp.json`)
3. Use BMad agents via slash commands:
   - `/BMad/agents/sm` - Create stories
   - `/BMad/agents/dev` - Implement stories
   - `/BMad/agents/qa` - Review and test
4. MCPs enhance agent capabilities:
   - Dev agent can test APIs via Swagger MCP
   - Dev agent can query DB via Supabase/MongoDB MCP
   - QA agent can generate E2E tests via Playwright MCP

### MCP-Enhanced Workflow

**Story Implementation (Dev Agent)**:
```
1. Dev reads story from docs/stories/
2. Dev implements code
3. Dev uses Swagger MCP to test API endpoints automatically
4. Dev uses DB MCP to verify database changes
5. Dev uses Playwright MCP to generate E2E tests
6. Dev marks story complete
```

**QA Review (QA Agent)**:
```
1. QA runs *review command
2. QA uses Playwright MCP to verify test coverage
3. QA uses Swagger MCP to validate API contracts
4. QA uses DB MCP to check database integrity
5. QA generates gate decision
```

## Environment-Specific Configuration

### Development
```json
// .mcp.json points to localhost
{
  "swagger": { "url": "http://localhost:8000/openapi.json" },
  "supabase": { "url": "http://localhost:54321/mcp" }
}
```

### Staging/Production
```json
// .claude/settings.local.json overrides for remote services
{
  "swagger": { "url": "https://staging-api.example.com/openapi.json" },
  "supabase": {
    "url": "https://mcp.supabase.com/mcp?project_ref=STAGING_REF&read_only=true"
  }
}
```

## Best Practices

### 1. Version Control
```bash
# Commit these:
✅ .mcp.json (team-shared MCP config)
✅ .claude/settings.local.json.example (template)
✅ docs/ (BMad documentation)
✅ .bmad-core/ (BMad framework)

# Ignore these:
❌ .claude/settings.local.json (personal overrides)
❌ .env.local (secrets)
```

### 2. Security
```
✅ Never commit credentials in .mcp.json
✅ Use environment variables for sensitive data
✅ Use read_only=true for Supabase MCP in production
✅ Separate dev/staging/prod project configurations
```

### 3. Team Collaboration
```
1. Share .mcp.json via git (team uses same MCPs)
2. Each developer overrides locally in .claude/settings.local.json
3. Document MCP usage in docs/architecture/mcp-integration.md
4. Update team when adding new MCPs
```

### 4. MCP Maintenance
```bash
# Update MCPs regularly
npm run mcp:update

# Verify MCP status
claude mcp list

# Test MCP connections
/mcp (in Claude Code)
```

## Troubleshooting

### MCP Not Appearing in Claude Code
```bash
# 1. Verify MCP configuration
claude mcp list

# 2. Check MCP status in Claude Code
/mcp

# 3. Restart Claude Code
# 4. Check .mcp.json syntax (must be valid JSON)
```

### Playwright MCP Issues
```bash
# Reinstall globally
claude mcp remove playwright
claude mcp add --scope user --transport stdio playwright -- npx @playwright/mcp

# Verify npx works
npx @playwright/mcp --version
```

### Database MCP Connection Errors
```bash
# Supabase: Check project_ref and URL
# MongoDB: Verify MONGODB_URI environment variable
# Both: Ensure database is running
```

## Next Steps

1. Review each template's README.md for stack-specific setup
2. Customize `docs/architecture/tech-stack.md` per project
3. Follow BMad workflow in `.bmad-core/enhanced-ide-development-workflow.md`
4. Leverage MCPs throughout development for enhanced productivity

## Support

- **BMad Documentation**: `.bmad-core/user-guide.md`
- **MCP Documentation**: `docs/templates/MCP-INTEGRATION-GUIDE.md`
- **Template Issues**: See individual template README files
