# Project Initialization Guide - HDA Translation Platform v2.0

**Purpose**: Step-by-step guide to initialize a new repository with backend rebuild
**Date**: 2025-10-02
**Related Documents**:
- `NEW-PRD.md` - Product requirements
- `TECHNICAL_ARCHITECTURE.md` - Technical implementation details
- `FRONTEND_BACKEND_GAP_ANALYSIS.md` - Frontend integration requirements

---

## Table of Contents

1. [Overview](#1-overview)
2. [Repository Structure](#2-repository-structure)
3. [Step-by-Step Initialization](#3-step-by-step-initialization)
4. [What to Copy vs What to Build Fresh](#4-what-to-copy-vs-what-to-build-fresh)
5. [Development Workflow](#5-development-workflow)
6. [Testing Strategy](#6-testing-strategy)
7. [Deployment Plan](#7-deployment-plan)

---

## 1. Overview

### 1.1 Initialization Goals

1. **Create clean repository** with proper structure
2. **Copy working frontend** (no changes needed)
3. **Build backend from scratch** (no code reuse from old backend)
4. **Set up Supabase Cloud** properly
5. **Configure Vertex AI** integration
6. **Test integration** thoroughly

### 1.2 What's Changing vs What's Staying

**Staying (Copy As-Is)**:
- ✅ Frontend code (`frontend/` directory)
- ✅ Frontend dependencies
- ✅ UI components and stores
- ✅ Documentation (PRD, architecture docs)

**Building Fresh (No Code Reuse)**:
- 🔨 Backend API (FastAPI)
- 🔨 Worker scripts
- 🔨 Database schema (run fresh SQL)
- 🔨 Supabase configuration
- 🔨 Vertex AI integration

**Not Needed (Remove)**:
- ❌ Old backend code
- ❌ Redis configuration
- ❌ Celery workers
- ❌ S3/local storage logic
- ❌ Socket.io code
- ❌ SQLite migrations
- ❌ Docker compose for complex services

---

## 2. Repository Structure

### 2.1 Recommended Directory Layout

```
hdav2/
├── .git/
├── .gitignore
├── README.md
├── LICENSE
│
├── docs/
│   ├── NEW-PRD.md                           # Product requirements
│   ├── TECHNICAL_ARCHITECTURE.md            # Implementation guide
│   ├── ARCHITECTURE_DECISIONS.md            # Architectural decisions
│   ├── FRONTEND_BACKEND_GAP_ANALYSIS.md     # Integration requirements
│   └── PROJECT_INITIALIZATION_GUIDE.md      # This file
│
├── frontend/                                # React + Vite frontend (COPY AS-IS)
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/                       # API clients, Supabase client
│   │   ├── store/                          # Zustand stores
│   │   ├── lib/                            # Utilities
│   │   └── main.tsx
│   ├── public/
│   ├── index.html
│   ├── package.json
│   ├── vite.config.ts
│   ├── tsconfig.json
│   └── .env.example
│
├── backend/                                 # Python FastAPI backend (BUILD FRESH)
│   ├── api/
│   │   ├── __init__.py
│   │   ├── main.py                         # FastAPI application
│   │   ├── config.py                       # Environment configuration
│   │   │
│   │   ├── routers/                        # API route handlers
│   │   │   ├── __init__.py
│   │   │   ├── documents.py               # Document upload endpoints
│   │   │   ├── text_extraction.py         # Extraction endpoints
│   │   │   └── translation.py             # Translation endpoints (future)
│   │   │
│   │   ├── services/                       # Business logic
│   │   │   ├── __init__.py
│   │   │   ├── supabase_client.py         # Supabase connection
│   │   │   ├── vertex_ai_service.py       # Vertex AI integration
│   │   │   ├── batch_processor.py         # Batch processing logic
│   │   │   └── storage_service.py         # File storage operations
│   │   │
│   │   ├── models/                         # Data models (Pydantic)
│   │   │   ├── __init__.py
│   │   │   ├── document.py
│   │   │   ├── extraction.py
│   │   │   └── translation.py
│   │   │
│   │   └── utils/                          # Utilities
│   │       ├── __init__.py
│   │       ├── token_estimator.py         # Token counting
│   │       ├── page_marker_inserter.py    # Page marker logic
│   │       ├── pdf_processor.py           # PDF operations
│   │       └── logger.py                  # Logging configuration
│   │
│   ├── workers/                            # Background workers
│   │   ├── __init__.py
│   │   ├── text_extraction_worker.py      # Extraction worker
│   │   └── translation_worker.py          # Translation worker (future)
│   │
│   ├── tests/                              # Backend tests
│   │   ├── __init__.py
│   │   ├── test_documents.py
│   │   ├── test_extraction.py
│   │   └── test_integration.py
│   │
│   ├── requirements.txt                    # Python dependencies
│   ├── requirements-dev.txt                # Development dependencies
│   ├── .env.example                        # Environment variables template
│   └── README.md                           # Backend setup instructions
│
├── database/                               # Database scripts
│   ├── schema.sql                          # Complete database schema
│   ├── seed.sql                            # Seed data for testing
│   └── migrations/                         # Future migrations (if needed)
│
├── scripts/                                # Utility scripts
│   ├── setup_supabase.sh                   # Supabase setup automation
│   ├── test_vertex_ai.py                   # Vertex AI connection test
│   └── seed_test_data.py                   # Create test documents
│
└── .github/                                # GitHub configuration (optional)
    └── workflows/
        ├── backend-tests.yml               # CI for backend
        └── frontend-build.yml              # CI for frontend
```

### 2.2 .gitignore

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
venv/
env/
ENV/

# Node
node_modules/
dist/
.cache/
.parcel-cache/

# Environment variables
.env
.env.local
.env.production
.env.development

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Supabase
.supabase/

# Logs
*.log
logs/

# Testing
.coverage
htmlcov/
.pytest_cache/

# Sensitive
service-account-key.json
*.pem
*.key
```

---

## 3. Step-by-Step Initialization

### Step 1: Create New Repository

```bash
# Create new directory
mkdir hdav2
cd hdav2

# Initialize git
git init
git branch -M main

# Create .gitignore
cat > .gitignore << 'EOF'
# [paste .gitignore from Section 2.2]
EOF

# Initial commit
git add .gitignore
git commit -m "Initial commit: project structure"
```

### Step 2: Copy Documentation

```bash
# Create docs directory
mkdir docs

# Copy documentation from old project
cp ../HDA2/NEW-PRD.md docs/
cp ../HDA2/TECHNICAL_ARCHITECTURE.md docs/
cp ../HDA2/ARCHITECTURE_DECISIONS.md docs/
cp ../HDA2/FRONTEND_BACKEND_GAP_ANALYSIS.md docs/
cp ../HDA2/PROJECT_INITIALIZATION_GUIDE.md docs/

# Commit
git add docs/
git commit -m "docs: add project documentation"
```

### Step 3: Copy Frontend (As-Is)

```bash
# Copy entire frontend directory
cp -r ../HDA2/frontend ./

# Create frontend .env.example
cat > frontend/.env.example << 'EOF'
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_API_URL=http://localhost:8000
EOF

# Install frontend dependencies (verify it works)
cd frontend
npm install
npm run dev  # Should start on localhost:5173
cd ..

# Commit
git add frontend/
git commit -m "feat: add frontend (Lovable-generated, no changes)"
```

### Step 4: Create Backend Structure

```bash
# Create backend directory structure
mkdir -p backend/{api/{routers,services,models,utils},workers,tests}

# Create __init__.py files
touch backend/__init__.py
touch backend/api/__init__.py
touch backend/api/routers/__init__.py
touch backend/api/services/__init__.py
touch backend/api/models/__init__.py
touch backend/api/utils/__init__.py
touch backend/workers/__init__.py
touch backend/tests/__init__.py

# Create requirements.txt
cat > backend/requirements.txt << 'EOF'
fastapi==0.117.0
uvicorn[standard]==0.34.0
python-multipart==0.0.20
python-dotenv==1.0.1
pydantic==2.10.3
pydantic-settings==2.7.0

# Supabase
supabase==2.13.0
postgrest==0.18.0

# PostgreSQL and pgmq
psycopg2-binary==2.9.10
pgmq==0.11.1

# Vertex AI
google-cloud-aiplatform==1.75.0
vertexai==1.75.0

# PDF Processing
PyPDF2==3.0.1
pdf2image==1.17.0
Pillow==11.0.0

# Utilities
httpx==0.28.1
aiofiles==24.1.0
python-magic==0.4.27
EOF

# Create requirements-dev.txt
cat > backend/requirements-dev.txt << 'EOF'
-r requirements.txt

# Testing
pytest==8.3.4
pytest-asyncio==0.24.0
pytest-cov==6.0.0
httpx==0.28.1

# Linting
ruff==0.8.4
black==24.10.0
mypy==1.13.0

# Development
ipython==8.31.0
ipdb==0.13.13
EOF

# Create .env.example
cat > backend/.env.example << 'EOF'
# Supabase Configuration
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_KEY=eyJ...
DATABASE_URL=postgresql://postgres.xxx:[PASSWORD]@aws-0-us-west-1.pooler.supabase.com:6543/postgres

# Vertex AI Configuration
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json
VERTEX_AI_LOCATION=us-central1

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
API_RELOAD=true
LOG_LEVEL=INFO

# CORS
CORS_ORIGINS=http://localhost:5173,http://localhost:3000

# Worker Configuration
WORKER_POLL_INTERVAL=2
WORKER_VISIBILITY_TIMEOUT=300
EOF

# Commit
git add backend/
git commit -m "chore: initialize backend structure"
```

### Step 5: Create Database Schema File

```bash
# Create database directory
mkdir database

# Create schema.sql (copy from TECHNICAL_ARCHITECTURE.md Section 2.1)
cat > database/schema.sql << 'EOF'
-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgmq";

-- [Copy complete schema from TECHNICAL_ARCHITECTURE.md Section 2.1]
-- (Documents table, text_extraction_results, translations, etc.)
EOF

# Commit
git add database/
git commit -m "db: add complete database schema"
```

### Step 6: Set Up Supabase Cloud

**Go to Supabase Dashboard**: https://supabase.com/dashboard

1. **Create New Project**
   - Organization: Create or select
   - Project name: `hdav2`
   - Database password: Generate strong password (save it!)
   - Region: Choose closest to you
   - Pricing plan: Free

2. **Get Connection Details**
   - Go to Project Settings > Database
   - Copy these values:
     - `Connection String` (pooler): This is your `DATABASE_URL`
     - Project URL: `https://xxx.supabase.co`
   - Go to Project Settings > API
   - Copy these values:
     - `anon` `public` key: This is `SUPABASE_ANON_KEY`
     - `service_role` `secret` key: This is `SUPABASE_SERVICE_KEY`

3. **Test Direct Connection**
   ```bash
   # Install psql if not installed
   # On Mac: brew install postgresql
   # On Ubuntu: sudo apt-get install postgresql-client

   # Test connection (replace with your connection string)
   psql "postgresql://postgres.xxx:[PASSWORD]@aws-0-us-west-1.pooler.supabase.com:6543/postgres"

   # Should connect successfully
   # Type \q to exit
   ```

4. **Run Database Schema**
   ```bash
   # Run schema.sql
   psql "postgresql://postgres.xxx:[PASSWORD]@..." < database/schema.sql

   # Verify tables created
   psql "postgresql://postgres.xxx:[PASSWORD]@..." -c "\dt"

   # Should show: documents, text_extraction_results, translations, etc.
   ```

5. **Create Storage Bucket**
   - Go to Storage in Supabase dashboard
   - Click "Create a new bucket"
   - Name: `documents`
   - Public: No (keep private)
   - Click "Create bucket"

6. **Enable Realtime**
   - Go to Database > Replication
   - Enable replication for tables:
     - `documents`
     - `text_extraction_results`
     - `translations`

7. **Update Backend .env**
   ```bash
   cd backend
   cp .env.example .env
   # Edit .env with real values from Supabase
   ```

### Step 7: Set Up Vertex AI

1. **Enable Vertex AI API**
   ```bash
   # Install gcloud CLI if not installed
   # https://cloud.google.com/sdk/docs/install

   # Login
   gcloud auth login

   # Set project
   gcloud config set project YOUR_PROJECT_ID

   # Enable Vertex AI API
   gcloud services enable aiplatform.googleapis.com
   ```

2. **Create Service Account**
   ```bash
   # Create service account
   gcloud iam service-accounts create hda-vertex-ai \
     --display-name="HDA Vertex AI Service Account" \
     --project=YOUR_PROJECT_ID

   # Grant permissions
   gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
     --member="serviceAccount:hda-vertex-ai@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/aiplatform.user"

   # Create and download key
   gcloud iam service-accounts keys create backend/service-account-key.json \
     --iam-account=hda-vertex-ai@YOUR_PROJECT_ID.iam.gserviceaccount.com

   # IMPORTANT: Add to .gitignore (already included)
   ```

3. **Test Vertex AI Connection**
   ```bash
   # Create test script
   cat > scripts/test_vertex_ai.py << 'EOF'
import os
import vertexai
from vertexai.generative_models import GenerativeModel

# Initialize
project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
location = os.getenv("VERTEX_AI_LOCATION", "us-central1")

vertexai.init(project=project_id, location=location)

# Test model
model = GenerativeModel("gemini-2.0-flash-exp")
response = model.generate_content("Hello, this is a test. Please respond.")

print(f"Response: {response.text}")
print("✅ Vertex AI connection successful!")
EOF

   # Run test
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   python ../scripts/test_vertex_ai.py
   ```

### Step 8: Implement Backend (Story 1.1)

**Start with main.py**:

```python
# backend/api/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.config import settings
from api.routers import documents, text_extraction
import logging

# Configure logging
logging.basicConfig(level=settings.LOG_LEVEL)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="HDA Translation Platform API",
    version="2.0.0",
    description="Text extraction and translation API powered by Vertex AI"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(documents.router, prefix="/api/documents", tags=["documents"])
app.include_router(text_extraction.router, prefix="/api/text-extraction", tags=["text-extraction"])

# Health check
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "version": "2.0.0",
        "environment": settings.ENVIRONMENT
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.API_HOST,
        port=settings.API_PORT,
        reload=settings.API_RELOAD
    )
```

**Create config.py**:

```python
# backend/api/config.py
from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    # Supabase
    SUPABASE_URL: str
    SUPABASE_ANON_KEY: str
    SUPABASE_SERVICE_KEY: str
    DATABASE_URL: str

    # Vertex AI
    GOOGLE_CLOUD_PROJECT: str
    GOOGLE_APPLICATION_CREDENTIALS: str
    VERTEX_AI_LOCATION: str = "us-central1"

    # API
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8000
    API_RELOAD: bool = True
    LOG_LEVEL: str = "INFO"
    ENVIRONMENT: str = "development"

    # CORS
    CORS_ORIGINS: List[str] = ["http://localhost:5173"]

    # Worker
    WORKER_POLL_INTERVAL: int = 2
    WORKER_VISIBILITY_TIMEOUT: int = 300

    class Config:
        env_file = ".env"

settings = Settings()
```

**Implement Supabase Client**:

```python
# backend/api/services/supabase_client.py
from supabase import create_client, Client
from api.config import settings

# Singleton Supabase client
_supabase: Client = None

def get_supabase() -> Client:
    global _supabase
    if _supabase is None:
        _supabase = create_client(
            settings.SUPABASE_URL,
            settings.SUPABASE_SERVICE_KEY  # Use service key for backend
        )
    return _supabase

# Convenience function
supabase = get_supabase()
```

**Continue building according to TECHNICAL_ARCHITECTURE.md Sections 3, 7, 8**

### Step 9: Test Backend

```bash
# Run backend
cd backend
source venv/bin/activate
uvicorn api.main:app --reload --host 0.0.0.0 --port 8000

# Test health check
curl http://localhost:8000/health

# Should return: {"status": "healthy", "version": "2.0.0"}
```

### Step 10: Test Frontend Integration

```bash
# In another terminal, run frontend
cd frontend
npm run dev

# Should start on http://localhost:5173

# Test upload flow:
# 1. Go to http://localhost:5173/upload
# 2. Upload a test PDF
# 3. Check backend logs for upload request
# 4. Verify file in Supabase Storage dashboard
# 5. Verify record in documents table
```

---

## 4. What to Copy vs What to Build Fresh

### 4.1 Copy As-Is (No Changes)

| Directory/File | Reason |
|----------------|--------|
| `frontend/` (entire directory) | Frontend is complete, tested, and working |
| `docs/*.md` (all documentation) | Documentation is current and accurate |
| None from backend | Backend being rebuilt from scratch |

### 4.2 Build Fresh (Do Not Copy Old Code)

| Component | Reason |
|-----------|--------|
| Backend API | Old implementation too complex, uses wrong architecture |
| Workers | Old workers tied to Redis/Celery |
| Database migrations | Start fresh with complete schema |
| Docker configuration | Not needed (using Supabase Cloud) |
| Environment setup | Different services, different configuration |

### 4.3 Reference but Don't Copy

| File | How to Use |
|------|-----------|
| Old backend code | Reference for Vertex AI API usage patterns only |
| Old worker scripts | Reference for job processing logic concepts |
| Test files | Reference for test scenarios |

---

## 5. Development Workflow

### 5.1 Development Order (Story Sequence)

**Week 1: Story 1.1 - Foundation**
- ✅ Set up Supabase Cloud
- ✅ Solve direct PostgreSQL connection
- ✅ Run database schema
- ✅ Test pgmq operations
- ✅ Set up Vertex AI
- ✅ Create backend structure

**Week 2: Story 1.2 - Upload API**
- Implement `POST /api/documents/upload`
- Test with frontend
- Verify storage and database
- Test with large PDFs (500+ pages)

**Week 3-4: Story 1.3 - Text Extraction**
- Implement batch processing logic
- Implement extraction API endpoints
- Create extraction worker
- **Implement page marker insertion** (critical!)
- Test with various PDF sizes
- Test Realtime updates

**Week 5: Story 1.4 - Integration**
- End-to-end testing
- Fix any integration issues
- Performance testing
- Bug fixes

**Future: Stories 1.5-1.7**
- Translation (if needed)
- Export/Download
- Authentication

### 5.2 Daily Development Cycle

```bash
# Morning: Start services
cd backend
source venv/bin/activate
uvicorn api.main:app --reload &

cd ../frontend
npm run dev &

# Work on feature
# ... code ...

# Test changes
curl -X POST http://localhost:8000/api/... \
  -H "Content-Type: application/json" \
  -d '...'

# Commit changes
git add .
git commit -m "feat: implement X"

# End of day: Push changes
git push origin main
```

### 5.3 Branch Strategy

```bash
# Create feature branch
git checkout -b feature/upload-api

# Work on feature
# ... commits ...

# Push branch
git push origin feature/upload-api

# Create PR on GitHub
# Review and merge to main
```

---

## 6. Testing Strategy

### 6.1 Unit Tests

```python
# backend/tests/test_documents.py
import pytest
from fastapi.testclient import TestClient
from api.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_upload_document():
    with open("test.pdf", "rb") as f:
        response = client.post(
            "/api/documents/upload",
            files={"file": ("test.pdf", f, "application/pdf")},
            params={"source_language": "en", "target_language": "es"}
        )
    assert response.status_code == 200
    assert "id" in response.json()
```

### 6.2 Integration Tests

```python
# backend/tests/test_integration.py
import pytest
from api.services.supabase_client import supabase

@pytest.mark.asyncio
async def test_upload_extraction_flow():
    # 1. Upload document
    # 2. Trigger extraction
    # 3. Poll status
    # 4. Verify extraction completed
    # 5. Verify extracted_text has page markers
    pass
```

### 6.3 Test with Real PDFs

```bash
# Create test PDFs directory
mkdir backend/tests/fixtures

# Add test PDFs:
# - small.pdf (10 pages)
# - medium.pdf (100 pages)
# - large.pdf (500 pages)

# Run integration tests
pytest backend/tests/test_integration.py -v
```

---

## 7. Deployment Plan

### 7.1 Deployment Checklist

**Pre-Deployment**:
- [ ] All Story 1.1-1.4 acceptance criteria met
- [ ] Integration tests passing
- [ ] Performance tested with 500+ page PDFs
- [ ] Frontend tested in production mode
- [ ] Environment variables documented
- [ ] Secrets secured (service keys, passwords)

**Deployment Steps**:

**Backend (Heroku/Railway/Render)**:
```bash
# Example: Deploy to Railway
railway init
railway link
railway up

# Set environment variables
railway variables set SUPABASE_URL=...
railway variables set SUPABASE_SERVICE_KEY=...
# ... etc
```

**Frontend (Vercel/Netlify)**:
```bash
# Example: Deploy to Vercel
cd frontend
vercel

# Set environment variables in Vercel dashboard
```

**Worker (Background Process)**:
```bash
# Option 1: Same platform as backend (separate process)
# Option 2: Separate service
# Option 3: Serverless (AWS Lambda, Google Cloud Run)
```

### 7.2 Post-Deployment

- [ ] Test upload flow in production
- [ ] Test extraction flow in production
- [ ] Monitor error logs
- [ ] Monitor queue depth
- [ ] Set up alerts (Sentry, DataDog, etc.)

---

## 8. Common Issues & Solutions

### Issue 1: Direct PostgreSQL Connection Fails

**Symptoms**:
- `psql` connection times out
- Backend can't connect to database
- Only PostgREST API works

**Solutions**:
- Try pooler connection string: `...pooler.supabase.com:6543`
- Check IPv6 vs IPv4 settings
- Use transaction pooler for long-running connections
- Use session pooler for short connections
- See Supabase docs: https://supabase.com/docs/guides/database/connecting-to-postgres

### Issue 2: Frontend Can't Connect to Backend

**Symptoms**:
- CORS errors in browser console
- 404 errors on API calls

**Solutions**:
- Check `CORS_ORIGINS` in backend `.env`
- Verify backend is running on port 8000
- Verify frontend `VITE_API_URL` points to `http://localhost:8000`

### Issue 3: Vertex AI Authentication Fails

**Symptoms**:
- `google.auth.exceptions.DefaultCredentialsError`
- "Could not automatically determine credentials"

**Solutions**:
- Verify `GOOGLE_APPLICATION_CREDENTIALS` path is correct
- Check service account key file exists
- Verify service account has `aiplatform.user` role

### Issue 4: Worker Not Processing Jobs

**Symptoms**:
- Jobs stay in queue
- Worker logs show no activity

**Solutions**:
- Check pgmq queue exists: `SELECT * FROM pgmq.list_queues();`
- Verify worker is connected to correct database
- Check worker logs for errors
- Manually read from queue to test: `SELECT * FROM pgmq.read('text_extraction_queue', 30, 1);`

---

## 9. Quick Reference Commands

```bash
# Backend
cd backend
source venv/bin/activate
uvicorn api.main:app --reload --host 0.0.0.0 --port 8000

# Worker
cd backend
source venv/bin/activate
python workers/text_extraction_worker.py

# Frontend
cd frontend
npm run dev

# Database (psql)
psql "postgresql://postgres.xxx:[PASSWORD]@...pooler.supabase.com:6543/postgres"

# Test API
curl http://localhost:8000/health

# Test upload
curl -X POST http://localhost:8000/api/documents/upload \
  -F "file=@test.pdf" \
  -F "source_language=en" \
  -F "target_language=es"

# Check queue
psql "..." -c "SELECT * FROM pgmq.read('text_extraction_queue', 0, 10);"

# Check documents
psql "..." -c "SELECT id, file_name, status FROM documents ORDER BY created_at DESC LIMIT 10;"
```

---

## 10. Success Criteria

### You're done with initialization when:

- [ ] Repository created with proper structure
- [ ] Frontend copied and running
- [ ] Backend structure created
- [ ] Supabase Cloud configured
- [ ] Database schema applied
- [ ] pgmq queues created
- [ ] Storage bucket created
- [ ] Realtime enabled
- [ ] Vertex AI tested
- [ ] Backend health check working
- [ ] Frontend can reach backend
- [ ] All documentation in place
- [ ] Ready to start Story 1.2

---

## Document Version History

- **2025-10-02**: Initial creation - Complete project initialization guide
