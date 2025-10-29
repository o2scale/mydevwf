# Node.js + Supabase Project Template

## Stack Overview

- **Frontend**: React with TypeScript (Next.js)
- **Backend**: Node.js with Express/Next.js API Routes
- **Database**: Supabase (PostgreSQL) with Auth & Storage
- **Testing**: Playwright (E2E), Jest (backend/frontend)
- **MCPs**: Playwright (global), Supabase (project), Swagger (project)

## Quick Start

### Prerequisites

- Node.js 18+ and npm
- Supabase CLI (`npm install -g supabase`)
- Claude Code with Playwright MCP installed globally
- Supabase account (for cloud deployment)

### Initial Setup

1. **Clone or copy this template**:
   ```bash
   cp -r project-templates/nodejs-supabase ../my-new-project
   cd ../my-new-project
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Initialize Supabase locally**:
   ```bash
   # Start local Supabase
   supabase init
   supabase start

   # Note the API URL and anon key from output
   ```

4. **Configure environment**:
   ```bash
   cp .env.example .env.local
   # Edit .env.local with Supabase credentials from above
   ```

5. **Start development server**:
   ```bash
   npm run dev:backend  # Terminal 1
   npm run dev:frontend # Terminal 2
   ```

6. **Generate API MCP Server** (⭐ NEW - enables direct API testing):
   ```bash
   # Terminal 3
   npm run mcp:generate  # Generates MCP server from OpenAPI spec
   npm run mcp:setup     # Installs MCP server dependencies
   ```

7. **Verify MCPs**:
   ```bash
   # In Claude Code (restart required after mcp:generate)
   /mcp
   # Should show: playwright (global), supabase, api-server, shadcn-ui (project)
   ```

**Note**: The `api-server` MCP allows Claude Code to **execute actual API calls** instead of just reading the spec. See `docs/MCP-API-SERVER-SETUP.md` for details.

### Development Workflow

Follow the BMad enhanced development workflow:

1. **Planning Phase** (Web UI recommended):
   - Use PM agent to create PRD
   - Use Architect agent to design system
   - Save documents to `docs/` directory

2. **Development Phase** (Claude Code):
   ```bash
   # Create story
   /BMad/agents/sm

   # Implement story
   /BMad/agents/dev
   /BMad/tasks/execute-checklist docs/stories/{story-file}.md
   ```

3. **QA Phase**:
   ```bash
   /BMad/agents/qa
   *review docs/stories/{story-file}.md
   ```

## MCP Usage

### Supabase MCP (Database & Auth)

**Local Configuration**: Connects to Supabase CLI running on localhost

**Cloud Configuration**: Use `.claude/settings.local.json` with `read_only=true`

**Usage in Claude Code**:
```
"Create a 'posts' table with user_id foreign key, title, content, and timestamps"
"Generate migration to add full-text search on the content column"
"Query all users who registered in the last 7 days"
"Show me the RLS policies for the posts table"
"Retrieve Edge Function logs from the last hour"
"Create an Edge Function for sending welcome emails"
```

**⚠️ CRITICAL Security**:
- ✅ Use `read_only=true` for remote Supabase projects
- ✅ Always scope to specific project with `project_ref`
- ❌ Never connect MCP to production database
- ✅ Use separate dev/staging Supabase projects

### API Server MCP (Direct API Execution) ⭐ NEW

**What Changed**: We now use **OpenAPI MCP Generator** instead of HTTP transport Swagger MCP.

**Old Approach** (HTTP Transport):
- ❌ Only reads API spec (can't execute)
- ❌ Requires manual Postman testing
- ❌ Time-consuming workflow

**New Approach** (Generated MCP Server):
- ✅ Executes actual API calls
- ✅ No Postman needed
- ✅ 50-60% faster development
- ✅ Automatic tool generation

**Setup** (one-time per project):
```bash
# Step 1: Start backend
npm run dev:backend

# Step 2: Generate MCP server from OpenAPI spec
npm run mcp:generate

# Step 3: Install MCP server dependencies
npm run mcp:setup

# Step 4: Restart Claude Code
```

**Usage in Claude Code**:
```
"Call GET /api/users and show me the results"
→ Executes actual API request
→ Returns real data from your database

"Create a new user with email test@example.com"
→ Calls POST /api/users
→ User created in database

