# Google Ads MCP Research Report

**Date**: 2025-11-01
**Researcher**: Claude (for Anjai)
**Purpose**: Evaluate Google Ads MCP servers for GAM (Google Ads Management) module

---

## Executive Summary

✅ **CONFIRMED**: Multiple production-ready Google Ads MCP servers exist for Claude Code

**Best Options Identified**:
1. **TrueClicks Google Ads MCP** (Node.js) - ⭐ **RECOMMENDED FOR BEGINNERS**
2. **cohnen/mcp-google-ads** (Python) - Professional/Advanced users
3. **Google Official MCP** (Python) - Enterprise (Oct 2025, newest)

**Key Finding**: Google Ads MCP setup is **MORE COMPLEX** than Facebook Ads MCP due to:
- Google Ads API Developer Token requirement (1-3 day approval)
- More authentication options (OAuth vs Service Account)
- GAQL (Google Ads Query Language) learning curve

**Recommendation**: Start with **TrueClicks MCP** (easiest), migrate to **cohnen MCP** when you need advanced control.

---

## Available MCP Servers

### 1. TrueClicks Google Ads MCP ⭐ **EASIEST**

**Repository**: https://github.com/TrueClicks/google-ads-mcp-js
**Language**: Node.js
**Trust Score**: N/A (new, but backed by PPC agency)

#### Advantages ✅

- **No Developer Token Required** - Uses GAQL.app backend
- **No Google Cloud Project Setup** - Eliminates OAuth complexity
- **5-Minute Setup** - Fastest to get running
- **Cross-Platform** - Windows, macOS, Intel, ARM
- **Beginner-Friendly** - Perfect for growth consultants

#### How It Works

1. Visit https://gaql.app
2. Log in with Google account
3. Copy GPT Token
4. Add to Claude config → Done!

**Backend**: GAQL.app handles authentication and query execution securely

#### Limitations ⚠️

- **Dependency on GAQL.app** - Third-party service (potential rate limits)
- **Less Control** - Can't customize API calls directly
- **Limited Documentation** - Newer, smaller community
- **Read-Only** - No campaign modification capabilities (yet)

#### Installation

```bash
# Windows
winget install nodejs

# macOS
brew install node

# Configure Claude Desktop
# Add to claude_desktop_config.json:
{
  "mcpServers": {
    "google-ads": {
      "command": "npx",
      "args": ["-y", "@trueclicks/google-ads-mcp"],
      "env": {
        "GAQL_TOKEN": "your_token_from_gaql_app"
      }
    }
  }
}
```

#### Use Cases

- Quick campaign performance checks
- Weekly reporting automation
- Basic optimization insights
- Learning GAQL queries via AI assistance

---

### 2. cohnen/mcp-google-ads - **RECOMMENDED FOR PRODUCTION**

**Repository**: https://github.com/cohnen/mcp-google-ads
**Language**: Python 3.11+
**Trust Score**: 7.1/10 (Context7)
**Code Snippets**: 52
**Release**: March 20, 2025

#### Advantages ✅

- **Direct API Access** - Full control over Google Ads API
- **OAuth + Service Account** - Flexible authentication
- **Custom GAQL Queries** - No limitations on queries
- **Manager Account Support** - Multi-account management
- **Well-Documented** - Comprehensive setup guides
- **Active Community** - Multiple tutorials, blog posts

#### How It Works

1. Create Google Cloud Project
2. Enable Google Ads API
3. Get Developer Token (1-3 day approval)
4. Configure OAuth2 or Service Account
5. Add to Claude Code

**Direct Connection**: Claude → MCP Server → Google Ads API (no intermediary)

#### Requirements 📋

**Google Cloud Console**:
- Create project
- Enable Google Ads API
- Create OAuth2 credentials OR Service Account

**Google Ads Account**:
- Apply for Developer Token (test token instant, production 1-3 days)
- Optional: Manager Account ID (for multi-account access)

**Environment Variables**:
```
GOOGLE_ADS_AUTH_TYPE=oauth
GOOGLE_ADS_CREDENTIALS_PATH=/path/to/credentials.json
GOOGLE_ADS_DEVELOPER_TOKEN=your_token_here
GOOGLE_ADS_LOGIN_CUSTOMER_ID=optional_manager_id
```

#### Available Tools

