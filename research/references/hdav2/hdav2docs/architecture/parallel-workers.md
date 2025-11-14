# Parallel Worker Architecture

**Version**: 2.0
**Status**: Implemented (Story 1.5) - Async Implementation
**Last Updated**: 2025-10-03

---

## Overview

This document describes the parallel worker architecture used for background job processing in the HDA Translation Platform. The system enables concurrent processing of text extraction and translation jobs using PostgreSQL's pgmq extension for message queuing.

**Current Implementation**: **Async Worker Pool** (Single-process, asyncio-based)
**Alternative**: Multiprocessing approach (documented for Linux/production)

**Key Capabilities**:
- 4 concurrent worker coroutines (configurable)
- Automatic message locking and concurrency control via pgmq
- Graceful shutdown on KeyboardInterrupt
- Low memory footprint (~250MB for 4 workers)
- No race conditions or data corruption
- Windows-compatible (no pickle issues)

---

## Implementation Summary

**Production Implementation** (Story 1.5 - ACTUAL):
- **File**: `backend/workers/worker_pool.py`
- **Architecture**: Single process with 4 async coroutines
- **Concurrency Model**: Asyncio event loop with cooperative multitasking
- **Platform**: Windows + Linux compatible
- **Memory**: ~250MB total (single process)

**Alternative Implementation** (Documented for future):
- **File**: `backend/workers/worker_pool_manager.py` (DEPRECATED on Windows)
- **Architecture**: 4 separate worker processes
- **Concurrency Model**: True multiprocessing (4 CPU cores)
- **Platform**: Linux only (pickle issues on Windows Python 3.13)
- **Memory**: ~1GB total (4 processes × 250MB)

---

## Architecture Diagram

### High-Level Architecture (Current - Async Implementation)

```
┌─────────────────────────────────────────────────────────────┐
│                     FastAPI Backend                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  POST /api/text-extraction/extract-with-batching     │  │
│  │  → Creates job record in database                    │  │
│  │  → Sends message to pgmq queue                       │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ↓
┌─────────────────────────────────────────────────────────────┐
│              PostgreSQL + pgmq (Message Queue)              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  text_extraction_queue                               │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │  │
│  │  │ Job #1  │ │ Job #2  │ │ Job #3  │ │ Job #4  │   │  │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                             │
                             ↓
         ┌───────────────────────────────────────────┐
         │   Async Worker Pool (Single Process)      │
         │   PID: 1234                               │
         │                                           │
         │   Asyncio Event Loop                      │
         │   ┌─────────────────────────────────┐    │
         │   │  Worker Coroutine 0             │    │
         │   │  • async poll_queue()           │    │
         │   │  • async process_job()          │    │
         │   │  • await vertex_ai.call()       │    │
         │   └─────────────────────────────────┘    │
         │   ┌─────────────────────────────────┐    │
         │   │  Worker Coroutine 1             │    │
         │   │  (concurrent via event loop)    │    │
         │   └─────────────────────────────────┘    │
         │   ┌─────────────────────────────────┐    │
         │   │  Worker Coroutine 2             │    │
         │   │  (concurrent via event loop)    │    │
         │   └─────────────────────────────────┘    │
         │   ┌─────────────────────────────────┐    │
         │   │  Worker Coroutine 3             │    │
         │   │  (concurrent via event loop)    │    │
         │   └─────────────────────────────────┘    │
         │                                           │
         │   Shared Memory & Connections             │
         └───────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────┐
│                    Supabase PostgreSQL                      │
│  • text_extraction_results (job status, progress)          │
│  • documents (document status)                              │
│  • processing_batches (batch tracking)                      │
└─────────────────────────────────────────────────────────────┘
```

### Async Worker Pool (Current Implementation)