"Test the authentication flow for /api/auth/login"
→ Executes login endpoint
→ Returns JWT token
```

**Documentation**: See `docs/MCP-API-SERVER-SETUP.md` for complete guide

**Regenerate when**:
- Adding new API endpoints
- Modifying endpoint parameters
- Changing request/response schemas

```bash
npm run mcp:generate && npm run mcp:setup
# Then restart Claude Code
```

### Playwright MCP (E2E Testing)

**Global Configuration**: Already installed, available automatically

**Usage in Claude Code**:
```
"Generate E2E test for user signup with Supabase Auth"
"Create test that verifies real-time subscription updates"
"Write test to check file upload to Supabase Storage"
```

## Project Structure

```
.
├── .mcp.json                          # MCP configuration (Supabase + Swagger)
├── .claude/
│   └── settings.local.json.example    # Remote MCP overrides template
├── src/
│   ├── app/                          # Next.js app router
│   │   ├── api/                      # API routes
│   │   ├── (auth)/                   # Auth pages group
│   │   └── (dashboard)/              # Protected pages group
│   ├── components/                   # React components
│   ├── lib/
│   │   ├── supabase/                 # Supabase clients
│   │   │   ├── client.ts             # Client-side client
│   │   │   ├── server.ts             # Server-side client
│   │   │   └── middleware.ts         # Auth middleware
│   │   └── utils/                    # Utilities
│   └── types/                        # TypeScript types
├── supabase/
│   ├── migrations/                   # Database migrations
│   ├── functions/                    # Edge Functions
│   └── seed.sql                      # Seed data
├── tests/
│   ├── e2e/                          # Playwright E2E tests
│   ├── integration/                  # Integration tests
│   └── unit/                         # Unit tests
├── docs/                             # BMad documentation
│   ├── prd.md.template               # PRD template
│   ├── architecture/                 # Architecture docs
│   ├── epics/                        # Sharded epics
│   ├── stories/                      # User stories
│   └── qa/                           # QA assessments and gates
├── package.json                      # Dependencies
└── README.md                         # This file
```

## Technology Details

### Frontend (Next.js + Supabase)

**Key Features**:
- Server Components with Supabase SSR
- Supabase Auth (email, OAuth, magic link)
- Real-time subscriptions
- File uploads to Supabase Storage
- Row Level Security (RLS) policies

**Supabase Client Setup**:
```typescript
// src/lib/supabase/client.ts (Client-side)
import { createBrowserClient } from '@supabase/ssr'

export const createClient = () =>
  createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )

// src/lib/supabase/server.ts (Server-side)
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export const createClient = () =>
  createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies }
  )
```

**Authentication**:
```typescript
// Sign up
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password',
})

// Sign in
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password',
})

// OAuth
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'github',
})
```

**Real-time Subscriptions**:
```typescript
const channel = supabase
  .channel('posts')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'posts' },
    (payload) => console.log('New post:', payload)
  )
  .subscribe()
```

### Database (Supabase / PostgreSQL)

**Migrations via Supabase CLI**:
```bash
# Create migration
supabase migration new create_posts_table

# Apply migrations locally
supabase db reset

# Push to remote
supabase db push
```

**Row Level Security (RLS)**:
```sql
-- Enable RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read their own posts
CREATE POLICY "Users can read own posts"
  ON posts FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own posts
CREATE POLICY "Users can insert own posts"
  ON posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

**Querying with Supabase Client**:
```typescript
// Fetch data
const { data, error } = await supabase
  .from('posts')
  .select('*, author:users(*)')
  .eq('published', true)
  .order('created_at', { ascending: false })

// Insert data
const { data, error } = await supabase
  .from('posts')
  .insert({ title: 'New Post', content: 'Content here' })
```

### Backend (Edge Functions / API Routes)

**Supabase Edge Functions** (Deno):
```typescript
// supabase/functions/send-email/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { email, message } = await req.json()

  // Send email logic here

  return new Response(
    JSON.stringify({ success: true }),
    { headers: { "Content-Type": "application/json" } },
  )
})
```

**Next.js API Routes** (Node.js):
```typescript
// src/app/api/posts/route.ts
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET() {
  const supabase = createClient()
  const { data, error } = await supabase
    .from('posts')
    .select('*')

  if (error) return NextResponse.json({ error }, { status: 500 })
  return NextResponse.json(data)
}
```

## Supabase Features

### Authentication
- Email/password
- Magic link (passwordless)
- OAuth (Google, GitHub, etc.)
- Phone/SMS
- JWT tokens

### Database
- PostgreSQL with extensions
- Real-time subscriptions
- Row Level Security (RLS)
- Database functions
- Full-text search

### Storage
- File uploads
- Bucket policies
- Image transformations
- CDN delivery

### Edge Functions
- Serverless functions (Deno)
- Database webhooks
- Scheduled jobs
- Third-party integrations

## Testing Strategy

### Backend Tests (Jest)
```bash
npm run test:backend
npm run test:backend:coverage
```

### Frontend Tests (Jest + React Testing Library)
```bash
npm test
npm run test:coverage
```

