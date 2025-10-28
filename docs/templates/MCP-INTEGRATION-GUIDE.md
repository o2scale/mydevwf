# MCP Integration Guide

## What are MCPs?

Model Context Protocol (MCP) is an open standard by Anthropic that enables Claude Code to connect with external tools, databases, and services. Think of MCPs as "superpowers" that let Claude Code interact with your development environment directly.

## MCPs in Your Workflow

### Global MCPs (User Scope)
Installed once, available in all projects:

```bash
✅ Playwright MCP - Already installed globally
```

### Project-Specific MCPs
Configured per project in `.mcp.json`:

```bash
⚙️ Swagger MCP - API testing and documentation
⚙️ Supabase MCP - PostgreSQL database operations (when using Supabase)
⚙️ MongoDB MCP - MongoDB operations (when using MongoDB)
```

## MCP Capabilities by Stack

### Python/FastAPI + PostgreSQL

**Active MCPs**:
- ✅ **Playwright MCP** (global) - E2E testing
- ✅ **Swagger MCP** (project) - API testing

**What Claude Can Do**:
```python
# Through Swagger MCP:
"Test the POST /api/users endpoint with sample data"
"Verify the authentication flow returns proper JWT tokens"
"Check API response schemas match OpenAPI spec"

# Through Playwright MCP:
"Generate E2E test for user registration flow"
"Create test that verifies dashboard loads after login"
"Test the forgot password email workflow"
```

**FastAPI's Built-in OpenAPI**:
- Auto-generates `/docs` (Swagger UI) and `/redoc`
- Swagger MCP connects to `http://localhost:8000/openapi.json`
- Claude can interact with API programmatically during development

**Configuration**:
```json
// .mcp.json
{
  "mcpServers": {
    "swagger-api": {
      "transport": "http",
      "url": "http://localhost:8000/openapi.json",
      "description": "FastAPI backend API documentation"
    }
  }
}
```

---

### Node.js + Supabase

**Active MCPs**:
- ✅ **Playwright MCP** (global) - E2E testing
- ✅ **Supabase MCP** (project) - Database operations
- ✅ **Swagger MCP** (project) - API testing

**What Claude Can Do**:
```javascript
// Through Supabase MCP:
"Create a 'posts' table with user_id foreign key and timestamp"
"Generate migration to add full-text search on content column"
"Query all users who registered in the last 7 days"
"Show me the RLS policies for the posts table"
"Retrieve error logs from the last hour"

// Through Swagger MCP:
"Test the /api/posts endpoint returns paginated results"
"Verify the GraphQL schema matches our types"

// Through Playwright MCP:
"Generate E2E test that creates a post and verifies it appears in feed"
```

**Supabase MCP Benefits**:
- Create and manage projects from Claude Code
- Design schemas and generate migrations via natural language
- Query data without writing SQL manually
- Manage Edge Functions and configurations
- Debug with log retrieval

**Configuration**:
```json
// .mcp.json
{
  "mcpServers": {
    "supabase-dev": {
      "transport": "http",
      "url": "http://localhost:54321/mcp",
      "description": "Local Supabase instance (via CLI)"
    },
    "swagger-api": {
      "transport": "http",
      "url": "http://localhost:3000/api-docs",
      "description": "Node.js backend API"
    }
  }
}

// .claude/settings.local.json (for remote Supabase)
{
  "mcpServers": {
    "supabase-staging": {
      "transport": "http",
      "url": "https://mcp.supabase.com/mcp?project_ref=YOUR_PROJECT_REF&read_only=true",
      "description": "Staging Supabase project (read-only)"
    }
  }
}
```

**Security Notes**:
- ⚠️ **CRITICAL**: Only use with dev/staging projects
- ❌ Never connect to production
- ✅ Always use `read_only=true` for remote instances
- ✅ Scope to specific project with `project_ref` parameter

---

### Node.js + MongoDB

**Active MCPs**:
- ✅ **Playwright MCP** (global) - E2E testing
- ✅ **MongoDB MCP** (project) - Database operations
- ✅ **Swagger MCP** (project) - API testing