```
┌─────────────────────────────────────────────────────────────┐
│         Async Worker Pool (worker_pool.py)                  │
│                    Single Process                           │
│                    PID: 1234                                │
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │           Asyncio Event Loop                       │    │
│  │  ┌──────────────────────────────────────────────┐ │    │
│  │  │ async def run_worker(worker_id):             │ │    │
│  │  │   while True:                                │ │    │
│  │  │     job = await poll_queue()  # I/O wait     │ │    │
│  │  │     if job:                                  │ │    │
│  │  │       pdf = await download()  # I/O wait     │ │    │
│  │  │       text = await vertex_ai()# I/O wait     │ │    │
│  │  │       await save_db()         # I/O wait     │ │    │
│  │  └──────────────────────────────────────────────┘ │    │
│  │                                                    │    │
│  │  Tasks Running Concurrently:                      │    │
│  │  • Worker Coroutine 0 (worker_id=0)              │    │
│  │  • Worker Coroutine 1 (worker_id=1)              │    │
│  │  • Worker Coroutine 2 (worker_id=2)              │    │
│  │  • Worker Coroutine 3 (worker_id=3)              │    │
│  │                                                    │    │
│  │  [Event loop switches between workers during      │    │
│  │   I/O waits - all 4 can wait concurrently]        │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  Shared Resources (Single Process):                        │
│  • Database connection (for pgmq polling)                  │
│  • 4 Supabase clients (one per worker)                     │
│  • 4 Vertex AI services (one per worker)                   │
│  • Memory: ~250MB total                                    │
└─────────────────────────────────────────────────────────────┘
```

### Alternative: Multiprocessing Approach (Linux/Future)

```
┌─────────────────────────────────────────────────────────┐
│           WorkerPoolManager (Parent Process)            │
│                        PID: 1234                        │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │ Responsibilities:                                 │ │
│  │ • Spawn N worker processes (multiprocessing)     │ │
│  │ • Monitor worker health (10s interval)           │ │
│  │ • Auto-restart failed workers                    │ │
│  │ • Handle SIGTERM/SIGINT (graceful shutdown)      │ │
│  │ • Provide status API                             │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  Spawns ↓                                               │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Worker Process 0 (PID: 1235)                     │  │
│  │ • Own memory space                               │  │
│  │ • Own DB connections                             │  │
│  │ • Polls pgmq.read('text_extraction_queue', 300)  │  │
│  │ • Processes job                                  │  │
│  │ • Archives message                               │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Worker Process 1 (PID: 1236)                     │  │
│  │ ...                                              │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Worker Process 2 (PID: 1237)                     │  │
│  │ ...                                              │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Worker Process 3 (PID: 1238)                     │  │
│  │ ...                                              │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## pgmq Concurrency Guarantees

### How pgmq Prevents Race Conditions

**Visibility Timeout (VT) Mechanism**:

```python
# Worker 1 (at 10:00:00)
msg = pgmq.read('text_extraction_queue', vt=300)  # 5 minute VT
# Message becomes INVISIBLE to other workers until 10:05:00

# Worker 2 (at 10:00:01) - simultaneous read
msg2 = pgmq.read('text_extraction_queue', vt=300)
# Gets DIFFERENT message (or None if queue empty)

