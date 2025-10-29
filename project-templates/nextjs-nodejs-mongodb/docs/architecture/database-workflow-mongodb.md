# MongoDB MCP Workflow Guide

## Overview

This guide provides MongoDB-specific implementation details for the generic database workflow described in `.bmad-core/data/database-workflow-guide.md`.

**Prerequisites**: Read the generic database workflow guide first for universal principles and patterns.

---

## MongoDB MCP Server Configuration

### MCP Server Details

**Package**: `mongodb-mcp-server` (official MongoDB MCP server)
**Repository**: https://github.com/mongodb-js/mongodb-mcp-server
**Installation**: Configured in `.mcp.json` (already set up in this template)

**Configuration Example**:
```json
{
  "mcpServers": {
    "MongoDB": {
      "command": "npx",
      "args": [
        "-y",
        "mongodb-mcp-server",
        "--connectionString",
        "env://MONGODB_CONNECTION_STRING"
      ]
    }
  }
}
```

### Environment Variables Required

```env
MONGODB_CONNECTION_STRING=mongodb+srv://username:password@cluster.mongodb.net/myDatabase
```

**For MongoDB Atlas** (optional, for Atlas-specific features):
```env
MDB_MCP_API_CLIENT_ID=your-atlas-client-id
MDB_MCP_API_CLIENT_SECRET=your-atlas-client-secret
```

### Optional Configuration

**Read-Only Mode**:
```bash
--readOnly
# or
export MDB_MCP_READ_ONLY=true
```

**Disable Specific Tools**:
```bash
--disabledTools create update delete
# or
export MDB_MCP_DISABLED_TOOLS="create,update,delete"
```

**Custom Log Path**:
```bash
--logPath=/path/to/logs
# or
export MDB_MCP_LOG_PATH="/path/to/logs"
```

---

## MongoDB MCP Tools Reference

### 1. Collection Schema Tools

**Purpose**: Define and manage collection schemas (similar to migrations in SQL databases)

**Tool Category**: `collectionSchema`

**When to Use**:
- Initial database schema setup
- Define document structure and validation rules
- Set up indexes for performance
- Establish data integrity rules

**MongoDB Schema Pattern**:
```javascript
{
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["field1", "field2"],
      properties: {
        field1: { bsonType: "string" },
        field2: { bsonType: "number" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
}
```

---

### 2. Create Operations

**Purpose**: Insert documents into collections

**Tool Category**: `create`

**When to Use**:
- Seeding initial data
- Creating test data
- Inserting new documents

**Example**:
```javascript
{
  collection: "users",
  document: {
    name: "John Doe",
    email: "john@example.com",
    createdAt: new Date()
  }
}
```

**Bulk Insert**:
```javascript
{
  collection: "users",
  documents: [
    { name: "User 1", email: "user1@example.com" },
    { name: "User 2", email: "user2@example.com" }
  ]
}
```

---

### 3. Read Operations

**Purpose**: Query documents from collections

**Tool Category**: `read`

**When to Use**:
- Verification queries
- Data inspection
- Testing queries

**Example**:
```javascript
{
  collection: "users",
  filter: { email: "john@example.com" },
  options: { limit: 10, sort: { createdAt: -1 } }
}
```

**Find All**:
```javascript
{
  collection: "users",
  filter: {}
}
```

**Aggregation Pipeline**:
```javascript
{
  collection: "orders",
  pipeline: [
    { $match: { status: "completed" } },
    { $group: { _id: "$userId", total: { $sum: "$amount" } } },
    { $sort: { total: -1 } }
  ]
}
```

---

### 4. Update Operations

**Purpose**: Modify existing documents

**Tool Category**: `update`

**When to Use**:
- Data corrections
- Schema migrations (adding fields)
- Bulk updates

**Example**:
```javascript
{
  collection: "users",
  filter: { _id: ObjectId("...") },
  update: {
    $set: { lastLogin: new Date() }
  }
}
```

**Update Many**:
```javascript
{
  collection: "users",
  filter: { status: "inactive" },
  update: {
    $set: { archived: true }
  },
  options: { multi: true }
}
```

---

### 5. Delete Operations

**Purpose**: Remove documents from collections

**Tool Category**: `delete`

**When to Use**:
- Data cleanup
- Test data removal
- Removing obsolete documents

**Example**:
```javascript
{
  collection: "sessions",
  filter: { expiresAt: { $lt: new Date() } }
}
```

**Delete One**:
```javascript
{
  collection: "users",
  filter: { _id: ObjectId("...") },
  options: { single: true }
}
```

---

### 6. Atlas Operations

