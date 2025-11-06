# Database Workflow Guide for Dev Agents

## Overview

This guide teaches Dev agents how to use Database MCP servers to implement database schemas EXACTLY as documented by the Architect agent. This ensures zero schema drift and provides full migration tracking.

**Database-Agnostic Guide**: This file contains universal principles applicable to ALL database types. For specific MCP tool usage, see template-specific guides in `docs/architecture/database-workflow-{database}.md`.

---

## Core Principle

**NEVER manually execute SQL/database commands for schema changes.**
**ALWAYS use Database MCP migration tools.**

**Why?**
- Schema changes are tracked in the database
- Migrations are auditable and versioned
- Rollback support is built-in
- Prevents typos and copy-paste errors
- Ensures implemented schema = documented schema (100% match)

---

## Universal Workflow Pattern

This workflow applies regardless of database type (Supabase/PostgreSQL, MongoDB, etc.).

### Step 1: Load Database Schema Documentation

**File to Load**: `docs/architecture/database-schema.md`

This file is created by the Architect agent and contains:
- Complete schema definition for your database
- Tables/Collections with fields and constraints
- Indexes for performance optimization
- Relationships and foreign keys (relational databases)
- Access control policies (if applicable)
- Database-specific features (triggers, functions, etc.)

**Critical**: This is the SINGLE SOURCE OF TRUTH for the database schema.

### Step 2: Load Database-Specific Workflow Guide

**File to Load**: `docs/architecture/database-workflow-{database}.md`

Where `{database}` is:
- `supabase` - For Supabase/PostgreSQL projects
- `mongodb` - For MongoDB projects
- `postgres` - For standalone PostgreSQL projects

This file contains:
- Specific MCP server details
- Exact tool names and parameters
- Database-specific considerations
- Concrete examples with actual tool calls

**How to Identify Database Type**: Check `docs/architecture/tech-stack.md` for database technology used.

### Step 3: Apply Schema via Database MCP

**Use the migration tool** from your database-specific MCP server:

**Generic Pattern**:
```
1. Load complete schema from database-schema.md
2. Call MCP migration tool with schema content
3. Use descriptive migration name (e.g., "001_initial_schema")
4. Verify success response
```

**Important Notes**:
- Copy the ENTIRE contents of `database-schema.md` into the migration
- Do NOT modify the schema (no typos, no "improvements")
- Do NOT split into multiple migrations unless required by dependencies
- Include ALL sections from documentation

### Step 4: Verify Schema Implementation

**Run verifications in this order**:

**4.1: Verify Structure Created**
- Use MCP tool to list tables/collections
- Confirm all documented structures exist
- Check naming matches exactly

**4.2: Verify Features Installed**
- Check database extensions (PostgreSQL)
- Verify indexes created
- Confirm constraints applied

**4.3: Verify Migration Tracking**
- Use MCP tool to list migrations
- Confirm migration was recorded
- Check timestamp for audit trail

**4.4: Spot-Check Implementation**
- Query at least one table/collection structure
- Compare fields/columns with documentation
- Verify data types match exactly

### Step 5: Document Completion

**In Story File**, add verification results to Dev Notes:

```markdown
## Dev Notes

### Database Setup - Verification Complete ✅

**Migration Applied**: 001_initial_schema
**Timestamp**: [timestamp from migration]

**Structures Created**: [count and list]
**Indexes Created**: [count]
**Relationships Created**: [count if applicable]

**Verification**:
- ✅ All structures exist
- ✅ All features installed
- ✅ Migration tracked in database
- ✅ Structure definitions match documentation

**Schema Status**: 100% match with docs/architecture/database-schema.md
```

---

## Schema Modification Workflow

When Architect updates database schema (e.g., adds new tables, fields):

### Step 1: Load Updated Schema Documentation

**File**: Updated `docs/architecture/database-schema.md`

### Step 2: Create New Migration

**NEVER modify existing migrations.** Always create a new migration:

**Generic Pattern**:
```
1. Identify changes from updated documentation
2. Create migration with incremented number (002, 003, etc.)
3. Apply only the CHANGES (not full schema again)
4. Use descriptive name reflecting the change
```

### Step 3: Verify Changes

```
1. List structures (should include new additions)
2. List migrations (should show new migration)
3. Query changed structure to verify updates
```

---

## Common Scenarios (Database-Agnostic)