# If Worker 1 crashes before 10:05:00 → message stays invisible
# At 10:05:00 → message automatically returns to queue
# Another worker can pick it up
```

**ACID Guarantees**:
- **Atomic**: Message read + visibility update is atomic transaction
- **Consistent**: No message can be read by 2 workers simultaneously
- **Isolated**: Each worker's transaction is isolated
- **Durable**: Message state persisted in PostgreSQL

**Message Lifecycle**:
```
1. AVAILABLE → Worker reads (pgmq.read)
2. INVISIBLE (VT active) → Worker processes job
3. ARCHIVED → Worker completes (pgmq.archive) OR
4. AVAILABLE (VT expired) → Worker crashed/timeout, returns to queue
```

### Why This Works

**PostgreSQL Row Locking**:
- pgmq uses `SELECT FOR UPDATE SKIP LOCKED`
- When Worker A locks a row, Worker B skips it
- No deadlocks, no conflicts

**Example Query** (simplified):
```sql
SELECT * FROM pgmq.text_extraction_queue
WHERE vt < NOW()  -- Only visible messages
ORDER BY priority DESC, msg_id ASC
LIMIT 1
FOR UPDATE SKIP LOCKED;  -- Lock row, skip if already locked
```

---

## Async Concurrency Model (Current Implementation)

### How Asyncio Enables Concurrent Processing

The async worker pool achieves **4x concurrent processing** using Python's `asyncio` event loop with **cooperative multitasking**.

### Key Concept: I/O-Bound Workload

Our text extraction workload is **99% I/O wait**:

```
Time breakdown for one job (63 seconds total):
┌─────────────────────────────────────────┐
│ 1. Read from pgmq:       0.1s (0.2%)   │ I/O
│ 2. Download PDF:         2.0s (3.2%)   │ I/O
│ 3. Call Vertex AI:      60.0s (95.2%)  │ I/O (network API wait)
│ 4. Save to database:     1.0s (1.6%)   │ I/O
├─────────────────────────────────────────┤
│ CPU time:               <1.0s (1.6%)   │ Actual computation
│ I/O wait time:         ~62.0s (98.4%)  │ Waiting for network/database
└─────────────────────────────────────────┘
```

**Since 98%+ of time is waiting for I/O**, async is ideal: workers can wait concurrently without blocking each other.

### Async Execution Timeline

**4 jobs processing concurrently** (timeline in seconds):

```
Time    Worker-0              Worker-1              Worker-2              Worker-3
────────────────────────────────────────────────────────────────────────────────
0.0s    Read Job A            Read Job B            Read Job C            Read Job D
        ↓ await               ↓ await               ↓ await               ↓ await
0.1s    Download PDF A        Download PDF B        Download PDF C        Download PDF D
        ↓ await (2s)          ↓ await (2s)          ↓ await (2s)          ↓ await (2s)

        [Event loop switches between workers during waits]

2.0s    [PDF ready] ✓         [PDF ready] ✓         [PDF ready] ✓         [PDF ready] ✓
2.1s    Call Vertex AI →      Call Vertex AI →      Call Vertex AI →      Call Vertex AI →
        ↓ await (60s)         ↓ await (60s)         ↓ await (60s)         ↓ await (60s)

        [All 4 workers waiting for Vertex AI simultaneously]
        [Event loop is idle - no CPU usage]

62.0s   ← Response A          ← Response B          ← Response C          ← Response D
62.1s   Save to DB            Save to DB            Save to DB            Save to DB
        ↓ await (1s)          ↓ await (1s)          ↓ await (1s)          ↓ await (1s)
63.0s   ✅ Done               ✅ Done               ✅ Done               ✅ Done
────────────────────────────────────────────────────────────────────────────────
Result: 4 jobs in ~63 seconds (vs 252 seconds sequential = 4x speedup)
```

### The `await` Keyword Magic

```python
# WITHOUT await (BLOCKING - Sequential)
response = vertex_ai.call()  # ← Blocks entire program for 60s
# Nothing else can run during this time
# Total for 4 jobs: 4 × 60s = 240 seconds

# WITH await (NON-BLOCKING - Concurrent)
response = await vertex_ai.call_async()  # ← Releases control to event loop
# Event loop switches to other workers during the 60s wait
# All 4 workers wait simultaneously
# Total for 4 jobs: ~60 seconds (all concurrent)
```

**What happens at `await`**:
1. Current coroutine **pauses** execution
2. **Releases control** back to event loop
3. Event loop **switches** to another ready coroutine
4. When I/O completes, event loop **resumes** the paused coroutine

### Event Loop Behavior

```python
# backend/workers/worker_pool.py (Simplified)

