# Worker Architecture

**Version**: 2.0
**Last Updated**: 2025-10-02
**Purpose**: Background worker implementation for processing jobs from pgmq queues

---

## Overview

Workers are Python processes that:
1. Poll pgmq queues for jobs
2. Download PDFs from Supabase Storage
3. Call Vertex AI for text extraction
4. Insert page markers in results
5. Update database with results
6. Notify frontend via Supabase Realtime

---

## Text Extraction Worker

### Architecture

```python
import asyncio
import psycopg2
from supabase import create_client
import vertexai
from vertexai.generative_models import GenerativeModel

class TextExtractionWorker:
    def __init__(self):
        # Database connection for pgmq
        self.db_conn = psycopg2.connect(os.getenv("DATABASE_URL"))

        # Supabase client
        self.supabase = create_client(
            os.getenv("SUPABASE_URL"),
            os.getenv("SUPABASE_SERVICE_KEY")
        )

        # Vertex AI client
        vertexai.init(
            project=os.getenv("GOOGLE_CLOUD_PROJECT"),
            location=os.getenv("VERTEX_AI_LOCATION")
        )
        self.vertex_model = GenerativeModel("gemini-2.0-flash-exp")

    async def run(self):
        """Main worker loop"""
        while True:
            try:
                # Read message from queue (5 min visibility timeout)
                cursor = self.db_conn.cursor()
                cursor.execute("""
                    SELECT * FROM pgmq.read('text_extraction_queue', 300, 1);
                """)
                messages = cursor.fetchall()
                cursor.close()

                if not messages:
                    await asyncio.sleep(2)  # Poll every 2 seconds
                    continue

                msg = messages[0]
                msg_id = msg[0]
                job_data = msg[1]  # JSONB message content

                # Process job
                await self.process_extraction_job(job_data)

                # Archive message
                cursor = self.db_conn.cursor()
                cursor.execute(
                    "SELECT pgmq.archive('text_extraction_queue', %s);",
                    (msg_id,)
                )
                self.db_conn.commit()
                cursor.close()

            except Exception as e:
                print(f"Worker error: {e}")
                await asyncio.sleep(5)
```

---

### Job Processing

```python
async def process_extraction_job(self, job_data: dict):
    """Process a single extraction job"""
    job_id = job_data["job_id"]
    document_id = job_data["document_id"]

    try:
        # Update job status to processing
        self.supabase.table("text_extraction_results").update({
            "status": "processing",
            "progress": 0
        }).eq("id", job_id).execute()

        # Get document info
        doc = self.supabase.table("documents").select("*").eq(
            "id", document_id
        ).single().execute()
        document = doc.data

        # Download PDF from storage
        pdf_bytes = self.supabase.storage.from_("documents").download(
            document["storage_path"]
        )

        # Get batches for this job
        batches = self.supabase.table("processing_batches").select("*").eq(
            "extraction_job_id", job_id
        ).order("batch_number").execute()

        total_batches = len(batches.data)
        batch_results = []

        # Process each batch SEQUENTIALLY
        for i, batch in enumerate(batches.data):
            # Update batch status
            self.supabase.table("processing_batches").update({
                "status": "processing"
            }).eq("id", batch["id"]).execute()

            # Extract text for this batch
            batch_text = await self.extract_batch(
                pdf_bytes,
                batch["start_page"],
                batch["end_page"]
            )

            # Update batch with results
            self.supabase.table("processing_batches").update({
                "status": "completed",
                "extracted_text": batch_text,
                "completed_at": datetime.now().isoformat()
            }).eq("id", batch["id"]).execute()

            batch_results.append({
                "batch_number": batch["batch_number"],
                "start_page": batch["start_page"],
                "end_page": batch["end_page"],
                "extracted_text": batch_text
            })

            # Update overall progress
            progress = int(((i + 1) / total_batches) * 100)
            self.supabase.table("text_extraction_results").update({
                "progress": progress
            }).eq("id", job_id).execute()

        # Combine results with page markers
        full_text = insert_page_markers(batch_results)

        # Update job as completed
        self.supabase.table("text_extraction_results").update({
            "status": "completed",
            "progress": 100,
            "extracted_text": full_text,
            "completed_at": datetime.now().isoformat()
        }).eq("id", job_id).execute()

        # Update document status
        self.supabase.table("documents").update({
            "status": "completed"
        }).eq("id", document_id).execute()

    except Exception as e:
        # Handle failure
        self.supabase.table("text_extraction_results").update({
            "status": "failed",
            "error_message": str(e)
        }).eq("id", job_id).execute()
```

---

### Batch Extraction with Vertex AI

```python
async def extract_batch(
    self,
    pdf_bytes: bytes,
    start_page: int,
    end_page: int
) -> str:
    """Extract text from a batch of pages using Vertex AI"""

    # Convert PDF pages to images
    images = pdf2image.convert_from_bytes(
        pdf_bytes,
        first_page=start_page,
        last_page=end_page
    )

    # Prepare prompt
    prompt = f"""Extract all text from these document pages ({start_page} to {end_page}).

Requirements:
- Preserve original text layout and structure
- Include all text, even if partially visible
- Maintain paragraph breaks and formatting
- If text is unclear, provide best-effort transcription

Return the extracted text only, without any additional commentary."""

    # Convert images to Vertex AI Part objects
    parts = [prompt]
    for img in images:
        img_bytes = io.BytesIO()
        img.save(img_bytes, format="PNG")
        parts.append(Part.from_data(img_bytes.getvalue(), mime_type="image/png"))

    # Call Vertex AI
    response = await self.vertex_model.generate_content_async(parts)

    return response.text
```