**Purpose**: MongoDB Atlas-specific operations (cluster management, backups, monitoring)

**Tool Category**: `atlas`

**Requirements**: Atlas API credentials configured

**When to Use**:
- Creating/managing Atlas clusters
- Configuring backups
- Monitoring cluster health
- Managing users and access

**Note**: These are infrastructure operations, typically not used during regular development.

---

## MongoDB-Specific Workflow

### Initial Database Setup

**Step 1: Load Schema Documentation**
```
File: docs/architecture/database-schema.md
```

MongoDB schema documentation typically includes:
- Collection names
- Document structure with types
- Validation rules (JSON Schema)
- Indexes for performance
- Unique constraints

**Step 2: Create Collections with Validation**

Unlike SQL migrations, MongoDB collections are created on first insert, but we establish schema validation:

```javascript
// For each collection in database-schema.md:

// 1. Create collection with validation
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["email", "name", "createdAt"],
      properties: {
        email: {
          bsonType: "string",
          pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        },
        name: { bsonType: "string" },
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// 2. Create indexes
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ createdAt: -1 });
```

**Step 3: Verify Implementation**

```javascript
// 3.1: List all collections
show collections
// or via MCP read operation
{ collection: "system.collections", filter: {} }

// 3.2: Check collection validation rules
db.getCollectionInfos({ name: "users" })

// 3.3: Check indexes
db.users.getIndexes()

// 3.4: Test validation (insert invalid document, should fail)
db.users.insertOne({ name: "Test" })  // Should fail: missing required 'email'
```

**Step 4: Document Completion**

**In Story File**, add verification results:

```markdown
## Dev Notes

### Database Setup - Verification Complete ✅

**Database**: myDatabase
**Collections Created**: 5 total
- users
- documents
- translations
- jobs
- audit_log

**Validation Rules**: Applied to all collections
**Indexes Created**: 12 total
**Unique Constraints**: 3 (email on users, hash on documents, jobId on translations)

**Verification**:
- ✅ All collections exist with validation rules
- ✅ All indexes created
- ✅ Validation rules tested and working
- ✅ Document structure matches documentation

**Schema Status**: 100% match with docs/architecture/database-schema.md
```

---

## MongoDB Schema Documentation Format

### Example: database-schema.md for MongoDB

```markdown
# Database Schema - MongoDB

## Collections

### users

**Purpose**: Store user account information

**Document Structure**:
```javascript
{
  _id: ObjectId,           // Auto-generated
  email: String,           // Required, unique, email format
  name: String,            // Required
  role: String,            // Enum: ["user", "admin", "moderator"]
  avatar: String,          // Optional, URL
  settings: Object,        // Optional, flexible structure
  createdAt: Date,         // Required, auto-set
  updatedAt: Date          // Required, auto-updated
}
```

**Validation Rules**:
```javascript
{
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["email", "name", "role", "createdAt"],
      properties: {
        email: {
          bsonType: "string",
          pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        },
        name: { bsonType: "string", minLength: 2 },
        role: { enum: ["user", "admin", "moderator"] },
        avatar: { bsonType: "string" },
        settings: { bsonType: "object" },
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" }
      }
    }
  }
}
```

**Indexes**:
- `{ email: 1 }` - Unique index
- `{ createdAt: -1 }` - Descending index for recent users
- `{ role: 1, createdAt: -1 }` - Compound index for role-based queries

---

### documents

**Purpose**: Store document metadata

**Document Structure**:
```javascript
{
  _id: ObjectId,
  fileName: String,        // Required
  originalName: String,    // Required
  fileSize: Number,        // Required, in bytes
  mimeType: String,        // Required
  hash: String,            // Required, unique (SHA-256)
  status: String,          // Enum: ["uploaded", "processing", "completed", "failed"]
  userId: ObjectId,        // Required, reference to users._id
  tenantId: ObjectId,      // Required for multi-tenant
  metadata: Object,        // Flexible structure
  createdAt: Date,
  updatedAt: Date
}
```

**Validation Rules**:
```javascript
{
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["fileName", "originalName", "fileSize", "mimeType", "hash", "userId", "tenantId", "status"],
      properties: {
        fileName: { bsonType: "string" },
        originalName: { bsonType: "string" },
        fileSize: { bsonType: "number", minimum: 0 },
        mimeType: { bsonType: "string" },
        hash: { bsonType: "string", minLength: 64, maxLength: 64 },
        status: { enum: ["uploaded", "processing", "completed", "failed"] },
        userId: { bsonType: "objectId" },
        tenantId: { bsonType: "objectId" },
        metadata: { bsonType: "object" },
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" }
      }
    }
  }
}
```

**Indexes**:
- `{ hash: 1 }` - Unique index for duplicate detection
- `{ userId: 1, createdAt: -1 }` - User's documents
- `{ tenantId: 1, status: 1 }` - Tenant queries
- `{ status: 1, createdAt: 1 }` - Processing queue

---

## (Repeat pattern for all collections)
```