async def run_worker(worker_id: int):
    """Each worker is an async coroutine"""
    while True:
        # Poll queue (releases control during DB I/O)
        job = await poll_queue()  # ← Event loop switches here

        if job:
            # Download PDF (releases control during network I/O)
            pdf = await download_pdf(job)  # ← Event loop switches here

            # Call Vertex AI (releases control during 60s API wait)
            text = await call_vertex_ai(pdf)  # ← Event loop switches here

            # Save to DB (releases control during DB I/O)
            await save_to_db(text)  # ← Event loop switches here
        else:
            # No jobs, wait 2 seconds
            await asyncio.sleep(2)  # ← Event loop switches here


async def main():
    """Start 4 workers concurrently"""
    workers = [
        asyncio.create_task(run_worker(0)),
        asyncio.create_task(run_worker(1)),
        asyncio.create_task(run_worker(2)),
        asyncio.create_task(run_worker(3)),
    ]

    # Run all 4 workers concurrently until KeyboardInterrupt
    await asyncio.gather(*workers)


# Start event loop
asyncio.run(main())
```

**`asyncio.gather(*workers)`** tells event loop: "Run all 4 workers concurrently, switching between them at `await` points"

### Real-World Analogy

**Multiprocessing** = 4 Chefs in 4 Kitchens:
```
Chef 1: Makes pizza → Waits for oven (15 min) → Serves
Chef 2: Makes pizza → Waits for oven (15 min) → Serves
Chef 3: Makes pizza → Waits for oven (15 min) → Serves
Chef 4: Makes pizza → Waits for oven (15 min) → Serves

All done in 15 minutes
Cost: 4 kitchens, 4 ovens, 4 chefs (expensive!)
```

**Async** = 1 Chef in 1 Kitchen with 4 Ovens:
```
Chef:
  Put Pizza A in Oven 1 → Start timer
  Put Pizza B in Oven 2 → Start timer
  Put Pizza C in Oven 3 → Start timer
  Put Pizza D in Oven 4 → Start timer
  [All 4 ovens cooking simultaneously]
  Wait 15 minutes (chef idle - minimal work)
  Take out all 4 pizzas

