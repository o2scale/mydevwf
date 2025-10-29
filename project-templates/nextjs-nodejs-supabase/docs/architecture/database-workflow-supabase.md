# Supabase MCP Workflow Guide

## Overview

This guide provides Supabase-specific implementation details for the generic database workflow described in `.bmad-core/data/database-workflow-guide.md`.

**Prerequisites**: Read the generic database workflow guide first for universal principles and patterns.

---

## Supabase MCP Server Configuration

### MCP Server Details

**Package**: `@modelcontextprotocol/server-supabase`
**Installation**: Configured in `.mcp.json` (already set up in this template)

**Configuration Example**:
```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-supabase",
        "env://SUPABASE_URL",
        "env://SUPABASE_ACCESS_TOKEN"
      ]
    }
  }
}
```

### Environment Variables Required

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ACCESS_TOKEN=your-service-role-key
```

**Important**: Use service role key (NOT anon key) for schema operations.

### Optional Configuration Flags

- `?read_only=true` - Prevent data modifications (useful for read-only sessions)
- `?project_ref=<ref>` - Scope to specific Supabase project
- `?features=database,docs` - Enable specific tool groups

---

## Supabase MCP Tools Reference

### 1. `apply_migration`
**Purpose**: Apply DDL operations (CREATE, ALTER, DROP) with migration tracking

**Tool Name**: `mcp__supabase__apply_migration` (when called via MCP)

**Parameters**:
```typescript
{
  name: string,    // Migration name (e.g., "001_initial_schema")
  sql: string      // Complete SQL to execute
}
```

**When to Use**:
- Initial database schema setup
- Schema modifications (add tables, columns, indexes)
- Foreign key creation
- Extension installation
- Trigger creation
- RLS policy creation

**Example**:
```typescript
apply_migration({
  name: "001_initial_schema",
  sql: `
    -- Extensions
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pgmq";

    -- Tables
    CREATE TABLE users (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      email TEXT UNIQUE NOT NULL,
      created_at TIMESTAMPTZ DEFAULT NOW()
    );

    -- Indexes
    CREATE INDEX idx_users_email ON users(email);

    -- RLS
    ALTER TABLE users ENABLE ROW LEVEL SECURITY;
    CREATE POLICY "Users can view own data"
      ON users FOR SELECT
      USING (auth.uid() = id);
  `
})
```

**Response Format**:
```
✅ Migration applied successfully: 001_initial_schema
Execution time: 245ms
```

---

### 2. `execute_sql`
**Purpose**: Run SQL queries (SELECT, INSERT, UPDATE, DELETE) - NOT tracked as migrations

**Tool Name**: `mcp__supabase__execute_sql`

**Parameters**:
```typescript
{
  sql: string     // SQL query to execute
}
```

**When to Use**:
- Seeding initial data
- Running verification queries
- Data transformations
- Testing queries

**Example**:
```typescript
execute_sql({
  sql: `
    INSERT INTO users (email) VALUES
      ('admin@example.com'),
      ('test@example.com');
  `
})
```

**Response Format**:
```json
{
  "rows": [...],
  "rowCount": 2,
  "command": "INSERT"
}
```

---

### 3. `list_tables`
**Purpose**: List all tables in the database

**Tool Name**: `mcp__supabase__list_tables`

**Parameters**: None

**When to Use**:
- Verify schema was created correctly
- Check table existence before operations
- Post-migration validation

**Example**:
```typescript
list_tables()
```

**Response Format**:
```json
{
  "tables": [
    "users",
    "documents",
    "pages",
    "translation_jobs",
    "translations"
  ]
}
```

---

### 4. `list_extensions`
**Purpose**: Show installed PostgreSQL extensions

**Tool Name**: `mcp__supabase__list_extensions`

**Parameters**: None

**When to Use**:
- Verify required extensions are installed
- Check extension versions
- Troubleshoot missing extension errors

**Example**:
```typescript
list_extensions()
```

**Response Format**:
```json
{
  "extensions": [
    {
      "name": "uuid-ossp",
      "version": "1.1",
      "schema": "public"
    },
    {
      "name": "pgmq",
      "version": "1.0",
      "schema": "pgmq"
    }
  ]
}
```

---

### 5. `list_migrations`
**Purpose**: Show migration history with timestamps

**Tool Name**: `mcp__supabase__list_migrations`

**Parameters**: None

**When to Use**:
- Audit trail of schema changes
- Verify migration was applied
- Check migration order
- Troubleshooting

**Example**:
```typescript
list_migrations()
```

**Response Format**:
```json
{
  "migrations": [
    {
      "name": "001_initial_schema",
      "applied_at": "2025-10-28T14:32:15.234Z"
    },
    {
      "name": "002_add_user_preferences",
      "applied_at": "2025-10-28T16:45:22.156Z"
    }
  ]
}
```

---

## Supabase-Specific Workflow

### Initial Database Setup

**Step 1: Load Schema Documentation**
```
File: docs/architecture/database-schema.md
```

**Step 2: Apply Complete Schema**
```typescript
apply_migration({
  name: "001_initial_schema",
  sql: [COMPLETE CONTENTS OF database-schema.md]
})
```

**Step 3: Verify Implementation**
```typescript
// 3.1: Check tables
list_tables()
// Expected: All tables from documentation

