# Next.js + FastAPI + Supabase Fullstack Template

## Stack Overview

**Fullstack Web Application Template**

- **Frontend**: Next.js 14+ (App Router) + TypeScript + Tailwind CSS + shadcn/ui
- **Backend**: Python + FastAPI
- **Database**: Supabase (PostgreSQL + Auth + Storage + Real-time + Edge Functions)
- **Testing**: Vitest (unit), Playwright MCP (E2E)
- **MCPs**: Playwright (global), Swagger (API testing), Supabase (database), shadcn-ui (components)

**Best for**: ML/AI applications, data pipelines, Python ecosystem integration, SaaS apps

## Why This Stack?

### Next.js Frontend
- Modern App Router architecture
- Server and client components
- Built-in API routes
- Excellent performance

### FastAPI Backend
- Automatic OpenAPI (Swagger) documentation
- Async/await Python support
- Type hints with Pydantic
- Perfect for ML/AI integration

### Supabase (Not Raw PostgreSQL!)
✅ PostgreSQL database (all standard features)
✅ Authentication (email, social, phone, magic links)
✅ File storage (S3-compatible)
✅ Real-time subscriptions (WebSocket)
✅ Edge Functions (serverless)
✅ Auto-generated REST & GraphQL APIs
✅ Row-Level Security (RLS)
✅ Database UI dashboard

**Supabase = PostgreSQL + Firebase-like features + Better DX**

## Quick Start

### Prerequisites