All done in 15 minutes
Cost: 1 kitchen, 4 ovens, 1 chef (efficient!)
```

The **ovens** = **I/O operations** (Vertex AI API calls, database queries)
The **chef** = **event loop** (manages all operations, switches tasks)
**Waiting** = **await** (chef waits for ovens, doesn't block other work)

### Why Async Works Perfectly for Us

✅ **I/O-bound workload** (98% waiting for network/database)
✅ **Low memory** (~250MB vs ~1GB for multiprocessing)
✅ **Simple management** (one process vs four processes)
✅ **Windows compatible** (no pickle issues)
✅ **Same performance** as multiprocessing for I/O tasks
✅ **Easier debugging** (single process, shared state visible)

### When Async Would NOT Work

❌ **CPU-bound tasks** (video encoding, image processing, scientific computing)
❌ **Blocking libraries** (libraries without async support)
❌ **Heavy computation** (where workers actually use CPU 100%)

For CPU-bound tasks, multiprocessing would be needed to use multiple CPU cores.

---

## Multiprocessing vs Async vs Threading

### Comparison Table

| Feature | Async (Current) | Multiprocessing | Threading |
|---------|----------------|-----------------|-----------|
| **Processes** | 1 | 4 | 1 |
| **Concurrency Model** | Cooperative (event loop) | True parallel (4 cores) | Concurrent (GIL-limited) |
| **Memory Usage** | ~250MB | ~1GB (4 × 250MB) | ~250MB |
| **CPU Cores Used** | 1 (I/O wait only) | 4 (if CPU-bound) | 1 (GIL limitation) |
| **Best For** | I/O-bound tasks | CPU-bound tasks | I/O-bound (limited) |
| **Windows Support** | ✅ Perfect | ❌ Pickle issues | ✅ Works |
| **Complexity** | Low | High | Medium |
| **Crash Isolation** | ❌ Crash kills all | ✅ Isolated | ❌ Crash kills all |
| **Performance (I/O)** | ✅ Excellent | ✅ Excellent | ⚠️ Good |
| **Performance (CPU)** | ❌ Limited to 1 core | ✅ Uses all cores | ❌ GIL bottleneck |

### Why We Chose Async (Actual Implementation)

**Decision Timeline**:
1. **Planned**: Multiprocessing (documented in initial specs)
2. **Attempted**: Multiprocessing implementation
3. **Blocked**: Windows Python 3.13 pickle errors (`TypeError: cannot pickle 'weakref.ReferenceType'`)
4. **Pivoted**: Async implementation (Story 1.5 completion)
5. **Result**: ✅ Same performance, simpler, Windows-compatible

**Reasons**:
1. **Windows Compatibility**: No pickle issues with async
2. **I/O-Bound Workload**: 98%+ I/O wait = async perfect fit
3. **Simpler**: Single process easier than managing 4 processes
4. **Lower Memory**: 250MB vs 1GB (4x reduction)
5. **Easier Debugging**: All state in one process, easier to inspect

### Why Multiprocessing Was Originally Planned

**Python GIL (Global Interpreter Lock)**:
- Threading: All threads share one GIL → no true parallelism for CPU-bound work
- Multiprocessing: Each process has own Python interpreter → true parallelism

**Our Workload**:
- PDF processing: CPU-intensive
- Vertex AI calls: I/O wait (but also data processing)
- Database operations: I/O wait

**Verdict**: Multiprocessing = better performance for our use case

### Process Isolation Benefits

**Independent Memory Spaces**:
- Worker crash doesn't affect other workers
- No shared state bugs
- Easier debugging (separate PIDs)

**Independent Database Connections**:
- Each worker has own connection pool
- No connection sharing issues
- PostgreSQL handles connection pooling

**Drawbacks (Accepted)**:
- Higher memory usage (~100MB per worker)
- Can't share objects between processes (must use queue/DB)

---

## Worker Lifecycle

### Startup Sequence

```
1. WorkerPoolManager starts
2. For i in range(pool_size):
   3. Spawn worker process (multiprocessing.Process)
   4. Worker imports modules
   5. Worker connects to PostgreSQL
   6. Worker connects to Supabase
   7. Worker initializes Vertex AI client
   8. Worker enters polling loop

Total startup time: ~2-3 seconds for 4 workers
```

### Polling Loop

```python
while True:
    # Read message (300s VT)
    msg = pgmq.read('text_extraction_queue', 300)

    if msg:
        # Process job
        process_extraction_job(msg)

        # Archive message (success)
        pgmq.archive('text_extraction_queue', msg_id)
    else:
        # No jobs, wait 2 seconds
        await asyncio.sleep(2)
```

**Key Points**:
- VT = 300 seconds (5 minutes) → gives worker time to process
- If processing takes >5 min → message returns to queue (safety)
- If worker crashes → message returns to queue automatically
- Poll interval = 2 seconds → low latency, low CPU usage

### Shutdown Sequence

```
1. User presses Ctrl+C or sends SIGTERM
2. Manager receives signal
3. Manager sets shutdown_flag = True
4. Manager terminates all workers (SIGTERM)
5. Workers finish current job (if <5s)
6. Workers exit cleanly
7. If worker doesn't exit in 5s → Manager kills (SIGKILL)
8. Manager exits
```

**Graceful Shutdown Guarantees**:
- Jobs in progress: May complete if <5s remaining
- Jobs in progress >5s: Return to queue (VT expires)
- No jobs lost
- No zombie processes

---

## Health Monitoring

### Manager Monitoring Loop

```python
while not shutdown_flag:
    time.sleep(10)  # Check every 10 seconds

    for worker in workers:
        if not worker.process.is_alive():
            # Worker died!
            print(f"⚠️  Worker-{worker.id} died")

            # Auto-restart
            spawn_worker(worker.id)
            restart_count += 1