**What Claude Can Do**:
```javascript
// Through MongoDB MCP:
"Create a 'users' collection with email index"
"Query all orders from last month with status 'pending'"
"Generate aggregation pipeline for user analytics by region"
"Optimize the products collection based on query patterns"
"Show me performance advisor recommendations"

// Through Swagger MCP:
"Test the REST API endpoints for CRUD operations on products"
"Verify authentication middleware protects admin routes"

// Through Playwright MCP:
"Generate E2E test for the shopping cart checkout flow"
```

**MongoDB MCP Benefits**:
- Direct CRUD operations via natural language
- Query optimization and index suggestions
- Aggregation pipeline generation
- Works with Atlas, Community, or Enterprise
- Integration with Performance Advisor

**Configuration**:
```json
// .mcp.json
{
  "mcpServers": {
    "mongodb-local": {
      "transport": "stdio",
      "command": "npx",
      "args": ["@mongodb/mcp-server-mongodb"],
      "env": {
        "MONGODB_URI": "mongodb://localhost:27017/myapp_dev"
      },
      "description": "Local MongoDB instance"
    },
    "swagger-api": {
      "transport": "http",
      "url": "http://localhost:4000/api-docs",
      "description": "Node.js backend API"
    }
  }
}

// .claude/settings.local.json (for MongoDB Atlas)
{
  "mcpServers": {
    "mongodb-atlas": {
      "transport": "stdio",
      "command": "npx",
      "args": ["@mongodb/mcp-server-mongodb"],
      "env": {
        "MONGODB_URI": "mongodb+srv://user:pass@cluster.mongodb.net/myapp_staging"
      },
      "description": "MongoDB Atlas staging cluster"
    }
  }
}
```

---

### React Native (Mobile)

**Active MCPs**:
- ✅ **Playwright MCP** (global) - E2E testing (web components)
- ✅ **Swagger MCP** (project) - Backend API testing
- ✅ **Backend MCP** (project) - Supabase OR MongoDB (depends on backend)

**What Claude Can Do**:
```typescript
// Through Playwright MCP (for web-based components):
"Generate tests for the WebView-based payment flow"
"Test the web-based OAuth login screen"

// Through Swagger MCP:
"Verify the mobile API endpoints return data in expected format"
"Test push notification registration endpoint"
"Check API versioning headers for mobile clients"

// Through Backend MCP:
"Query user profiles to verify mobile app data sync"
"Check notification delivery status in database"
```

**React Native Testing Notes**:
- Playwright MCP primarily for web-based components (WebViews, OAuth screens)
- For native component testing, use Jest/React Native Testing Library (not MCP)
- Backend MCPs (Supabase/MongoDB) remain valuable for data verification

**Configuration**:
```json
// .mcp.json (with Supabase backend)
{
  "mcpServers": {
    "supabase-dev": {
      "transport": "http",
      "url": "http://localhost:54321/mcp",
      "description": "Local Supabase for mobile backend"
    },
    "swagger-mobile-api": {
      "transport": "http",
      "url": "http://localhost:3000/api/mobile/docs",
      "description": "Mobile API endpoints"
    }
  }
}
```

---

## BMad Workflow Integration

### Planning Phase (Architect/PM)

**Without MCPs**: Manually document API contracts, database schemas, test strategies

**With MCPs**:
```bash
# Architect can validate designs:
"Use Swagger MCP to verify the API spec is valid"
"Check with Supabase MCP if this schema design is optimal"
"Query MongoDB MCP for index recommendations on this collection"
```

### Development Phase (Dev Agent)

**Without MCPs**: Dev writes code → manually tests in Postman/browser → writes tests

**With MCPs**:
```bash
# Dev implements story:
/BMad/tasks/execute-checklist docs/stories/epic-1.story-1.md

# Claude automatically:
1. Implements feature code
2. Uses Swagger MCP to test API endpoints
3. Uses DB MCP to verify data persistence
4. Uses Playwright MCP to generate E2E tests
5. Validates all acceptance criteria
```

### QA Phase (QA Agent)

