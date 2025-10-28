# Python/FastAPI + PostgreSQL Project Template

## Stack Overview

- **Frontend**: React with TypeScript (Next.js)
- **Backend**: Python with FastAPI
- **Database**: PostgreSQL
- **Testing**: Playwright (E2E), Pytest (backend), Jest (frontend)
- **MCPs**: Playwright (global), Swagger (project)

## Quick Start

### Prerequisites

- Python 3.10+ and pip
- Node.js 18+ and npm
- PostgreSQL 14+
- Claude Code with Playwright MCP installed globally

### Initial Setup

1. **Clone or copy this template**:
   ```bash
   cp -r project-templates/python-fastapi-postgres ../my-new-project
   cd ../my-new-project
   ```

2. **Install dependencies**:
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

3. **Configure environment**:
   ```bash
   # Backend
   cp backend/.env.example backend/.env
   # Edit backend/.env with your PostgreSQL credentials

   # Frontend
   cp frontend/.env.example frontend/.env.local
   ```

4. **Start services**:
   ```bash
   # Option A: Docker Compose (recommended)
   docker-compose up -d

   # Option B: Manual
   # Terminal 1 - Database
   psql -U postgres  # Start PostgreSQL

   # Terminal 2 - Backend
   cd backend
   source venv/bin/activate
   uvicorn main:app --reload --port 8000

   # Terminal 3 - Frontend
   cd frontend
   npm run dev
   ```

5. **Verify MCPs**:
   ```bash
   # In Claude Code
   /mcp
   # Should show: playwright (global), swagger-api (project)
   ```

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
   # Follow prompts to generate story from epic

   # Implement story
   /BMad/agents/dev
   # Use: /BMad/tasks/execute-checklist docs/stories/{story-file}.md
   ```

3. **QA Phase**:
   ```bash
   /BMad/agents/qa
   *review docs/stories/{story-file}.md
   ```

## MCP Usage

### Swagger MCP (API Testing)

**Automatic Configuration**: FastAPI generates OpenAPI docs at `/openapi.json`

**Usage in Claude Code**:
```
"Test the POST /api/users endpoint with payload: {email: 'test@example.com', name: 'John Doe'}"
"Verify all API endpoints return proper status codes"
"Show me the available API routes from the Swagger spec"
```

**Access Documentation**:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
- OpenAPI JSON: http://localhost:8000/openapi.json

### Playwright MCP (E2E Testing)

**Global Configuration**: Already installed, available automatically

**Usage in Claude Code**:
```
"Generate E2E test for user registration flow"
"Create test that verifies dashboard loads after login"
"Write test to check form validation on signup page"
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
├── .mcp.json                          # MCP configuration (Swagger)
├── .claude/
│   └── settings.local.json.example    # Local MCP overrides template
├── backend/
│   ├── app/
│   │   ├── api/                      # API routes
│   │   ├── core/                     # Config, security, dependencies
│   │   ├── models/                   # SQLAlchemy models
│   │   ├── schemas/                  # Pydantic schemas
│   │   └── services/                 # Business logic
│   ├── alembic/                      # Database migrations
│   ├── tests/                        # Backend tests
│   ├── main.py                       # FastAPI app entry
│   ├── requirements.txt              # Python dependencies
│   └── .env.example                  # Environment variables template
├── frontend/
│   ├── src/
│   │   ├── app/                      # Next.js app router
│   │   ├── components/               # React components
│   │   ├── lib/                      # Utilities
│   │   └── types/                    # TypeScript types
│   ├── public/                       # Static assets
│   ├── package.json                  # Node dependencies
│   └── .env.example                  # Frontend env template
├── tests/
│   ├── e2e/                          # Playwright E2E tests
│   ├── integration/                  # Integration tests
│   └── unit/                         # Additional unit tests
├── docs/                             # BMad documentation
│   ├── prd.md.template               # PRD template
│   ├── architecture/                 # Architecture docs
│   ├── epics/                        # Sharded epics
│   ├── stories/                      # User stories
│   └── qa/                           # QA assessments and gates
├── docker-compose.yml                # Local development stack
└── README.md                         # This file
```

## Technology Details

### Backend (FastAPI)

**Key Features**:
- Automatic OpenAPI (Swagger) documentation
- Type hints with Pydantic validation
- Async/await support
- SQLAlchemy ORM with Alembic migrations
- JWT authentication
- CORS middleware

**API Development**:
```python
# backend/app/api/routes/users.py
from fastapi import APIRouter, Depends
from app.schemas import UserCreate, UserResponse

router = APIRouter(prefix="/api/users", tags=["users"])

