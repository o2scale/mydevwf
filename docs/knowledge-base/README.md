# Knowledge Base

**Purpose**: Project-specific knowledge repository for patterns, integrations, and solutions discovered during development.

**Last Updated**: 2025-11-02
**Maintained By**: Dev agents during implementation

---

## Overview

The Knowledge Base (KB) is a living documentation system that captures reusable patterns, integration guides, and solutions as your project evolves. Unlike static documentation, KB entries are created by Dev agents during story implementation, ensuring documentation stays synchronized with actual code.

### Why Knowledge Base?

**Problems It Solves**:
- ✅ **Prevents Re-solving Issues**: Solutions documented once, referenced forever
- ✅ **Maintains Consistency**: Patterns captured ensure consistent implementation
- ✅ **Accelerates Development**: Future stories reference existing patterns
- ✅ **Onboarding Aid**: New developers understand established patterns quickly
- ✅ **Integration Memory**: Third-party integrations documented with gotchas

**Example Workflow**:
1. Dev agent implements S3 file upload (Story 2.3)
2. Dev creates `integrations/s3-uploads.md` with pattern
3. Later story needs file uploads (Story 5.1)
4. Dev loads `integrations/s3-uploads.md`, reuses pattern
5. Consistent implementation, zero duplication

---

## Directory Structure

```
docs/knowledge-base/
├── README.md                    # This file
├── _entry-template.md           # Template for creating new KB entries
│
├── backend-patterns/            # Backend architecture patterns
│   ├── api-error-handling.md   # Example: Standardized error responses
│   ├── middleware-auth.md      # Example: JWT authentication middleware
│   └── database-transactions.md # Example: Transaction patterns
│
├── ui-patterns/                 # Frontend/UI patterns
│   ├── form-validation.md      # Example: React Hook Form patterns
│   ├── data-tables.md          # Example: Sortable/filterable tables
│   └── modal-dialogs.md        # Example: Modal component patterns
│
├── integrations/                # Third-party service integrations
│   ├── supabase-auth.md        # Example: Supabase authentication
│   ├── stripe-payments.md      # Example: Stripe checkout flow
│   └── s3-file-uploads.md      # Example: AWS S3 integration
│
└── common-issues/               # Known issues and solutions
    ├── cors-errors.md          # Example: CORS troubleshooting
    ├── env-variable-loading.md # Example: Environment config issues
    └── build-errors.md         # Example: Common build failures
```

---

## When to Create KB Entries

### Mandatory KB Entry Scenarios

Create KB entries when:

1. **Integration Implementation** (Story includes third-party service)
   - Example: Implementing Stripe, SendGrid, AWS S3
   - Entry captures: Setup, configuration, code pattern, gotchas

2. **Reusable Pattern Established** (Story creates pattern others will use)
   - Example: API pagination, error handling, auth middleware
   - Entry captures: Pattern implementation, use cases, when NOT to use

3. **Non-Obvious Solution** (Story solves complex/tricky issue)
   - Example: Handling race conditions, optimizing queries
   - Entry captures: Problem, solution, why this approach works

4. **Dev Notes Require KB** (Story explicitly requests documentation)
   - Example: Story says "Document this pattern for future stories"
   - Entry captures: As specified in story requirements

---

## How to Create KB Entries

### Step 1: Use the Template

Copy `_entry-template.md` as starting point:

```bash
# Example: Creating S3 integration entry
cp docs/knowledge-base/_entry-template.md docs/knowledge-base/integrations/s3-uploads.md
```

### Step 2: Fill Out Sections

**Required Sections**:
- **Overview**: What problem does this solve? When to use?
- **Pattern**: Code example showing correct implementation
- **Common Mistakes**: What NOT to do (with explanations)
- **Configuration**: Required env vars, dependencies, setup steps
- **When to Use / When NOT to Use**: Clear guidance

### Step 3: Reference in Story

When KB entry created, add reference to story

---

## KB Entry Naming Conventions

**Use kebab-case** (lowercase with hyphens):
- ✅ `api-error-handling.md`
- ✅ `stripe-checkout-flow.md`
- ✅ `react-form-validation.md`

**Be specific but concise**:
- ✅ `supabase-realtime-subscriptions.md`
- ❌ `realtime.md` (too vague)
- ❌ `how-to-implement-supabase-realtime-subscriptions-with-websockets.md` (too long)

**Group by category**:
- Backend patterns → `backend-patterns/`
- UI patterns → `ui-patterns/`
- Third-party services → `integrations/`
- Known issues → `common-issues/`

---

## Using KB Entries During Development

### Dev Agent Workflow

**Before Implementing Story**:
1. Check if KB has relevant entries
2. Load applicable patterns
3. Follow established conventions

### SM Agent Workflow

**When Creating Stories**:
1. Reference KB entries in Dev Notes
2. Flag if new pattern should be documented
3. Include KB requirements in acceptance criteria

---

## KB Best Practices

### DO ✅

- **Be Specific**: Include actual code from your project
- **Show Examples**: Real implementation > theoretical explanation
- **Document Gotchas**: Capture non-obvious issues
- **Update Regularly**: Keep entries current with code
- **Link Related**: Connect to other KB entries

### DON'T ❌

- **Copy Generic Docs**: KB is project-specific, not library docs
- **Over-Document**: Only patterns actually used in project
- **Leave TODOs**: Complete entry before marking story done
- **Skip Template**: Follow `_entry-template.md` structure
- **Duplicate Entries**: Search first, update instead of creating

---

**Knowledge Base Status**: ✅ Active
**Next Step**: Create first KB entry during story implementation
**Template Ready**: `_entry-template.md` available for use