- Python 3.10+ and pip
- Node.js 18+ and npm
- Supabase account (free tier: https://supabase.com)
- Claude Code with Playwright MCP installed globally

### Initial Setup

1. **Create Supabase Project**:
   ```bash
   # Go to https://supabase.com/dashboard
   # Click "New Project"
   # Note your project URL and service_role key
   ```

2. **Clone or copy this template**:
   ```bash
   # From mydevwf directory
   npm run create-project nextjs-fastapi-supabase my-ml-app
   cd ../my-ml-app
   ```

3. **Configure Supabase**:
   ```bash
   # Edit .mcp.json
   {
     "mcpServers": {
       "supabase": {
         "env": {
           "SUPABASE_URL": "https://xxxxx.supabase.co",
           "SUPABASE_SERVICE_ROLE_KEY": "eyJ..."
         }
       }
     }
   }
   ```

4. **Configure shadcn-ui (optional but recommended)**:
   ```bash
   # Add GitHub token to .mcp.json for better rate limits
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

5. **Install dependencies**:
   ```bash
   # Backend
   cd backend
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   pip install -r requirements.txt

   # Frontend
   cd ../frontend
   npm install
   ```

6. **Configure environment**:
   ```bash
   # Backend
   cp backend/.env.example backend/.env
   # Edit backend/.env:
   # SUPABASE_URL=https://xxxxx.supabase.co
   # SUPABASE_SERVICE_KEY=eyJ...
   # SECRET_KEY=your-secret-key-here

   # Frontend
   cp frontend/.env.example frontend/.env.local
   # NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
   # NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
   # NEXT_PUBLIC_API_URL=http://localhost:8000
   ```

7. **Start services**:
   ```bash
   # Terminal 1 - Backend
   cd backend
   source venv/bin/activate
   uvicorn main:app --reload --port 8000

   # Terminal 2 - Frontend
   cd frontend
   npm run dev
   ```

8. **Verify MCPs**:
   ```bash
   # In Claude Code
   /mcp
   # Should show: playwright, swagger-api, supabase, shadcn-ui
   ```

## Development Workflow

Follow the BMad enhanced development workflow:

1. **Planning Phase** (Web UI recommended for large context):
   - Use PM agent to create PRD
   - Use Architect agent to design system
   - Use UX Expert to create front-end-spec.md (shadcn/ui components)
   - Save documents to `docs/` directory

2. **Development Phase** (Claude Code):
   ```bash
   # Create story
   /BMad/agents/sm
   # Follow prompts to generate story from epic

   # Implement story
   /BMad/agents/dev
   # Dev agent will check for GitHub token (shadcn-ui MCP)
   # Dev agent loads front-end-spec.md for frontend stories
   # Use: /BMad/tasks/execute-checklist docs/stories/{story-file}.md
   ```

3. **QA Phase**:
   ```bash
   /BMad/agents/qa
   *review docs/stories/{story-file}.md
   ```

## MCP Usage

### Supabase MCP (Database Operations)

**Automatic Configuration**: Claude Code can directly interact with your Supabase project

**Usage Examples**:
```
"Query all users created in the last week"
"Create a new table called 'products' with columns: id, name, price"
"Show me the schema for the users table"
"Enable RLS on the products table"
"Create a storage bucket for user avatars"
```

**Access Supabase Dashboard**:
- Dashboard: https://supabase.com/dashboard/project/{project-id}
- Table Editor, SQL Editor, Authentication, Storage all available

### Swagger MCP (API Testing)

**Automatic Configuration**: FastAPI generates OpenAPI docs at `/openapi.json`

**Usage Examples**:
```
"Test the POST /api/users endpoint with payload: {email: 'test@example.com', name: 'John Doe'}"
"Verify all API endpoints return proper status codes"
"Show me the available API routes from the Swagger spec"
```

**Access Documentation**:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
- OpenAPI JSON: http://localhost:8000/openapi.json

### shadcn-ui MCP (Component Library)

**Automatic Configuration**: UX Expert and Dev agents will ask for GitHub token on activation

**Usage Examples**:
```
# UX Expert agent
"List all available shadcn/ui components"
"Show me the Button component demo"
"Get implementation examples for Form component"

# Dev agent
"Install shadcn Button and Form components"
"Show me how to use the Dialog component"
```

**Installation**:
```bash
cd frontend
npx shadcn@latest add button form input dialog toast
```

### Playwright MCP (E2E Testing)

**Global Configuration**: Already installed, available automatically

**Usage Examples**:
```
"Navigate to the login page and take a screenshot"
"Test the user registration flow from start to finish"
"Click the submit button and verify the success toast appears"
```

**Run Tests**:
```bash
cd tests/e2e
npx playwright test
npx playwright test --ui  # Interactive mode
```

## Project Structure

```
.
├── .mcp.json                          # MCP configuration (Supabase + Swagger + shadcn-ui)
├── .claude/
│   └── settings.local.json.example    # Local MCP overrides template
├── backend/
│   ├── app/
│   │   ├── api/                      # API routes
│   │   ├── core/                     # Config, security, dependencies
│   │   ├── models/                   # Pydantic schemas
│   │   ├── services/                 # Business logic
│   │   └── supabase/                 # Supabase client and utilities
│   ├── tests/                        # Backend tests (Pytest)
│   ├── main.py                       # FastAPI app entry
│   ├── requirements.txt              # Python dependencies
│   └── .env.example                  # Environment variables template
├── frontend/
│   ├── src/
│   │   ├── app/                      # Next.js app router
│   │   ├── components/               # React components
│   │   │   └── ui/                   # shadcn/ui components
│   │   ├── lib/                      # Utilities
│   │   │   ├── supabase.ts           # Supabase client
│   │   │   └── utils.ts              # shadcn utils
│   │   └── types/                    # TypeScript types
│   ├── public/                       # Static assets
│   ├── package.json                  # Node dependencies
│   ├── tailwind.config.ts            # Tailwind config
│   ├── components.json               # shadcn/ui config
│   └── .env.example                  # Frontend env template
├── tests/
│   ├── e2e/                          # Playwright E2E tests
│   ├── integration/                  # Integration tests
│   └── unit/                         # Vitest unit tests
├── docs/                             # BMad documentation
│   ├── prd.md.template               # PRD template
│   ├── architecture/                 # Architecture docs
│   ├── front-end-spec.md             # UX Expert creates this (shadcn/ui specs)
│   ├── stories/                      # User stories
│   └── qa/                           # QA assessments and gates
└── README.md                         # This file
```

## Technology Details

### Frontend (Next.js + shadcn/ui)

**Key Features**:
- App Router (Next.js 14+)
- TypeScript for type safety
- Tailwind CSS for styling
- shadcn/ui components (50+ accessible components)
- Supabase client for auth and data

**shadcn/ui Integration**:
```bash
# Initialize shadcn/ui (first time only)
cd frontend
npx shadcn@latest init

# Add components as needed
npx shadcn@latest add button form input dialog toast table card
```

**Example Component Usage**:
```typescript
// frontend/src/app/dashboard/page.tsx
import { Button } from "@/components/ui/button"
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card"

export default function Dashboard() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Welcome to Dashboard</CardTitle>
      </CardHeader>
      <CardContent>
        <Button variant="default">Get Started</Button>
      </CardContent>
    </Card>
  )
}
```

**Supabase Auth Integration**:
```typescript
// frontend/src/lib/supabase.ts
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'