---

## Common MongoDB Scenarios

### Scenario 1: Multi-Tenant Setup

**Pattern**:
```javascript
// Add tenantId to all collections
db.users.updateMany(
  {},
  { $set: { tenantId: ObjectId("default-tenant-id") } }
);

// Create indexes for tenant isolation
db.users.createIndex({ tenantId: 1 });
db.documents.createIndex({ tenantId: 1, createdAt: -1 });

// Update validation rules to require tenantId
db.runCommand({
  collMod: "users",
  validator: {
    $jsonSchema: {
      required: ["email", "name", "tenantId"],
      // ... rest of schema
    }
  }
});
```

### Scenario 2: Full-Text Search

**Pattern**:
```javascript
// Create text index on searchable fields
db.documents.createIndex({
  fileName: "text",
  originalName: "text",
  "metadata.description": "text"
});

// Search documents
db.documents.find({
  $text: { $search: "invoice 2024" }
});

// Search with score
db.documents.find(
  { $text: { $search: "important document" } },
  { score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } });
```

### Scenario 3: Aggregation Pipeline for Analytics

**Pattern**:
```javascript
// Documents by user with totals
db.documents.aggregate([
  {
    $match: {
      createdAt: { $gte: new Date("2024-01-01") }
    }
  },
  {
    $group: {
      _id: "$userId",
      totalDocuments: { $sum: 1 },
      totalSize: { $sum: "$fileSize" },
      statuses: { $push: "$status" }
    }
  },
  {
    $lookup: {
      from: "users",
      localField: "_id",
      foreignField: "_id",
      as: "userInfo"
    }
  },
  {
    $sort: { totalDocuments: -1 }
  }
]);
```

### Scenario 4: Schema Migration (Add New Field)

**Pattern**:
```javascript
// 1. Update validation rules to allow new field
db.runCommand({
  collMod: "users",
  validator: {
    $jsonSchema: {
      required: ["email", "name", "createdAt"],
      properties: {
        // ... existing fields ...
        preferences: {
          bsonType: "object",
          properties: {
            theme: { enum: ["light", "dark"] },
            notifications: { bsonType: "bool" }
          }
        }
      }
    }
  }
});

// 2. Set default values for existing documents
db.users.updateMany(
  { preferences: { $exists: false } },
  { $set: { preferences: { theme: "light", notifications: true } } }
);

// 3. Verify
db.users.find({ preferences: { $exists: false } }).count()  // Should be 0
```

---

## Error Handling (MongoDB-Specific)

### Error: "Document failed validation"

**Cause**: Document doesn't match schema validation rules

**Fix**:
```javascript
// Check validation rules
db.getCollectionInfos({ name: "users" })

// Test specific document
db.runCommand({
  insert: "users",
  documents: [{ /* test document */ }]
})
```

### Error: "E11000 duplicate key error"

**Cause**: Attempting to insert document that violates unique index

**Fix**:
```javascript
// Check indexes
db.collection.getIndexes()

// Find conflicting document
db.collection.findOne({ uniqueField: "conflicting-value" })

// Use upsert if intentional
db.collection.updateOne(
  { uniqueField: "value" },
  { $set: { /* updates */ } },
  { upsert: true }
)
```

### Error: "Connection string is invalid"

**Cause**: Malformed MONGODB_CONNECTION_STRING

**Fix**:
```bash
# Correct format for MongoDB Atlas:
mongodb+srv://username:password@cluster.mongodb.net/database?retryWrites=true&w=majority

# Correct format for local MongoDB:
mongodb://localhost:27017/database

# Ensure password is URL-encoded if it contains special characters
```

### Error: "Authentication failed"

**Cause**: Invalid credentials in connection string

**Fix**:
1. Verify username/password in MongoDB Atlas dashboard
2. Check IP whitelist (Atlas requires IP whitelisting)
3. Ensure database user has correct permissions
4. URL-encode password special characters

---

## Verification Queries (MongoDB-Specific)

### List All Collections
```javascript
show collections
// or
db.getCollectionNames()
```

### Check Collection Validation Rules
```javascript
db.getCollectionInfos({ name: "users" })
```

### Check All Indexes
```javascript
db.users.getIndexes()
```