### Scenario 1: Adding Indexes for Performance

**When**: Architect adds indexes to `database-schema.md`

**Pattern**:
```
1. Create new migration (e.g., "003_add_performance_indexes")
2. Include only the new index definitions
3. Verify indexes exist after migration
```

### Scenario 2: Adding Relationships

**When**: Architect adds foreign keys or references

**Pattern**:
```
1. Ensure referenced structures already exist
2. Create migration with relationship definitions
3. Verify relationships are enforced
```

### Scenario 3: Seeding Initial Data

**When**: Project needs starter data

**Pattern**:
```
1. Use MCP query tool (NOT migration tool)
2. Data seeding is separate from schema migration
3. Document seed data separately
```

**Important**: Data operations use different MCP tools than schema migrations.

---

## Best Practices (Universal)

### ✅ DO

1. **Always use MCP migration tools for schema changes**
2. **Copy schema exactly from `database-schema.md`** (no modifications)
3. **Verify after every migration** using MCP verification tools
4. **Use descriptive migration names** (e.g., "001_initial_schema", "002_add_user_preferences")
5. **Include all sections** when applying initial schema
6. **Document verification results** in story Dev Notes
7. **Use sequential numbering** for migrations (001, 002, 003...)

### ❌ DON'T

1. **Don't manually execute schema commands** (use MCP migration tools)
2. **Don't modify existing migrations** (create new ones for changes)
3. **Don't split initial schema** unnecessarily (apply as single migration unless dependencies require splitting)
4. **Don't skip verification** (always verify with MCP tools)
5. **Don't use migration tools for data operations** (use query tools instead)
6. **Don't assume migrations were applied** (always verify)

---

## Integration with Story Implementation

### Story 1.1: Database Setup (P0 BLOCKER)

**Every backend/fullstack project** should have Database Setup as the first story.

**Story Template Pattern**:
```markdown
# Story 1.1: Database Setup

**Epic**: 1 - Foundation
**Priority**: P0 (BLOCKER - all other stories depend on this)
**Estimate**: 2 SP

## Description
Implement complete database schema as defined in `docs/architecture/database-schema.md` using Database MCP migration tracking.

## Acceptance Criteria
- AC1: All structures created as documented
- AC2: All indexes created for performance
- AC3: All relationships created for data integrity
- AC4: All features installed (extensions, etc.)
- AC5: Migration tracked in database (001_initial_schema)
- AC6: Schema verification confirms 100% match with documentation

## Dev Notes
- Load: docs/architecture/database-schema.md
- Load: .bmad-core/data/database-workflow-guide.md (this file)
- Load: docs/architecture/database-workflow-{database}.md (specific tools)
- Use: Database MCP migration tool
- Verify: Structure listing, feature verification, migration tracking
- Document: Verification results in this section
```

**Dev Workflow**:
1. Load story file
2. Load `docs/architecture/database-schema.md`
3. Load `.bmad-core/data/database-workflow-guide.md` (universal principles)
4. Load `docs/architecture/database-workflow-{database}.md` (specific tools)
5. Execute Step 1-5 from "Universal Workflow Pattern" above
6. Mark story complete with verification results

---

## Required Files to Load

For any database-related story:

**Always Load**:
- `docs/architecture/database-schema.md` (the schema definition)
- `.bmad-core/data/database-workflow-guide.md` (this file - universal principles)

**Template-Specific (Load based on project type)**:
- `docs/architecture/database-workflow-supabase.md` (for Supabase projects)
- `docs/architecture/database-workflow-mongodb.md` (for MongoDB projects)
- `docs/architecture/database-workflow-postgres.md` (for PostgreSQL projects)

**How to Identify**: Check `docs/architecture/tech-stack.md` for database technology.

---

## MCP Tool Categories

While specific tool names vary by database, MCP servers generally provide these categories:

### Migration Tools
**Purpose**: Apply schema changes with tracking

**When to Use**:
- Initial schema setup
- Schema modifications (add/alter/drop structures)
- Index creation
- Constraint management

**Characteristics**:
- Changes are tracked in database
- Creates audit trail
- Supports versioning
- Enables rollback

### Query Tools
**Purpose**: Execute data operations (NOT tracked as migrations)

**When to Use**:
- Seeding data
- Running verification queries
- Data transformations
- Testing queries

**Characteristics**:
- No migration tracking
- Immediate execution
- Used for data, not schema

