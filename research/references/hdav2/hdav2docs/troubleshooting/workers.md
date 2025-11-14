# Worker Troubleshooting Guide

**Version**: 1.0
**Last Updated**: 2025-10-03
**Related**: Story 1.5 - Parallel Worker Architecture

---

## Overview

This guide helps diagnose and fix common issues with the worker pool system. Follow the troubleshooting steps in order for fastest resolution.

**Quick Links**:
- [Workers Won't Start](#workers-wont-start)
- [Workers Crash Repeatedly](#workers-crash-repeatedly)
- [Jobs Stuck in Queue](#jobs-stuck-in-queue)
- [High Memory Usage](#high-memory-usage)
- [Database Connection Errors](#database-connection-errors)
- [Vertex AI Errors](#vertex-ai-errors)
- [Performance Issues](#performance-issues)

---

## Quick Diagnostics

### Check Worker Status

```bash
# Are workers running?
ps aux | grep worker_pool_manager

# Expected: 1 process (manager)
# If none: Workers not started
```

```bash
# Are worker processes running?
ps aux | grep text_extraction_worker

# Expected: 4 processes (or WORKER_POOL_SIZE value)
# If none: Manager started but workers failed
```

### Check Worker Health

```bash
# API health check
curl http://localhost:8000/api/workers/health

# Expected: {"status": "healthy", "database": "connected", "queue": "available"}
# If error: See specific issue below
```

### Check Queue Status

```bash
# Queue depth
curl http://localhost:8000/api/workers/status

# Expected: {"worker_pool_size": 4, "active_jobs": X, "queue_depth": Y}
# If queue_depth growing: Workers not processing
```

### Check Logs (Recent Errors)

```bash
# systemd
sudo journalctl -u hda-workers -n 50 --no-pager | grep -E "ERROR|❌|Exception"

# Docker
docker-compose logs --tail=50 workers | grep -E "ERROR|❌|Exception"

# Manual run
# Look for error messages in terminal output
```

---

## Workers Won't Start

### Symptom
```bash
ps aux | grep worker_pool_manager
# Returns: No processes found
```

### Diagnosis

**Step 1: Check if systemd service exists**
```bash
sudo systemctl status hda-workers

# If "Unit hda-workers.service could not be found":
# → Service not installed (see Deployment Guide)
```

**Step 2: Check service status**
```bash
sudo systemctl status hda-workers

# If "Active: failed (Result: exit-code)":
# → Service crashed on startup (check logs)
```

**Step 3: Check Python path**
```bash
which python

# Expected: /opt/hda/venv/bin/python (or your venv path)
# If wrong: Update systemd ExecStart path
```

**Step 4: Check working directory**
```bash
ls -la /opt/hda/backend/workers/worker_pool_manager.py

# If "No such file or directory":
# → Wrong WorkingDirectory in systemd service
```

### Solutions

**Solution 1: Service not installed**
```bash
# Install service
sudo cp /opt/hda/hda-workers.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable hda-workers
sudo systemctl start hda-workers
```

**Solution 2: Python path wrong**
```bash
# Edit service file
sudo nano /etc/systemd/system/hda-workers.service

# Update ExecStart line:
ExecStart=/opt/hda/venv/bin/python /opt/hda/backend/workers/worker_pool_manager.py

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart hda-workers
```

**Solution 3: Missing dependencies**
```bash
# Activate virtualenv
source /opt/hda/venv/bin/activate

# Install dependencies
pip install -r /opt/hda/backend/requirements.txt

# Restart service
sudo systemctl restart hda-workers
```

**Solution 4: Environment variables missing**
```bash
# Check .env file exists
cat /opt/hda/backend/.env

# If missing, create it:
nano /opt/hda/backend/.env

# Add required variables (see Deployment Guide)
DATABASE_URL=...
SUPABASE_URL=...
WORKER_POOL_SIZE=4

# Restart
sudo systemctl restart hda-workers
```

---

## Workers Crash Repeatedly

### Symptom
```
[Worker-2] Text Extraction Worker started (PID: 12345)
[Worker-2] ❌ Fatal error: ...
⚠️  Worker-2 died (PID: 12345)
🔄 Restarting Worker-2...
[Worker-2] Text Extraction Worker started (PID: 12346)
[Worker-2] ❌ Fatal error: ...
⚠️  Worker-2 died (PID: 12346)
```

### Diagnosis

**Step 1: Check error message**
```bash
# Get last 100 lines with errors
sudo journalctl -u hda-workers -n 100 | grep "❌"

# Common errors:
# - "KeyError: 'DATABASE_URL'" → Missing environment variable
# - "psycopg2.OperationalError" → Database connection failed
# - "google.auth.exceptions" → Vertex AI credentials invalid
```

**Step 2: Check resource limits**
```bash
# Check memory
free -h

# If "available" < 500MB:
# → Out of memory (need more RAM or reduce workers)

# Check disk space
df -h

# If "Use%" > 95%:
# → Out of disk space
```

**Step 3: Test worker manually**
```bash
cd /opt/hda/backend
source venv/bin/activate
python workers/text_extraction_worker.py

# If crashes immediately:
# → Check error message
# → Fix issue
# → Test again
```

### Solutions

**Solution 1: Missing environment variable**
```bash
# Error: KeyError: 'DATABASE_URL'

# Add to .env
echo "DATABASE_URL=postgresql://..." >> .env

# Restart
sudo systemctl restart hda-workers
```

**Solution 2: Database connection failed**
```bash
# Error: psycopg2.OperationalError: could not connect to server

# Test connection
psql "$DATABASE_URL"

# If fails:
# → Check DATABASE_URL is correct
# → Check network connectivity
# → Check PostgreSQL is running

# Fix DATABASE_URL
nano .env
# Update DATABASE_URL=...

sudo systemctl restart hda-workers
```

**Solution 3: Vertex AI credentials invalid**
```bash
# Error: google.auth.exceptions.DefaultCredentialsError

# Check credentials file exists
ls -la /opt/hda/backend/vertex-ai-credentials.json

# If missing:
# → Download from Google Cloud Console
# → Place in correct location

# Check GOOGLE_APPLICATION_CREDENTIALS
cat .env | grep GOOGLE_APPLICATION_CREDENTIALS

# Should be:
GOOGLE_APPLICATION_CREDENTIALS=./vertex-ai-credentials.json

# Restart
sudo systemctl restart hda-workers
```

**Solution 4: Out of memory**
```bash
# Error: Killed (OOM)

# Check current memory usage
ps aux | grep text_extraction_worker | awk '{print $6}'

# If >500MB per worker:
# → Reduce worker count

# Edit .env
nano .env
# Change: WORKER_POOL_SIZE=2 (reduce from 4)

sudo systemctl restart hda-workers
```

**Solution 5: Import error**
```bash
# Error: ModuleNotFoundError: No module named 'supabase'

# Install missing module
source venv/bin/activate
pip install supabase

# Or reinstall all dependencies
pip install -r requirements.txt

sudo systemctl restart hda-workers
```

---

## Jobs Stuck in Queue

### Symptom
```bash
curl http://localhost:8000/api/workers/status
# Response: {"queue_depth": 10, "active_jobs": 0}

# Jobs in queue, but no workers processing
```

### Diagnosis

**Step 1: Are workers running?**
```bash
ps aux | grep text_extraction_worker

# If no processes:
# → Workers not running (see "Workers Won't Start")
```

**Step 2: Are workers polling?**
```bash
sudo journalctl -u hda-workers -n 20 | grep "Polling queue"

# Expected: Recent "Polling queue" messages every 2 seconds
# If none in last 30 seconds:
# → Workers hung (need restart)
```

**Step 3: Check queue for messages**
```bash
# Connect to database
psql "$DATABASE_URL"

# Check queue
SELECT COUNT(*) FROM pgmq.text_extraction_queue;

# If 0:
# → Queue empty (jobs not being queued)

# If >0:
# → Messages in queue (workers not reading)
```

**Step 4: Check invisible messages (VT)**
```bash
psql "$DATABASE_URL"

SELECT COUNT(*) FROM pgmq.text_extraction_queue WHERE vt > NOW();

# If >0:
# → Messages being processed or stuck invisible
```

### Solutions

**Solution 1: Workers hung (restart)**
```bash
sudo systemctl restart hda-workers

# Watch logs for startup
sudo journalctl -u hda-workers -f
```

**Solution 2: Messages stuck invisible**
```bash
# Reset visibility timeout (force visible)
psql "$DATABASE_URL" <<EOF
UPDATE pgmq.text_extraction_queue
SET vt = NOW()
WHERE vt > NOW();
EOF

# Workers will now pick up messages
```

**Solution 3: Jobs not being queued**
```bash
# Check API endpoint
curl -X POST http://localhost:8000/api/text-extraction/extract-with-batching/DOC_ID \
  -H "Content-Type: application/json" \
  -d '{"auto_translate": false}'

# If 500 error:
# → API server issue (check backend logs)

# If 200 success:
# → Check queue again
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM pgmq.text_extraction_queue;"
```

**Solution 4: Queue doesn't exist**
```bash
# Check if queue exists
psql "$DATABASE_URL" <<EOF
SELECT queue_name FROM pgmq.list_queues();
EOF

# If "text_extraction_queue" not in list:
# → Create queue
psql "$DATABASE_URL" <<EOF
SELECT pgmq.create('text_extraction_queue');
EOF
```

**Solution 5: Worker can't read queue (permissions)**
```bash
# Grant permissions
psql "$DATABASE_URL" <<EOF
GRANT ALL ON ALL TABLES IN SCHEMA pgmq TO postgres;
EOF

# Restart workers
sudo systemctl restart hda-workers
```

---

## High Memory Usage

### Symptom
```bash
free -h
# Shows: available < 100MB (out of memory)

ps aux | grep text_extraction_worker
# Shows: Each worker using >500MB
```

### Diagnosis

**Step 1: Check per-worker memory**
```bash
ps aux | grep text_extraction_worker | awk '{print $6 " " $11}'

# Expected: ~150MB per worker
# If >500MB:
# → Memory leak or processing large PDFs
```

**Step 2: Check total workers**
```bash
ps aux | grep -c text_extraction_worker

# If >4 (or your WORKER_POOL_SIZE):
# → Too many workers spawned
```

**Step 3: Check for zombie processes**
```bash
ps aux | grep defunct

# If found:
# → Zombie processes not cleaned up
```

### Solutions

**Solution 1: Reduce worker count**
```bash
# Edit .env
nano .env

# Reduce workers
WORKER_POOL_SIZE=2  # Was: 4

# Restart
sudo systemctl restart hda-workers

# Verify memory
free -h
```

**Solution 2: Add memory cleanup**
```python
# In text_extraction_worker.py, after job completion:

import gc

async def process_extraction_job(self, job_data: dict):
    # ... process job ...

    # Cleanup
    gc.collect()  # Force garbage collection
```

**Solution 3: Kill zombie processes**
```bash
# Find parent process
ps aux | grep defunct

# Kill parent (workers will restart via systemd)
sudo kill <parent_pid>

# Verify zombies gone
ps aux | grep defunct
```

**Solution 4: Reduce batch size (less memory per job)**
```python
# In text_extraction router, reduce pages per batch
# backend/api/routers/text_extraction.py

# Change from:
pages_per_batch = 10

# To:
pages_per_batch = 5  # Smaller batches = less memory
```

**Solution 5: Add swap space (temporary)**
```bash
# Create 2GB swap file
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent (add to /etc/fstab)
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Note: This is a workaround, not a fix
```

---

## Database Connection Errors

### Symptom
```
[Worker-1] ❌ Job failed: psycopg2.OperationalError: connection timeout
[Worker-2] ❌ psycopg2.InterfaceError: connection already closed
```

### Diagnosis

**Step 1: Test database connection**
```bash
psql "$DATABASE_URL" -c "SELECT 1;"

# If fails:
# → Database unreachable

# If succeeds:
# → Database OK, connection string issue in workers
```

**Step 2: Check connection count**
```bash
psql "$DATABASE_URL" <<EOF
SELECT count(*) FROM pg_stat_activity;
EOF

# If >100:
# → Connection limit reached (Supabase default: 100)
```

**Step 3: Check for idle connections**
```bash
psql "$DATABASE_URL" <<EOF
SELECT count(*) FROM pg_stat_activity
WHERE state = 'idle' AND state_change < NOW() - INTERVAL '10 minutes';
EOF

# If >20:
# → Too many idle connections
```

### Solutions

**Solution 1: Database unreachable**
```bash
# Check DATABASE_URL
echo $DATABASE_URL

# Should be Session Pooler (Port 5432) for pgmq:
# postgresql://postgres.{ref}:...@aws-1-{region}.pooler.supabase.com:5432/postgres

# NOT Transaction Pooler (Port 6543):
# Wrong: ...pooler.supabase.com:6543/...

# Fix DATABASE_URL
nano .env
DATABASE_URL=postgresql://...pooler.supabase.com:5432/postgres

sudo systemctl restart hda-workers
```

**Solution 2: Connection limit reached**
```bash
# Kill idle connections
psql "$DATABASE_URL" <<EOF
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE state = 'idle'
AND state_change < NOW() - INTERVAL '10 minutes';
EOF

# Restart workers (clean slate)
sudo systemctl restart hda-workers
```

**Solution 3: Connection timeout (long jobs)**
```python
# In text_extraction_worker.py, add reconnect logic:

async def process_extraction_job(self, job_data: dict):
    try:
        # Process job...
        # ... long Vertex AI call (15 minutes) ...

        # Update database
        self.supabase.table(...).update(...).execute()

    except Exception as e:
        if "connection" in str(e).lower():
            # Reconnect
            self.supabase = create_client(
                os.getenv("SUPABASE_URL"),
                os.getenv("SUPABASE_SERVICE_KEY")
            )
            # Retry update
            self.supabase.table(...).update(...).execute()
```

**Solution 4: Increase connection limit (Supabase)**
```bash
# Upgrade Supabase plan (Free tier: 100 connections)
# OR
# Use connection pooling (already using Session Pooler)

# Check pooler settings in Supabase Dashboard:
# Settings → Database → Connection Pooler
# Mode: Session (correct for pgmq)
# Pool size: 15 (default)
```

---

## Vertex AI Errors

### Symptom
```
[Worker-3] ❌ Job failed: google.api_core.exceptions.PermissionDenied: 403 Permission denied
[Worker-1] ❌ Job failed: google.api_core.exceptions.ResourceExhausted: 429 Quota exceeded
```

### Diagnosis

**Step 1: Check credentials file**
```bash
ls -la /opt/hda/backend/vertex-ai-credentials.json

# If not found:
# → Credentials file missing

# If found, check format:
cat vertex-ai-credentials.json

# Should be valid JSON with "type": "service_account"
```

**Step 2: Test Vertex AI connection**
```bash
python3 <<EOF
import vertexai
import os
from dotenv import load_dotenv

load_dotenv()
vertexai.init(
    project=os.getenv('GOOGLE_CLOUD_PROJECT'),
    location=os.getenv('VERTEX_AI_LOCATION')
)
print("✅ Vertex AI initialized successfully")
EOF
```

### Solutions

**Solution 1: Credentials missing**
```bash
# Download from Google Cloud Console:
# 1. Go to: https://console.cloud.google.com/iam-admin/serviceaccounts
# 2. Select service account
# 3. Keys → Add Key → Create New Key → JSON
# 4. Save as vertex-ai-credentials.json

# Copy to worker directory
cp ~/Downloads/vertex-ai-credentials.json /opt/hda/backend/

# Update .env
nano .env
GOOGLE_APPLICATION_CREDENTIALS=./vertex-ai-credentials.json

sudo systemctl restart hda-workers
```

**Solution 2: Permission denied (403)**
```bash
# Grant Vertex AI User role to service account:

# 1. Get service account email from credentials file
cat vertex-ai-credentials.json | grep client_email

# 2. Grant role (via gcloud CLI)
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:SERVICE_ACCOUNT_EMAIL" \
  --role="roles/aiplatform.user"

# 3. Wait 1-2 minutes for propagation

# 4. Retry job
```

**Solution 3: Quota exceeded (429)**
```bash
# Error: 429 Quota exceeded / Rate limit

# Temporary fix: Reduce worker count (less concurrent API calls)
nano .env
WORKER_POOL_SIZE=2  # Was: 4

sudo systemctl restart hda-workers

# Permanent fix: Request quota increase
# 1. Go to: https://console.cloud.google.com/iam-admin/quotas
# 2. Filter: Service = "Vertex AI API"
# 3. Select quota: "Requests per minute"
# 4. Request increase
```

**Solution 4: Model not found**
```bash
# Error: Model gemini-2.0-flash-exp not found

# Check available models
gcloud ai models list --region=us-central1

# Update to available model
nano .env
VERTEX_AI_MODEL=gemini-1.5-flash  # Use stable version

sudo systemctl restart hda-workers
```

**Solution 5: Region unavailable**
```bash
# Error: Region not available

# Check VERTEX_AI_LOCATION
cat .env | grep VERTEX_AI_LOCATION

# Available regions: us-central1, europe-west4, asia-northeast1

# Update to available region
nano .env
VERTEX_AI_LOCATION=us-central1

sudo systemctl restart hda-workers
```

---

## Performance Issues

### Symptom 1: Slow Job Processing

```
Job processing time: 10 minutes (expected: 2 minutes)
```

**Diagnosis**:
```bash
# Check worker logs for slow steps
sudo journalctl -u hda-workers -n 100 | grep -E "Processing batch|complete"

# Example output:
[Worker-0] Processing batch 1 of 3  (10:00:00)
[Worker-0] ✓ Batch 1 complete (10:05:00)  # 5 minutes → TOO SLOW

# Normal: ~30 seconds per batch
# Slow: >2 minutes per batch
```

**Solutions**:

**Solution 1: Network latency to Vertex AI**
```bash
# Test latency
curl -w "\nTime: %{time_total}s\n" https://us-central1-aiplatform.googleapis.com

# If >2 seconds:
# → Change to closer region

nano .env
VERTEX_AI_LOCATION=europe-west4  # If in Europe

sudo systemctl restart hda-workers
```

**Solution 2: Large PDFs**
```bash
# Check PDF size
ls -lh /path/to/uploaded/pdfs

# If >50MB per PDF:
# → Reduce batch size (fewer pages per API call)

# backend/api/routers/text_extraction.py
pages_per_batch = 5  # Was: 10

# Restart backend
sudo systemctl restart hda-backend
```

**Solution 3: Database query slow**
```bash
# Enable slow query log
psql "$DATABASE_URL" <<EOF
ALTER DATABASE postgres SET log_min_duration_statement = 1000;  -- Log queries >1s
EOF

# Check logs for slow queries
sudo journalctl -u hda-workers | grep "duration:"

# If found, optimize query or add index
```

---

### Symptom 2: High CPU Usage

```
top
# Shows: Worker processes at 100% CPU
```

**Diagnosis**:
```bash
# Check if CPU-bound or I/O-bound
iostat -x 1 5

# If "await" >100ms:
# → I/O-bound (disk slow)

# If "await" <10ms and CPU at 100%:
# → CPU-bound (PDF processing intensive)
```

**Solutions**:

**Solution 1: CPU-bound (reduce workers)**
```bash
# If CPU at 100% and workers = CPU cores:
# → Already at max capacity

# Reduce workers to leave headroom for system
nano .env
WORKER_POOL_SIZE=3  # On 4-core system

sudo systemctl restart hda-workers
```

**Solution 2: I/O-bound (faster disk)**
```bash
# Upgrade to SSD (if on HDD)
# Or use faster Supabase region
```

---

### Symptom 3: Workers Idle (Queue Has Jobs)

```
curl /api/workers/status
# Response: {"queue_depth": 10, "active_jobs": 0}

ps aux | grep text_extraction_worker
# Shows: 4 workers, but all idle
```

**Diagnosis**:
```bash
# Check if workers polling
sudo journalctl -u hda-workers -n 20 | grep "Polling queue"

# If no recent polls:
# → Workers hung
```

**Solutions**:
```bash
# Restart workers
sudo systemctl restart hda-workers

# If happens repeatedly:
# → Add health check timeout

# In worker_pool_manager.py:
# Monitor worker activity, restart if no activity for 60s
```

---

## Log Analysis

### Understanding Log Patterns

**Healthy Log Pattern**:
```
[Worker-0] Polling queue: text_extraction_queue
[Worker-0] 📥 Received job: abc-123
[Worker-0]    Processing batch 1 of 3
[Worker-0]    ✓ Batch 1 complete (33%)
[Worker-0]    Processing batch 2 of 3
[Worker-0]    ✓ Batch 2 complete (67%)
[Worker-0]    Processing batch 3 of 3
[Worker-0]    ✓ Batch 3 complete (100%)
[Worker-0] ✅ Job abc-123 completed successfully
[Worker-0] ✅ Job abc-123 archived from queue
[Worker-0] Polling queue: text_extraction_queue
```

**Unhealthy Log Patterns**:

**Pattern 1: Worker restarts**
```
[Worker-2] ❌ Job failed: Exception
⚠️  Worker-2 died (PID: 12345)
🔄 Restarting Worker-2...
[Worker-2] Text Extraction Worker started (PID: 12346)

→ Worker crashing repeatedly (investigate exception)
```

**Pattern 2: No polling**
```
[Worker-0] Polling queue: text_extraction_queue  (10:00:00)
[Worker-0] Polling queue: text_extraction_queue  (10:00:02)
[Worker-0] Polling queue: text_extraction_queue  (10:00:04)
... (30 seconds gap) ...
[Worker-0] Polling queue: text_extraction_queue  (10:00:34)

→ Worker hung for 30 seconds (restart)
```

**Pattern 3: Jobs never complete**
```
[Worker-1] 📥 Received job: xyz-789
[Worker-1]    Processing batch 1 of 5
... (no more logs for this job) ...

→ Job processing stuck (timeout, crash, or infinite loop)
```

### Log Search Commands

**Find all errors**:
```bash
sudo journalctl -u hda-workers --since "1 hour ago" | grep "❌"
```

**Find specific job**:
```bash
sudo journalctl -u hda-workers | grep "abc-123"
```

**Find worker restarts**:
```bash
sudo journalctl -u hda-workers --since today | grep "Restarting"
```

**Find slow batches (>2 minutes)**:
```bash
sudo journalctl -u hda-workers --since "1 hour ago" | \
  grep "Processing batch" | \
  while read line; do
    # Extract timestamp and compare
    # (manual inspection - look for large gaps)
    echo "$line"
  done
```

**Count jobs completed**:
```bash
sudo journalctl -u hda-workers --since today | \
  grep "completed successfully" | \
  wc -l
```

---

## Emergency Procedures

### Emergency Stop (All Workers)

```bash
# systemd
sudo systemctl stop hda-workers

# Docker
docker-compose stop workers

# Kubernetes
kubectl scale deployment hda-workers --replicas=0

# Manual
pkill -SIGTERM -f worker_pool_manager
```

### Emergency Restart (With Queue Preservation)

```bash
# Jobs in queue are preserved (pgmq in PostgreSQL)

# 1. Stop workers
sudo systemctl stop hda-workers

# 2. Wait 5 seconds (let VT expire)
sleep 5

# 3. Start workers
sudo systemctl start hda-workers

# Jobs will resume automatically
```

### Emergency Queue Clear (Dangerous!)

```bash
# ⚠️  WARNING: This deletes ALL queued jobs

psql "$DATABASE_URL" <<EOF
DELETE FROM pgmq.text_extraction_queue;
EOF

# Use only if:
# - Queue corrupted beyond repair
# - Need to clear stuck jobs
# - User consent obtained
```

### Emergency Database Failover

```bash
# If Supabase primary region down:

# 1. Update DATABASE_URL to backup region
nano .env
DATABASE_URL=postgresql://backup-region...

# 2. Restart workers
sudo systemctl restart hda-workers

# 3. Verify workers connect
curl /api/workers/health
```

---

## Getting Help

### Before Requesting Support

**Gather this information**:

1. **Worker status**:
   ```bash
   ps aux | grep -E "worker_pool|text_extraction" > worker-status.txt
   ```

2. **Logs (last 200 lines)**:
   ```bash
   sudo journalctl -u hda-workers -n 200 > worker-logs.txt
   ```

3. **Queue status**:
   ```bash
   curl http://localhost:8000/api/workers/status > queue-status.json
   ```

4. **System info**:
   ```bash
   uname -a > system-info.txt
   free -h >> system-info.txt
   df -h >> system-info.txt
   ```

5. **Environment**:
   ```bash
   env | grep -E "WORKER|DATABASE|SUPABASE|VERTEX" > env-vars.txt
   ```

### Support Channels

**GitHub Issues**:
- https://github.com/your-org/hda-platform/issues
- Tag: `worker-pool`, `troubleshooting`

**Slack**:
- Channel: `#hda-workers`
- Include: Error message + worker-logs.txt

**Email**:
- devops@your-org.com
- Subject: "Worker Pool Issue - [Brief Description]"

---

## Prevention & Monitoring

### Proactive Monitoring

**Set up alerts** (using monitoring tools):

1. **Worker health check fails**:
   ```bash
   # Check every minute
   */1 * * * * curl -f http://localhost:8000/api/workers/health || mail -s "Workers unhealthy" admin@example.com
   ```

2. **Queue depth >20**:
   ```bash
   # Alert if queue growing
   */5 * * * * curl http://localhost:8000/api/workers/status | jq '.queue_depth > 20' | grep true && mail -s "Queue depth high" admin@example.com
   ```

3. **Worker restart count >5**:
   ```bash
   # Check systemd restart count
   systemctl show hda-workers | grep NRestarts
   ```

### Regular Maintenance

**Daily**:
- Check `/api/workers/health`
- Review error logs

**Weekly**:
- Analyze job completion rate
- Check worker restart count
- Review resource usage trends

**Monthly**:
- Update dependencies
- Review and optimize slow queries
- Capacity planning based on queue trends

---

## FAQ

**Q: How do I know if workers are processing jobs?**
```bash
curl /api/workers/status
# Look for: "active_jobs": > 0
```

**Q: Can I restart workers without losing jobs?**
```
Yes. Jobs in queue are preserved in PostgreSQL.
Jobs being processed will return to queue (VT expires).
```

**Q: How long does a job stay "invisible" (VT)?**
```
5 minutes (300 seconds).
If worker doesn't archive within 5 min, job returns to queue.
```

**Q: Can multiple workers process the same job?**
```
No. pgmq guarantees one worker per message.
```

**Q: What happens if all workers crash?**
```
1. Manager detects (within 10s)
2. Manager spawns new workers
3. Jobs return to queue (VT expires)
4. New workers pick up jobs
```

**Q: How do I add more workers?**
```bash
nano .env
WORKER_POOL_SIZE=8  # Was: 4

sudo systemctl restart hda-workers
```

**Q: How do I debug a specific job?**
```bash
# Find job in logs
sudo journalctl -u hda-workers | grep "JOB_ID"

# Check database
psql "$DATABASE_URL" -c "SELECT * FROM text_extraction_results WHERE id='JOB_ID';"
```

---

**Document Owner**: DevOps Team
**Contributors**: Backend Team, Support Team
**Last Updated**: 2025-10-03