| Tool | Function | Input |
|------|----------|-------|
| `list_accounts` | List all accessible accounts | None |
| `execute_gaql_query` | Run custom GAQL queries | Account ID + query |
| `get_campaign_performance` | Campaign metrics | Account ID + date range |
| `get_ad_performance` | Ad-level metrics | Account ID + date range |
| `run_gaql` | GAQL with custom formatting | Account ID + query + format |

#### GAQL Query Examples

**Campaign Performance**:
```sql
SELECT
  campaign.name,
  metrics.clicks,
  metrics.impressions,
  metrics.conversions,
  metrics.cost_micros
FROM campaign
WHERE segments.date DURING LAST_7_DAYS
ORDER BY metrics.clicks DESC
```

**Keyword Analysis**:
```sql
SELECT
  keyword.text,
  metrics.average_position,
  metrics.ctr,
  metrics.quality_score
FROM keyword_view
WHERE metrics.clicks > 100
ORDER BY metrics.impressions DESC
```

**Ad Group Insights**:
```sql
SELECT
  ad_group.name,
  metrics.conversions,
  metrics.cost_micros,
  metrics.conversion_rate
FROM ad_group
WHERE campaign.status = 'ENABLED'
```

#### Installation

```bash
# Clone repository
git clone https://github.com/cohnen/mcp-google-ads.git
cd mcp-google-ads

# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # Mac/Linux
# .venv\Scripts\activate   # Windows

# Install dependencies
pip install -r requirements.txt

# Create .env file
cat > .env << EOF
GOOGLE_ADS_AUTH_TYPE=oauth
GOOGLE_ADS_CREDENTIALS_PATH=/path/to/credentials.json
GOOGLE_ADS_DEVELOPER_TOKEN=your_token
GOOGLE_ADS_LOGIN_CUSTOMER_ID=optional_manager_id
EOF

# Add to Claude Code
claude mcp add-json "googleAdsServer" '{
  "command": "/FULL/PATH/.venv/bin/python",
  "args": ["/FULL/PATH/google_ads_server.py"],
  "env": {
    "GOOGLE_ADS_CREDENTIALS_PATH": "/path/to/credentials.json",
    "GOOGLE_ADS_DEVELOPER_TOKEN": "your_token",
    "GOOGLE_ADS_LOGIN_CUSTOMER_ID": "optional_id"
  }
}'
```

#### Use Cases

- Production client management
- Automated reporting pipelines
- Custom data analysis
- Multi-account operations
- Advanced GAQL queries

---

### 3. Google Official MCP Server - **ENTERPRISE**

**Repository**: https://github.com/googleads/google-ads-mcp
**Language**: Python
**Release**: October 10, 2025 (NEWEST!)
**Backed By**: Google (official)

#### Advantages ✅

- **Official Google Product** - Best long-term support
- **Read-Only by Design** - Safe for exploration
- **Gemini Integration** - Works with Gemini Code Assist
- **Enterprise-Ready** - Built for scale
- **Two Core Tools**:
  - `search` - GAQL queries over Ads accounts
  - `list_accessible_customers` - Enumerate customer resources

#### Installation

```bash
# Via pipx (recommended)
pipx install google-ads-mcp

# Configure (creates config interactively)
google-ads-mcp configure

# Add to Claude Code
# (Uses standard MCP client configuration)
```

#### OAuth2 Scopes Required

```
https://www.googleapis.com/auth/adwords
```

#### Use Cases

- Enterprise environments
- Read-only audits
- Gemini Code Assist workflows
- Google Workspace integration

#### Limitations ⚠️

- **Read-Only** - No campaign modifications
- **Newer** - Less community content than cohnen
- **OAuth Required** - No service account support (yet)

---

## Comparison Matrix

| Feature | TrueClicks | cohnen | Google Official |
|---------|------------|---------|-----------------|
| **Setup Time** | 5 mins | 30-60 mins | 20-40 mins |
| **Developer Token** | ❌ Not needed | ✅ Required | ✅ Required |
| **Google Cloud Project** | ❌ Not needed | ✅ Required | ✅ Required |
| **Authentication** | GAQL.app token | OAuth + Service Account | OAuth only |
| **GAQL Queries** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Manager Accounts** | ⚠️ Limited | ✅ Full support | ✅ Full support |
| **Custom Queries** | ⚠️ Via GAQL.app | ✅ Unlimited | ✅ Unlimited |
| **Read-Only** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Write Operations** | ❌ No | ❌ No | ❌ No |
| **Language** | Node.js | Python | Python |
| **Community** | Small (new) | Medium | Growing |
| **Trust Score** | N/A | 7.1/10 | Official |
| **Best For** | Beginners | Production | Enterprise |

