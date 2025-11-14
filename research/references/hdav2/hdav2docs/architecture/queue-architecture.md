# Queue Architecture

**Version**: 2.0
**Last Updated**: 2025-10-02
**Purpose**: pgmq-based queue architecture for background job processing

---

## Overview

Uses **pgmq** (PostgreSQL Message Queue) - a PostgreSQL extension that provides message queue functionality within the database.

**Why pgmq**:
- Built into PostgreSQL (no separate service)
- ACID guarantees with database operations
- Exactly-once delivery
- Simple to use, reliable
- No Redis or Celery dependency

---

## Queue Structure

### 1. text_extraction_queue

Handles PDF text extraction jobs.

**Create Queue**:
```sql
CREATE EXTENSION IF NOT EXISTS pgmq;
SELECT pgmq.create('text_extraction_queue');
```

**Message Format**:
```json
{
  "job_id": "660e8400-e29b-41d4-a716-446655440000",
  "document_id": "550e8400-e29b-41d4-a716-446655440000",
  "batch_count": 3,
  "priority": 8,
  "selected_pages": [1, 2, 3, 4, 5],
  "timestamp": "2025-10-02T10:00:00Z"
}
```

### 2. translation_queue (Future)

Handles translation jobs.

**Create Queue**:
```sql
SELECT pgmq.create('translation_queue');
```

**Message Format**:
```json
{
  "translation_id": "770e8400-e29b-41d4-a716-446655440000",
  "document_id": "550e8400-e29b-41d4-a716-446655440000",
  "source_extraction_id": "660e8400-e29b-41d4-a716-446655440000",
  "target_language": "es",
  "priority": 7,
  "timestamp": "2025-10-02T10:10:00Z"
}
```

---

## Queue Operations

### Send Message

```python
import psycopg2
import json

conn = psycopg2.connect(DATABASE_URL)
cursor = conn.cursor()

message = {
    "job_id": "uuid",
    "document_id": "uuid",
    "batch_count": 3
}

cursor.execute(
    "SELECT pgmq.send(%s, %s::jsonb);",
    ("text_extraction_queue", json.dumps(message))
)
conn.commit()
msg_id = cursor.fetchone()[0]
```

### Read Message (with Visibility Timeout)

```python
# Read with 5-minute visibility timeout
cursor.execute("""
    SELECT * FROM pgmq.read('text_extraction_queue', 300, 1);
""")
messages = cursor.fetchall()

if messages:
    msg = messages[0]
    msg_id = msg[0]
    job_data = msg[1]  # JSONB message content

    # Process job...
```

### Archive Message (Success)

```python
cursor.execute(
    "SELECT pgmq.archive('text_extraction_queue', %s);",
    (msg_id,)
)
conn.commit()
```

### Delete Message (Permanent Removal)

```python
cursor.execute(
    "SELECT pgmq.delete('text_extraction_queue', %s);",
    (msg_id,)
)
conn.commit()
```

---

## Priority System

### Priority Calculation

```python
def calculate_priority(page_count):
    """
    Calculate job priority based on page count
    Higher priority = processed first
    """
    if page_count <= 10:
        return 8  # High priority (small docs, fast completion)
    elif page_count <= 50:
        return 5  # Medium priority
    else:
        return 3  # Low priority (large batches)
```

**Reasoning**: Small jobs complete faster → better user experience

### Priority Queue Implementation

```python
# pgmq doesn't have native priority support
# Implement priority by reading multiple messages and sorting

cursor.execute("""
    SELECT * FROM pgmq.read('text_extraction_queue', 300, 10);
""")
messages = cursor.fetchall()

# Sort by priority (stored in message JSON)
sorted_messages = sorted(
    messages,
    key=lambda m: m[1].get("priority", 0),
    reverse=True
)

# Process highest priority first
for msg in sorted_messages:
    process_job(msg)
```

---

## Failure Handling

### Retry Logic

**Visibility Timeout Mechanism**:
- Message read with visibility timeout (e.g., 5 minutes)
- If worker crashes/fails, message automatically returns to queue after timeout
- Max retries: 3 attempts
- After max retries: Move to dead letter queue

**Implementation**:
```python
async def process_job_with_retry(job_data):
    try:
        # Update retry count in database
        retry_count = job_data.get("retry_count", 0)

        if retry_count >= 3:
            # Move to dead letter queue
            await pgmq.send("dead_letter_queue", job_data)
            return

        # Process job
        await do_extraction(job_data)

        # Success - archive message
        await pgmq.archive("text_extraction_queue", msg_id)

    except Exception as e:
        # Increment retry count
        job_data["retry_count"] = retry_count + 1
        job_data["last_error"] = str(e)

        # Let visibility timeout expire (automatic retry)
        logger.error(f"Job {job_id} failed (attempt {retry_count + 1}): {e}")
```

---

## Timeout Configuration

```python
TIMEOUTS = {
    'text_extraction': 300,   # 5 minutes per message
    'translation': 600        # 10 minutes per message
}

# Read with appropriate timeout
job = await pgmq.read('text_extraction_queue', vt=TIMEOUTS['text_extraction'])
```

---

## Monitoring

### Queue Depth

```sql
-- Check queue depth (number of messages)
SELECT queue_name, COUNT(*) as message_count
FROM pgmq.q_text_extraction_queue
GROUP BY queue_name;
```

### Message Age

```sql
-- Find oldest messages
SELECT msg_id, message, enqueued_at
FROM pgmq.q_text_extraction_queue
ORDER BY enqueued_at ASC
LIMIT 10;
```

### Dead Letter Queue

```sql
-- Check failed messages
SELECT * FROM pgmq.q_dead_letter_queue;
```

---

## Worker Architecture Integration

Workers poll queues continuously:

```python
async def worker_loop():
    while True:
        # Read message
        messages = await pgmq.read('text_extraction_queue', vt=300, qty=1)

        if not messages:
            await asyncio.sleep(2)  # Poll every 2 seconds
            continue

        # Process message
        await process_job(messages[0])
```

---

**Reference**: See `docs/architecture/worker-architecture.md` for worker implementation details.