### Inspection Tools
**Purpose**: Verify database state

**When to Use**:
- List structures (tables/collections)
- Check installed features
- Review migration history
- Verify schema correctness

**Characteristics**:
- Read-only operations
- No side effects
- Used for validation

---

## Error Handling Patterns

### Error: "Migration already exists"

**Cause**: Attempting to apply a migration with a duplicate name

**Fix**: Use incremented migration number

**Pattern**:
```
❌ Wrong (if 001 already exists): name = "001_initial_schema"
✅ Correct: name = "002_schema_update"
```

### Error: "Structure already exists"

**Cause**: Attempting to create a table/collection that already exists

**Fix**: Check existing schema first

**Steps**:
1. Use MCP inspection tool to list structures
2. Use MCP inspection tool to check migrations
3. Either skip if already applied, or create migration that doesn't conflict

### Error: "Required feature not available"

**Cause**: Database doesn't support required feature

**Fix**: Check database-specific capabilities

**Pattern**:
1. Review template-specific workflow guide
2. Check supported features list
3. Use alternative approach or adjust architecture

---

## Quick Reference Workflow

### Database Setup (3-Step Pattern)

1. **Apply Migration**
   - Use MCP migration tool
   - Pass complete schema from `database-schema.md`
   - Use descriptive name: "001_initial_schema"

2. **Verify Implementation**
   - List structures → Check all exist
   - Check features → Verify installed
   - List migrations → Confirm tracking

3. **Document Results**
   - Add verification section to story Dev Notes
   - Confirm 100% match with documentation
   - Include migration name and timestamp

### Schema Update (3-Step Pattern)

1. **Create New Migration**
   - Use incremented number (002, 003, etc.)
   - Include only changes (not full schema)
   - Use descriptive name reflecting change

2. **Verify Changes**
   - Confirm new structures/changes exist
   - Verify migration was tracked
   - Spot-check implementation

3. **Document Updates**
   - Note what changed
   - Reference migration name
   - Update architecture documentation if needed

---

## Testing Integration

### Unit Tests (Vitest)
- Test database utilities and helpers
- Test data transformation logic
- Test validation functions
- **Location**: `docs/qa/unit/`

### E2E Tests (Playwright MCP)
- Test full user flows involving database
- Write scenarios in markdown format
- QA executes via Playwright MCP
- **Location**: `docs/qa/e2e/`

**Important**: Database setup must be complete before any tests can run.

---

## Troubleshooting Guide

### Issue: Database MCP not responding

**Check**:
1. `.mcp.json` has database MCP configured
2. Environment variables set (connection strings, credentials)
3. Claude Code restarted after `.mcp.json` changes
4. Run `/mcp` command to verify MCP status

### Issue: Permission denied errors

**Check**:
1. Database credentials have correct permissions
2. Using admin/service credentials for schema changes
3. Access control policies don't block operations

### Issue: Migration appears successful but structures don't exist

**Debug**:
1. Use MCP inspection tool - was migration recorded?
2. List structures - are they present?
3. Check for syntax errors in migration
4. Review database logs for errors

### Issue: Schema drift detected (implemented ≠ documented)

**Fix**:
1. Identify differences using inspection tools
2. Create corrective migration to align with documentation
3. Update `database-schema.md` if intentional changes were made
4. Apply corrective migration

---

## Summary Checklist

Before marking Database Setup story complete:

- [ ] Loaded `docs/architecture/database-schema.md`
- [ ] Loaded database-specific workflow guide
- [ ] Applied schema via MCP migration tool
- [ ] Verified structures exist
- [ ] Verified features installed
- [ ] Verified migration tracked
- [ ] Spot-checked structure definitions
- [ ] Documented verification results in story Dev Notes
- [ ] Confirmed: Implemented schema = Documented schema (100%)

**Result**: Database is production-ready, fully tracked, and matches architecture documentation exactly.

---

## Next Steps

For database-specific implementation details, tool names, and examples:

- **Supabase projects**: See `docs/architecture/database-workflow-supabase.md`
- **MongoDB projects**: See `docs/architecture/database-workflow-mongodb.md`
- **PostgreSQL projects**: See `docs/architecture/database-workflow-postgres.md`

These guides contain:
- Specific MCP server configuration
- Exact tool names and signatures
- Database-specific best practices
- Concrete implementation examples
- Tool-specific error handling
