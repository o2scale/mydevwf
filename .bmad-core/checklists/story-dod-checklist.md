<!-- Powered by BMAD™ Core -->

# Story Definition of Done (DoD) Checklist

## Instructions for Developer Agent

Before marking a story as 'Review', please go through each item in this checklist. Report the status of each item (e.g., [x] Done, [ ] Not Done, [N/A] Not Applicable) and provide brief comments if necessary.

[[LLM: INITIALIZATION INSTRUCTIONS - STORY DOD VALIDATION

This checklist is for DEVELOPER AGENTS to self-validate their work before marking a story complete.

IMPORTANT: This is a self-assessment. Be honest about what's actually done vs what should be done. It's better to identify issues now than have them found in review.

EXECUTION APPROACH:

1. Go through each section systematically
2. Mark items as [x] Done, [ ] Not Done, or [N/A] Not Applicable
3. Add brief comments explaining any [ ] or [N/A] items
4. Be specific about what was actually implemented
5. Flag any concerns or technical debt created

The goal is quality delivery, not just checking boxes.]]

## Checklist Items

1. **Requirements Met:**

   [[LLM: Be specific - list each requirement and whether it's complete]]
   - [ ] All functional requirements specified in the story are implemented.
   - [ ] All acceptance criteria defined in the story are met.

2. **Coding Standards & Project Structure:**

   [[LLM: Code quality matters for maintainability. Check each item carefully]]
   - [ ] All new/modified code strictly adheres to `Operational Guidelines`.
   - [ ] All new/modified code aligns with `Project Structure` (file locations, naming, etc.).
   - [ ] Adherence to `Tech Stack` for technologies/versions used (if story introduces or modifies tech usage).
   - [ ] Adherence to `Api Reference` and `Data Models` (if story involves API or data model changes).
   - [ ] Basic security best practices (e.g., input validation, proper error handling, no hardcoded secrets) applied for new/modified code.
   - [ ] No new linter errors or warnings introduced.
   - [ ] Code is well-commented where necessary (clarifying complex logic, not obvious statements).

3. **Testing:**

   [[LLM: Testing proves your code works. Be honest about test coverage]]
   - [ ] All required unit tests as per the story and `Operational Guidelines` Testing Strategy are implemented.
   - [ ] All required integration tests (if applicable) as per the story and `Operational Guidelines` Testing Strategy are implemented.
   - [ ] All tests (unit, integration, E2E if applicable) pass successfully.
   - [ ] Test coverage meets project standards (if defined).

4. **Functionality & Verification:**

   [[LLM: Did you actually run and test your code? Be specific about what you tested]]
   - [ ] Functionality has been manually verified by the developer (e.g., running the app locally, checking UI, testing API endpoints).
   - [ ] Edge cases and potential error conditions considered and handled gracefully.

5. **Story Administration:**

   [[LLM: Documentation helps the next developer. What should they know?]]
   - [ ] All tasks within the story file are marked as complete.
   - [ ] Any clarifications or decisions made during development are documented in the story file or linked appropriately.
   - [ ] The story wrap up section has been completed with notes of changes or information relevant to the next story or overall project, the agent model that was primarily used during development, and the changelog of any changes is properly updated.

6. **Dependencies, Build & Configuration:**

   [[LLM: Build issues block everyone. Ensure everything compiles and runs cleanly]]
   - [ ] Project builds successfully without errors.
   - [ ] Project linting passes
   - [ ] Any new dependencies added were either pre-approved in the story requirements OR explicitly approved by the user during development (approval documented in story file).
   - [ ] If new dependencies were added, they are recorded in the appropriate project files (e.g., `package.json`, `requirements.txt`) with justification.
   - [ ] No known security vulnerabilities introduced by newly added and approved dependencies.
   - [ ] If new environment variables or configurations were introduced by the story, they are documented and handled securely.

7. **Documentation (If Applicable):**

   [[LLM: Good documentation prevents future confusion. What needs explaining?]]
   - [ ] Relevant inline code documentation (e.g., JSDoc, TSDoc, Python docstrings) for new public APIs or complex logic is complete.
   - [ ] User-facing documentation updated, if changes impact users.
   - [ ] Technical documentation (e.g., READMEs, system diagrams) updated if significant architectural changes were made.

8. **QA Handoff & Process Management:**

   [[LLM: CRITICAL - This is YOUR responsibility as Dev, not QA's. Verify each item carefully]]
   - [ ] All required background processes (frontend, backend, workers, database) have been started and are running.
   - [ ] Process IDs (PIDs) recorded for each background process.
   - [ ] All process URLs verified accessible (e.g., http://localhost:3000, http://localhost:8000).
   - [ ] **IF story modified ANY backend files** (routes, controllers, models, middleware, services, server.js, app.js, or ANY .js/.ts files in backend/server directories): Backend processes restarted with fresh code BEFORE QA Handoff (stop old PIDs, restart backend, verify successful start, record new PID + restart timestamp).
   - [ ] Detailed QA Handoff document created in `docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-qa-handoff.md` with comprehensive implementation details (implementation summary, background processes with URLs/PIDs/shell IDs, files created/modified, test details, edge cases, validation checklist, dev notes, backend restart confirmation if applicable).
   - [ ] Compact QA Handoff snippet output to terminal with document reference using format from `.bmad-core/data/handoff-templates.md`.
   - [ ] QA Handoff snippet includes: timestamp, completed tasks summary, key files to review, test counts (Vitest + E2E), all background process URLs with PIDs, backend restart status (if applicable), focus areas for testing.

9. **Navigation Integration (MANDATORY for user-facing changes):**

   [[LLM: Navigation is CRITICAL - users must be able to REACH your feature via normal navigation flow (not just direct URL). Check story Navigation Notes section - ALL specified menu items, breadcrumbs, and navigation elements are MANDATORY. If story creates new page but has NO Navigation Notes OR Navigation Notes say "N/A - Backend only", verify story is truly backend-only with zero UI changes. If story has UI changes but missing Navigation Notes, FLAG THIS AS BLOCKING ISSUE - you CANNOT proceed without navigation design (return to UX Expert). Do NOT mark this section N/A unless story is truly backend-only with zero UI changes. QA will independently verify navigation and FAIL stories with missing menus.]]
   - [ ] **CRITICAL**: Story Navigation Notes section is populated (if missing for user-facing story, BLOCK until UX provides navigation design)
   - [ ] **CRITICAL**: Feature is accessible via normal user navigation (not just direct URL) - manually tested from dashboard/main menu
   - [ ] All menu items specified in Navigation Notes are implemented in correct menu locations (header/sidebar/dashboard)
   - [ ] Menu items use exact labels specified in Navigation Notes (consistent terminology)
   - [ ] All buttons/links specified in Navigation Notes are implemented on correct pages with exact placement
   - [ ] Users can reach the new feature from multiple entry points per Navigation Notes (minimum 2 paths tested)
   - [ ] Breadcrumbs implemented correctly per Navigation Notes (page hierarchy accurate)
   - [ ] Navigation follows front-end spec design patterns (consistent with existing UI, same menu styling/behavior)
   - [ ] Navigation elements included in E2E test scenarios (at least 1 test case starts with "User navigates from X to feature via menu/link")

10. **Knowledge Base Documentation:**

   [[LLM: KB entries preserve patterns for future stories. Review story implementation carefully BEFORE creating Story Completion Summary. This is MANDATORY - not optional. Check each trigger carefully and be honest about whether KB documentation is needed.]]
   - [ ] **BEFORE creating Story Completion Summary**, reviewed story implementation against KB triggers:
     - Did story implement third-party integration? (Stripe, S3, Supabase, Vertex AI, SendGrid, etc.) → CREATE KB entry in `docs/knowledge-base/integrations/`
     - Did story establish reusable pattern? (pagination, auth, error handling, batch processing, middleware, etc.) → CREATE KB entry in `docs/knowledge-base/backend-patterns/` or `docs/knowledge-base/ui-patterns/`
     - Did story solve complex/non-obvious issue? (race conditions, performance optimization, data integrity, etc.) → CREATE KB entry in `docs/knowledge-base/common-issues/`
     - Did story Dev Notes explicitly request KB documentation? → CREATE KB entry per requirements
   - [ ] If KB entry created: Used `docs/knowledge-base/_entry-template.md` as starting point
   - [ ] If KB entry created: Filled all required sections (Overview, Pattern with code example, Common Mistakes, Configuration, When to Use/Not Use)
   - [ ] If KB entry created: Updated `docs/knowledge-base/README.md` catalog with new entry (added to appropriate category section)
   - [ ] If KB entry created: Verified KB entry has actual implementation code from THIS story (not generic documentation)
   - [ ] If NO KB entry needed: Confirmed story doesn't match any KB trigger criteria above (document reasoning in Completion Notes)

11. **Git/Version Control:**

   [[LLM: Git commits ensure code is safely versioned and traceable. Follow git-workflow-guide.md exactly]]
   - [ ] Implementation commit created BEFORE QA Handoff (feat(story-X.Y): Implementation complete with task list, test counts, file counts per `.bmad-core/data/git-workflow-guide.md` Commit Point 1).
   - [ ] Commit message follows conventional commits format with proper prefix (feat/fix/chore).
   - [ ] Commit includes all implemented files (staged with `git add`).
   - [ ] Commit pushed to story branch (`git push origin story/{epic}.{story}-{slug}`).
   - [ ] **IF QA finds issues**: Fixes commit created after addressing QA findings (fix(story-X.Y): Address QA findings with issue list, test counts, quality gate status per git-workflow-guide.md Commit Point 2).

## Final Confirmation

[[LLM: FINAL DOD SUMMARY

After completing the checklist:

1. Summarize what was accomplished in this story
2. List any items marked as [ ] Not Done with explanations
3. Identify any technical debt or follow-up work needed
4. Note any challenges or learnings for future stories
5. Confirm whether the story is truly ready for review

Be honest - it's better to flag issues now than have them discovered later.]]

- [ ] I, the Developer Agent, confirm that all applicable items above have been addressed.
