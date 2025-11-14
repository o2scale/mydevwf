# Worker Pool Deployment Guide

**Version**: 2.0
**Last Updated**: 2025-10-03
**Related**: Story 1.5 - Parallel Worker Architecture

---

## Overview

This guide explains how to deploy and manage the worker pool for background job processing in the HDA Translation Platform. The worker pool handles text extraction and translation jobs concurrently.

**Current Implementation**: Async worker pool (single process, 4 coroutines)
**Alternative**: Multiprocessing approach (for Linux/production, if needed)

**What You'll Deploy**:
- **Async Pool** (Current): Single process with 4 concurrent coroutines
- Health monitoring endpoints
- Configuration via environment variables

---

## Prerequisites

### System Requirements

**Minimum**:
- Python 3.13+
- 2GB RAM (500MB for workers + 1.5GB buffer)
- 2 CPU cores
- PostgreSQL access (Supabase)
- Vertex AI credentials

**Recommended**:
- 4GB RAM
- 4+ CPU cores (1 per worker)
- Fast network connection (Vertex AI API calls)

### Dependencies

**Python Packages**:
```bash
pip install -r requirements.txt
```

Required packages:
- `psycopg2-binary` - PostgreSQL driver
- `supabase` - Supabase client
- `google-cloud-aiplatform` - Vertex AI SDK
- `python-dotenv` - Environment variables
- `PyPDF2` - PDF processing

---

## Environment Configuration

### Environment Variables

Create `.env` file in `backend/` directory:

```bash
# Database (Supabase Session Pooler - Port 5432)
DATABASE_URL=postgresql://postgres.{PROJECT_REF}:{PASSWORD}@aws-1-{REGION}.pooler.supabase.com:5432/postgres

# Supabase
SUPABASE_URL=https://{PROJECT_REF}.supabase.co
SUPABASE_SERVICE_KEY=your-service-key-here

# Vertex AI
GOOGLE_CLOUD_PROJECT=your-gcp-project-id
VERTEX_AI_LOCATION=us-central1
VERTEX_AI_MODEL=gemini-2.0-flash-exp
GOOGLE_APPLICATION_CREDENTIALS=./vertex-ai-credentials.json

# Worker Pool Configuration
WORKER_POOL_SIZE=4  # Number of concurrent workers (default: 4)

# Application
ENVIRONMENT=production
DEBUG=false
```

### Verify Configuration

Test database connection:
```bash
python -c "import psycopg2; import os; from dotenv import load_dotenv; load_dotenv(); conn = psycopg2.connect(os.getenv('DATABASE_URL')); print('✅ Database connected')"
```

Test Supabase connection:
```bash
python -c "from supabase import create_client; import os; from dotenv import load_dotenv; load_dotenv(); client = create_client(os.getenv('SUPABASE_URL'), os.getenv('SUPABASE_SERVICE_KEY')); print('✅ Supabase connected')"
```

Test Vertex AI:
```bash
python -c "import vertexai; import os; from dotenv import load_dotenv; load_dotenv(); vertexai.init(project=os.getenv('GOOGLE_CLOUD_PROJECT')); print('✅ Vertex AI initialized')"
```

---

## Development Deployment

### Local Development - Async Pool (Current Implementation)

#### macOS/Linux

**Start Worker Pool**:
```bash
cd backend
source venv/bin/activate
python workers/worker_pool.py
```

**Expected Output**:
```
Starting worker pool with 4 workers...
[Worker-0] Initializing...
[Worker-1] Initializing...
[Worker-2] Initializing...
[Worker-3] Initializing...
[Worker-0] Starting to poll queue: text_extraction_queue
[Worker-1] Starting to poll queue: text_extraction_queue
[Worker-2] Starting to poll queue: text_extraction_queue
[Worker-3] Starting to poll queue: text_extraction_queue
Worker pool started. Press Ctrl+C to stop.
```

**Stop Worker Pool**:
```bash
# Press Ctrl+C (KeyboardInterrupt)
```

**Expected Shutdown Output**:
```
^C
Shutting down worker pool...
Cancelling worker 0...
Cancelling worker 1...
Cancelling worker 2...
Cancelling worker 3...
Worker pool shutdown complete.
```

#### Windows

**Start Worker Pool**:
```cmd
cd backend
venv\Scripts\activate
python workers\worker_pool.py
```

**Stop Worker Pool**:
- Press `Ctrl+C` (KeyboardInterrupt)

**Windows Compatibility**:
- ✅ Fully compatible (no pickle issues)
- ✅ Single process (no multiprocessing issues)
- ✅ Same performance as Linux