---

## Worker Deployment

### Development (Local)

```bash
# Terminal 1: Run worker
cd backend
python workers/text_extraction_worker.py

# Worker output:
# 🚀 Text Extraction Worker started
#    Polling queue: text_extraction_queue
#    Model: gemini-2.0-flash-exp
# 📥 Received job: uuid
#    Processing batch 1 of 3
#    ✓ Batch 1 complete (33%)
# ...
```

### Production (Supervisor)

**supervisord.conf**:
```ini
[program:text_extraction_worker]
command=python /app/backend/workers/text_extraction_worker.py
directory=/app/backend
user=app
autostart=true
autorestart=true
stderr_logfile=/var/log/extraction_worker.err.log
stdout_logfile=/var/log/extraction_worker.out.log
environment=DATABASE_URL="...",SUPABASE_URL="...",GOOGLE_CLOUD_PROJECT="..."
```

**Start with Supervisor**:
```bash
supervisord -c supervisord.conf
supervisorctl status
```

---

## Scaling Workers

### Horizontal Scaling

Run multiple worker instances:

```bash
# Terminal 1
python workers/text_extraction_worker.py

# Terminal 2
python workers/text_extraction_worker.py

# Terminal 3
python workers/text_extraction_worker.py
```

**Benefits**:
- Jobs processed in parallel
- Faster overall throughput
- Automatic load balancing (pgmq handles distribution)

**Considerations**:
- Each worker needs its own database connection
- Vertex AI rate limits apply per project
- Monitor memory usage (PDF processing is memory-intensive)

---

## Monitoring & Health Checks

### Worker Health Check

```python
# Add to worker
async def health_check(self):
    """Periodic health check"""
    try:
        # Test database connection
        cursor = self.db_conn.cursor()
        cursor.execute("SELECT NOW();")
        cursor.close()

        # Test Supabase connection
        self.supabase.table("documents").select("id").limit(1).execute()

        # Log heartbeat
        print(f"✅ Worker healthy at {datetime.now()}")
        return True
    except Exception as e:
        print(f"❌ Worker unhealthy: {e}")
        return False

async def run_with_health_checks(self):
    """Run worker with periodic health checks"""
    last_health_check = datetime.now()

    while True:
        # Health check every 5 minutes
        if (datetime.now() - last_health_check).seconds > 300:
            await self.health_check()
            last_health_check = datetime.now()

        # Normal processing
        await self.process_next_job()
```

### Monitoring Metrics

**Key Metrics to Track**:
- Jobs processed per hour
- Average processing time per job
- Error rate (failed jobs / total jobs)
- Queue depth (number of pending jobs)
- Worker uptime

**Query for Metrics**:
```sql
-- Jobs processed in last hour
SELECT COUNT(*)
FROM text_extraction_results
WHERE status = 'completed'
  AND completed_at > NOW() - INTERVAL '1 hour';

-- Average processing time
SELECT AVG(processing_time) as avg_seconds
FROM text_extraction_results
WHERE status = 'completed';

-- Error rate
SELECT
    COUNT(CASE WHEN status = 'failed' THEN 1 END) * 100.0 / COUNT(*) as error_rate_pct
FROM text_extraction_results;
```

---

## Error Handling & Retry Logic

### Automatic Retry (via Visibility Timeout)

```python
# If worker crashes or raises exception:
# - Message visibility timeout expires (5 minutes)
# - Message automatically returns to queue
# - Another worker can pick it up

# Track retry count in database:
async def process_with_retry(self, job_data):
    retry_count = job_data.get("retry_count", 0)

    if retry_count >= 3:
        # Max retries reached - permanent failure
        await self.mark_as_failed(job_data["job_id"], "Max retries exceeded")
        await self.move_to_dead_letter_queue(job_data)
        return

    try:
        await self.process_extraction_job(job_data)
    except Exception as e:
        # Increment retry count
        job_data["retry_count"] = retry_count + 1
        # Let visibility timeout expire (automatic retry)
        raise
```

---

## Graceful Shutdown

```python
import signal

class Worker:
    def __init__(self):
        self.shutdown_requested = False
        signal.signal(signal.SIGINT, self.handle_shutdown)
        signal.signal(signal.SIGTERM, self.handle_shutdown)

    def handle_shutdown(self, signum, frame):
        print("\n🛑 Shutdown requested, finishing current job...")
        self.shutdown_requested = True

    async def run(self):
        while not self.shutdown_requested:
            # Process jobs
            await self.process_next_job()

        print("✅ Worker shut down gracefully")
```

**Usage**:
```bash
# Ctrl+C to gracefully shutdown
python workers/text_extraction_worker.py
# Worker finishes current job before exiting
```

---

## Translation Worker (Future - Story 1.5)

Similar architecture, different queue:

```python
class TranslationWorker:
    async def run(self):
        while True:
            # Poll translation_queue instead
            messages = await pgmq.read('translation_queue', vt=600, qty=1)

            if messages:
                await self.process_translation_job(messages[0])
```

---

**Reference**: See `docs/stories/1.3-text-extraction.md` for complete worker implementation.