// 3.2: Check extensions
list_extensions()
// Expected: uuid-ossp, pgmq, etc.

// 3.3: Check migration tracking
list_migrations()
// Expected: [{ name: "001_initial_schema", applied_at: "..." }]

// 3.4: Spot-check table structure
execute_sql({
  sql: `
    SELECT column_name, data_type, is_nullable, column_default
    FROM information_schema.columns
    WHERE table_name = 'documents'
    ORDER BY ordinal_position;
  `
})
// Expected: Column definitions match documentation
```

**Step 4: Verify RLS Policies (Supabase-Specific)**
```typescript
execute_sql({
  sql: `
    SELECT schemaname, tablename, policyname, permissive, roles, cmd
    FROM pg_policies
    WHERE schemaname = 'public'
    ORDER BY tablename, policyname;
  `
})
```

---

## Supabase-Specific Features

### Row-Level Security (RLS)

**Always include in schema**:
```sql
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

CREATE POLICY "policy_name"
  ON table_name
  FOR SELECT
  USING (auth.uid() = user_id);
```

**Verification**:
```typescript
execute_sql({
  sql: "SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public'"
})
// Check rowsecurity = true for all tables
```

### Realtime

**Enable for specific tables**:
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE table_name;
```

**Verification**:
```typescript
execute_sql({
  sql: "SELECT tablename FROM pg_publication_tables WHERE pubname = 'supabase_realtime'"
})
```

### PostgreSQL Extensions

**Commonly used in Supabase**:
- `uuid-ossp` - UUID generation
- `pgcrypto` - Cryptographic functions
- `pg_trgm` - Trigram matching for fuzzy search
- `postgis` - Geospatial data
- `pg_stat_statements` - Query performance tracking
- `pgmq` - Message queue

**Installation Pattern**:
```sql
CREATE EXTENSION IF NOT EXISTS "extension_name";
```

**Verification**:
```typescript
list_extensions()
// Check extension appears in list
```

---

## Common Supabase Scenarios

### Scenario 1: Multi-Tenant Setup

**Pattern**:
```typescript
apply_migration({
  name: "002_enable_rls_multi_tenant",
  sql: `
    -- Add tenant_id to all tables
    ALTER TABLE documents ADD COLUMN tenant_id UUID NOT NULL;
    ALTER TABLE pages ADD COLUMN tenant_id UUID NOT NULL;

    -- Create indexes
    CREATE INDEX idx_documents_tenant_id ON documents(tenant_id);
    CREATE INDEX idx_pages_tenant_id ON pages(tenant_id);

    -- RLS policies
    ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
    CREATE POLICY "Users can only access own tenant data"
      ON documents FOR ALL
      USING (tenant_id = current_setting('app.tenant_id')::UUID);
  `
})
```

