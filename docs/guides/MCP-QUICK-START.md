# MCP Quick Start Guide

**Purpose**: Detailed MCP setup, configuration, and usage for MyDevWF projects.

**Last Updated**: 2025-11-24

---

## Available MCPs

**All MCPs are Project-Specific** (configured per-project in `.mcp.json`):
- **Playwright MCP**: E2E testing and browser automation (saves to project folder automatically)
- **Context7 MCP**: Up-to-date library documentation and patterns
- **shadcn-ui MCP**: Access to shadcn/ui component library (Next.js projects)
- **Swagger MCP**: API testing via OpenAPI/Swagger specs
- **Supabase MCP**: Database operations, migrations, logs (Supabase projects)
- **MongoDB MCP**: Database queries, indexes, optimization (MongoDB projects)

---

## MCP Installation

### Project-Specific MCP Setup (All MCPs)

**Option 1: Via .mcp.json** (Recommended)

Create `.mcp.json` in project root:

**Windows format** (use `cmd /c npx`):
```json
{
  "mcpServers": {
    "playwright": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@executeautomation/playwright-mcp-server"],
      "env": {}
    },
    "context7": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@upstash/context7-mcp"],
      "env": {}
    },
    "shadcn-ui": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@jpisnice/shadcn-ui-mcp-server"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": ""
      }
    },
    "supabase": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@modelcontextprotocol/server-supabase"],
      "env": {
        "SUPABASE_URL": "http://localhost:54321",
        "SUPABASE_SERVICE_ROLE_KEY": ""
      }
    }
  }
}
```

**Unix/Mac format** (use `npx` directly):
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@executeautomation/playwright-mcp-server"],
      "env": {}
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "env": {}
    },
    "shadcn-ui": {
      "command": "npx",
      "args": ["-y", "@jpisnice/shadcn-ui-mcp-server"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": ""
      }
    },
    "supabase": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-supabase"],
      "env": {
        "SUPABASE_URL": "http://localhost:54321",
        "SUPABASE_SERVICE_ROLE_KEY": ""
      }
    }
  }
}
```

**HTTP server format** (for remote APIs like Swagger/OpenAPI):
```json
{
  "mcpServers": {
    "swagger-api": {
      "type": "http",
      "url": "http://localhost:8000/openapi.json"
    }
  }
}
```

**Critical Fields for stdio servers**:
- ✅ **`command`** - The executable (e.g., "cmd", "npx", "node")
- ✅ **`args`** - Array of arguments (e.g., ["/c", "npx", "-y", "@package"])
- ✅ **`env`** - Environment variables object (can be empty `{}`)
- ❌ **NO `"transport"` field** - Not used in .mcp.json (only in CLI commands)
- ❌ **NO `"description"` field** - Optional, not required
- ❌ **NO `"type"` field** - Only for HTTP servers

**Critical Fields for HTTP servers**:
- ✅ **`type: "http"`** - Required for HTTP servers
- ✅ **`url`** - The HTTP endpoint URL

**Option 2: Via Global Config**

```bash
# Add to global Claude Code config
claude mcp add context7 npx -- -y @upstash/context7-mcp
claude mcp add shadcn-ui npx -- -y @jpisnice/shadcn-ui-mcp-server
```

---

## GitHub Token Setup (shadcn-ui MCP)

**Why needed**: Better rate limits (60/hour → 5000/hour)

**Steps**:
1. Create token: https://github.com/settings/tokens/new
2. Select scope: `public_repo` (read access to public repositories)
3. Add to `.mcp.json`:
   ```json
   {
     "mcpServers": {
       "shadcn-ui": {
         "env": {
           "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token_here"
         }
       }
     }
   }
   ```
4. Restart Claude Code

**Important**: `.mcp.json` should be in `.gitignore`

---

## MCP Usage Examples

### Context7 MCP

**Purpose**: Get up-to-date library documentation

**Usage in prompts**:
```
"use context7 - How do I implement authentication with NextAuth.js?"
"use context7 - What's the latest Supabase real-time subscription pattern?"
```

**When to use**:
- Researching new libraries
- Checking for API changes
- Finding current best practices
- Validating deprecated patterns

### shadcn-ui MCP

**Purpose**: Access shadcn/ui component library

**Available tools**:
- `list_components` - See all 50+ available components
- `get_component("button")` - Get component source code
- `get_component_demo("form")` - Get usage examples
- `get_block("dashboard-01")` - Get pre-built page sections
- `list_blocks` - See all available blocks

**Usage**:
```
"Show me all shadcn/ui components"
"Get the form component demo"
"Install button, form, and input components"
```

### Supabase MCP

**Purpose**: Database operations, migrations, logs

**Available operations**:
- Create/manage tables
- Run migrations
- Query data
- View logs
- Manage RLS policies

**Usage**:
```
"Create a 'posts' table with user_id foreign key, title, content, and timestamps"
"Generate migration to add full-text search on the content column"
"Query all users who registered in the last 7 days"
"Show me the RLS policies for the posts table"
```

**Security**:
- ✅ Use `read_only=true` for remote Supabase projects
- ✅ Always scope to specific project with `project_ref`
- ❌ Never connect MCP to production database
- ✅ Use separate dev/staging Supabase projects

### Swagger MCP

**Purpose**: API testing via OpenAPI/Swagger specs

**Setup**:
```bash
# Generate MCP server from OpenAPI spec
npm run mcp:generate

