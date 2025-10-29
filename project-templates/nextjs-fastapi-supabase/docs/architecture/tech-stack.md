# Technology Stack

## Frontend

### Core Framework
- **Next.js 14+**: React framework with App Router
- **React 18+**: UI library with Server Components
- **TypeScript 5+**: Type-safe JavaScript

### Styling & UI
- **Tailwind CSS**: Utility-first CSS framework
- **shadcn/ui**: Re-usable component library
- **Lucide Icons**: Icon library

### State Management
- **React Context**: For global app state
- **React Query (TanStack Query)**: Server state management and caching
- **Zustand**: Lightweight state management (optional)

### API Communication
- **Fetch API**: Native browser API
- **Axios** (alternative): HTTP client with interceptors

### Development Tools
- **ESLint**: Code linting
- **Prettier**: Code formatting
- **Jest**: Unit testing
- **React Testing Library**: Component testing

---

## Backend

### Core Framework
- **FastAPI**: Modern Python web framework
- **Python 3.10+**: Programming language
- **Uvicorn**: ASGI server
- **Pydantic**: Data validation using type hints

### Database & ORM
- **PostgreSQL 14+**: Relational database
- **SQLAlchemy 2.0+**: SQL toolkit and ORM
- **Alembic**: Database migration tool
- **asyncpg**: Async PostgreSQL driver

### Authentication & Security
- **JWT (python-jose)**: JSON Web Tokens
- **passlib**: Password hashing (bcrypt)
- **python-multipart**: File upload support
- **CORS middleware**: Cross-origin resource sharing

### Development Tools
- **Pytest**: Testing framework
- **Black**: Code formatter
- **Flake8**: Code linter
- **MyPy**: Static type checker
- **Coverage.py**: Code coverage

---

## Testing

### E2E Testing
- **Playwright**: Browser automation
- **@playwright/test**: Test runner
- **Playwright MCP**: Integration with Claude Code

### Backend Testing
- **Pytest**: Test framework
- **pytest-asyncio**: Async test support
- **httpx**: Async HTTP client for testing
- **pytest-cov**: Coverage plugin

### Frontend Testing
- **Jest**: JavaScript testing framework
- **React Testing Library**: React component testing
- **Testing Library User Events**: User interaction simulation

---

## DevOps & Infrastructure

### Containerization
- **Docker**: Container platform
- **Docker Compose**: Multi-container orchestration

### Database Management
- **Alembic**: Database migrations
- **PostgreSQL Client (psql)**: Database CLI

### CI/CD (Placeholder)
- **GitHub Actions**: Automation workflows
- **Pre-commit hooks**: Code quality checks

---

## Development Tools

### Claude Code MCPs
- **Playwright MCP** (global): E2E test generation and browser automation
- **Swagger MCP** (project): API testing via FastAPI's auto-generated OpenAPI

### Version Control
- **Git**: Source control
- **GitHub/GitLab/Bitbucket**: Remote repository

### Package Management
- **npm**: Node.js package manager
- **pip**: Python package manager
- **venv**: Python virtual environment

---

## API Documentation

### FastAPI Built-in
- **Swagger UI**: Interactive API docs at `/docs`
- **ReDoc**: Alternative API docs at `/redoc`
- **OpenAPI 3.0**: Auto-generated specification at `/openapi.json`

---

## Architecture Patterns

### Backend Patterns
- **Repository Pattern**: Data access abstraction
- **Service Layer**: Business logic separation
- **Dependency Injection**: Via FastAPI's `Depends()`
- **Router-based Architecture**: Modular API structure

### Frontend Patterns
- **Server Components**: Default in Next.js App Router
- **Client Components**: For interactive UI (`"use client"`)
- **API Routes**: Backend-for-Frontend pattern
- **Layout System**: Shared layouts via `layout.tsx`

### Database Patterns
- **Migrations-first**: Alembic manages schema changes
- **Connection Pooling**: SQLAlchemy session management
- **Async Queries**: Using asyncpg driver

