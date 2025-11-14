# Batch Processing System

**Version**: 2.0
**Last Updated**: 2025-10-02
**Purpose**: Token-based batch splitting and processing for large PDFs

---

## Overview

Large PDFs (500+ pages) must be split into batches to stay within Vertex AI Gemini 2.5 Pro token limits.

**Vertex AI Limits**:
- Max input: 1,000,000 tokens
- Max output: 65,000 tokens
- Safe limit per batch: 900,000 tokens (10% buffer)

---

## Token Estimation Algorithm

```python
def estimate_tokens(page_count: int, document_type: str) -> int:
    """
    Estimate token count for PDF pages

    Token estimation rules:
    - Digital text PDFs: ~500-800 tokens per page
    - Scanned/image PDFs: ~300-500 tokens per page
    - Add 20% buffer for safety
    """
    if document_type == "digital":
        tokens_per_page = 650  # Average
    else:  # scanned
        tokens_per_page = 400  # Average

    estimated = page_count * tokens_per_page
    buffered = int(estimated * 1.2)  # Add 20% buffer

    return buffered
```

---

## Batch Size Calculation

```python
def calculate_batch_size(
    total_pages: int,
    estimated_tokens: int,
    document_type: str = "digital"
) -> int:
    """
    Calculate optimal batch size based on token limits

    Returns: Number of pages per batch
    """
    SAFE_TOKEN_LIMIT = 900_000

    tokens_per_page = estimated_tokens / total_pages
    max_pages_per_batch = int(SAFE_TOKEN_LIMIT / tokens_per_page)

    # Apply document-type specific limits
    if document_type == "digital":
        # Digital PDFs can handle larger batches
        batch_size = min(max_pages_per_batch, 100)
    else:  # scanned
        # Scanned PDFs need smaller batches (more processing intensive)
        batch_size = min(max_pages_per_batch, 30)

    return max(batch_size, 1)  # At least 1 page per batch
```

---

## Batch Creation

```python
def create_batches(
    document_id: str,
    job_id: str,
    total_pages: int,
    selected_pages: List[int],
    document_type: str = "digital"
) -> Dict:
    """
    Create batch records for a document

    Returns: Batch information dictionary
    """
    # Estimate tokens
    estimated_tokens = estimate_tokens(len(selected_pages), document_type)

    # Calculate batch size
    batch_size = calculate_batch_size(
        len(selected_pages),
        estimated_tokens,
        document_type
    )

    # Create batches
    batches = []
    for i in range(0, len(selected_pages), batch_size):
        batch_pages = selected_pages[i:i + batch_size]
        batch_number = (i // batch_size) + 1
        total_batches = (len(selected_pages) + batch_size - 1) // batch_size

        batch = {
            "document_id": document_id,
            "extraction_job_id": job_id,
            "batch_number": batch_number,
            "total_batches": total_batches,
            "start_page": batch_pages[0],
            "end_page": batch_pages[-1],
            "page_count": len(batch_pages),
            "estimated_tokens": int(
                estimated_tokens * len(batch_pages) / len(selected_pages)
            ),
            "status": "pending"
        }
        batches.append(batch)

    # Insert into database
    supabase.table("processing_batches").insert(batches).execute()

    return {
        "total_pages": total_pages,
        "selected_pages": len(selected_pages),
        "total_batches": len(batches),
        "estimated_tokens": estimated_tokens,
        "batch_strategy": "token-based"
    }
```

---

## Batch Processing Flow

```
1. API receives extraction request
   ↓
2. Create extraction job record (status: 'queued')
   ↓
3. Estimate total tokens for selected pages
   ↓
4. Calculate batch size based on token limits
   ↓
5. Create batch records in processing_batches table
   ↓
6. Send message to pgmq queue
   ↓
7. Worker polls queue and receives message
   ↓
8. Worker processes batches SEQUENTIALLY:
   For each batch:
       a. Update batch status to 'processing'
       b. Download PDF from Supabase Storage
       c. Extract pages for this batch (virtual extraction, not physical split)
       d. Call Vertex AI with batch pages
       e. Insert page markers in extracted text
       f. Update batch status to 'completed'
       g. Update extraction job progress
       h. Supabase Realtime notifies frontend
   ↓
9. After all batches complete:
   a. Combine all batch results
   b. Update extraction job status to 'completed'
   c. Store full extracted_text with page markers
   d. Update document status to 'completed'
```

---

## Page Marker Insertion

