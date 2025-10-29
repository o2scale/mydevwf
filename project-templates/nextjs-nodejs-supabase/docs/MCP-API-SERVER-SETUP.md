# OpenAPI MCP Generator Setup Guide

## Overview

This template uses **OpenAPI MCP Generator** to create a fully functional MCP server from your Node.js API's OpenAPI specification. This enables Claude Code to **execute actual API calls** instead of just reading the API documentation.

### Old Approach (HTTP Transport)

```
Claude Code
    ↓ (reads)
OpenAPI Spec (http://localhost:3000/api-docs)
    ↓ (shows endpoints)
Claude Code (can't call APIs)
    ↓
You open Postman manually
```

**Limitations**:
- ❌ Only reads API specs
- ❌ Cannot execute API calls
- ❌ Requires manual testing in Postman
- ❌ Time-consuming workflow

### New Approach (Generated MCP Server)

```
Node.js Backend
    ↓ (exposes)
OpenAPI Spec (http://localhost:3000/api-docs-json)
    ↓ (input to)
openapi-mcp-generator
    ↓ (generates)
MCP Server (.mcp-server/)
    ↓ (connects via stdio)
Claude Code (executes API calls directly!)
```

**Benefits**:
- ✅ Executes actual API calls
- ✅ No Postman needed
- ✅ Automatic tool generation
- ✅ Auth support (API keys, Bearer, OAuth2)
- ✅ 50-60% faster development

## Prerequisites

1. **Node.js Backend** must expose OpenAPI spec at `/api-docs-json`:
   ```javascript
   // backend/src/app.js
   const swaggerJsdoc = require('swagger-jsdoc');
   const swaggerUi = require('swagger-ui-express');

   const swaggerOptions = {
     definition: {
       openapi: '3.0.0',
       info: {
         title: 'My API',
         version: '1.0.0',
       },
       servers: [{ url: 'http://localhost:3000' }],
     },
     apis: ['./src/routes/*.js'],
   };

   const swaggerSpec = swaggerJsdoc(swaggerOptions);

   // Serve Swagger UI
   app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

   // Serve JSON spec (for MCP generator)
   app.get('/api-docs-json', (req, res) => {
     res.json(swaggerSpec);
   });
   ```

2. **Claude Code** with BMad workflow installed

3. **openapi-mcp-generator** (installed via npm scripts)

## Quick Start

### Step 1: Install Dependencies

```bash
# From project root
npm install
```

This installs `openapi-mcp-generator` as a dev dependency.

### Step 2: Start Backend

```bash
# Terminal 1
npm run dev:backend
```

**Verify**: Open http://localhost:3000/api-docs-json in browser
- Should see OpenAPI spec JSON
- If 404, your backend isn't exposing the spec correctly

### Step 3: Generate MCP Server

```bash
# Terminal 2
npm run mcp:generate
```

**What this does**:
```bash
openapi-mcp-generator \
  --input http://localhost:3000/api-docs-json \
  --output ./.mcp-server \
  --server-name api-server \
  --transport stdio \
  --force
```

**Output**:
```
✓ Parsed OpenAPI specification
✓ Extracted 12 operations
✓ Generated 12 MCP tools
✓ Created server at ./.mcp-server
```

### Step 4: Install MCP Server Dependencies

```bash
npm run mcp:setup
```

This runs `npm install` inside `.mcp-server/` directory.

### Step 5: Configure Authentication (if needed)

If your API requires authentication, set environment variables:

**API Key Authentication**:
```bash
# .mcp-server/.env
API_KEY_MY_AUTH=your-api-key-here
```

**Bearer Token**:
```bash
# .mcp-server/.env
BEARER_TOKEN_MY_AUTH=your-bearer-token-here
```

**Basic Auth**:
```bash
# .mcp-server/.env
BASIC_USERNAME_MY_AUTH=username
BASIC_PASSWORD_MY_AUTH=password
```

**OAuth2**:
```bash
# .mcp-server/.env
OAUTH_CLIENT_ID_MY_AUTH=your-client-id
OAUTH_CLIENT_SECRET_MY_AUTH=your-client-secret
OAUTH_SCOPES_MY_AUTH=read,write
```

### Step 6: Restart Claude Code

```bash
# Close and restart Claude Code to load new MCP configuration
```

Claude Code will read `.mcp.json` and start the generated MCP server automatically.

### Step 7: Verify MCP Tools

```bash
# In Claude Code
/mcp
```

You should see:
- **supabase** - Database operations
- **api-server** - Your API endpoints (12 tools)
- **shadcn-ui** - Component library

### Step 8: Test API Calls

In Claude Code, try:

```
"Call the GET /api/users endpoint and show me the results"
```

Claude Code will:
1. Find the `getUsers` tool (from your OpenAPI spec)
2. Execute `GET http://localhost:3000/api/users`
3. Return actual API response

**No Postman needed!**

## Generated MCP Tools

The generator creates one tool per API endpoint. Example:

**Your OpenAPI Spec**:
```yaml
paths:
  /api/users:
    get:
      operationId: getUsers
      summary: Get all users
      responses:
        200:
          description: List of users
    post:
      operationId: createUser
      summary: Create a new user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                email:
                  type: string
                name:
                  type: string
```

**Generated MCP Tools**:
- `getUsers` → `GET /api/users`
- `createUser` → `POST /api/users`

