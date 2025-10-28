# {Pattern/Integration Name}

**Last Updated:** {Use: date '+%Y-%m-%d %H:%M:%S'}
**Updated By:** {Agent Name} ({Agent Type})
**Sprint/Story**: Sprint-{N} / Epic-{N} / Story-{N}

---

## Overview

Brief description of the pattern/integration and when to use it.

**Purpose**: {What problem does this solve?}
**Use Cases**: {When should this pattern be used?}

---

## Reference Implementation

**File**: `{path/to/reference/file.ts}`
**Story**: `docs/sprint-N/epics/epic-N/story-N.md`

---

## Pattern

```{language}
// Code example showing the correct pattern

// Example for S3 integration:
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';

export const s3Client = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!
  }
});

export async function uploadFile(file: Buffer, key: string) {
  const command = new PutObjectCommand({
    Bucket: process.env.S3_BUCKET_NAME,
    Key: key,
    Body: file
  });

  return await s3Client.send(command);
}
```

---

## Common Mistakes

❌ **DON'T**: {Description of mistake}
- {Why it's wrong}
- {What happens if you do this}

❌ **DON'T**: {Description of another mistake}
- {Why it's wrong}
- {What happens if you do this}

✅ **DO**: {Correct approach}
- {Why it's correct}
- {Benefits}

---

## Gotchas

### Gotcha 1: {Title}
**Problem**: {What catches developers off guard}
**Solution**: {How to handle it}
**Example**: {Code example if needed}

### Gotcha 2: {Title}
**Problem**: {What catches developers off guard}
**Solution**: {How to handle it}
**Example**: {Code example if needed}

---

## Configuration

**Environment Variables Required**:
```bash
# .env.local
VARIABLE_NAME=value
ANOTHER_VARIABLE=value
```

**Dependencies**:
```json
{
  "dependencies": {
    "package-name": "^version"
  }
}
```

**Setup Steps**:
1. Install dependencies: `npm install package-name`
2. Configure environment variables
3. {Additional setup steps}

---

## When to Use

Use this pattern when:
- ✅ {Use case 1}
- ✅ {Use case 2}
- ✅ {Use case 3}

**Examples**:
- User profile picture uploads
- Document storage (invoices, receipts)
- {More examples}

---

## When NOT to Use

Avoid this pattern when:
- ❌ {Anti-pattern 1 - explain why}
- ❌ {Anti-pattern 2 - explain why}
- ❌ {Anti-pattern 3 - explain why}

**Alternatives**:
- {Alternative 1}: When to use this instead
- {Alternative 2}: When to use this instead

---

## Testing

**Unit Tests** (if applicable):
```typescript
// Example Vitest test
import { describe, it, expect } from 'vitest';
import { uploadFile } from '@/lib/s3Client';

describe('uploadFile', () => {
  it('uploads file to S3', async () => {
    const buffer = Buffer.from('test content');
    const result = await uploadFile(buffer, 'test.txt');
    expect(result).toBeDefined();
  });
});
```

**E2E Tests**:
- Test scenario location: `docs/qa/e2e/sprint-N/epics/epic-N/story-N/scenario-{name}.md`
- Key test cases: {Brief description}

---

## Related Patterns

- See: `{category/related-pattern-1.md}` - {Brief description of relationship}
- See: `{category/related-pattern-2.md}` - {Brief description of relationship}

---

## Additional Resources

- **Official Docs**: {Link to library/service docs}
- **GitHub**: {Link to relevant repo}
- **Tutorial**: {Link to helpful tutorial if available}

---

## Update History

| Date | Updated By | Changes |
|------|------------|---------|
| {timestamp} | {Agent Name} | Initial creation from Story {N} |

