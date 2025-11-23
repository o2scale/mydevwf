# Authentication Test Credentials

**Purpose**: Test user credentials for authentication testing

**Location**: `test-data/auth/`

**Last Updated**: [YYYY-MM-DD] (update when credentials change)

---

## Available Credentials

### `creds.txt`

**Format**: Key-value pairs (one per line)

```
# Standard test user
username: test@example.com
password: testpassword123
user_role: user

# Admin test account
admin_username: admin@example.com
admin_password: adminpass456
admin_role: admin

# Additional test accounts (if needed)
# guest_username: guest@example.com
# guest_password: guestpass789
# guest_role: guest
```

**CRITICAL**: These credentials MUST match users created by seed scripts in database

---

## Use Cases

| Credential | Use Case | Test Scenarios |
|------------|----------|----------------|
| **test@example.com** | Standard user login, basic features | Login, dashboard access, user-level operations |
| **admin@example.com** | Admin role testing, privileged operations | Admin panel, user management, system settings |

---

## For Developers: Creating Test Users

### Seed Script Requirements

When implementing authentication features, YOU (Dev) are responsible for:

1. **Create seed script** that matches credentials in this file EXACTLY
2. **Test user accounts** must exist in development database before QA testing
3. **Update creds.txt** if you change test credentials (keep in sync with seed script)

### Seed Script Location

Save seed scripts to:
```
database/seeds/
└── auth_test_users.sql          # SQL seed script
OR
backend/scripts/
└── seed_test_users.py           # Python seed script
```

### Example Seed Script (SQL - Supabase)

```sql
-- database/seeds/auth_test_users.sql
-- Create test users for authentication testing
-- Credentials match test-data/auth/creds.txt

-- Standard test user
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, role)
VALUES (
  'test-user-uuid',
  'test@example.com',
  crypt('testpassword123', gen_salt('bf')),  -- Bcrypt hash
  NOW(),
  'user'
) ON CONFLICT (email) DO NOTHING;

-- Admin test user
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, role)
VALUES (
  'admin-user-uuid',
  'admin@example.com',
  crypt('adminpass456', gen_salt('bf')),
  NOW(),
  'admin'
) ON CONFLICT (email) DO NOTHING;
```

### Example Seed Script (Python - FastAPI)

```python
# backend/scripts/seed_test_users.py
import asyncio
from api.services.auth import create_user

async def seed_test_users():
    """Create test users matching test-data/auth/creds.txt"""

    # Standard test user
    await create_user(
        email="test@example.com",
        password="testpassword123",
        role="user"
    )

    # Admin test user
    await create_user(
        email="admin@example.com",
        password="adminpass456",
        role="admin"
    )

    print("✅ Test users seeded successfully")

if __name__ == "__main__":
    asyncio.run(seed_test_users())
```

### Running Seed Scripts

**SQL Seed**:
```bash
psql $DATABASE_URL -f database/seeds/auth_test_users.sql
```

**Python Seed**:
```bash
python backend/scripts/seed_test_users.py
```

---

## For QA: Using Test Credentials

### In E2E Test Scenarios

**ALWAYS reference credentials from this file**:

```markdown
### TC1.1: Login with valid credentials

**Test Data**: `test-data/auth/creds.txt` (test user account)

**Steps**:
1. Navigate to /login
2. Read credentials from test-data/auth/creds.txt
3. Fill email: test@example.com (from creds.txt)
4. Fill password: testpassword123 (from creds.txt)
5. Click "Login" button
6. Verify redirect to /dashboard
```

### Playwright MCP Execution

```javascript
// QA reads creds.txt first, then uses credentials
browser_navigate("http://localhost:3000/login")
browser_fill("input[name='email']", "test@example.com")  // from creds.txt
browser_fill("input[name='password']", "testpassword123")  // from creds.txt
browser_click("button[type='submit']")
```

---

## Security Best Practices

### ✅ DO

- Use **dummy/fake credentials** (test@example.com, password123, etc.)
- Commit creds.txt to git (ensures test consistency across team)
- Create test accounts in **development database only**
- Keep credentials simple and memorable for testing

### ❌ DO NOT

- **NEVER use real user credentials** for testing
- **NEVER commit production passwords** to git
- **NEVER use these credentials in production** environment
- **NEVER share real user accounts** between team members

---

## Maintenance

### When to Update

- New user roles added (moderator, guest, etc.)
- Authentication system changes (OAuth, SSO)
- Multi-tenant testing needs (different tenants)

### Update Workflow

1. Update `creds.txt` with new credentials
2. Update seed script to create new test users
3. Run seed script to populate database
4. Update this README with new credential details
5. Update E2E test scenarios to use new credentials

---

## Troubleshooting

### QA: "Test login fails - invalid credentials"

**Possible causes**:
1. Dev hasn't run seed script yet → Check with Dev
2. Development database reset → Re-run seed script
3. Credentials mismatch → Verify creds.txt matches seed script

**Resolution**: Dev should verify test users exist in database

### Dev: "Which credentials should I create?"

**Answer**: Use EXACT credentials from `test-data/auth/creds.txt`
- Don't make up your own test credentials
- Match email, password, and role exactly
- Keep seed script in sync with creds.txt

---

**Template Version**: 1.0
**Last Updated**: [YYYY-MM-DD]
**Maintained By**: Dev agents (seed scripts) + QA agents (test execution)
