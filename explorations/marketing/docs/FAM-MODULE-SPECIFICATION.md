# Facebook Ads Management (FAM) Module - Complete Specification

**Version**: 1.0.0
**Date**: 2025-11-01
**Author**: Anjai
**Framework**: BMad V6 Alpha
**Purpose**: Custom BMad module for Facebook/Instagram ads workflow automation for growth consultants

---

## Table of Contents

1. [Module Overview](#module-overview)
2. [Architecture](#architecture)
3. [Custom Agents](#custom-agents)
4. [Custom Workflows](#custom-workflows)
5. [Meta Ads MCP Integration](#meta-ads-mcp-integration)
6. [Directory Structure](#directory-structure)
7. [Implementation Roadmap](#implementation-roadmap)
8. [Usage Guide](#usage-guide)

---

## Module Overview

### Purpose

The **Facebook Ads Management (FAM)** module provides growth consultants with AI-powered workflows to:
- Analyze campaign performance with data-driven insights
- Optimize ad spend and targeting strategies
- Review and improve ad creatives
- Generate client-ready performance reports
- Automate repetitive ads management tasks

### Target Users

- Growth consultants managing client ad accounts
- Digital marketing agencies
- Freelance ads specialists
- In-house marketing teams

### Key Benefits

- ⚡ **50-70% time savings** on campaign audits and reporting
- 📊 **Data-driven decisions** powered by Meta Ads MCP
- 🎯 **Consistent processes** via BMad workflows
- 📈 **Scalable operations** across multiple client accounts
- 🤖 **AI-powered insights** from specialized agents

### Dependencies

**Required**:
- BMad V6 Alpha
- Meta Ads MCP (Pipeboard)
- Facebook Marketing API access
- Claude Code

**Optional**:
- Context7 MCP (for ads best practices documentation)

---

## Architecture

### Module Structure

```
bmad/
├── cagents/fam/              # Custom FAM agents
│   ├── ads-analyst.md
│   ├── ads-optimizer.md
│   ├── creative-expert.md
│   ├── ads-reporter.md
│   └── campaign-strategist.md
│
├── cworkflows/fam/           # Custom FAM workflows
│   ├── campaign-audit/
│   ├── creative-review/
│   ├── performance-report/
│   ├── budget-optimizer/
│   ├── ab-test-analysis/
│   ├── audience-insights/
│   └── scaling-strategy/
│
└── cmodule/fam/              # FAM module metadata
    ├── config.yaml
    ├── README.md
    └── integration-guide.md
```

### Integration Points

**Meta Ads MCP**:
- Campaign data retrieval
- Performance metrics analysis
- Creative asset access
- Budget and spend tracking

**BMad Core**:
- Workflow execution engine
- Agent orchestration
- Context management
- Output generation

**Claude Code**:
- Slash command integration
- Interactive workflows
- Report generation

---

## Custom Agents

### 1. Ads Analyst

**Agent ID**: `fam/ads-analyst`
**Icon**: 📊
**Persona**: Data-driven performance analyst

#### Role

Analyzes Facebook/Instagram campaign performance and provides actionable insights based on metrics, trends, and industry benchmarks.

#### Capabilities

**Data Analysis**:
- Campaign performance metrics (CTR, CPC, CPM, ROAS, CPA)
- Trend analysis over time periods
- Benchmark comparisons (industry standards)
- Anomaly detection (sudden drops/spikes)

**Meta Ads MCP Integration**:
- Fetch campaign data via MCP
- Pull ad set and ad-level metrics
- Access audience insights
- Retrieve spend and budget data

#### Commands

- `*analyze-campaign` - Deep dive into campaign performance
- `*compare-periods` - Compare performance across date ranges
- `*identify-issues` - Flag underperforming campaigns/ad sets
- `*benchmark-check` - Compare against industry standards
- `*trend-report` - Weekly/monthly trend analysis

#### Inputs

- Ad account ID(s)
- Campaign ID(s) (optional, for specific campaigns)
- Date range (e.g., "last 30 days", "2025-10-01 to 2025-10-31")
- Benchmarks (optional, custom industry benchmarks)

#### Outputs

- Performance analysis report (`docs/fam/analysis/{campaign-id}-{date}.md`)
- Issue identification list
- Trend visualizations (markdown tables)
- Recommendations for optimizer agent

#### Context Files

- `bmad/cmodule/fam/data/metrics-guide.md` - Metric definitions and benchmarks
- `bmad/cmodule/fam/data/analysis-framework.md` - Analysis methodology

---

### 2. Ads Optimizer

**Agent ID**: `fam/ads-optimizer`
**Icon**: ⚡
**Persona**: Strategic optimization specialist

#### Role

Provides optimization recommendations based on analyst insights and executes optimization workflows for campaigns, ad sets, and ads.

#### Capabilities

**Optimization Strategies**:
- Budget reallocation (increase winners, decrease losers)
- Bid strategy adjustments
- Targeting refinements
- Ad scheduling optimization
- Creative rotation strategies

**Meta Ads MCP Integration**:
- Propose changes (not execute directly - recommendations only)
- Access current campaign settings
- Pull historical optimization data

#### Commands

- `*optimize-campaign` - Generate optimization plan for campaign
- `*budget-strategy` - Budget allocation recommendations
- `*targeting-refine` - Audience targeting improvements
- `*schedule-adjust` - Ad delivery scheduling optimization
- `*creative-rotate` - Creative rotation strategy

#### Inputs

- Analysis report from Ads Analyst
- Campaign ID(s)
- Optimization goals (e.g., "reduce CPA by 20%", "increase ROAS to 3.5x")
- Constraints (e.g., max budget, must-keep audiences)

#### Outputs

- Optimization plan (`docs/fam/optimization/{campaign-id}-plan-{date}.md`)
- Action items checklist
- Expected impact estimates
- Implementation instructions (for human to execute)

#### Context Files

- `bmad/cmodule/fam/data/optimization-playbook.md` - Proven optimization tactics
- `bmad/cmodule/fam/data/platform-best-practices.md` - Meta platform guidelines

---

### 3. Creative Expert

**Agent ID**: `fam/creative-expert`
**Icon**: 🎨
**Persona**: Visual storytelling and copywriting specialist

#### Role

Reviews ad creatives (images, videos, copy) and provides recommendations for improving engagement and conversion rates.

#### Capabilities

**Creative Analysis**:
- Visual design review (composition, branding, clarity)
- Copywriting review (headlines, primary text, CTAs)
- Hook analysis (first 3 seconds for video)
- A/B test creative comparisons

**Meta Ads MCP Integration**:
- Access ad creatives (images, videos, copy)
- Pull engagement metrics per creative
- Compare creative performance

#### Commands

- `*review-creative` - Comprehensive creative review
- `*copy-review` - Focus on ad copy and messaging
- `*visual-review` - Focus on visual design
- `*ab-compare` - Compare A/B test creatives
- `*creative-refresh` - Suggest creative refresh ideas

#### Inputs

- Ad ID(s) or Campaign ID
- Creative type (image, video, carousel)
- Performance metrics (from Analyst)
- Brand guidelines (optional)

#### Outputs

- Creative review report (`docs/fam/creative/{ad-id}-review-{date}.md`)
- Improvement recommendations
- Creative refresh ideas
- Testing suggestions

#### Context Files

- `bmad/cmodule/fam/data/creative-frameworks.md` - Creative best practices
- `bmad/cmodule/fam/data/copywriting-guide.md` - Ad copy principles

---

### 4. Ads Reporter

**Agent ID**: `fam/ads-reporter`
**Icon**: 📄
**Persona**: Client communication specialist

#### Role

Generates professional, client-ready performance reports with insights, visualizations, and recommendations.

#### Capabilities

**Report Types**:
- Weekly performance summary
- Monthly comprehensive report
- Campaign launch report
- Quarterly business review (QBR)
- Custom date range reports

**Meta Ads MCP Integration**:
- Aggregate performance data
- Pull spend and conversion data
- Access campaign metadata

#### Commands

- `*weekly-report` - Generate weekly summary
- `*monthly-report` - Full monthly report with insights
- `*campaign-report` - Specific campaign deep dive
- `*qbr-report` - Quarterly business review
- `*custom-report` - User-defined date range and metrics

#### Inputs

- Ad account ID(s)
- Date range
- Report type (weekly, monthly, campaign, QBR)
- Client name (for customization)
- Key highlights (optional, from Analyst)

#### Outputs

- Professional report (`docs/fam/reports/{client-name}-{type}-{date}.md`)
- Executive summary section
- Performance tables and visualizations
- Insights and recommendations
- Next steps

#### Context Files

- `bmad/cmodule/fam/data/report-templates.md` - Report structure templates
- `bmad/cmodule/fam/data/client-communication-guide.md` - Professional tone guidelines

---

### 5. Campaign Strategist

**Agent ID**: `fam/campaign-strategist`
**Icon**: 🎯
**Persona**: Strategic planning expert

#### Role

Plans new campaigns, develops testing strategies, and creates scaling roadmaps for successful campaigns.

#### Capabilities

**Strategic Planning**:
- New campaign planning (objectives, targeting, budget)
- Testing frameworks (A/B tests, variable testing)
- Scaling strategies (vertical, horizontal)
- Funnel optimization planning

**Meta Ads MCP Integration**:
- Research existing campaign structures
- Analyze past campaign performance
- Identify successful patterns

#### Commands

- `*plan-campaign` - Plan new campaign from scratch
- `*test-strategy` - Design A/B testing plan
- `*scale-plan` - Create scaling roadmap for winners
- `*funnel-optimize` - Optimize full funnel strategy
- `*relaunch-plan` - Plan campaign relaunch with learnings

#### Inputs

- Campaign objective (awareness, consideration, conversion)
- Target audience description
- Budget range
- Success criteria
- Historical performance data (optional)

#### Outputs

- Campaign strategy document (`docs/fam/strategy/{campaign-name}-strategy-{date}.md`)
- Testing plan
- Budget allocation
- Timeline and milestones
- Success metrics

#### Context Files

- `bmad/cmodule/fam/data/strategy-frameworks.md` - Campaign planning methodologies
- `bmad/cmodule/fam/data/testing-best-practices.md` - A/B testing guidelines

---

## Custom Workflows

### 1. Campaign Audit Workflow

**Workflow ID**: `fam/campaign-audit`
**Type**: Interactive
**Estimated Duration**: 15-20 minutes

#### Purpose

Comprehensive health check of Facebook/Instagram campaigns with actionable insights.

#### Steps

**Step 1: Setup**
- Prompt: Enter ad account ID and date range
- Variables: `{account_id}`, `{date_range}`
- Load: `bmad/cmodule/fam/data/metrics-guide.md`

**Step 2: Data Collection** (via Meta Ads MCP)
- Fetch all campaigns for account
- Retrieve performance metrics (impressions, clicks, conversions, spend)
- Pull creative data
- Store in session variables

**Step 3: Performance Analysis**
- Activate: Ads Analyst agent
- Run: `*analyze-campaign` with fetched data
- Identify: Top performers, underperformers, issues
- Store: Analysis results

**Step 4: Creative Review**
- Activate: Creative Expert agent
- Run: `*review-creative` for underperforming ads
- Generate: Creative improvement recommendations

**Step 5: Optimization Planning**
- Activate: Ads Optimizer agent
- Run: `*optimize-campaign` with analysis
- Generate: Prioritized action plan

**Step 6: Report Generation**
- Compile all findings
- Create: Campaign audit report
- Save: `docs/fam/audits/{account_id}-audit-{date}.md`
- Show: Executive summary to user

#### Inputs

- Ad account ID
- Date range (default: last 30 days)
- Focus areas (optional: performance, creative, targeting)

#### Outputs

- **Primary**: Campaign audit report (markdown)
- **Secondary**: Action items checklist
- **Artifacts**: Performance data (JSON), creative analysis, optimization plan

#### Validation Checklist

- [ ] All active campaigns reviewed
- [ ] Performance metrics analyzed
- [ ] Creatives reviewed (at least underperformers)
- [ ] Optimization recommendations provided
- [ ] Report saved successfully
- [ ] Executive summary clear and actionable

---

### 2. Creative Review Workflow

**Workflow ID**: `fam/creative-review`
**Type**: Interactive
**Estimated Duration**: 10-15 minutes

#### Purpose

Analyze ad creative performance and provide improvement recommendations.

#### Steps

**Step 1: Setup**
- Prompt: Enter campaign ID or ad IDs
- Variables: `{campaign_id}` or `{ad_ids}`
- Load: `bmad/cmodule/fam/data/creative-frameworks.md`

**Step 2: Creative Data Collection** (via Meta Ads MCP)
- Fetch ad creatives (images, videos, copy)
- Retrieve engagement metrics per creative
- Pull A/B test data if available

**Step 3: Visual Analysis**
- Activate: Creative Expert agent
- Run: `*visual-review` for each creative
- Identify: Design strengths/weaknesses

**Step 4: Copy Analysis**
- Run: `*copy-review` for ad copy
- Analyze: Headlines, primary text, CTAs
- Check: Brand voice consistency

**Step 5: Performance Correlation**
- Correlate creative elements with performance
- Identify: Winning patterns (colors, messaging, formats)
- Flag: Losing patterns

**Step 6: Recommendations**
- Generate: Creative refresh ideas
- Suggest: A/B testing opportunities
- Create: Creative brief for new variations

**Step 7: Report**
- Save: `docs/fam/creative/{campaign_id}-creative-review-{date}.md`
- Show: Top 3 recommendations

#### Inputs

- Campaign ID or specific ad IDs
- Creative type (image, video, carousel, all)
- Performance threshold (optional, e.g., "below 1% CTR")

#### Outputs

- **Primary**: Creative review report
- **Secondary**: Creative refresh ideas, testing plan
- **Artifacts**: Creative performance data, pattern analysis

#### Validation Checklist

- [ ] All creatives reviewed (visual + copy)
- [ ] Performance patterns identified
- [ ] Recommendations specific and actionable
- [ ] Testing suggestions included
- [ ] Report saved successfully

---

### 3. Performance Report Workflow

**Workflow ID**: `fam/performance-report`
**Type**: Document
**Estimated Duration**: 8-12 minutes

#### Purpose

Generate professional client-ready performance reports (weekly, monthly, custom).

#### Steps

**Step 1: Report Configuration**
- Prompt: Report type (weekly, monthly, campaign, QBR)
- Prompt: Client name, account ID, date range
- Variables: `{report_type}`, `{client_name}`, `{account_id}`, `{date_range}`
- Load: `bmad/cmodule/fam/data/report-templates.md`

**Step 2: Data Collection** (via Meta Ads MCP)
- Fetch aggregated performance data
- Calculate key metrics (ROAS, CPA, CTR, etc.)
- Pull top/bottom performing campaigns
- Retrieve spend and conversion data

**Step 3: Insight Generation**
- Activate: Ads Analyst agent
- Run: `*trend-report` for date range
- Identify: Key highlights, lowlights, trends

**Step 4: Report Assembly**
- Activate: Ads Reporter agent
- Run: `*{report_type}-report`
- Structure:
  - Executive Summary (key metrics, highlights)
  - Performance Overview (tables, comparisons)
  - Campaign Breakdown (top 5 campaigns)
  - Insights & Analysis (trends, patterns)
  - Recommendations (from Optimizer)
  - Next Steps

**Step 5: Quality Check**
- Validate all data included
- Check formatting and clarity
- Ensure client-appropriate tone

**Step 6: Delivery**
- Save: `docs/fam/reports/{client_name}-{report_type}-{date}.md`
- Optional: Generate PDF version (future enhancement)
- Show: Summary to user

#### Inputs

- Ad account ID
- Client name
- Report type (weekly, monthly, campaign, QBR, custom)
- Date range
- Custom highlights (optional)

#### Outputs

- **Primary**: Professional performance report (markdown)
- **Secondary**: Executive summary (for email)
- **Artifacts**: Performance data tables, metric calculations

#### Validation Checklist

- [ ] All key metrics included
- [ ] Data accuracy verified
- [ ] Insights are actionable
- [ ] Professional tone maintained
- [ ] Client name and branding correct
- [ ] Report saved successfully

---

### 4. Budget Optimizer Workflow

**Workflow ID**: `fam/budget-optimizer`
**Type**: Interactive
**Estimated Duration**: 12-18 minutes

#### Purpose

Analyze budget allocation and recommend reallocation strategies to maximize ROI.

#### Steps

**Step 1: Setup**
- Prompt: Ad account ID, optimization goal
- Variables: `{account_id}`, `{goal}` (e.g., "maximize ROAS", "reduce CPA")
- Load: `bmad/cmodule/fam/data/optimization-playbook.md`

**Step 2: Current Allocation Analysis** (via Meta Ads MCP)
- Fetch all campaigns with budgets
- Calculate current spend distribution
- Pull ROAS/CPA per campaign
- Identify: Budget vs. performance correlation

**Step 3: Performance Segmentation**
- Activate: Ads Analyst agent
- Segment campaigns: Winners, Potential, Losers, Dead
- Calculate: Efficiency scores

**Step 4: Reallocation Modeling**
- Activate: Ads Optimizer agent
- Run: `*budget-strategy` with performance data
- Model scenarios:
  - Scenario A: Conservative (10-20% shifts)
  - Scenario B: Aggressive (30-50% shifts)
  - Scenario C: Custom (user-defined constraints)

**Step 5: Impact Estimation**
- Estimate: Expected ROAS/CPA changes
- Calculate: Potential lift in conversions
- Show: Side-by-side comparison (current vs. optimized)

**Step 6: Implementation Plan**
- Generate: Step-by-step budget change instructions
- Create: Timeline (immediate, next week, next month)
- Flag: Risks and monitoring points

**Step 7: Output**
- Save: `docs/fam/optimization/{account_id}-budget-plan-{date}.md`
- Show: Recommended scenario with expected impact

#### Inputs

- Ad account ID
- Optimization goal (maximize ROAS, reduce CPA, increase conversions)
- Budget constraints (optional, e.g., "max $10k/month")
- Time horizon (1 week, 1 month, 1 quarter)

#### Outputs

- **Primary**: Budget optimization plan
- **Secondary**: Reallocation scenarios, impact estimates
- **Artifacts**: Performance segmentation, efficiency scores

#### Validation Checklist

- [ ] All campaigns analyzed
- [ ] Multiple scenarios provided
- [ ] Impact estimates included
- [ ] Implementation plan clear
- [ ] Risks identified
- [ ] Report saved successfully

---

### 5. A/B Test Analysis Workflow

**Workflow ID**: `fam/ab-test-analysis`
**Type**: Interactive
**Estimated Duration**: 10-15 minutes

#### Purpose

Analyze A/B test results, determine statistical significance, and recommend next steps.

#### Steps

**Step 1: Test Identification**
- Prompt: Campaign ID or ad set IDs being tested
- Prompt: Test variable (creative, audience, placement, etc.)
- Variables: `{test_ids}`, `{test_variable}`
- Load: `bmad/cmodule/fam/data/testing-best-practices.md`

**Step 2: Data Collection** (via Meta Ads MCP)
- Fetch performance data for test variants
- Retrieve: Impressions, clicks, conversions, spend
- Calculate: CTR, CPC, CPA, ROAS per variant

**Step 3: Statistical Analysis**
- Calculate: Sample size adequacy
- Determine: Statistical significance (95% confidence)
- Identify: Winner, loser, or inconclusive

**Step 4: Insights Generation**
- Activate: Ads Analyst agent
- Run: `*compare-periods` for variants
- Identify: Why winner won (creative, copy, targeting)

**Step 5: Recommendations**
- If winner clear: Scale winner, pause loser
- If inconclusive: Continue test, increase budget
- If both performing: Run additional tests
- Activate: Campaign Strategist for next test ideas

**Step 6: Documentation**
- Save: `docs/fam/tests/{test_ids}-analysis-{date}.md`
- Record: Learnings for future tests
- Update: Testing knowledge base

#### Inputs

- Campaign ID or ad set IDs
- Test variable (creative, audience, placement, copy)
- Minimum sample size (optional, default from best practices)

#### Outputs

- **Primary**: A/B test analysis report
- **Secondary**: Winner declaration, next test recommendations
- **Artifacts**: Statistical calculations, performance comparison tables

#### Validation Checklist

- [ ] Sample size adequate for significance
- [ ] Statistical significance calculated
- [ ] Winner/loser determination clear
- [ ] Learnings documented
- [ ] Next steps provided
- [ ] Report saved successfully

---

### 6. Audience Insights Workflow

**Workflow ID**: `fam/audience-insights`
**Type**: Interactive
**Estimated Duration**: 12-18 minutes

#### Purpose

Deep dive into audience performance to identify best-performing segments and expansion opportunities.

#### Steps

**Step 1: Audience Selection**
- Prompt: Campaign ID or custom audience IDs
- Variables: `{campaign_id}` or `{audience_ids}`
- Load: `bmad/cmodule/fam/data/audience-targeting-guide.md`

**Step 2: Data Collection** (via Meta Ads MCP)
- Fetch audience performance metrics
- Retrieve: Demographics, interests, behaviors breakdown
- Pull: Frequency, reach, engagement data

**Step 3: Segmentation Analysis**
- Activate: Ads Analyst agent
- Segment by: Age, gender, location, device
- Identify: Top-performing segments
- Calculate: Efficiency scores per segment

**Step 4: Overlap and Saturation Check**
- Analyze: Audience overlap (if multiple audiences)
- Check: Frequency distribution (identify saturation)
- Flag: Overexposed segments

**Step 5: Expansion Opportunities**
- Identify: Similar audiences to top performers
- Suggest: Lookalike audience strategies
- Recommend: Interest/behavior expansions

**Step 6: Targeting Refinement Plan**
- Activate: Ads Optimizer agent
- Generate: Audience optimization recommendations
- Create: New audience suggestions
- Plan: Testing strategy for new audiences

**Step 7: Output**
- Save: `docs/fam/audiences/{campaign_id}-audience-insights-{date}.md`
- Show: Top 3 segments and expansion opportunities

#### Inputs

- Campaign ID or custom audience IDs
- Performance metric focus (ROAS, CPA, CTR)
- Date range (default: last 30 days)

#### Outputs

- **Primary**: Audience insights report
- **Secondary**: Targeting refinement plan, new audience suggestions
- **Artifacts**: Segmentation data, overlap analysis

#### Validation Checklist

- [ ] All audience segments analyzed
- [ ] Top performers identified
- [ ] Saturation issues flagged
- [ ] Expansion opportunities provided
- [ ] Targeting refinement plan clear
- [ ] Report saved successfully

---

### 7. Scaling Strategy Workflow

**Workflow ID**: `fam/scaling-strategy`
**Type**: Interactive
**Estimated Duration**: 15-25 minutes

#### Purpose

Develop comprehensive scaling plan for successful campaigns to maximize profitable growth.

#### Steps

**Step 1: Campaign Selection**
- Prompt: Campaign ID(s) to scale
- Prompt: Scaling goal (e.g., "3x spend while maintaining ROAS")
- Variables: `{campaign_ids}`, `{scaling_goal}`
- Load: `bmad/cmodule/fam/data/scaling-playbook.md`

**Step 2: Baseline Analysis** (via Meta Ads MCP)
- Fetch current performance metrics
- Analyze: Stability over time (consistency check)
- Check: Learning phase status, frequency, saturation
- Validate: Campaign is ready to scale

**Step 3: Scaling Readiness Assessment**
- Activate: Ads Analyst agent
- Criteria check:
  - Consistent ROAS/CPA (>14 days stable)
  - Not in learning phase
  - Frequency < 2.5
  - Audience size supports scale
  - Creative performance strong
- Determine: Green light, yellow caution, red stop

**Step 4: Scaling Strategy Design**
- Activate: Campaign Strategist agent
- Design strategies:
  - **Vertical Scaling**: Increase budget gradually
  - **Horizontal Scaling**: Duplicate to new audiences
  - **Creative Scaling**: More creative variations
  - **Placement Scaling**: Expand placements
- Recommend: Best approach based on current state

**Step 5: Phased Rollout Plan**
- Create timeline:
  - Week 1: 20-30% budget increase
  - Week 2: Analyze, adjust, continue if stable
  - Week 3-4: Aggressive scaling if Week 2 successful
- Set monitoring checkpoints
- Define: Kill criteria (when to stop scaling)

**Step 6: Risk Mitigation**
- Identify risks: Audience saturation, creative fatigue, CPA inflation
- Plan contingencies: Backup audiences, creative refresh schedule
- Set alerts: Performance drop triggers

**Step 7: Documentation**
- Save: `docs/fam/scaling/{campaign_id}-scaling-plan-{date}.md`
- Create: Week-by-week action checklist
- Show: Phase 1 action items

#### Inputs

- Campaign ID(s) to scale
- Scaling goal (target spend, ROAS maintenance)
- Timeline (weeks/months)
- Constraints (optional, e.g., max budget, audience restrictions)

#### Outputs

- **Primary**: Comprehensive scaling strategy document
- **Secondary**: Phased rollout plan, risk mitigation plan
- **Artifacts**: Readiness assessment, monitoring checkpoints

#### Validation Checklist

- [ ] Baseline performance documented
- [ ] Scaling readiness validated
- [ ] Multiple scaling strategies provided
- [ ] Phased rollout plan detailed
- [ ] Risks and mitigation identified
- [ ] Monitoring checkpoints clear
- [ ] Report saved successfully

---

## Meta Ads MCP Integration

### MCP Server Configuration

**Server**: Pipeboard Meta Ads MCP
**URL**: `https://mcp.pipeboard.co/meta-ads-mcp`
**Installation**:
```bash
claude mcp add meta-ads npx -- mcp-remote https://mcp.pipeboard.co/meta-ads-mcp
```

### Required Credentials

**Facebook Marketing API Access**:
- Facebook App ID
- Facebook App Secret
- User Access Token (with `ads_read`, `ads_management` permissions)
- Ad Account ID(s)

**OAuth Setup**:
- Follow Pipeboard MCP documentation for OAuth flow
- Store credentials securely (not in version control)

### MCP Tool Usage

**In Agents**:
Agents reference Meta Ads MCP tools via natural language:

```markdown
## Step 3: Fetch Campaign Data

Use Meta Ads MCP to retrieve campaign performance:
- Campaigns for account: {account_id}
- Date range: {date_range}
- Metrics: impressions, clicks, conversions, spend, ctr, cpc, cpa, roas
```

**In Workflows**:
Workflows specify MCP tool calls in `workflow.yaml`:

```yaml
steps:
  - name: "Fetch Campaign Data"
    type: "mcp-tool"
    tool: "meta-ads.get_campaigns"
    inputs:
      account_id: "{account_id}"
      fields: "name,status,objective,daily_budget,lifetime_budget"
      date_preset: "last_30d"
    output_var: "campaigns_data"
```

### Data Flow

```
User Input → Workflow → Agent → Meta Ads MCP → Facebook API
                ↓                      ↓
         Session Vars ←────── MCP Response
                ↓
         Analysis/Processing
                ↓
         Report Generation → Save to docs/
```

### Rate Limits and Best Practices

**Facebook API Rate Limits**:
- Marketing API: 200 calls/hour per user
- Batch requests recommended for multiple campaigns
- Cache data in session variables (avoid redundant calls)

**MCP Best Practices**:
- Always specify required fields (avoid fetching all data)
- Use date presets when possible (more efficient)
- Batch similar requests together
- Handle errors gracefully (network, API limits, permissions)

---

## Directory Structure

### Complete FAM Module Layout

```
d:/Dev/mydevwf/facebook-ads-workflow/
│
├── bmad/
│   ├── cagents/fam/                        # Custom FAM Agents
│   │   ├── ads-analyst.md                  # Performance analysis agent
│   │   ├── ads-optimizer.md                # Optimization recommendations
│   │   ├── creative-expert.md              # Creative review and suggestions
│   │   ├── ads-reporter.md                 # Client report generation
│   │   └── campaign-strategist.md          # Campaign planning and scaling
│   │
│   ├── cworkflows/fam/                     # Custom FAM Workflows
│   │   ├── campaign-audit/
│   │   │   ├── workflow.yaml
│   │   │   ├── instructions.md
│   │   │   ├── checklist.md
│   │   │   └── README.md
│   │   │
│   │   ├── creative-review/
│   │   │   ├── workflow.yaml
│   │   │   ├── instructions.md
│   │   │   ├── checklist.md
│   │   │   └── README.md
│   │   │
│   │   ├── performance-report/
│   │   │   ├── workflow.yaml
│   │   │   ├── instructions.md
│   │   │   ├── checklist.md
│   │   │   └── README.md
│   │   │
│   │   ├── budget-optimizer/
│   │   │   ├── workflow.yaml
│   │   │   ├── instructions.md
│   │   │   ├── checklist.md
│   │   │   └── README.md
│   │   │
│   │   ├── ab-test-analysis/
│   │   │   ├── workflow.yaml
│   │   │   ├── instructions.md
│   │   │   ├── checklist.md
│   │   │   └── README.md
│   │   │
│   │   ├── audience-insights/
│   │   │   ├── workflow.yaml
│   │   │   ├── instructions.md
│   │   │   ├── checklist.md
│   │   │   └── README.md
│   │   │
│   │   └── scaling-strategy/
│   │       ├── workflow.yaml
│   │       ├── instructions.md
│   │       ├── checklist.md
│   │       └── README.md
│   │
│   ├── cmodule/fam/                        # FAM Module Metadata
│   │   ├── config.yaml                     # Module configuration
│   │   ├── README.md                       # Module documentation
│   │   ├── integration-guide.md            # Meta Ads MCP setup guide
│   │   │
│   │   └── data/                           # Reference Data Files
│   │       ├── metrics-guide.md            # Facebook Ads metrics definitions
│   │       ├── analysis-framework.md       # Performance analysis methodology
│   │       ├── optimization-playbook.md    # Proven optimization tactics
│   │       ├── platform-best-practices.md  # Meta platform guidelines
│   │       ├── creative-frameworks.md      # Creative best practices
│   │       ├── copywriting-guide.md        # Ad copy principles
│   │       ├── report-templates.md         # Report structure templates
│   │       ├── client-communication-guide.md # Professional tone guidelines
│   │       ├── strategy-frameworks.md      # Campaign planning methodologies
│   │       ├── testing-best-practices.md   # A/B testing guidelines
│   │       ├── audience-targeting-guide.md # Audience targeting strategies
│   │       └── scaling-playbook.md         # Scaling strategies and tactics
│   │
│   ├── bmb/                                # BMad Builder (unchanged)
│   ├── bmm/                                # BMad Method (unchanged)
│   ├── cis/                                # Creative Intelligence Suite (unchanged)
│   └── core/                               # BMad Core (unchanged)
│
├── .claude/
│   ├── commands/
│   │   └── fam/                            # FAM Slash Commands
│   │       ├── agents/
│   │       │   ├── ads-analyst.md
│   │       │   ├── ads-optimizer.md
│   │       │   ├── creative-expert.md
│   │       │   ├── ads-reporter.md
│   │       │   └── campaign-strategist.md
│   │       │
│   │       └── workflows/
│   │           ├── campaign-audit.md
│   │           ├── creative-review.md
│   │           ├── performance-report.md
│   │           ├── budget-optimizer.md
│   │           ├── ab-test-analysis.md
│   │           ├── audience-insights.md
│   │           └── scaling-strategy.md
│   │
│   └── agents/                             # (BMad default agents)
│
├── docs/
│   ├── FAM-MODULE-SPECIFICATION.md         # This document
│   │
│   └── fam/                                # FAM Generated Outputs
│       ├── audits/                         # Campaign audit reports
│       ├── analysis/                       # Performance analysis reports
│       ├── creative/                       # Creative review reports
│       ├── optimization/                   # Optimization plans
│       ├── reports/                        # Client performance reports
│       ├── tests/                          # A/B test analysis
│       ├── audiences/                      # Audience insights
│       └── scaling/                        # Scaling strategies
│
└── .mcp.json                               # MCP Server Configuration
```

---

## Implementation Roadmap

### Phase 1: Foundation (Week 1)

**Objective**: Set up core infrastructure and first agent/workflow

**Tasks**:
1. ✅ Install BMad V6 Alpha (COMPLETED)
2. ✅ Create specification document (COMPLETED)
3. Add Meta Ads MCP to project
4. Configure Facebook API credentials
5. Test MCP connection (basic campaign data fetch)
6. Create FAM module structure (`cagents/fam/`, `cworkflows/fam/`, `cmodule/fam/`)
7. Create first data file: `metrics-guide.md`
8. Create first agent: **Ads Analyst**
9. Create first workflow: **Campaign Audit**
10. Test end-to-end: Campaign Audit workflow

**Deliverables**:
- [ ] Meta Ads MCP configured and tested
- [ ] Ads Analyst agent functional
- [ ] Campaign Audit workflow functional
- [ ] First audit report generated
- [ ] Documentation updated

**Success Criteria**:
- Can run `/fam/agents/ads-analyst` → `*analyze-campaign` successfully
- Campaign Audit workflow fetches real data and generates report
- Report saved to `docs/fam/audits/`

---

### Phase 2: Core Agents (Week 2)

**Objective**: Build remaining core agents

**Tasks**:
1. Create **Ads Optimizer** agent
2. Create **Creative Expert** agent
3. Create **Ads Reporter** agent
4. Create data files:
   - `optimization-playbook.md`
   - `creative-frameworks.md`
   - `report-templates.md`
5. Test each agent individually
6. Integrate agents into Campaign Audit workflow
7. Documentation and slash commands

**Deliverables**:
- [ ] Ads Optimizer agent functional
- [ ] Creative Expert agent functional
- [ ] Ads Reporter agent functional
- [ ] Campaign Audit workflow enhanced with all agents
- [ ] All agent data files created

**Success Criteria**:
- All 3 agents can be activated and execute commands
- Campaign Audit workflow uses all 4 agents (Analyst, Optimizer, Creative, Reporter)
- Generated reports are comprehensive and actionable

---

### Phase 3: Additional Workflows (Week 3)

**Objective**: Build specialized workflows

**Tasks**:
1. Create **Performance Report** workflow
2. Create **Budget Optimizer** workflow
3. Create **A/B Test Analysis** workflow
4. Create data files:
   - `testing-best-practices.md`
   - `client-communication-guide.md`
5. Test each workflow independently
6. Create workflow documentation

**Deliverables**:
- [ ] Performance Report workflow functional
- [ ] Budget Optimizer workflow functional
- [ ] A/B Test Analysis workflow functional
- [ ] All workflow data files created
- [ ] Workflow READMEs complete

**Success Criteria**:
- Can generate weekly/monthly reports on demand
- Budget optimization recommendations are data-driven
- A/B test analysis includes statistical significance

---

### Phase 4: Advanced Features (Week 4)

**Objective**: Add advanced workflows and strategist agent

**Tasks**:
1. Create **Campaign Strategist** agent
2. Create **Audience Insights** workflow
3. Create **Scaling Strategy** workflow
4. Create **Creative Review** workflow (standalone)
5. Create data files:
   - `strategy-frameworks.md`
   - `audience-targeting-guide.md`
   - `scaling-playbook.md`
   - `copywriting-guide.md`
6. Integration testing across all workflows
7. Create FAM module documentation (`cmodule/fam/README.md`)

**Deliverables**:
- [ ] Campaign Strategist agent functional
- [ ] All 7 workflows functional
- [ ] All data files created
- [ ] FAM module documentation complete
- [ ] Integration guide for Meta Ads MCP

**Success Criteria**:
- Complete FAM module is functional
- All agents and workflows tested
- Documentation is comprehensive
- Users can navigate FAM module independently

---

### Phase 5: Polish and Optimization (Week 5)

**Objective**: Refinement, optimization, and user testing

**Tasks**:
1. User testing with real client accounts
2. Performance optimization (reduce unnecessary MCP calls)
3. Error handling improvements
4. Report formatting enhancements
5. Create quick start guide
6. Create FAM cheat sheet (common workflows)
7. Video walkthrough (optional)
8. Community feedback

**Deliverables**:
- [ ] User testing completed (3-5 real audits)
- [ ] Performance optimizations implemented
- [ ] Error handling robust
- [ ] Quick start guide created
- [ ] FAM cheat sheet created

**Success Criteria**:
- Users can run workflows without errors
- Workflows complete in expected time (per spec)
- Generated reports are professional and actionable
- Positive user feedback

---

## Usage Guide

### Getting Started

#### 1. Prerequisites

**Install Requirements**:
```bash
# Ensure BMad V6 Alpha is installed
cd d:/Dev/mydevwf/facebook-ads-workflow

# Add Meta Ads MCP
claude mcp add meta-ads npx -- mcp-remote https://mcp.pipeboard.co/meta-ads-mcp

# Verify
claude mcp list
```

**Configure Facebook API**:
- Create Facebook App at https://developers.facebook.com
- Get App ID and App Secret
- Generate User Access Token with `ads_read`, `ads_management` permissions
- Configure in Meta Ads MCP (follow Pipeboard docs)

#### 2. Activate FAM Agents

**Via Slash Commands**:
```
/fam/agents/ads-analyst          # Performance analysis
/fam/agents/ads-optimizer        # Optimization recommendations
/fam/agents/creative-expert      # Creative review
/fam/agents/ads-reporter         # Report generation
/fam/agents/campaign-strategist  # Strategic planning
```

**Example Session**:
```
/fam/agents/ads-analyst
*analyze-campaign

[Enter ad account ID: 123456789]
[Enter date range: last 30 days]

[Analyst fetches data and generates analysis]
[Report saved to docs/fam/analysis/123456789-analysis-2025-11-01.md]
```

#### 3. Run Workflows

**Via Slash Commands**:
```
/fam/workflows/campaign-audit       # Comprehensive audit
/fam/workflows/creative-review      # Creative analysis
/fam/workflows/performance-report   # Client reports
/fam/workflows/budget-optimizer     # Budget optimization
/fam/workflows/ab-test-analysis     # A/B test results
/fam/workflows/audience-insights    # Audience deep dive
/fam/workflows/scaling-strategy     # Scaling plans
```

**Example Session**:
```
/fam/workflows/campaign-audit

[Workflow initiates]
[Prompts for account ID and date range]
[Executes multi-step process]
[Generates comprehensive audit report]
[Shows executive summary]
```

---

### Common Workflows

#### Weekly Client Check-In

**Workflow**: Performance Report (Weekly)

```
/fam/workflows/performance-report

Report Type: Weekly
Client Name: [Client Name]
Account ID: [Account ID]
Date Range: last 7 days

[Report generated in 8-10 minutes]
[Saved to docs/fam/reports/{client}-weekly-2025-11-01.md]
```

**Use Case**: Send to client every Monday morning

---

#### New Campaign Planning

**Workflow**: Campaign Strategist → Plan Campaign

```
/fam/agents/campaign-strategist
*plan-campaign

Campaign Objective: Lead Generation
Target Audience: B2B SaaS decision makers, 35-55, USA
Budget: $5,000/month
Success Criteria: $50 CPL or better

[Strategist creates comprehensive campaign plan]
[Includes targeting, budget allocation, creative brief, testing plan]
[Saved to docs/fam/strategy/campaign-name-strategy-2025-11-01.md]
```

**Use Case**: Planning new client campaigns

---

#### Monthly Deep Dive

**Workflow**: Campaign Audit + Performance Report

```
# Step 1: Run audit
/fam/workflows/campaign-audit
[Account ID: 123456789]
[Date Range: last 30 days]

# Step 2: Generate monthly report
/fam/workflows/performance-report
[Report Type: Monthly]
[Client Name: Client ABC]
[Include audit insights]

[Two comprehensive documents generated]
```

**Use Case**: Monthly client business reviews

---

#### Scaling Winner Campaigns

**Workflow**: Scaling Strategy

```
/fam/workflows/scaling-strategy

Campaign ID: 987654321
Scaling Goal: 3x spend while maintaining 4.5x ROAS
Timeline: 4 weeks
Constraints: None

[Workflow analyzes campaign readiness]
[Generates phased scaling plan]
[Identifies risks and mitigation strategies]
[Saved to docs/fam/scaling/987654321-scaling-plan-2025-11-01.md]
```

**Use Case**: Growing successful campaigns profitably

---

### Tips for Success

**1. Start Simple**
- Begin with Campaign Audit workflow (most comprehensive)
- Get familiar with one agent before using multiple
- Run workflows on test accounts first

**2. Leverage Meta Ads MCP**
- Agents automatically fetch data via MCP
- No need to export CSVs or use Ads Manager
- Trust the data - MCP pulls directly from Facebook API

**3. Customize Data Files**
- Update `bmad/cmodule/fam/data/` files with your benchmarks
- Add industry-specific best practices
- Tailor report templates to your brand

**4. Build Workflow Habits**
- Weekly: Performance reports for all clients
- Bi-weekly: Campaign audits for active accounts
- Monthly: Deep dive with full audit + report
- Quarterly: Scaling strategy reviews

**5. Iterate and Improve**
- Use `*edit-agent` and `*edit-workflow` to refine
- Add learnings to data files
- Share feedback with BMad community

---

## Appendix

### Key Terms

**FAM**: Facebook Ads Management module
**BMB**: BMad Builder (BOMB)
**MCP**: Model Context Protocol
**ROAS**: Return on Ad Spend
**CPA**: Cost per Acquisition
**CTR**: Click-Through Rate
**CPC**: Cost per Click
**CPM**: Cost per Thousand Impressions

### Resources

**BMad V6 Documentation**: https://bmadcodes.com/v6-alpha/
**Meta Ads MCP**: https://github.com/pipeboard-co/meta-ads-mcp
**Facebook Marketing API**: https://developers.facebook.com/docs/marketing-apis
**Claude Code MCP Docs**: https://docs.claude.com/en/docs/claude-code/mcp

### Support

**Questions/Issues**: Create issue in BMad GitHub repo
**Enhancements**: Use BMad Builder to extend FAM module
**Community**: BMad Discord/Slack (links in main repo)

---

**Document Version**: 1.0.0
**Last Updated**: 2025-11-01
**Status**: ✅ READY FOR IMPLEMENTATION
**Next Step**: Phase 1 - Foundation (Add Meta Ads MCP, create first agent/workflow)
