<!-- Powered by BMAD™ Core -->

# Create Next Story Task

## Purpose

To identify the next logical story based on project progress and epic definitions, and then to prepare a comprehensive, self-contained, and actionable story file using the `Story Template`. This task ensures the story is enriched with all necessary technical context, requirements, and acceptance criteria, making it ready for efficient implementation by a Developer Agent with minimal need for additional research or finding its own context.

## SEQUENTIAL Task Execution (Do not proceed until current Task is complete)

### 0. Load Core Configuration and Check Workflow

- Load `.bmad-core/core-config.yaml` from the project root
- If the file does not exist, HALT and inform the user: "core-config.yaml not found. This file is required for story creation. You can either: 1) Copy it from GITHUB bmad-core/core-config.yaml and configure it for your project OR 2) Run the BMad installer against your project to upgrade and add the file automatically. Please add and configure core-config.yaml before proceeding."
- Extract key configurations: `devStoryLocation`, `prd.*`, `architecture.*`, `workflow.*`

### 1. Identify Next Story for Preparation

#### 1.1 Locate Epic Files and Review Existing Stories

- Based on `prdSharded` from config, locate epic files (sharded location/pattern or monolithic PRD sections)
- If `devStoryLocation` has story files, load the highest `{epicNum}.{storyNum}.story.md` file
- **If highest story exists:**
  - Verify status is 'Done'. If not, alert user: "ALERT: Found incomplete story! File: {lastEpicNum}.{lastStoryNum}.story.md Status: [current status] You should fix this story first, but would you like to accept risk & override to create the next story in draft?"
  - If proceeding, select next sequential story in the current epic
  - If epic is complete, prompt user: "Epic {epicNum} Complete: All stories in Epic {epicNum} have been completed. Would you like to: 1) Begin Epic {epicNum + 1} with story 1 2) Select a specific story to work on 3) Cancel story creation"
  - **CRITICAL**: NEVER automatically skip to another epic. User MUST explicitly instruct which story to create.
- **If no story files exist:** The next story is ALWAYS 1.1 (first story of first epic)
- Announce the identified story to the user: "Identified next story for preparation: {epicNum}.{storyNum} - {Story Title}"

#### 1.2 Check for Database Setup Requirement (Story 1.1 Only)

- **If identified story is 1.1 (first story of first epic):**
  - Check `docs/architecture/tech-stack.md` for database technology (Supabase, MongoDB, PostgreSQL)
  - Check `docs/architecture/database-schema.md` exists
  - **If database exists in project:**
    - Override Story 1.1 to be "Database Setup"
    - This story becomes P0 BLOCKER (all other stories depend on this)
    - Estimated effort: 2 SP
    - Announce: "Story 1.1 will be Database Setup (P0 BLOCKER) - Required for all backend stories"
  - **If no database found:**
    - Proceed with normal Story 1.1 from epic

### 2. Gather Story Requirements and Previous Story Context

- Extract story requirements from the identified epic file
- If previous story exists, review Dev Agent Record sections for:
  - Completion Notes and Debug Log References
  - Implementation deviations and technical decisions
  - Challenges encountered and lessons learned
- Extract relevant insights that inform the current story's preparation

### 3. Gather Architecture Context

#### 3.1 Determine Architecture Reading Strategy

- **If `architectureVersion: >= v4` and `architectureSharded: true`**: Read `{architectureShardedLocation}/index.md` then follow structured reading order below
- **Else**: Use monolithic `architectureFile` for similar sections

#### 3.2 Read Architecture Documents Based on Story Type

**For ALL Stories (from docs/architecture/):** tech-stack.md, unified-project-structure.md, coding-standards.md

**For ALL Stories (from .bmad-core/data/):** testing-stack-guide.md

**For Backend/API Stories, additionally:** data-models.md, database-schema.md, backend-architecture.md, rest-api-spec.md, external-apis.md

**For Frontend/UI Stories, additionally:** frontend-architecture.md, components.md, core-workflows.md, data-models.md

**For Full-Stack Stories:** Read both Backend and Frontend sections above

#### 3.3 Extract Story-Specific Technical Details

Extract ONLY information directly relevant to implementing the current story. Do NOT invent new libraries, patterns, or standards not in the source documents.

Extract:

- Specific data models, schemas, or structures the story will use
- API endpoints the story must implement or consume
- Component specifications for UI elements in the story
- File paths and naming conventions for new code
- Testing requirements specific to the story's features
- Security or performance considerations affecting the story

ALWAYS cite source documents: `[Source: architecture/{filename}.md#{section}]`

### 4. Verify Project Structure Alignment

- Cross-reference story requirements with Project Structure Guide from `docs/architecture/unified-project-structure.md`
- Ensure file paths, component locations, or module names align with defined structures
- Document any structural conflicts in "Project Structure Notes" section within the story draft

### 5. Populate Story Template with Full Context

- Create new story file: `{devStoryLocation}/{epicNum}.{storyNum}.story.md` using Story Template
- Fill in basic story information: Title, Status (Draft), Story statement, Acceptance Criteria from Epic

#### 5.1 Special Handling for Database Setup Story (Story 1.1 with Database)

**If this is Story 1.1 AND database was detected in Step 1.2:**