---

## Environment Configuration

### Development
```
Frontend: http://localhost:3000
Backend: http://localhost:8000
Database: postgresql://localhost:5432/myapp_dev
```

### Staging (Example)
```
Frontend: https://staging.example.com
Backend: https://staging-api.example.com
Database: postgresql://staging-db.example.com:5432/myapp_staging
```

### Production (Example)
```
Frontend: https://example.com
Backend: https://api.example.com
Database: postgresql://prod-db.example.com:5432/myapp_prod
```

---

## Performance Considerations

### Frontend
- **Code Splitting**: Automatic via Next.js
- **Image Optimization**: Next.js `<Image>` component
- **Font Optimization**: Next.js font system
- **React Server Components**: Reduce client-side JavaScript

### Backend
- **Async Endpoints**: FastAPI async/await support
- **Database Connection Pooling**: SQLAlchemy pool
- **Response Caching**: (Implement as needed)
- **Background Tasks**: FastAPI BackgroundTasks

### Database
- **Indexes**: Add on frequently queried columns
- **Query Optimization**: Use SQLAlchemy's query tools
- **Connection Limits**: Configure pool size

---

## Security Best Practices

### Authentication
- JWT with short expiration (30 min recommended)
- Refresh token rotation
- Password hashing with bcrypt (12 rounds)
- HTTPS only in production

### API Security
- CORS configured for specific origins
- Rate limiting (implement as needed)
- Input validation via Pydantic schemas
- SQL injection prevention (SQLAlchemy ORM)

### Frontend Security
- XSS prevention via React's escaping
- CSRF protection for forms
- Secure cookie settings
- Content Security Policy headers

---

## Scalability Roadmap

### Short-term
- Horizontal scaling with load balancer
- Redis caching layer
- CDN for static assets
- Database read replicas

### Long-term
- Microservices architecture
- Message queue (RabbitMQ/Kafka)
- Kubernetes orchestration
- Multi-region deployment

---

## Key Dependencies

### Frontend (package.json)
```json
{
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "typescript": "^5.0.0",
    "@tanstack/react-query": "^5.0.0"
  },
  "devDependencies": {
    "@playwright/test": "^1.40.0",
    "eslint": "^8.0.0",
    "prettier": "^3.0.0",
    "jest": "^29.0.0"
  }
}
```

### Backend (requirements.txt)
```
fastapi==0.104.0
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
alembic==1.12.0
asyncpg==0.29.0
pydantic==2.5.0
pydantic-settings==2.1.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
pytest==7.4.0
pytest-asyncio==0.21.0
httpx==0.25.0
```

---

## Technology Decision Rationale

### Why FastAPI?
- Automatic OpenAPI generation (Swagger MCP integration)
- High performance (async/await)
- Type safety with Pydantic
- Excellent documentation
- Growing ecosystem

### Why Next.js?
- Server-side rendering out of the box
- Excellent developer experience
- App Router for modern React patterns
- Built-in API routes
- Vercel deployment optimization

### Why PostgreSQL?
- ACID compliance
- Rich data types (JSON, arrays)
- Mature ecosystem
- Excellent performance
- Strong community support

### Why TypeScript?
- Type safety reduces bugs
- Better IDE support
- Self-documenting code
- Easier refactoring
- Industry standard for React

---

## Learning Resources

### FastAPI
- Official Docs: https://fastapi.tiangolo.com
- Tutorial: https://fastapi.tiangolo.com/tutorial/

### Next.js
- Official Docs: https://nextjs.org/docs
- Learn Next.js: https://nextjs.org/learn

### PostgreSQL
- Official Docs: https://www.postgresql.org/docs/
- SQLAlchemy Docs: https://docs.sqlalchemy.org/

### Playwright
- Official Docs: https://playwright.dev
- Best Practices: https://playwright.dev/docs/best-practices