```

**Failure Detection**:
- Check every 10 seconds
- Detect: `process.is_alive() == False`
- Auto-restart: Spawn new worker with same ID
- Log: Worker death + restart count

### Worker Health Indicators

**Healthy Worker**:
- Process alive: `is_alive() == True`
- Polling queue: Logs show "Polling queue..." every 2s
- Processing jobs: Logs show "Processing job X"
- Archiving messages: Logs show "Archived job X"

**Unhealthy Worker**:
- Process dead: `is_alive() == False`
- No logs for >30 seconds
- Database connection errors
- Vertex AI connection errors

---

## Database Connection Strategy

### Per-Worker Connections

```python
class TextExtractionWorker:
    def __init__(self, worker_id: int):
        # Each worker gets own connections
        self.db_conn = psycopg2.connect(os.getenv("DATABASE_URL"))

        self.supabase = create_client(
            os.getenv("SUPABASE_URL"),
            os.getenv("SUPABASE_SERVICE_KEY")
        )
```

**Connection Count**:
- 4 workers × 2 connections each = 8 connections
- PostgreSQL default limit: 100 connections
- Plenty of headroom

**Connection Pooling**:
- Supabase client uses connection pooling internally
- psycopg2 creates single connection per worker
- No explicit pooling needed (simple architecture)

### Long-Running Jobs

**Problem**: Database connections time out after 10-15 minutes of inactivity

**Solution**: Reconnect before final update
```python
# After long Vertex AI call (15 minutes)
try:
    # Try to update database
    supabase.table(...).update(...).execute()
except Exception:
    # Connection timed out, reconnect
    self.supabase = create_client(...)
    supabase.table(...).update(...).execute()
```

---

## Scaling Considerations

### When to Scale Up (Add Workers)

**Indicators**:
- Queue depth consistently >10 jobs
- Jobs waiting >5 minutes
- Worker CPU usage <50% (underutilized)

**How to Scale**:
```bash
# Increase worker pool size
export WORKER_POOL_SIZE=8
python backend/workers/worker_pool_manager.py
```

**Limits**:
- Database connections: 100 max → ~45 workers max
- CPU cores: 1 worker per core recommended
- Memory: ~100MB per worker

### When to Scale Down

**Indicators**:
- Queue depth consistently 0
- Workers idle >80% of time
- Cost optimization needed

**How to Scale**:
```bash
export WORKER_POOL_SIZE=2
```

### Horizontal Scaling (Multiple Servers)

**Current Architecture** (Single Server):
```
Server 1: WorkerPoolManager → 4 workers → PostgreSQL
```

**Horizontal Architecture** (Future):
```
Server 1: WorkerPoolManager → 4 workers → PostgreSQL
Server 2: WorkerPoolManager → 4 workers → PostgreSQL
Server 3: WorkerPoolManager → 4 workers → PostgreSQL
Total: 12 workers across 3 servers
```

**Requirements**:
- Same PostgreSQL database (shared state)
- Same Supabase Storage (shared files)
- Same environment variables
- pgmq handles concurrency automatically

---

## Performance Metrics

### Throughput

**Before (Sequential)**:
- 1 worker processing jobs sequentially
- 4 documents = 4 minutes (1 min each)
- Throughput: 15 docs/hour

**After (Parallel)**:
- 4 workers processing concurrently
- 4 documents = 1 minute (all concurrent)
- Throughput: 60 docs/hour
- **4x improvement**

### Latency

**Queue Wait Time**:
- 0 workers busy: 0 seconds (immediate start)
- 4 workers busy: 60 seconds average (depends on job duration)
- 4 workers busy + 10 in queue: ~2.5 minutes average

**Processing Time** (unchanged):
- 10-page PDF: ~60 seconds
- 50-page PDF: ~180 seconds
- 100-page PDF: ~300 seconds

### Resource Usage

**CPU**:
- 4 workers idle: ~5% CPU
- 4 workers processing: 40-60% CPU (depends on PDF complexity)
- Manager process: <1% CPU

**Memory**:
- Manager: ~50MB
- Each worker: ~100-150MB (with Vertex AI client)
- Total: ~500-650MB for 4 workers

**Database Connections**:
- 4 workers × 2 connections = 8 connections
- Supabase limit: 100 connections
- Headroom: 92 connections available

---

## Error Handling

### Worker Crash Scenarios

**Scenario 1: Python Exception**
```
Worker-2 crashes with exception
→ Manager detects (10s interval)
→ Manager spawns Worker-2 (new PID)
→ Crashed job returns to queue (VT expires)
→ Another worker picks it up
```

**Scenario 2: Out of Memory**
```
Worker-1 OOM killed by OS
→ Manager detects (10s interval)
→ Manager spawns Worker-1 (new PID)
→ Job returns to queue
```

**Scenario 3: Database Connection Lost**
```
Worker-3 loses DB connection
→ Job fails with exception
→ Worker logs error, continues polling
→ Job returns to queue (VT expires)
→ Worker picks up next job (connection restored)
```

### Message Handling

**Message States**:
1. **Available**: Can be read by worker
2. **Invisible**: Read by worker, processing (VT active)
3. **Archived**: Successfully processed
4. **Dead Letter** (future): Failed after 3 retries

**Retry Logic**:
```
Attempt 1: Worker-0 reads, crashes → Returns to queue
Attempt 2: Worker-1 reads, processes → Success (archived)

