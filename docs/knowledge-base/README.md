# Knowledge Base

**Purpose**: Centralized repository of patterns, integrations, and solutions to prevent "pattern amnesia" between stories and sprints.

---

## Overview

The Knowledge Base system captures proven patterns and solutions from implemented stories, making them discoverable for future work. This prevents agents from reinventing solutions and ensures consistency across the codebase.

---

## Folder Structure

```
knowledge-base/
├── integrations/         # Third-party service patterns
│   ├── s3-storage.md
│   ├── authentication.md
│   ├── supabase-client.md
│   └── stripe-payments.md
├── ui-patterns/          # Frontend patterns
│   ├── form-validation.md
│   ├── table-pagination.md
│   └── modal-handling.md
├── backend-patterns/     # Backend patterns
│   ├── api-error-handling.md
│   ├── database-transactions.md
│   └── file-uploads.md
└── common-issues/        # Recurring bugs/fixes
    ├── cors-debugging.md
    ├── typescript-errors.md
    └── deployment-gotchas.md
```

---

## When to Create Knowledge Base Entries

### Dev Agent Creates Entry When:
- ✅ Implementing third-party integration (S3, Stripe, Auth0, etc.)
- ✅ Solving complex pattern (authentication flow, file uploads, etc.)
- ✅ Establishing new UI pattern (modal system, form validation, etc.)
- ✅ Creating reusable backend pattern (error handling, logging, etc.)
- ✅ Fixing recurring issue (CORS, env vars, deployment, etc.)

### QA Agent Can Suggest Entry When:
- Recurring issue found across multiple stories
- Dev forgot pattern from previous story
- Solution would benefit future development

### Ownership:
- **Dev**: Creates and maintains entries
- **QA**: Can suggest entries during review
- **User**: Can request entries for important patterns

---

## When NOT to Create Entries

Skip knowledge base entries for:
- ❌ Trivial implementations (simple CRUD)
- ❌ One-time solutions (unlikely to recur)
- ❌ Project-specific business logic (belongs in code comments)
- ❌ Standard patterns already well-documented in framework docs

---

## How to Use Knowledge Base

### Before Implementing:
1. Check `docs/knowledge-base/` for existing patterns
2. Search by integration name, pattern type, or issue
3. If pattern exists: Follow reference implementation EXACTLY
4. If pattern doesn't exist: Implement, then CREATE entry

### After Implementing:
1. If significant pattern established: Create knowledge base entry
2. Use template from `_entry-template.md`
3. Include: Overview, reference implementation, gotchas, when to use
4. Add timestamp and reference story

### When Updating:
1. If new gotchas discovered: Update existing entry
2. Add "Updated" timestamp
3. Keep reference to original story

---

## Entry Template

See `_entry-template.md` for the standard format.

**Key Sections**:
- Overview
- Reference Implementation (file path + story reference)
- Pattern (code example)
- Common Mistakes
- Gotchas
- When to Use / When NOT to Use
- Related Patterns

---

## Examples of Good Knowledge Base Entries

### integrations/s3-storage.md
- **Why**: S3 setup is complex, easy to forget initialization pattern
- **Prevents**: Reinitializing S3Client on every request (memory leak)
- **Value**: 30+ min saved on future S3 implementations

### ui-patterns/form-validation.md
- **Why**: Form validation pattern spans multiple libraries (React Hook Form, Zod)
- **Prevents**: Inconsistent validation across forms
- **Value**: Consistent UX, easier maintenance

### common-issues/cors-debugging.md
- **Why**: CORS issues recur every few sprints
- **Prevents**: 1-2 hours of debugging each time
- **Value**: Quick reference for common CORS fixes

---

## Maintenance Workflow

### Creation Flow:
1. Dev implements feature (e.g., S3 upload in Sprint-1/Epic-1/Story-3)
2. Feature passes QA
3. Dev creates `docs/knowledge-base/integrations/s3-storage.md`
4. Includes: Pattern, gotchas, reference story, timestamp
5. Commits with story

### Usage Flow:
1. New story requires S3 (Sprint-3/Epic-2/Story-7)
2. Dev checks `docs/knowledge-base/integrations/`
3. Finds `s3-storage.md`
4. Reads reference implementation from Story-3
5. Uses exact pattern (avoids reinventing)
6. Updates entry if new gotchas discovered

### Update Flow:
1. Dev implementing Sprint-3/Epic-2/Story-7
2. Discovers new S3 gotcha (bucket CORS issue)
3. Adds gotcha to existing `s3-storage.md`
4. Updates timestamp and "Updated By" field

---

## Benefits

✅ **Pattern Reuse**: Established once, reused forever
✅ **Consistency**: Same solutions across codebase
✅ **Faster Development**: No time wasted reinventing patterns
✅ **Knowledge Persistence**: New agents learn from past stories
✅ **Reduced Bugs**: Proven patterns less error-prone
✅ **Onboarding**: New team members read knowledge base first

---

## Integration with BMad Workflow

### Dev Agent Checklist:
```yaml
implementation_phase:
  - "Check docs/knowledge-base/ for existing patterns"
  - "If pattern exists: Follow reference implementation EXACTLY"
  - "If pattern doesn't exist: Implement, then CREATE knowledge base entry"
```

### QA Agent Checklist:
```yaml
review_phase:
  - "If recurring issue found: Suggest knowledge base entry to Dev"
  - "Verify Dev followed existing knowledge base patterns (if applicable)"
```

---

## Getting Started

1. **First Story**: No knowledge base entries yet - implement as needed
2. **After Story Complete**: Create entry for significant patterns
3. **Future Stories**: Check knowledge base BEFORE implementing
4. **Over Time**: Knowledge base grows, development accelerates

**Golden Rule**: If you spent > 30 minutes solving it, document it in knowledge base!

---

**Last Updated**: 2025-10-28
**Version**: 1.0