```python
def insert_page_markers(batch_results: List[Dict]) -> str:
    """
    Combine batch results and insert page markers

    CRITICAL: Page marker format MUST be exact: # [Page N]

    Input: List of batch results
    [
        {
            "batch_number": 1,
            "start_page": 1,
            "end_page": 50,
            "extracted_text": "..."
        },
        {
            "batch_number": 2,
            "start_page": 51,
            "end_page": 100,
            "extracted_text": "..."
        }
    ]

    Output: Combined text with page markers
    # [Page 1]
    Line 1 text
    Line 2 text

    # [Page 2]
    Line 1 text
    ...
    """
    combined_text = []

    for batch in sorted(batch_results, key=lambda x: x["batch_number"]):
        # Parse Vertex AI response to extract page-by-page text
        pages = parse_vertex_response(
            batch["extracted_text"],
            batch["start_page"],
            batch["end_page"]
        )

        for page_num, page_text in pages.items():
            # Insert page marker (EXACT FORMAT)
            combined_text.append(f"# [Page {page_num}]")
            combined_text.append(page_text.strip())
            combined_text.append("")  # Blank line between pages

    return "\n".join(combined_text)


def parse_vertex_response(
    vertex_text: str,
    start_page: int,
    end_page: int
) -> Dict[int, str]:
    """
    Parse Vertex AI response to extract individual pages

    Vertex AI may or may not return page breaks. This function:
    1. Checks if Vertex AI included page markers
    2. If not, estimates page breaks based on content length
    3. Returns dict: {page_number: page_text}
    """
    # Check if Vertex AI included page markers (it sometimes does)
    if "Page " in vertex_text or "[Page" in vertex_text:
        # Parse existing markers
        return parse_existing_markers(vertex_text, start_page)

    # Otherwise, estimate page breaks
    # This is a simplified approach - real implementation should be smarter
    lines = vertex_text.split("\n")
    total_lines = len(lines)
    page_count = end_page - start_page + 1
    lines_per_page = max(total_lines // page_count, 1)

    pages = {}
    for i in range(page_count):
        page_num = start_page + i
        start_line = i * lines_per_page
        end_line = (i + 1) * lines_per_page if i < page_count - 1 else total_lines
        page_text = "\n".join(lines[start_line:end_line])
        pages[page_num] = page_text

    return pages
```

---

## Example: 448-Page PDF

**Input**: PDF with 448 pages
**Document Type**: Digital

**Batch Calculation**:
```python
estimated_tokens = estimate_tokens(448, "digital") = 448 * 650 * 1.2 = 349,440 tokens
batch_size = calculate_batch_size(448, 349440, "digital") = 100 pages (token limit not hit)

# But apply digital PDF limit
batch_size = min(100, 100) = 100 pages

total_batches = (448 + 100 - 1) // 100 = 5 batches
```

**Batches Created**:
1. Batch 1: Pages 1-100 (100 pages)
2. Batch 2: Pages 101-200 (100 pages)
3. Batch 3: Pages 201-300 (100 pages)
4. Batch 4: Pages 301-400 (100 pages)
5. Batch 5: Pages 401-448 (48 pages)

**Processing Time**: ~5 minutes (60 seconds per batch)

---

## Progress Tracking

**Database Updates**:
```python
# After each batch completes
progress = int(((completed_batches / total_batches) * 100))

supabase.table("text_extraction_results").update({
    "progress": progress
}).eq("id", job_id).execute()
```

**Frontend Receives**:
- Realtime notification via Supabase postgres_changes
- OR polling status endpoint every 2 seconds

---

## Error Handling

**Batch Failure**:
```python
try:
    batch_text = await extract_batch(pdf_bytes, start_page, end_page)

    supabase.table("processing_batches").update({
        "status": "completed",
        "extracted_text": batch_text
    }).eq("id", batch_id).execute()

except Exception as e:
    # Mark batch as failed
    supabase.table("processing_batches").update({
        "status": "failed",
        "error_message": str(e)
    }).eq("id", batch_id).execute()

    # Mark entire job as failed
    supabase.table("text_extraction_results").update({
        "status": "failed",
        "error_message": f"Batch {batch_number} failed: {e}"
    }).eq("id", job_id).execute()

    raise  # Stop processing remaining batches
```

---

## Performance Metrics

| PDF Size | Batches | Est. Time | Token Count |
|----------|---------|-----------|-------------|
| 10 pages | 1 batch | 30 sec | ~7,800 tokens |
| 100 pages | 1 batch | 60 sec | ~78,000 tokens |
| 500 pages | 5 batches | 5 min | ~390,000 tokens |
| 1000 pages | 10 batches | 10 min | ~780,000 tokens |

---

**Reference**: See `docs/stories/1.3-text-extraction.md` for implementation details.