---

## Google Ads vs Facebook Ads MCP

### Similarities ✅

- Both provide read-only access to ad data
- Both support campaign performance analysis
- Both integrate with Claude Code
- Both require API credentials

### Key Differences ⚠️

| Aspect | Facebook Ads MCP | Google Ads MCP |
|--------|------------------|----------------|
| **Setup Complexity** | 🟢 Easy (OAuth only) | 🟡 Medium (Developer Token + OAuth) |
| **Approval Time** | Instant | 1-3 days (Developer Token) |
| **Query Language** | Graph API (simpler) | GAQL (more powerful) |
| **Best MCP** | Pipeboard Meta Ads | cohnen (production) / TrueClicks (beginner) |
| **Write Operations** | ❌ None | ❌ None |
| **Multi-Account** | Manager integration | Manager Account ID |
| **Authentication** | OAuth | OAuth + Service Account |

### Query Language Complexity

**Facebook Graph API** (easier):
```
GET /v18.0/{account_id}/insights?fields=campaign_name,impressions,clicks
```

**Google GAQL** (more powerful but steeper learning curve):
```sql
SELECT
  campaign.name,
  metrics.impressions,
  metrics.clicks
FROM campaign
WHERE segments.date DURING LAST_7_DAYS
```

---

## Recommended Setup Strategy

### Phase 1: Quick Start (Week 1)

**Use**: TrueClicks Google Ads MCP

**Why**:
- No Developer Token wait time
- Get familiar with GAQL via AI
- Test workflows before investing in setup

**Actions**:
1. Install TrueClicks MCP (5 mins)
2. Connect to GAQL.app
3. Run basic queries via Claude
4. Learn GAQL syntax
5. Identify workflow needs

---

### Phase 2: Production Setup (Week 2-3)

**Migrate to**: cohnen/mcp-google-ads

**Why**:
- Direct API access (no intermediary)
- Manager Account support
- Unlimited queries
- Production-ready

**Actions**:
1. Create Google Cloud Project
2. Apply for Developer Token (submit and wait)
3. Set up OAuth2 credentials
4. Install cohnen MCP
5. Test with TrueClicks queries (migrated)
6. Integrate into workflows

---

### Phase 3: Scale (Week 4+)

**Consider**: Google Official MCP (optional)

**Why**:
- Official support
- Enterprise features
- Long-term stability

**Actions**:
1. Evaluate vs. cohnen
2. Test Gemini integration (if using Gemini)
3. Decide based on needs

---

## Developer Token Application Process

### What is a Developer Token?

A Developer Token is required by Google Ads API to authenticate your application. It's separate from OAuth credentials.

### How to Apply

1. **Sign in** to Google Ads Manager Account
2. **Navigate** to Tools & Settings → Setup → API Center
3. **Apply for Developer Token**
   - Fill out application form
   - Describe use case (e.g., "AI-powered campaign analysis for clients")
   - Submit

### Approval Timeline

- **Test Token**: Instant (limited to test accounts)
- **Production Token**: 1-3 business days (full access)

### Test vs Production Token

| Feature | Test Token | Production Token |
|---------|------------|------------------|
| **Approval** | Instant | 1-3 days |
| **Accounts** | Test accounts only | All accounts |
| **Rate Limits** | Lower | Higher |
| **Use Case** | Development, testing | Client work, production |

**Recommendation**: Start with test token, apply for production immediately.

---

## Integration into GAM Module

### Agents Using Google Ads MCP

**1. Ads Analyst**
- Query: Campaign performance metrics
- Tool: `get_campaign_performance`

**2. Keyword Analyst** (NEW - Google-specific)
- Query: Keyword performance, Quality Score
- Tool: `execute_gaql_query` with keyword views

**3. Search Query Analyst** (NEW - Google-specific)
- Query: Search term performance
- Tool: `execute_gaql_query` with search_term_view