**Usage in Claude Code**:
```
"Get all users"
→ Calls getUsers tool
→ Executes GET /api/users
→ Returns: [{ id: 1, email: "test@example.com", name: "John" }]

"Create a user with email test2@example.com and name Jane"
→ Calls createUser tool
→ Executes POST /api/users with payload
→ Returns: { id: 2, email: "test2@example.com", name: "Jane" }
```

## Development Workflow

### Standard Workflow

```bash
# Terminal 1: Backend
npm run dev:backend

# Terminal 2: MCP Server (after changes to API)
npm run mcp:generate
npm run mcp:setup
# Restart Claude Code

# Terminal 3: Frontend
npm run dev:frontend
```

### When to Regenerate MCP Server

Regenerate when you:
- ✅ Add new API endpoints
- ✅ Modify endpoint parameters
- ✅ Change request/response schemas
- ✅ Update authentication methods

**Quick regeneration**:
```bash
npm run mcp:generate && npm run mcp:setup
# Then restart Claude Code
```

## Troubleshooting

### Issue: MCP server not found

**Error**:
```
Error: Cannot find module '.mcp-server/build/index.js'
```

**Solution**:
```bash
# Run generation and setup
npm run mcp:generate
npm run mcp:setup

# Verify .mcp-server directory exists
ls -la .mcp-server/
```

### Issue: OpenAPI spec not found

**Error**:
```
Error: Failed to fetch OpenAPI spec from http://localhost:3000/api-docs-json
```

**Solution**:
1. Ensure backend is running: `npm run dev:backend`
2. Check endpoint manually: `curl http://localhost:3000/api-docs-json`
3. Verify backend exposes `/api-docs-json` route

### Issue: MCP tools not appearing in Claude Code

**Solution**:
1. Verify `.mcp.json` is correct
2. Restart Claude Code
3. Run `/mcp` to check loaded servers
4. Check Claude Code logs for errors

### Issue: API calls failing with 401/403

**Cause**: Authentication not configured

**Solution**:
1. Check which auth scheme your API uses (OpenAPI spec)
2. Set appropriate environment variables in `.mcp-server/.env`
3. Restart Claude Code

### Issue: Wrong base URL

**Error**:
```
Error: connect ECONNREFUSED 127.0.0.1:3000
```

**Solution**:
Update `.mcp.json`:
```json
{
  "api-server": {
    "env": {
      "API_BASE_URL": "http://localhost:YOUR_PORT"
    }
  }
}
```

## Advanced Configuration

### Custom OpenAPI Spec URL

Edit `package.json`:
```json
{
  "scripts": {
    "mcp:generate": "openapi-mcp-generator --input https://your-api.com/openapi.json --output ./.mcp-server --transport stdio --force"
  }
}
```

### Filter Specific Endpoints

Only generate tools for specific tags:
```bash
openapi-mcp-generator \
  --input http://localhost:3000/api-docs-json \
  --output ./.mcp-server \
  --filter-tag users,posts \
  --transport stdio
```

### Exclude Dangerous Operations

Exclude DELETE operations:
```bash
openapi-mcp-generator \
  --input http://localhost:3000/api-docs-json \
  --output ./.mcp-server \
  --exclude-operation-id deleteUser,deletePost \
  --transport stdio
```

## Comparison: Old vs New

### Old Approach (HTTP Transport)

**Configuration**:
```json
{
  "swagger-api": {
    "transport": "http",
    "url": "http://localhost:3000/api-docs"
  }
}
```

**Workflow**:
1. Backend exposes OpenAPI spec
2. Claude Code reads spec via HTTP
3. Claude Code sees endpoints (read-only)
4. You open Postman to test
5. Manually create requests
6. Copy responses back to Claude Code

**Time per endpoint**: ~3-5 minutes

### New Approach (Generated MCP Server)

**Configuration**:
```json
{
  "api-server": {
    "command": "node",
    "args": [".mcp-server/build/index.js"],
    "env": {
      "API_BASE_URL": "http://localhost:3000"
    }
  }
}
```

**Workflow**:
1. Backend exposes OpenAPI spec
2. Generate MCP server: `npm run mcp:generate`
3. Claude Code executes API calls directly
4. Get real responses in conversation

**Time per endpoint**: ~30 seconds

**Time saved**: 80-85% per API endpoint test

## BMad Integration

### Dev Agent Usage

When implementing API stories, the dev agent can now:

```
# Old workflow
1. Write API endpoint
2. Document in OpenAPI
3. Save file
4. Ask user to test in Postman
5. Wait for feedback

# New workflow (with MCP generator)
1. Write API endpoint
2. Document in OpenAPI
3. Save file
4. Dev agent calls API directly: "Test POST /api/users with sample data"
5. Immediate validation
```

### QA Agent Usage

QA agent can now test APIs directly:

```
/BMad/agents/qa
*review docs/stories/1.2.story.md

# QA agent tests API endpoints
"Call GET /api/users and verify it returns an array"
"Create a test user via POST /api/users"
"Verify the user was created via GET /api/users/{id}"
```

## Next Steps

1. **Implement API endpoints** with OpenAPI annotations
2. **Generate MCP server** after adding endpoints
3. **Test in Claude Code** - call APIs directly
4. **Iterate faster** - no Postman context switching

## Resources

- **OpenAPI MCP Generator**: https://github.com/harsha-iiiv/openapi-mcp-generator
- **OpenAPI Specification**: https://swagger.io/specification/
- **Model Context Protocol**: https://modelcontextprotocol.io/
- **BMad Workflow**: `.bmad-core/user-guide.md`