export const supabase = createClientComponentClient()

// Usage in components
const { data: user } = await supabase.auth.getUser()
```

### Backend (FastAPI + Supabase)

**Key Features**:
- Automatic OpenAPI (Swagger) documentation
- Type hints with Pydantic validation
- Async/await support
- Supabase Python client
- JWT authentication (via Supabase)

**API Development**:
```python
# backend/app/api/routes/users.py
from fastapi import APIRouter, Depends
from app.schemas import UserCreate, UserResponse
from app.supabase import get_supabase

router = APIRouter(prefix="/api/users", tags=["users"])

@router.post("/", response_model=UserResponse)
async def create_user(user: UserCreate):
    supabase = get_supabase()
    result = supabase.table("users").insert(user.dict()).execute()
    return result.data[0]
```

**Testing with Swagger MCP**:
Claude Code can automatically test this endpoint via Swagger MCP without manual Postman usage.

### Database (Supabase)

**Direct Database Access via MCP**:
```
# In Claude Code, just ask:
"Show me all users in the database"
"Create a new product with name 'Widget' and price 29.99"
"What's the schema for the orders table?"
```

**SQL Editor** (Supabase Dashboard):
```sql
-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policy: users can only see their own data
CREATE POLICY "Users can view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);
```

**Authentication** (Built-in):
- Email/password signup and login
- OAuth (Google, GitHub, etc.)
- Magic links (passwordless)
- Phone/SMS authentication

**Storage** (Built-in):
```typescript
// Upload user avatar
const { data, error } = await supabase.storage
  .from('avatars')
  .upload(`${userId}/avatar.png`, file)
```

**Real-time** (Built-in):
```typescript
// Subscribe to new messages
supabase
  .channel('messages')
  .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'messages' },
    payload => console.log('New message!', payload))
  .subscribe()
```

## Testing Strategy

### Unit Tests (Vitest)
```bash
npm run test
# Only write tests for complex logic (10+ edge cases)
# Do NOT test shadcn/ui components (already tested)
```

### E2E Tests (Playwright via MCP)
```bash
# Dev writes test scenarios in markdown:
docs/qa/e2e/sprint-1/epics/epic-1/story-1/TC1.1-user-registration.md

# QA executes via Playwright MCP tools
# QA observes real browser behavior and screenshots
```

**Testing Approach**:
- ✅ Test YOUR business logic and user workflows
- ❌ Do NOT test shadcn/ui components (already tested by shadcn)
- ✅ E2E tests have consistent selectors (Radix UI structure)

## BMad Integration

### Core BMad Files

This template includes the BMad framework in `.bmad-core/`. Key files:

- `user-guide.md` - Complete BMad methodology
- `enhanced-ide-development-workflow.md` - Development cycle guide
- `working-in-the-brownfield.md` - For existing codebases

### Workflow Integration

**Dev Agent Context** (`.bmad-core/core-config.yaml`):
```yaml
devLoadAlwaysFiles:
  - docs/architecture/coding-standards.md
  - docs/architecture/tech-stack.md
  - docs/architecture/unified-project-structure.md
  - .bmad-core/data/testing-stack-guide.md