### E2E Tests (Playwright via MCP)
```bash
npm run test:e2e
npm run test:e2e:ui      # Interactive mode
```

**MCP-Enhanced Testing**:
```
"Generate E2E test for user signup, login, and creating a post with Supabase"
"Create test that verifies real-time updates when another user posts"
```

## Supabase CLI Commands

```bash
# Start local Supabase
supabase start

# Stop local Supabase
supabase stop

# Create migration
supabase migration new <migration_name>

# Apply migrations
supabase db reset

# Link to remote project
supabase link --project-ref <project-ref>

# Push migrations to remote
supabase db push

# Pull remote schema
supabase db pull

# Generate TypeScript types
supabase gen types typescript --local > src/types/database.ts

# Deploy Edge Function
supabase functions deploy <function-name>

# View logs
supabase functions logs <function-name>
```

## Environment Variables

```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here

# For production
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-production-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key  # Server-side only!
```

## BMad Integration

### Dev Agent Context
Update `.bmad-core/core-config.yaml`:
```yaml
devLoadAlwaysFiles:
  - docs/architecture/coding-standards.md
  - docs/architecture/tech-stack.md
  - docs/architecture/source-tree.md
  - docs/architecture/supabase-patterns.md  # Supabase best practices
```

### MCP Enhancement Example

**Traditional Flow** (20-25 min per story):
1. Write API code
2. Test manually in browser
3. Check database in Supabase dashboard
4. Write E2E tests manually
5. Debug and repeat

**MCP-Enhanced Flow** (8-12 min per story):
1. Write API code
2. **Supabase MCP auto-verifies data**
3. **Swagger MCP auto-tests API**
4. **Playwright MCP auto-generates E2E tests**
5. Done

**Time Saved**: ~50-60% per story

## Common Commands

```bash
# Development
npm run dev              # Start Next.js dev server
npm run supabase:start   # Start local Supabase
npm run supabase:stop    # Stop local Supabase

# Testing
npm test                 # Run all tests
npm run test:e2e         # Playwright tests
npm run test:watch       # Watch mode

# Database
npm run db:migrate       # Create migration
npm run db:reset         # Reset local database
npm run db:types         # Generate TypeScript types

# Edge Functions
npm run functions:deploy # Deploy all functions
npm run functions:logs   # View function logs

# MCP
npm run mcp:verify       # Check MCP status
```

## Troubleshooting

### Supabase MCP Not Working

**Issue**: Claude Code can't access Supabase

**Solutions**:
1. Ensure Supabase CLI is running: `supabase status`
2. Verify local MCP endpoint: `curl http://localhost:54321/mcp`
3. Check `.mcp.json` configuration
4. For remote: Verify `project_ref` and `read_only=true` parameters
5. Restart Claude Code

### Authentication Errors

**Issue**: Supabase auth not working

**Solutions**:
1. Check environment variables are set correctly
2. Verify Supabase client initialization
3. Ensure cookies are properly handled (SSR)
4. Check RLS policies aren't blocking access

### Real-time Not Working

**Issue**: Subscriptions not receiving updates

**Solutions**:
1. Enable Realtime on tables in Supabase dashboard
2. Check RLS policies allow SELECT
3. Verify correct channel subscription syntax
4. Check browser console for WebSocket errors

## Security Best Practices

### RLS Policies
- Enable RLS on all tables
- Test policies thoroughly
- Use `auth.uid()` for user isolation
- Separate public/private data

### API Keys
- Never expose `service_role` key in client code
- Use `anon` key for client-side
- Rotate keys periodically
- Use environment variables

### MCP Safety
- Always use `read_only=true` for remote Supabase MCP
- Never connect to production database
- Scope to specific projects with `project_ref`
- Review changes before applying migrations

## Next Steps

1. **Update BMad Documents**:
   - Fill in `docs/architecture/tech-stack.md`
   - Create `docs/architecture/supabase-patterns.md`
   - Document RLS policies and patterns

2. **Configure Supabase**:
   - Set up authentication providers
   - Create initial database schema
   - Define RLS policies
   - Set up storage buckets

3. **Start Development**:
   - Use SM agent to create stories
   - Use Dev agent with Supabase MCP for database operations
   - Leverage Playwright MCP for E2E tests

## Resources

- Supabase Docs: https://supabase.com/docs
- Next.js + Supabase: https://supabase.com/docs/guides/getting-started/quickstarts/nextjs
- Supabase MCP: https://supabase.com/docs/guides/getting-started/mcp
- BMad Guide: `.bmad-core/user-guide.md`
- MCP Guide: `docs/templates/MCP-INTEGRATION-GUIDE.md`