### Scenario 2: Full-Text Search

**Pattern**:
```typescript
apply_migration({
  name: "003_add_full_text_search",
  sql: `
    -- Install extension
    CREATE EXTENSION IF NOT EXISTS "pg_trgm";

    -- Add tsvector column
    ALTER TABLE documents
    ADD COLUMN search_vector tsvector
    GENERATED ALWAYS AS (
      to_tsvector('english', coalesce(file_name, '') || ' ' || coalesce(original_name, ''))
    ) STORED;

    -- Create GIN index
    CREATE INDEX idx_documents_search ON documents USING GIN(search_vector);
  `
})
```

### Scenario 3: Audit Trail with Triggers

**Pattern**:
```typescript
apply_migration({
  name: "004_add_audit_triggers",
  sql: `
    -- Create audit log table
    CREATE TABLE audit_log (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      table_name TEXT NOT NULL,
      record_id UUID NOT NULL,
      action TEXT NOT NULL,
      old_data JSONB,
      new_data JSONB,
      user_id UUID,
      created_at TIMESTAMPTZ DEFAULT NOW()
    );

    -- Create trigger function
    CREATE OR REPLACE FUNCTION audit_trigger_function()
    RETURNS TRIGGER AS $$
    BEGIN
      INSERT INTO audit_log (table_name, record_id, action, old_data, new_data, user_id)
      VALUES (
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        TG_OP,
        CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) ELSE NULL END,
        auth.uid()
      );
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql SECURITY DEFINER;

    -- Attach to tables
    CREATE TRIGGER audit_documents
      AFTER INSERT OR UPDATE OR DELETE ON documents
      FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
  `
})
```

---

## Error Handling (Supabase-Specific)

### Error: "permission denied for schema public"

**Cause**: Access token doesn't have required permissions

**Fix**:
1. Verify using service role key (not anon key)
2. Check Supabase dashboard → Settings → API → Service role key
3. Update `.env` with correct key
4. Restart Claude Code to reload environment variables

### Error: "extension \"X\" does not exist"

**Cause**: Extension not available in Supabase or not enabled

**Supported Extensions**:
Check Supabase docs for current list. Common ones:
- ✅ uuid-ossp, pgcrypto, pg_trgm, postgis, timescaledb
- ❌ Custom extensions (not supported)

**Fix**: Use alternative approach or contact Supabase support for extension requests

### Error: "relation \"X\" already exists"

**Cause**: Table was created in previous migration

**Fix**:
```typescript
// Option 1: Check first
list_tables()  // See what exists

// Option 2: Use IF NOT EXISTS
apply_migration({
  name: "005_safe_migration",
  sql: "CREATE TABLE IF NOT EXISTS new_table (...)"
})
```

### Error: "infinite recursion detected in policy"

**Cause**: RLS policy references itself or creates circular dependency

**Fix**: Review RLS policies for circular references
```typescript
execute_sql({
  sql: "SELECT * FROM pg_policies WHERE schemaname = 'public'"
})
```

---

## Verification Queries (Supabase-Specific)

### Check All Table Structures
```sql
SELECT
  table_name,
  column_name,
  data_type,
  character_maximum_length,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;
```

### Check All Indexes
```sql
SELECT
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```

### Check All Foreign Keys
```sql
SELECT
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name,
  tc.constraint_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
ORDER BY tc.table_name;
```