---

### Local Development - Multiprocessing (Alternative, Linux Only)

⚠️ **Note**: This approach has pickle issues on Windows Python 3.13. Use async pool instead.

#### Linux Only

**Start Worker Pool**:
```bash
cd backend
source venv/bin/activate
python workers/worker_pool_manager.py
```

**Expected Output**:
```
🚀 Worker Pool Manager starting with 4 workers
   Manager PID: 12345
   Queue: text_extraction_queue
------------------------------------------------------------
   Worker-0 spawned (PID: 12346)
   Worker-1 spawned (PID: 12347)
   Worker-2 spawned (PID: 12348)
   Worker-3 spawned (PID: 12349)
✅ 4 workers started successfully

📊 Monitoring worker health...
   Press Ctrl+C to shutdown gracefully
```

**Stop Worker Pool**:
```bash
# Press Ctrl+C (SIGINT)
# OR
kill -SIGTERM <manager_pid>
```

**Expected Shutdown Output**:
```
🛑 Shutdown signal received
   Stopping workers gracefully...
   Stopping Worker-0 (PID: 12346)
   Stopping Worker-1 (PID: 12347)
   Stopping Worker-2 (PID: 12348)
   Stopping Worker-3 (PID: 12349)
✅ All workers stopped
👋 Worker Pool Manager shutdown complete
```

---

## Production Deployment

### Option 1: systemd (Linux/Ubuntu)

**Create systemd service file**:

`/etc/systemd/system/hda-workers.service`:
```ini
[Unit]
Description=HDA Translation Platform - Worker Pool
After=network.target postgresql.service

[Service]
Type=simple
User=hda
Group=hda
WorkingDirectory=/opt/hda/backend
Environment="PATH=/opt/hda/venv/bin"
Environment="WORKER_POOL_SIZE=4"
EnvironmentFile=/opt/hda/backend/.env
ExecStart=/opt/hda/venv/bin/python /opt/hda/backend/workers/worker_pool_manager.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=hda-workers

[Install]
WantedBy=multi-user.target
```

**Install and start service**:
```bash
# Copy service file
sudo cp hda-workers.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable service (start on boot)
sudo systemctl enable hda-workers

# Start service
sudo systemctl start hda-workers

# Check status
sudo systemctl status hda-workers
```

**View logs**:
```bash
# Real-time logs
sudo journalctl -u hda-workers -f

# Last 100 lines
sudo journalctl -u hda-workers -n 100

# Logs from today
sudo journalctl -u hda-workers --since today
```

**Restart service**:
```bash
sudo systemctl restart hda-workers
```

**Stop service**:
```bash
sudo systemctl stop hda-workers
```

---

### Option 2: Docker

**Dockerfile** (`backend/Dockerfile.worker`):
```dockerfile
FROM python:3.13-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Run worker pool
CMD ["python", "workers/worker_pool_manager.py"]
```

**docker-compose.yml**:
```yaml
version: '3.8'

services:
  workers:
    build:
      context: ./backend
      dockerfile: Dockerfile.worker
    environment:
      - WORKER_POOL_SIZE=4
      - DATABASE_URL=${DATABASE_URL}
      - SUPABASE_URL=${SUPABASE_URL}
      - SUPABASE_SERVICE_KEY=${SUPABASE_SERVICE_KEY}
      - GOOGLE_CLOUD_PROJECT=${GOOGLE_CLOUD_PROJECT}
      - VERTEX_AI_LOCATION=${VERTEX_AI_LOCATION}
      - VERTEX_AI_MODEL=${VERTEX_AI_MODEL}
    volumes:
      - ./backend/vertex-ai-credentials.json:/app/vertex-ai-credentials.json:ro
      - ./backend/.env:/app/.env:ro
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

**Deploy**:
```bash
# Build and start
docker-compose up -d workers

# View logs
docker-compose logs -f workers

# Restart
docker-compose restart workers

# Stop
docker-compose stop workers