@router.post("/", response_model=UserResponse)
async def create_user(user: UserCreate):
    # FastAPI auto-generates OpenAPI spec from this
    return {"id": 1, "email": user.email}
```

**Testing with Swagger MCP**:
Claude Code can automatically test this endpoint via Swagger MCP without manual Postman usage.

### Frontend (Next.js + TypeScript)

**Key Features**:
- App Router (Next.js 14+)
- TypeScript for type safety
- Tailwind CSS for styling
- React Server Components
- API client with type safety

**Development**:
```typescript
// frontend/src/app/api/users/route.ts
export async function POST(request: Request) {
  const body = await request.json();
  const response = await fetch('http://localhost:8000/api/users', {
    method: 'POST',
    body: JSON.stringify(body),
  });
  return Response.json(await response.json());
}
```

### Database (PostgreSQL)

**Migrations**:
```bash
# Create migration
cd backend
alembic revision --autogenerate -m "Add users table"

# Apply migration
alembic upgrade head

# Rollback
alembic downgrade -1
```

**Connection**:
```python
# backend/app/core/database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
```

## Testing Strategy

### Backend Tests (Pytest)
```bash
cd backend
pytest
pytest --cov=app tests/  # With coverage
```

### Frontend Tests (Jest)
```bash
cd frontend
npm test
npm run test:coverage
```

### E2E Tests (Playwright via MCP)
```bash
cd tests/e2e
npx playwright test
npx playwright test --headed  # See browser
npx playwright test --debug   # Debug mode
```

**MCP-Enhanced Testing**:
Ask Claude Code to generate tests:
```
"Generate E2E test for the complete user registration and login flow"
```

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
  - docs/architecture/source-tree.md
```

Update these files with your project-specific standards.

### MCP Enhancement

**Standard Dev Flow**:
1. Dev reads story
2. Dev writes code
3. Dev manually tests API in Postman
4. Dev manually writes E2E tests
5. Dev commits

**MCP-Enhanced Flow**:
1. Dev reads story
2. Dev writes code
3. **Swagger MCP auto-tests API**
4. **Playwright MCP auto-generates E2E tests**
5. Dev commits

**Time Saved**: ~40-50% per story

## Environment Variables

### Backend (.env)
```bash
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/myapp_dev

# Security
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# CORS
BACKEND_CORS_ORIGINS=["http://localhost:3000"]
```

### Frontend (.env.local)
```bash
NEXT_PUBLIC_API_URL=http://localhost:8000
```

## Common Commands

```bash
# Development
npm run dev:all          # Start all services (docker-compose)
npm run dev:backend      # Backend only
npm run dev:frontend     # Frontend only

# Testing
npm run test:backend     # Pytest
npm run test:frontend    # Jest
npm run test:e2e         # Playwright

# Database
npm run db:migrate       # Run migrations
npm run db:reset         # Reset database

# MCP
npm run mcp:verify       # Check MCP status
```

## Troubleshooting

### Swagger MCP Not Working

**Issue**: Claude Code can't access API

**Solutions**:
1. Ensure backend is running: `curl http://localhost:8000/openapi.json`
2. Check `.mcp.json` URL is correct
3. Restart Claude Code
4. Verify with `/mcp` command

### PostgreSQL Connection Errors

**Issue**: Backend can't connect to database

**Solutions**:
1. Check PostgreSQL is running: `pg_isready`
2. Verify DATABASE_URL in backend/.env
3. Ensure database exists: `createdb myapp_dev`
4. Check credentials

### Frontend Can't Reach Backend

**Issue**: CORS errors or connection refused

**Solutions**:
1. Verify backend CORS settings include frontend URL
2. Check NEXT_PUBLIC_API_URL in frontend/.env.local
3. Ensure backend is running on correct port

## Next Steps

1. **Update BMad Documents**:
   - Fill in `docs/architecture/tech-stack.md` with this stack info
   - Create `docs/architecture/coding-standards.md` for your team
   - Document your source tree structure

2. **Start Planning**:
   - Use PM agent (web UI) to create PRD
   - Use Architect agent to design system architecture
   - Save documents to `docs/` directory

3. **Begin Development**:
   - Use SM agent to create first story
   - Use Dev agent with MCP enhancements to implement
   - Use QA agent to review and validate

## Resources

- FastAPI Docs: https://fastapi.tiangolo.com
- Next.js Docs: https://nextjs.org/docs
- Playwright Docs: https://playwright.dev
- BMad Guide: `.bmad-core/user-guide.md`
- MCP Guide: `docs/templates/MCP-INTEGRATION-GUIDE.md`
