#!/usr/bin/env node

/**
 * Help Script - Shows available commands and templates
 */

console.log(`
╔═══════════════════════════════════════════════════════════════╗
║          MyDevWF - Development Workflow Templates            ║
╚═══════════════════════════════════════════════════════════════╝

📚 AVAILABLE TEMPLATES:

1. python-fastapi-postgres
   Stack: React/Next.js + Python/FastAPI + PostgreSQL
   MCPs: Playwright (global) + Swagger
   Use: API-first backends, data-intensive apps

2. nodejs-supabase
   Stack: React/Next.js + Node.js + Supabase
   MCPs: Playwright (global) + Supabase + Swagger
   Use: Rapid prototyping, real-time apps, serverless

3. nodejs-mongodb
   Stack: React/Next.js + Node.js + MongoDB
   MCPs: Playwright (global) + MongoDB + Swagger
   Use: Document-heavy apps, flexible schemas

4. react-native
   Stack: React Native (TypeScript) + Backend agnostic
   MCPs: Playwright (global) + Backend-specific
   Use: Cross-platform mobile apps (iOS + Android)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 QUICK START:

  # Create a new project
  npm run create-project <template> <project-name>

  Example:
  npm run create-project nodejs-supabase my-awesome-app

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔧 MCP COMMANDS:

  # Verify MCPs
  npm run mcp:verify

  # List all MCPs
  npm run mcp:list

  # In Claude Code
  /mcp

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📖 DOCUMENTATION:

  Master Guide:
    docs/templates/MASTER-TEMPLATE-GUIDE.md

  MCP Integration:
    docs/templates/MCP-INTEGRATION-GUIDE.md

  BMad Method:
    .bmad-core/user-guide.md
    .bmad-core/enhanced-ide-development-workflow.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ WORKFLOW:

  1. Choose template for your stack
  2. Create project: npm run create-project <template> <name>
  3. Follow template README for setup
  4. Use BMad agents for development
  5. Leverage MCPs for enhanced productivity

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Need help? Check CLAUDE.md or template-specific README files.

`);