# Install dependencies
npm run mcp:setup

# Restart Claude Code
```

**Usage**:
```
"Call GET /api/users and show me the results"
"Create a new user with email test@example.com"
"Test the authentication flow for /api/auth/login"
```

**Regenerate when**:
- Adding new API endpoints
- Modifying endpoint parameters
- Changing request/response schemas

### Playwright MCP

**Purpose**: E2E testing and browser automation

**Per-Project Setup Benefits**:
- ✅ Screenshots/files save to project folder automatically (not Windows Downloads)
- ✅ Evidence organized by project (docs/qa/evidence/)
- ✅ No need to specify `downloadsDir` parameter manually
- ✅ Clean separation between projects

**Available tools** (26 interactive tools):
- `browser_navigate` - Navigate to URL
- `browser_snapshot` - Get page state
- `browser_screenshot` - Capture screenshot
- `browser_click` - Click element
- `browser_fill` - Fill form field
- And 21 more browser control tools

**Usage**:
```
"Navigate to http://localhost:3000 and take a screenshot"
"Click the login button and fill the email field with test@example.com"
"Take a snapshot of the page state after form submission"
```

**When to use**:
- Understanding/debugging UI issues
- Manual E2E test execution
- Visual regression testing
- Browser automation

---

## MCP Commands

```bash
# List all MCPs (global + project)
claude mcp list

# Check MCP status in Claude Code
/mcp

# Verify MCPs are working
npm run mcp:verify
```

---

## Troubleshooting

### MCP Not Detected

**Issue**: Claude Code can't see MCP servers

**Solutions**:
1. Ensure `.mcp.json` in project root
2. Restart Claude Code
3. Check `/mcp` command
4. Verify JSON syntax is valid

### Supabase MCP Not Working

**Issue**: Can't access Supabase

**Solutions**:
1. Ensure Supabase CLI is running: `supabase status`
2. Verify local MCP endpoint: `curl http://localhost:54321/mcp`
3. Check `.mcp.json` configuration
4. For remote: Verify `project_ref` and `read_only=true`
5. Restart Claude Code

### shadcn-ui MCP Rate Limited

**Issue**: Hitting GitHub API rate limits (60/hour)

**Solution**: Add GitHub Personal Access Token (see setup section above)

---

## Template-Specific Configurations

### Next.js + Node.js + Supabase
MCPs: Context7, shadcn-ui, Supabase, Swagger (optional)

### Next.js + Node.js + MongoDB
MCPs: Context7, shadcn-ui, MongoDB, Swagger (optional)

### Next.js + FastAPI + Supabase
MCPs: Context7, shadcn-ui, Supabase, Swagger (for FastAPI)

### React Native Mobile
MCPs: Context7, Playwright, Backend-specific MCPs

---

**For comprehensive MCP documentation, see**: `docs/templates/MCP-INTEGRATION-GUIDE.md`