```

Update these files with your project-specific standards.

### MCP Enhancement

**Standard Dev Flow**:
1. Dev reads story
2. Dev writes code
3. Dev manually tests API in Postman
4. Dev manually queries database
5. Dev manually writes E2E tests
6. Dev commits

**MCP-Enhanced Flow**:
1. Dev reads story
2. Dev writes code
3. **Swagger MCP auto-tests API**
4. **Supabase MCP queries/updates database directly**
5. **shadcn-ui MCP provides component examples**
6. **Playwright MCP auto-generates/runs E2E tests**
7. Dev commits

**Time Saved**: ~50-60% per story

## Environment Variables

### Backend (.env)
```bash
# Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Security
SECRET_KEY=your-secret-key-here-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# CORS
BACKEND_CORS_ORIGINS=["http://localhost:3000"]
```

### Frontend (.env.local)
```bash
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
NEXT_PUBLIC_API_URL=http://localhost:8000
```

## Common Commands

```bash
# Development
npm run dev:backend      # Start FastAPI backend
npm run dev:frontend     # Start Next.js frontend

# Testing
npm run test             # Run Vitest unit tests
npm run test:e2e         # Run Playwright E2E tests

# Database (via Supabase Dashboard)
# https://supabase.com/dashboard/project/{id}/editor

# MCP
npm run mcp:verify       # Check MCP status
```

## Troubleshooting

### Supabase MCP Not Working

**Issue**: Claude Code can't access Supabase

**Solutions**:
1. Verify Supabase credentials in `.mcp.json`
2. Check project URL format: `https://xxxxx.supabase.co` (no trailing slash)
3. Use service_role key (not anon key) in MCP configuration
4. Restart Claude Code
5. Verify with `/mcp` command

### Swagger MCP Not Working

**Issue**: Claude Code can't access API

**Solutions**:
1. Ensure backend is running: `curl http://localhost:8000/openapi.json`
2. Check `.mcp.json` URL is correct
3. Restart Claude Code
4. Verify with `/mcp` command

### shadcn-ui Components Not Installing

**Issue**: `npx shadcn@latest add button` fails

**Solutions**:
1. Ensure you're in frontend/ directory
2. Run `npx shadcn@latest init` first (one-time setup)
3. Check `components.json` exists in frontend/
4. Verify TypeScript and Tailwind are configured

### Frontend Can't Reach Backend

**Issue**: CORS errors or connection refused

**Solutions**:
1. Verify backend CORS settings include frontend URL
2. Check NEXT_PUBLIC_API_URL in frontend/.env.local
3. Ensure backend is running on correct port (8000)

## Next Steps

1. **Update BMad Documents**:
   - Fill in `docs/architecture/tech-stack.md` with this stack info
   - Create `docs/architecture/coding-standards.md` for your team
   - Document your unified project structure

2. **Create Frontend Specification**:
   - Use UX Expert agent to create `docs/front-end-spec.md`
   - UX Expert will specify shadcn/ui components for each UI element
   - Dev agent will reference this during implementation

3. **Set up Supabase Schema**:
   - Design tables in Supabase Table Editor
   - Enable Row Level Security (RLS) policies
   - Configure authentication providers
   - Create storage buckets as needed

4. **Start Planning**:
   - Use PM agent (web UI) to create PRD
   - Use Architect agent to design system architecture
   - Use UX Expert to create front-end spec
   - Save documents to `docs/` directory

5. **Begin Development**:
   - Use SM agent to create first story
   - Use Dev agent with MCP enhancements to implement
   - Use QA agent to review and validate

## Resources

- **FastAPI Docs**: https://fastapi.tiangolo.com
- **Next.js Docs**: https://nextjs.org/docs
- **Supabase Docs**: https://supabase.com/docs
- **shadcn/ui Docs**: https://ui.shadcn.com
- **Playwright Docs**: https://playwright.dev
- **BMad Guide**: `.bmad-core/user-guide.md`
- **MCP Guide**: `docs/templates/MCP-INTEGRATION-GUIDE.md`
- **shadcn/ui Setup**: `docs/templates/SHADCN-UI-SETUP.md`