# Scale to 8 workers (future)
docker-compose up -d --scale workers=2  # 2 containers × 4 workers = 8 total
```

---

### Option 3: Kubernetes (Production Scale)

**Deployment** (`k8s/worker-deployment.yaml`):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hda-workers
  namespace: hda-production
spec:
  replicas: 2  # 2 pods × 4 workers = 8 total workers
  selector:
    matchLabels:
      app: hda-workers
  template:
    metadata:
      labels:
        app: hda-workers
    spec:
      containers:
      - name: worker-pool
        image: your-registry/hda-workers:latest
        env:
        - name: WORKER_POOL_SIZE
          value: "4"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: hda-secrets
              key: database-url
        - name: SUPABASE_URL
          valueFrom:
            configMapKeyRef:
              name: hda-config
              key: supabase-url
        - name: SUPABASE_SERVICE_KEY
          valueFrom:
            secretKeyRef:
              name: hda-secrets
              key: supabase-service-key
        - name: GOOGLE_APPLICATION_CREDENTIALS
          value: /secrets/vertex-ai-credentials.json
        volumeMounts:
        - name: vertex-credentials
          mountPath: /secrets
          readOnly: true
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "2000m"
      volumes:
      - name: vertex-credentials
        secret:
          secretName: vertex-ai-credentials
```

**Deploy**:
```bash
# Apply deployment
kubectl apply -f k8s/worker-deployment.yaml

# Check status
kubectl get pods -n hda-production -l app=hda-workers

# View logs
kubectl logs -f -n hda-production -l app=hda-workers

# Scale up
kubectl scale deployment hda-workers --replicas=4 -n hda-production

# Restart
kubectl rollout restart deployment hda-workers -n hda-production
```

---

## Worker Pool Configuration

### Adjusting Worker Count

**Determine Optimal Worker Count**:

1. **CPU-based** (recommended):
   ```
   Workers = Number of CPU cores
   Example: 4 cores → WORKER_POOL_SIZE=4
   ```

2. **Queue depth-based**:
   ```
   Workers = Average queue depth / 2
   Example: 10 jobs in queue → WORKER_POOL_SIZE=5
   ```

3. **Testing-based**:
   - Start with 4 workers
   - Monitor queue depth and CPU usage
   - Increase if queue growing and CPU <60%
   - Decrease if workers idle >80% of time

**Change Worker Count**:

```bash
# Edit .env
WORKER_POOL_SIZE=8

# Restart worker pool
sudo systemctl restart hda-workers  # systemd
docker-compose restart workers      # Docker
kubectl rollout restart ...         # Kubernetes
```

---

## Monitoring

### Health Check Endpoints

**Worker Status**:
```bash
curl http://localhost:8000/api/workers/status

# Response:
{
  "worker_pool_size": 4,
  "active_jobs": 2,
  "queue_depth": 5,
  "completed_today": 47,
  "status": "busy"
}
```

**Health Check**:
```bash
curl http://localhost:8000/api/workers/health

# Response:
{
  "status": "healthy",
  "database": "connected",
  "queue": "available"
}
```

### Process Monitoring

**Check running workers**:
```bash
# List worker processes
ps aux | grep worker_pool_manager
ps aux | grep text_extraction_worker

# Count workers
ps aux | grep -c text_extraction_worker
# Should return: 4 (or your WORKER_POOL_SIZE)
```

**Monitor resource usage**:
```bash
# CPU and memory per worker
top -p $(pgrep -d ',' -f text_extraction_worker)

# Or use htop (install: apt install htop)
htop -p $(pgrep -d ',' -f text_extraction_worker)
```

### Log Monitoring

**Key log patterns**:

✅ **Healthy**:
```
[Worker-0] Polling queue: text_extraction_queue
[Worker-1] 📥 Received job: abc-123
[Worker-2] ✓ Batch 1 complete (33%)
[Worker-3] ✅ Job xyz-789 completed successfully
```

⚠️ **Warnings**:
```
⚠️  Worker-2 died (PID: 12348)
🔄 Restarting Worker-2...
✅ Worker-2 restarted (restart #1)
```

❌ **Errors**:
```
[Worker-1] ❌ Job failed: Database connection timeout
[Worker-3] ❌ Vertex AI API error: 429 Rate limit exceeded
```

**Search logs**:
```bash
# Find errors
sudo journalctl -u hda-workers | grep "❌"

# Find job completions
sudo journalctl -u hda-workers | grep "✅ Job"

# Find worker restarts
sudo journalctl -u hda-workers | grep "Restarting"
```

---

## Scaling Strategies

### Vertical Scaling (Single Server)

**Increase workers on same server**:

1. Check CPU usage:
   ```bash
   mpstat 1 5  # 5 samples, 1 second interval
   # If <60% → can add more workers
   ```

2. Check memory:
   ```bash
   free -h
   # Need ~150MB per additional worker
   ```

3. Update configuration:
   ```bash
   WORKER_POOL_SIZE=8  # Double from 4 to 8
   sudo systemctl restart hda-workers
   ```

**Limits**:
- CPU cores (1 worker per core max)
- RAM (150MB per worker)
- Database connections (100 max, 2 per worker)