OR

Attempt 1: Worker-0 reads, crashes → Returns to queue
Attempt 2: Worker-1 reads, crashes → Returns to queue
Attempt 3: Worker-2 reads, crashes → Returns to queue
Future: Move to dead_letter_queue after 3 retries
```

---

## Monitoring & Observability

### Log Format

```
[Worker-0] 2025-10-03 10:30:15 | Text Extraction Worker started (PID: 1235)
[Worker-0] 2025-10-03 10:30:15 | Polling queue: text_extraction_queue
[Worker-0] 2025-10-03 10:30:20 | 📥 Received job: abc-123
[Worker-0] 2025-10-03 10:30:20 |    Processing batch 1 of 3
[Worker-0] 2025-10-03 10:30:45 |    ✓ Batch 1 complete (33%)
[Worker-0] 2025-10-03 10:31:10 |    ✓ Batch 2 complete (67%)
[Worker-0] 2025-10-03 10:31:35 |    ✓ Batch 3 complete (100%)
[Worker-0] 2025-10-03 10:31:35 | ✅ Job abc-123 completed successfully
[Worker-0] 2025-10-03 10:31:35 | ✅ Job abc-123 archived from queue
```

### API Endpoints

**Worker Status** (`GET /api/workers/status`):
```json
{
  "worker_pool_size": 4,
  "active_jobs": 3,
  "queue_depth": 5,
  "completed_today": 47,
  "status": "busy"
}
```

**Health Check** (`GET /api/workers/health`):
```json
{
  "status": "healthy",
  "database": "connected",
  "queue": "available"
}
```

### Metrics to Track

**Key Metrics**:
- Queue depth (jobs waiting)
- Active jobs (workers busy)
- Jobs completed per hour
- Average processing time per job
- Worker restart count
- Error rate

**Future Metrics** (with monitoring tools):
- CPU usage per worker
- Memory usage per worker
- Database query duration
- Vertex AI API latency

---

## Security Considerations

### Worker Isolation

**Process Isolation**:
- Each worker runs in separate process
- Memory isolation (no shared state)
- One compromised worker ≠ entire system compromised

**Database Access**:
- Workers use service account key (read/write)
- No user credentials in worker processes
- Environment variables for secrets

### pgmq Security

**Queue Access**:
- Direct PostgreSQL connection required
- No public API exposure
- Database-level authentication

**Message Content**:
- Messages contain only job metadata (IDs)
- No sensitive data in queue messages
- PDFs stored in Supabase Storage (not in queue)

---

## Comparison: Alternatives Considered

### Alternative 1: Threading (multithread)

**Pros**:
- Lower memory usage
- Easier to share objects

**Cons**:
- Python GIL limits parallelism
- Not suitable for CPU-bound work
- Harder to debug race conditions

**Verdict**: ❌ Rejected (GIL bottleneck)

---

### Alternative 2: Celery + Redis

**Pros**:
- Industry standard
- Rich feature set (retries, scheduling, monitoring)
- Battle-tested

**Cons**:
- Additional infrastructure (Redis)
- More complex setup
- Overkill for our needs

**Verdict**: ❌ Rejected (complexity, cost)

---

### Alternative 3: Kubernetes Jobs

**Pros**:
- Auto-scaling
- Enterprise-grade
- Cloud-native

**Cons**:
- Requires Kubernetes cluster
- Complex setup
- Premature optimization

**Verdict**: ❌ Rejected for MVP (can adopt later)

---

### Alternative 4: pgmq + Multiprocessing (CHOSEN)

**Pros**:
- Simple architecture
- No additional infrastructure
- Built into PostgreSQL
- ACID guarantees
- Easy to understand and debug

**Cons**:
- Limited to single server (for now)
- No built-in monitoring UI
- Manual scaling

**Verdict**: ✅ **Chosen** (best for MVP, can scale later)

---

## Future Enhancements

### Short Term (Next Sprint)
- [ ] Dead letter queue (failed jobs after 3 retries)
- [ ] Worker performance metrics (jobs/minute)
- [ ] Dynamic scaling based on queue depth

### Medium Term (Post-MVP)
- [ ] Web UI for worker monitoring
- [ ] Prometheus metrics export
- [ ] Alert on worker failures (email/Slack)
- [ ] Scheduled jobs (cron-like)

### Long Term (Scale Phase)
- [ ] Horizontal scaling across multiple servers
- [ ] Kubernetes deployment
- [ ] Auto-scaling based on load
- [ ] Advanced queue routing (priority queues)

---

## Implementation History & Documentation Note

### Why This Document Shows Both Approaches

This document was **originally written** (2025-10-03 20:30) assuming a **multiprocessing** implementation, which is a common pattern for parallel workers.

During **Story 1.5 implementation** (2025-10-03 20:40), we **pivoted to async** due to Windows compatibility issues, but the multiprocessing documentation remains valuable for:

1. **Linux/Production Deployment**: Multiprocessing may still be preferred on Linux servers
2. **CPU-Bound Tasks**: If future features require heavy computation
3. **Architectural Reference**: Understanding both approaches helps make informed decisions

### Current Implementation (Production)

**File**: `backend/workers/worker_pool.py`
**Model**: Async worker pool (single process, 4 coroutines)
**Platform**: Windows + Linux compatible
**Status**: ✅ Tested and working (Story 1.5 complete)

### Alternative Implementation (Documented for Future)

**File**: `backend/workers/worker_pool_manager.py` (DEPRECATED on Windows)
**Model**: Multiprocessing (4 separate processes)
**Platform**: Linux only (pickle issues on Windows Python 3.13)
**Status**: 📋 Documented for future consideration

---

## References

- **pgmq Documentation**: https://github.com/tembo-io/pgmq
- **Python asyncio**: https://docs.python.org/3/library/asyncio.html
- **Python multiprocessing**: https://docs.python.org/3/library/multiprocessing.html
- **Story 1.5**: `docs/stories/1.5-parallel-workers.md` (Original spec)
- **Story 1.5 Completion**: `docs/stories/1.5-parallel-workers-completion.md` (Actual implementation)
- **Story 1.6**: Will reuse async pattern for translation workers

---

**Document Owner**: Tech Lead
**Contributors**: Backend Team
**Last Updated**: 2025-10-03 (Updated to reflect async implementation)
**Version**: 2.0 (Added async concurrency model section)