**4. Ads Reporter**
- Query: Aggregated data for reports
- Tool: Multiple GAQL queries

**5. Ads Optimizer**
- Input: Performance data from MCP
- Output: Recommendations (no write operations yet)

### Workflows Using Google Ads MCP

**Campaign Audit**:
- Fetch campaigns via `list_accounts`
- Pull metrics via GAQL queries
- Analyze performance

**Keyword Analysis** (Google-specific):
- Query keyword performance
- Identify high/low Quality Score keywords
- Recommend bid adjustments

**Search Query Mining** (Google-specific):
- Pull search term reports
- Identify negative keyword opportunities
- Find expansion opportunities

**Performance Report**:
- Aggregate data across campaigns
- Generate client reports
- Compare periods

---

## GAQL Learning Resources

**Official Documentation**:
- https://developers.google.com/google-ads/api/docs/query/overview
- https://developers.google.com/google-ads/api/fields/v16/overview

**Interactive Query Builder**:
- https://developers.google.com/google-ads/api/fields/v16/overview_query_builder

**Common GAQL Patterns**:
```sql
-- Time-based filtering
WHERE segments.date DURING LAST_7_DAYS
WHERE segments.date BETWEEN '2025-10-01' AND '2025-10-31'

-- Metric filtering
WHERE metrics.clicks > 100
WHERE metrics.cost_micros > 10000000  -- $10

-- Status filtering
WHERE campaign.status = 'ENABLED'
WHERE ad_group.status IN ('ENABLED', 'PAUSED')

-- Sorting
ORDER BY metrics.clicks DESC
ORDER BY metrics.cost_micros ASC
```

---

## Recommendations for Anjai

### Immediate Actions (Tonight/Tomorrow)

1. ✅ **Review this research document**
2. ⏳ **Decide on MCP approach**:
   - Option A: TrueClicks (quick start, test workflows)
   - Option B: cohnen (production-ready, wait for token)
   - Option C: Both (TrueClicks now, cohnen when ready)

3. ⏳ **Apply for Google Ads Developer Token** (if choosing cohnen or Google Official)
   - Do this ASAP (1-3 day approval time)
   - You can still use TrueClicks while waiting

### Next Week Actions

1. ⏳ **Install chosen MCP server**
2. ⏳ **Test with sample queries**
3. ⏳ **Create GAM (Google Ads Management) module specification** (like FAM spec)
4. ⏳ **Plan BMad agents for Google Ads** (similar to Facebook, but with Google-specific agents)

### Week 2-3 Actions

1. ⏳ **Build GAM module using BMad Builder**
2. ⏳ **Create Google-specific workflows** (Keyword Analysis, Search Query Mining)
3. ⏳ **Integrate with client accounts**
4. ⏳ **Test and refine**

---

## Key Takeaways

1. ✅ **Google Ads MCP exists and is production-ready**
2. ⚠️ **Setup is more complex than Facebook Ads** (Developer Token requirement)
3. ⭐ **TrueClicks MCP = fastest way to start** (no token needed)
4. 🏆 **cohnen MCP = best for production** (full control, manager accounts)
5. 🔮 **Google Official MCP = future-proof** (newest, enterprise-ready)
6. 📚 **GAQL has learning curve** (but AI can help)
7. 🎯 **Recommended: Start with TrueClicks, migrate to cohnen**

---

## Questions for Anjai to Consider

1. **Do you already have Google Ads Developer Token?**
   - If yes → Use cohnen MCP immediately
   - If no → Start with TrueClicks, apply for token now

2. **How many client accounts will you manage?**
   - Single account → TrueClicks is fine
   - Multiple accounts → cohnen with Manager Account

3. **What's your urgency?**
   - Need to start TODAY → TrueClicks
   - Can wait 1-3 days → cohnen (better long-term)

4. **Do you prefer Node.js or Python?**
   - Node.js → TrueClicks
   - Python → cohnen or Google Official

---

**Status**: ✅ RESEARCH COMPLETE
**Next Step**: Create GAM (Google Ads Management) module specification
**Recommendation**: Use cohnen/mcp-google-ads for production GAM module

---

**Document Version**: 1.0.0
**Last Updated**: 2025-11-01
**Research Time**: 25 minutes
**Ready for**: GAM specification creation