---

### Horizontal Scaling (Multiple Servers)

**Deploy to multiple servers**:

1. **Server 1** (existing):
   ```bash
   WORKER_POOL_SIZE=4
   ```

2. **Server 2** (new):
   ```bash
   # Same .env configuration
   DATABASE_URL=<same-database>
   SUPABASE_URL=<same-supabase>

   WORKER_POOL_SIZE=4

   python workers/worker_pool_manager.py
   ```

3. **Server 3** (new):
   ```bash
   # Same configuration
   WORKER_POOL_SIZE=4
   ```

**Total**: 12 workers across 3 servers

**Requirements**:
- All servers access same PostgreSQL database
- All servers access same Supabase Storage
- pgmq handles message distribution automatically

---

### Auto-Scaling (Future)

**Kubernetes HPA** (Horizontal Pod Autoscaler):

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: hda-workers-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hda-workers
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: External
    external:
      metric:
        name: queue_depth
        selector:
          matchLabels:
            queue_name: text_extraction_queue
      target:
        type: AverageValue
        averageValue: "5"  # Scale up if queue depth > 5 per pod
```

**Custom Scaling Script**:
```python
import psycopg2
import subprocess

while True:
    # Check queue depth
    conn = psycopg2.connect(DATABASE_URL)
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM pgmq.text_extraction_queue;")
    queue_depth = cursor.fetchone()[0]

    # Scale up if queue growing
    if queue_depth > 20:
        subprocess.run(["kubectl", "scale", "deployment", "hda-workers", "--replicas=6"])

    # Scale down if queue empty
    elif queue_depth == 0:
        subprocess.run(["kubectl", "scale", "deployment", "hda-workers", "--replicas=2"])

    time.sleep(60)  # Check every minute
```

---

## Backup & Recovery

### Worker Pool Crash Recovery

**Automatic Recovery** (systemd):
- Service restarts automatically (`Restart=always`)
- 10-second delay between restarts (`RestartSec=10`)
- Infinite retries

**Manual Recovery**:
```bash
# Check if workers running
sudo systemctl status hda-workers

# If failed, restart
sudo systemctl restart hda-workers

# Check logs for cause
sudo journalctl -u hda-workers -n 100
```

### Database Connection Recovery

**If PostgreSQL down**:
1. Workers will fail to connect
2. systemd restarts workers automatically
3. Workers reconnect when PostgreSQL available

**If connection pool exhausted**:
1. Check connection count:
   ```sql
   SELECT count(*) FROM pg_stat_activity;
   ```
2. Kill idle connections:
   ```sql
   SELECT pg_terminate_backend(pid)
   FROM pg_stat_activity
   WHERE state = 'idle' AND state_change < NOW() - INTERVAL '10 minutes';
   ```

### Queue Message Recovery

**If messages stuck in queue**:
1. Check queue depth:
   ```sql
   SELECT COUNT(*) FROM pgmq.text_extraction_queue;
   ```
2. Check invisible messages (being processed):
   ```sql
   SELECT COUNT(*) FROM pgmq.text_extraction_queue WHERE vt > NOW();
   ```
3. Reset invisible messages (force visibility):
   ```sql
   UPDATE pgmq.text_extraction_queue SET vt = NOW() WHERE vt > NOW();
   ```

---

## Troubleshooting

See [worker-troubleshooting.md](../troubleshooting/workers.md) for detailed troubleshooting guide.

**Quick fixes**:

**Workers not starting**:
```bash
# Check Python path
which python
# Should be: /opt/hda/venv/bin/python

# Check dependencies
pip list | grep -E "psycopg2|supabase|google-cloud"

# Check environment
env | grep -E "DATABASE_URL|WORKER_POOL_SIZE"
```

**Workers crashing repeatedly**:
```bash
# Check logs
sudo journalctl -u hda-workers -n 200

# Common causes:
# - Missing environment variable
# - Invalid DATABASE_URL
# - Vertex AI credentials expired
```

**High memory usage**:
```bash
# Check per-worker memory
ps aux | grep text_extraction_worker