- **Title**: "Database Setup"
- **Epic**: 1 - Foundation
- **Priority**: P0 (BLOCKER - all other stories depend on this)
- **Estimate**: 2 SP
- **Description**: "Implement complete database schema as defined in `docs/architecture/database-schema.md` using Database MCP migration tracking. This ensures the database structure matches architecture documentation exactly with zero schema drift."
- **Acceptance Criteria**:
  - AC1: All tables/collections created as documented
  - AC2: All indexes created for performance
  - AC3: All relationships/constraints created for data integrity
  - AC4: All features installed (extensions for PostgreSQL, validation for MongoDB)
  - AC5: Migration tracked in database (001_initial_schema)
  - AC6: Schema verification confirms 100% match with documentation
- **Dev Notes**:
  - Load: `docs/architecture/database-schema.md` (the schema definition)
  - Load: `.bmad-core/data/database-workflow-guide.md` (universal principles)
  - Load: `docs/architecture/database-workflow-{database}.md` (Supabase/MongoDB/Postgres-specific tools)
  - Database type: [detected from tech-stack.md]
  - Use: Database MCP migration tool (NOT manual SQL/commands)
  - Verify: Structure listing, feature verification, migration tracking
  - Document: Verification results in Dev Agent Record section
- **Testing**:
  - Unit Tests: Not applicable for database setup
  - E2E Tests: Not applicable (database is infrastructure, not user-facing)
  - Verification: Manual verification via MCP inspection tools
- **Tasks**:
  1. Load database schema documentation (docs/architecture/database-schema.md)
  2. Load database workflow guides (generic + database-specific)
  3. Apply schema via Database MCP migration tool (001_initial_schema)
  4. Verify all structures created (tables/collections)
  5. Verify all features installed (indexes, extensions, validation rules)
  6. Verify migration tracked in database
  7. Spot-check structure definitions match documentation
  8. Document verification results in story Dev Notes

**Skip to Step 6 after populating Database Setup story.**

#### 5.2 Regular Story Population (All Other Stories)
- **`Dev Notes` section (CRITICAL):**
  - CRITICAL: This section MUST contain ONLY information extracted from architecture documents. NEVER invent or assume technical details.
  - Include ALL relevant technical details from Steps 2-3, organized by category:
    - **Previous Story Insights**: Key learnings from previous story
    - **Data Models**: Specific schemas, validation rules, relationships [with source references]
    - **API Specifications**: Endpoint details, request/response formats, auth requirements [with source references]
    - **Component Specifications**: UI component details, props, state management [with source references]
    - **File Locations**: Exact paths where new code should be created based on project structure
    - **Testing Requirements**: Specific test cases or strategies from testing-stack-guide.md
    - **Technical Constraints**: Version requirements, performance considerations, security rules
  - Every technical detail MUST include its source reference: `[Source: architecture/{filename}.md#{section}]`
  - If information for a category is not found in the architecture docs, explicitly state: "No specific guidance found in architecture docs"
- **`Testing` section (CRITICAL):**
  - **Unit Tests (Vitest)**: Required ONLY if complex logic with 10+ edge cases
    - Examples: Tax calculations, complex validations, algorithms with multiple branches
    - Location: `docs/qa/unit/sprint-N/epics/epic-N/story-N/`
    - Dev writes actual `.test.ts` files with test code
    - [Source: .bmad-core/data/testing-stack-guide.md]
  - **E2E Test Scenarios**: Required for ALL user journeys (login, checkout, forms, workflows)
    - Format: Markdown test scenarios, NOT test code files (no `.spec.ts`)
    - Location: `docs/qa/e2e/sprint-N/epics/epic-N/story-N/`
    - Organize by acceptance criteria: TC{AC-number}.{case-number}
    - Include for each test case: Steps, Expected behavior, Priority (P0/P1/P2/P3)
    - Example: TC1.1 (first test case for AC1), TC1.2 (second test case for AC1)
    - [Source: .bmad-core/data/testing-stack-guide.md#test-scenario-writing-guidelines]
  - **Context7 Usage**: Add "use context7" to prompts when writing tests for latest Vitest/Playwright patterns
  - **Testing Workflow**: Dev writes tests but does NOT run them (QA's responsibility)
- **`Tasks / Subtasks` section:**
  - Generate detailed, sequential list of technical tasks based ONLY on: Epic Requirements, Story AC, Reviewed Architecture Information
  - Each task must reference relevant architecture documentation
  - Include Vitest unit test writing as explicit subtasks IF complex logic exists (10+ edge cases)
  - Include E2E test scenario writing as explicit subtasks for ALL user-facing features
  - Link tasks to ACs where applicable (e.g., `Task 1 (AC: 1, 3)`)
- Add notes on project structure alignment or discrepancies found in Step 4

### 6. Story Draft Completion and Review

- Review all sections for completeness and accuracy
- Verify all source references are included for technical details
- Ensure tasks align with both epic requirements and architecture constraints
- Update status to "Draft" and save the story file
- Execute `.bmad-core/tasks/execute-checklist` `.bmad-core/checklists/story-draft-checklist`
- Provide summary to user including:
  - Story created: `{devStoryLocation}/{epicNum}.{storyNum}.story.md`
  - Status: Draft
  - Key technical components included from architecture docs
  - Any deviations or conflicts noted between epic and architecture
  - Checklist Results
  - Next steps: For Complex stories, suggest the user carefully review the story draft and also optionally have the PO run the task `.bmad-core/tasks/validate-next-story`