### Check All RLS Policies
```sql
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

### Check Table Row Counts
```sql
SELECT
  schemaname,
  relname AS tablename,
  n_tup_ins AS inserts,
  n_tup_upd AS updates,
  n_tup_del AS deletes,
  n_live_tup AS live_rows
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY relname;
```

---

## Best Practices (Supabase-Specific)

### ✅ DO

1. **Always enable RLS** on user-facing tables
2. **Use uuid-ossp** for primary keys (better than serial)
3. **Add tenant_id early** if building multi-tenant app
4. **Create indexes** on foreign keys and frequently queried columns
5. **Use timestamptz** (not timestamp) for timezone awareness
6. **Test RLS policies** thoroughly before production
7. **Use service role key** for migrations (never anon key)
8. **Enable realtime** only on tables that need it (performance)

### ❌ DON'T

1. **Don't use anon key** for schema operations
2. **Don't forget RLS** - tables without RLS are public by default
3. **Don't store sensitive data** without encryption
4. **Don't create too many realtime subscriptions** (performance impact)
5. **Don't use serial/bigserial** - use UUID instead for better distribution
6. **Don't skip indexes** on foreign keys (major performance issue)
7. **Don't create RLS policies** that allow unintended access

---

## Integration with Supabase Dashboard

### Viewing Applied Migrations

**Dashboard**: Database → Migrations
Shows all migrations with timestamps and SQL

### Manual SQL Editor

**Dashboard**: SQL Editor
Can run queries manually (but prefer MCP for tracking)

### Table Editor

**Dashboard**: Table Editor
Visual interface to view/edit data (not schema)

### Realtime Inspector

**Dashboard**: Realtime → Inspector
Monitor realtime subscriptions and events

---

## Quick Reference

### Tool Selection
- **Schema changes** → `apply_migration`
- **Data operations** → `execute_sql`
- **List tables** → `list_tables`
- **Check extensions** → `list_extensions`
- **Migration history** → `list_migrations`

### Required Environment Variables
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ACCESS_TOKEN=your-service-role-key
```

### Migration Workflow
1. `apply_migration({ name, sql })`
2. `list_tables()` → verify
3. `list_extensions()` → verify
4. `list_migrations()` → verify
5. Document in story Dev Notes

### RLS Verification
```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';
```

All user-facing tables should have `rowsecurity = true`.

---

## Example: Complete Supabase Database Setup

```typescript
// Step 1: Load schema
const schemaSQL = `[CONTENTS FROM docs/architecture/database-schema.md]`;

// Step 2: Apply migration
apply_migration({
  name: "001_initial_schema",
  sql: schemaSQL
});

// Step 3: Verify tables
list_tables();
// Expected: ['documents', 'pages', 'translation_jobs', 'translations', 'processing_queue']

// Step 4: Verify extensions
list_extensions();
// Expected: [{ name: 'uuid-ossp', version: '1.1' }, { name: 'pgmq', version: '1.0' }]

// Step 5: Verify migrations
list_migrations();
// Expected: [{ name: '001_initial_schema', applied_at: '2025-10-28T14:32:15Z' }]

// Step 6: Verify RLS enabled
execute_sql({
  sql: "SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public'"
});
// Expected: All tables show rowsecurity = true

// Step 7: Spot-check structure
execute_sql({
  sql: `
    SELECT column_name, data_type, is_nullable
    FROM information_schema.columns
    WHERE table_name = 'documents'
    ORDER BY ordinal_position
  `
});
// Compare with database-schema.md

// Step 8: Document in story
// ✅ Migration applied: 001_initial_schema
// ✅ 5 tables created
// ✅ 2 extensions installed
// ✅ 15 indexes created
// ✅ 8 foreign keys created
// ✅ RLS enabled on all tables
// ✅ 100% match with documentation
```

---

## Troubleshooting Checklist

- [ ] `.mcp.json` has Supabase MCP configured
- [ ] `SUPABASE_URL` set in environment
- [ ] `SUPABASE_ACCESS_TOKEN` set (service role, not anon)
- [ ] Claude Code restarted after environment changes
- [ ] `/mcp` command shows Supabase MCP active
- [ ] Database exists in Supabase dashboard
- [ ] Network access allowed (if using local development)

---

## Resources

**Official Docs**: https://supabase.com/docs
**MCP Server**: https://github.com/modelcontextprotocol/servers/tree/main/src/supabase
**Supabase CLI**: https://supabase.com/docs/guides/cli

For generic workflow principles, see: `.bmad-core/data/database-workflow-guide.md`