# If >500MB per worker:
# - Reduce WORKER_POOL_SIZE
# - Investigate memory leak
# - Restart workers
```

---

## Performance Tuning

### Database Tuning

**Connection pooling** (Supabase):
```bash
# Use Session Pooler (Port 5432) for pgmq
DATABASE_URL=postgresql://...pooler.supabase.com:5432/...
```

**Increase connection limit**:
```sql
-- On Supabase Dashboard → Settings → Database
ALTER SYSTEM SET max_connections = 200;
SELECT pg_reload_conf();
```

### Worker Tuning

**Reduce memory usage**:
- Process smaller batches
- Clear memory after each job:
  ```python
  import gc
  gc.collect()  # After job completion
  ```

**Reduce CPU usage**:
- Increase poll interval (2s → 5s)
- Reduce worker count

**Increase throughput**:
- Increase worker count (if CPU/RAM available)
- Optimize batch size (10 pages → 20 pages)

---

## Security Best Practices

### Credentials Management

**Never commit credentials**:
```bash
# Add to .gitignore
.env
vertex-ai-credentials.json
*.pem
*.key
```

**Use environment variables**:
```bash
# Development
export DATABASE_URL="..."

# Production (systemd)
EnvironmentFile=/opt/hda/backend/.env

# Production (Docker)
docker-compose.yml → environment or env_file

# Production (Kubernetes)
kubectl create secret generic hda-secrets --from-literal=database-url="..."
```

### Network Security

**Firewall rules**:
```bash
# Only allow outbound connections to:
# - Supabase (PostgreSQL, Storage)
# - Vertex AI (us-central1.aiplatform.googleapis.com)

# No inbound connections needed (workers don't listen)
```

**VPC / Private Network** (AWS/GCP):
- Deploy workers in private subnet
- Access PostgreSQL via private endpoint
- NAT gateway for outbound (Vertex AI)

---

## Maintenance

### Regular Tasks

**Daily**:
- Check worker status: `curl /api/workers/health`
- Monitor queue depth
- Review error logs

**Weekly**:
- Analyze job completion rate
- Review worker restart count
- Check database connection count

**Monthly**:
- Update dependencies: `pip install --upgrade -r requirements.txt`
- Rotate logs (systemd handles automatically)
- Review resource usage trends

### Updates & Upgrades

**Update worker code**:
```bash
# 1. Pull latest code
git pull origin main

# 2. Install dependencies
pip install -r requirements.txt

# 3. Restart workers
sudo systemctl restart hda-workers
```

**Upgrade Python version**:
```bash
# 1. Install new Python
pyenv install 3.14.0

# 2. Create new virtualenv
python3.14 -m venv venv-new

# 3. Install dependencies
source venv-new/bin/activate
pip install -r requirements.txt

# 4. Test
python workers/worker_pool_manager.py

# 5. Update systemd
# Edit /etc/systemd/system/hda-workers.service
# Change ExecStart path to venv-new

# 6. Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart hda-workers
```

---

## Cost Optimization

### Reduce Worker Count During Off-Peak

**Cron job** (reduce at night, restore in morning):
```bash
# /etc/cron.d/hda-workers-schedule
# Scale down at 10 PM
0 22 * * * root echo "WORKER_POOL_SIZE=1" >> /opt/hda/backend/.env && systemctl restart hda-workers

# Scale up at 6 AM
0 6 * * * root echo "WORKER_POOL_SIZE=4" >> /opt/hda/backend/.env && systemctl restart hda-workers
```

### Serverless Workers (Future)

**AWS Lambda / Cloud Run**:
- Workers run only when jobs in queue
- Pay per execution (not per hour)
- Auto-scale 0 → 100 workers

**Caveat**: Cold start latency (~5-10 seconds)

---

## Support & Resources

**Documentation**:
- Architecture: `docs/architecture/parallel-workers.md`
- Troubleshooting: `docs/troubleshooting/workers.md`
- Story 1.5: `docs/stories/1.5-parallel-workers.md`

**Logs**:
- systemd: `sudo journalctl -u hda-workers`
- Docker: `docker-compose logs workers`
- Kubernetes: `kubectl logs -l app=hda-workers`

**Monitoring Endpoints**:
- Status: `http://localhost:8000/api/workers/status`
- Health: `http://localhost:8000/api/workers/health`

**Support Channels**:
- GitHub Issues: https://github.com/your-org/hda-platform/issues
- Slack: #hda-workers channel
- Email: devops@your-org.com

---

**Document Owner**: DevOps Team
**Last Updated**: 2025-10-03

---

## Implementation Note

This guide was originally written assuming multiprocessing, which is documented throughout. During Story 1.5 implementation, we **pivoted to async** due to Windows compatibility.

**Current Production**: `backend/workers/worker_pool.py` (async)
**Alternative/Future**: `backend/workers/worker_pool_manager.py` (multiprocessing, Linux only)

Both approaches are documented. **Use async pool** unless you have specific reasons to use multiprocessing (CPU-bound tasks, Linux-only deployment).