**Without MCPs**: QA manually verifies tests, checks API contracts, inspects database

**With MCPs**:
```bash
# QA review with MCP enhancements:
/BMad/agents/qa
*review docs/stories/epic-1.story-1.md

# Claude automatically:
1. Verifies test coverage via Playwright MCP
2. Validates API contracts via Swagger MCP
3. Checks database integrity via DB MCP
4. Generates comprehensive quality gate
```

### Example: Story Implementation with MCPs

**Story**: Implement user registration endpoint

**Traditional Flow** (15-20 min):
1. Write endpoint code
2. Start server
3. Open Postman
4. Manually test with sample data
5. Check database manually
6. Write E2E test manually
7. Run test, debug, repeat

**MCP-Enhanced Flow** (5-8 min):
```bash
# Dev agent with MCPs active:
"Implement the user registration endpoint per story requirements"

# Claude Code automatically:
1. ✅ Writes endpoint code (FastAPI/Express)
2. ✅ Tests endpoint via Swagger MCP (no manual Postman)
3. ✅ Verifies user created in DB via DB MCP
4. ✅ Generates E2E test via Playwright MCP
5. ✅ Runs test and reports results
6. ✅ Marks story tasks complete
```

---

## MCP Commands Cheat Sheet

### Management
```bash
# List all MCPs (global + project)
claude mcp list

# Check MCP status in Claude Code
/mcp

# Add project-scoped MCP
claude mcp add --scope project --transport http <name> <url>

# Remove MCP
claude mcp remove <name>

# Get MCP details
claude mcp get <name>
```

### Natural Language Usage (in Claude Code)

**Swagger MCP**:
```
"Test the POST /api/users endpoint with this payload: {email: 'test@example.com', password: '12345'}"
"Show me all available API endpoints from the Swagger spec"
"Verify the API schema matches our TypeScript types"
```

**Supabase MCP**:
```
"Create a migration to add a 'verified_at' timestamp column to users table"
"Query all users who have posts in the last week"
"Show me the RLS policies for the posts table"
"Retrieve Edge Function logs from the last hour"
```

**MongoDB MCP**:
```
"Create an index on the 'email' field in users collection"
"Show me all documents in orders collection with status 'pending'"
"Generate aggregation to count users by country"
"What indexes does Performance Advisor recommend for products collection?"
```

**Playwright MCP**:
```
"Generate E2E test for the login flow"
"Create test that verifies the dashboard loads after authentication"
"Write test to check the shopping cart persists across page reloads"
```

---

## Configuration Patterns

### Development (Local)
```json
// .mcp.json - Team-shared, version-controlled
{
  "mcpServers": {
    "swagger-api": {
      "transport": "http",
      "url": "http://localhost:8000/openapi.json"
    },
    "database": {
      "transport": "stdio",
      "command": "npx",
      "args": ["@mongodb/mcp-server-mongodb"],
      "env": {
        "MONGODB_URI": "mongodb://localhost:27017/myapp_dev"
      }
    }
  }
}
```

### Staging (Remote)
```json
// .claude/settings.local.json - Personal, gitignored
{
  "mcpServers": {
    "swagger-api": {
      "transport": "http",
      "url": "https://staging-api.example.com/openapi.json"
    },
    "supabase-staging": {
      "transport": "http",
      "url": "https://mcp.supabase.com/mcp?project_ref=STAGING_REF&read_only=true"
    }
  }
}
```

### Environment Variables
```bash
# .env.local (gitignored)
MONGODB_URI=mongodb://localhost:27017/myapp_dev
SUPABASE_PROJECT_REF=your_project_ref
SWAGGER_API_URL=http://localhost:8000/openapi.json
```

---

## Troubleshooting

### MCP Not Working

**Symptom**: MCP doesn't appear in `/mcp` command

**Solutions**:
1. Check `.mcp.json` syntax (must be valid JSON, no trailing commas)
2. Restart Claude Code
3. Verify MCP server is running (for HTTP transport)
4. Check `claude mcp list` output
5. Ensure transport type matches server capabilities