### Count Documents in Collection
```javascript
db.users.countDocuments()
db.users.countDocuments({ status: "active" })
```

### Get Collection Stats
```javascript
db.users.stats()
// Shows: count, size, indexes, avgObjSize, storageSize
```

### Check Database Size
```javascript
db.stats()
```

### Validate Collection Integrity
```javascript
db.users.validate()
// Checks for corruption, index consistency
```

---

## Best Practices (MongoDB-Specific)

### ✅ DO

1. **Use schema validation** on all collections (even though MongoDB is schemaless)
2. **Index frequently queried fields** (especially foreign keys and sort fields)
3. **Use ObjectId for _id** (default, don't override unless necessary)
4. **Plan for multi-tenancy** early (add tenantId from start)
5. **Use compound indexes** for common query patterns
6. **Validate before deploying** (test validation rules with sample data)
7. **Use aggregation pipelines** for complex queries (avoid client-side processing)
8. **Index text fields** if full-text search is needed
9. **Use updateMany carefully** (test with countDocuments first)
10. **Enable authentication** even in development

### ❌ DON'T

1. **Don't skip validation rules** - MongoDB allows anything without them
2. **Don't use embedded documents** for large arrays (16MB document limit)
3. **Don't forget indexes** on foreign keys (major performance issue)
4. **Don't store files** in MongoDB (use GridFS for files >16MB or external storage)
5. **Don't use $where** operator (performance issue, security risk)
6. **Don't create too many indexes** (slows down writes)
7. **Don't use string _id** (ObjectId is optimized for performance)
8. **Don't store sensitive data** without encryption
9. **Don't forget to paginate** large result sets (use limit + skip or cursor-based)
10. **Don't use auto-increment _id** (doesn't scale in distributed systems)

---

## MongoDB MCP Tool Usage Summary

### Schema Operations
```javascript
// Create collection with validation
mcp_tool: collectionSchema
action: create
collection: "users"
validator: { $jsonSchema: { ... } }

// Update validation rules
mcp_tool: collectionSchema
action: update
collection: "users"
validator: { $jsonSchema: { ... } }
```

### Data Operations
```javascript
// Insert
mcp_tool: create
collection: "users"
document: { ... }

// Query
mcp_tool: read
collection: "users"
filter: { ... }

// Update
mcp_tool: update
collection: "users"
filter: { ... }
update: { $set: { ... } }

// Delete
mcp_tool: delete
collection: "users"
filter: { ... }
```

---

## Quick Reference

### Required Environment Variables
```env
MONGODB_CONNECTION_STRING=mongodb+srv://username:password@cluster.mongodb.net/myDatabase
```

### Schema Setup Workflow
1. Create collection with validation rules
2. Create indexes
3. Test validation with invalid document
4. Verify with `db.getCollectionInfos()`
5. Document in story Dev Notes

### Verification Checklist
- [ ] All collections created
- [ ] Validation rules applied and tested
- [ ] All indexes created
- [ ] Unique constraints tested
- [ ] Sample queries executed successfully
- [ ] Collection stats reviewed

### Common Commands
```javascript
// Collections
show collections
db.getCollectionNames()

// Validation
db.getCollectionInfos({ name: "collection" })

// Indexes
db.collection.getIndexes()

// Stats
db.collection.stats()
db.stats()
```

---

## Integration with Testing

### Unit Tests (Vitest)
- Test data transformation logic
- Test validation helpers
- Test query builders
- **Location**: `docs/qa/unit/`

### E2E Tests (Playwright MCP)
- Test full user flows involving database
- Write scenarios in markdown format
- QA executes via Playwright MCP
- **Location**: `docs/qa/e2e/`

**Important**: Database setup must be complete before any tests can run.

---

## Troubleshooting Checklist

- [ ] `.mcp.json` has MongoDB MCP configured
- [ ] `MONGODB_CONNECTION_STRING` set in environment
- [ ] Connection string format correct (mongodb:// or mongodb+srv://)
- [ ] Database user has read/write permissions
- [ ] IP address whitelisted (if using Atlas)
- [ ] Claude Code restarted after environment changes
- [ ] `/mcp` command shows MongoDB MCP active
- [ ] Database exists (created automatically on first write)

---

## Resources

**Official Docs**: https://www.mongodb.com/docs
**MongoDB MCP Server**: https://github.com/mongodb-js/mongodb-mcp-server
**MongoDB Atlas**: https://www.mongodb.com/cloud/atlas
**MongoDB University**: https://university.mongodb.com (free courses)

For generic workflow principles, see: `.bmad-core/data/database-workflow-guide.md`