### Swagger MCP Connection Errors

**Symptom**: "Failed to connect to Swagger API"

**Solutions**:
1. Ensure backend server is running
2. Verify OpenAPI spec URL is accessible: `curl http://localhost:8000/openapi.json`
3. Check CORS settings if using HTTP transport
4. Validate OpenAPI spec syntax

### Database MCP Errors

**Supabase**:
```
❌ Error: "Project not found"
✅ Solution: Check project_ref parameter in URL

❌ Error: "Unauthorized"
✅ Solution: Authenticate with Supabase CLI: supabase login
```

**MongoDB**:
```
❌ Error: "Connection refused"
✅ Solution: Ensure MongoDB is running: mongod --version

❌ Error: "Authentication failed"
✅ Solution: Check MONGODB_URI includes correct credentials
```

### Playwright MCP Issues

**Symptom**: Playwright commands not working

**Solutions**:
1. Verify global installation: `claude mcp list` should show `playwright`
2. Test npx access: `npx @playwright/mcp --version`
3. Reinstall if needed: `claude mcp remove playwright && claude mcp add --scope user --transport stdio playwright -- npx @playwright/mcp`
4. Install Playwright browsers: `npx playwright install`

---

## Best Practices

### 1. Security
```
✅ Use read_only=true for Supabase MCP on remote instances
✅ Scope Supabase MCP to specific project with project_ref
✅ Never commit .claude/settings.local.json (add to .gitignore)
✅ Use environment variables for sensitive values
✅ Separate dev/staging/prod configurations
❌ Never connect MCPs to production databases directly
```

### 2. Team Collaboration
```
✅ Commit .mcp.json (team shares same MCP config)
✅ Provide .claude/settings.local.json.example template
✅ Document MCP usage in docs/architecture/mcp-integration.md
✅ Update team when adding/changing MCPs
✅ Use consistent naming conventions for MCP servers
```

### 3. Performance
```
✅ Use HTTP transport for remote services (faster than stdio)
✅ Keep MCP servers close to your dev environment (localhost preferred)
✅ Use specific project_ref for Supabase to reduce data transfer
✅ Limit MongoDB query results in MCP interactions
```

### 4. Maintenance
```
✅ Update MCP packages regularly: npm update
✅ Test MCP connections after updates: /mcp in Claude Code
✅ Monitor MCP server logs for errors
✅ Document any custom MCP configurations in project README
```

---

## Advanced Usage

### Custom MCP Parameters

**Supabase with Read-Only**:
```json
{
  "supabase-prod": {
    "url": "https://mcp.supabase.com/mcp?project_ref=PROD_REF&read_only=true"
  }
}
```

**MongoDB with Specific Database**:
```json
{
  "mongodb-analytics": {
    "env": {
      "MONGODB_URI": "mongodb://localhost:27017/myapp_analytics"
    }
  }
}
```

### Multiple Environments

```json
// .mcp.json (development - default)
{
  "mcpServers": {
    "api": { "url": "http://localhost:8000/openapi.json" }
  }
}

// .claude/settings.local.json (override for staging)
{
  "mcpServers": {
    "api": { "url": "https://staging-api.example.com/openapi.json" },
    "api-prod": { "url": "https://api.example.com/openapi.json" }
  }
}
```

### MCP Aliases

Use descriptive names for multiple instances:
```json
{
  "mcpServers": {
    "swagger-auth-service": { "url": "http://localhost:8000/openapi.json" },
    "swagger-payment-service": { "url": "http://localhost:8001/openapi.json" },
    "swagger-notification-service": { "url": "http://localhost:8002/openapi.json" }
  }
}
```

---

## Resources

- **Anthropic MCP Docs**: https://docs.claude.com/en/docs/mcp
- **Swagger MCP**: https://github.com/dcolley/swagger-mcp
- **Supabase MCP**: https://supabase.com/docs/guides/getting-started/mcp
- **MongoDB MCP**: https://www.mongodb.com/company/blog/announcing-mongodb-mcp-server
- **Playwright MCP**: https://github.com/microsoft/playwright-mcp
