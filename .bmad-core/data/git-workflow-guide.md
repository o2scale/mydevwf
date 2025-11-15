# BMad Method Git Workflow Guide

**Version:** 1.0
**Last Updated:** 2025-11-08
**Status:** Production

---

## Overview

This document defines the Git workflow for BMad Method projects, ensuring code is committed at appropriate points with clear, informative commit messages.

---

## Branch Strategy

### Main Branches

**1. `main` (or `master`)**
- Production-ready code
- Protected branch (no direct commits)
- All merges require QA approval (PASS quality gate)

**2. `develop` (or `devwf`)**
- Integration branch for features
- All story work branches from here
- Merges back here after QA PASS

### Story Branches

**Naming Convention:**
```
story/{epic}.{story}-{slug}

Examples:
story/1.3-user-authentication
story/2.1-payment-integration
story/1.5-profile-page
```

**Creation:**
```bash
# Branch from develop
git checkout develop
git pull origin develop
git checkout -b story/1.3-user-authentication
```

---

## Commit Points in BMad Workflow

### Commit Point 1: After Dev Implementation (Before QA)

**When**: Dev agent completes implementation, all tests pass, BEFORE creating QA Handoff

**Who**: Dev agent

**What**: All implementation changes (code, tests, docs)

**Commit Message Format**:
```
feat(story-{epic}.{story}): {brief summary}

Implementation complete:
- {task 1 description}
- {task 2 description}
- {task 3 description}

Tests: {vitest-count} unit + {e2e-count} E2E scenarios
Files: {count} created/modified

Status: Ready for QA
Story: docs/stories/{epic}.{story}.story.md

Authored by O2Scale
```

**Example**:
```
feat(story-1.3): Implement user authentication system

Implementation complete:
- JWT token generation and validation
- Login/logout endpoints with bcrypt password hashing
- Session management with Redis
- Password reset via email

Tests: 12 unit + 5 E2E scenarios
Files: 8 created/modified

Status: Ready for QA
Story: docs/stories/1.3.story.md

Authored by O2Scale
```

### Commit Point 2: After QA Fixes (If QA FAIL/CONCERNS)

**When**: Dev agent addresses QA findings, fixes implemented, tests pass

**Who**: Dev agent

**What**: Bug fixes, test improvements, addressing QA concerns

**Commit Message Format**:
```
fix(story-{epic}.{story}): {brief description of fixes}

QA findings addressed:
- {issue 1 and fix}
- {issue 2 and fix}
- {issue 3 and fix}

Tests: {vitest-count} unit + {e2e-count} E2E scenarios
Quality Gate: {previous-status} → Ready for re-review

Reference: docs/handoffs/.../developer-handoff.md

Authored by O2Scale
```

**Example**:
```
fix(story-1.3): Address QA findings on authentication

QA findings addressed:
- Fixed password validation to require special characters
- Added rate limiting to login endpoint (5 attempts/15 min)
- Improved error messages for expired tokens
- Fixed session cleanup on logout

Tests: 15 unit + 7 E2E scenarios
Quality Gate: CONCERNS → Ready for re-review

Reference: docs/handoffs/sprint-1/epics/epic-1/1.3-developer-handoff.md

Authored by O2Scale
```

### Commit Point 3: After QA PASS (Story Complete)

**When**: QA validates story, Quality Gate = PASS

**Who**: QA agent OR Dev agent (after receiving Completion Handoff)

**What**: Final story completion marker, quality gate reference

**Commit Message Format**:
```
chore(story-{epic}.{story}): Story complete - QA approved

Quality Gate: PASS ✅
QA Approval: {timestamp}

All acceptance criteria validated:
- {AC1 summary}
- {AC2 summary}
- {AC3 summary}

Evidence: docs/qa/gates/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}.yml
Story Status: Complete

Authored by O2Scale
```

**Example**:
```
chore(story-1.3): Story complete - QA approved

Quality Gate: PASS ✅
QA Approval: 2025-11-08 14:30:00

All acceptance criteria validated:
- Users can register with email/password
- Users can login with secure authentication
- Password reset functionality works via email
- Session management persists across page reloads

Evidence: docs/qa/gates/sprint-1/epics/epic-1/1.3-user-authentication.yml
Story Status: Complete

Authored by O2Scale
```

---

## Handoff Commits (Separate from 3 Code Commit Points)

**Purpose**: All handoff documents are version-controlled with dedicated commits to preserve audit trail and enable version history.

**Philosophy**: Handoff commits are **DOCUMENTATION commits**, separate from the 3 **CODE commits** (Commit Points 1, 2, 3). This separation allows:
- Independent handoff updates without triggering new code commits
- Clear audit trail of communication between agents
- Git diff comparison between handoff versions
- Blame/attribution tracking for handoffs

**When**: IMMEDIATELY after creating OR updating any handoff document

**Commit Message Format**: `handoff({epic}.{story}): {action} {type} - {brief-reason}`

---

### Handoff Types and Commit Messages

**1. QA Handoff** (Dev → QA):
```bash
git add docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-qa-handoff.md
git commit -m "handoff({epic}.{story}): Create QA handoff - implementation complete

Authored by O2Scale"
```

**When to UPDATE** (if Dev re-implements after major changes):
```bash
git commit -m "handoff({epic}.{story}): Update QA handoff - fixes applied

Authored by O2Scale"
```

---

**2. Developer Handoff** (QA → Dev):
```bash
git add docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-developer-handoff.md \
        docs/qa/gates/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}.yml
git commit -m "handoff({epic}.{story}): Create Developer handoff - Gemini API timeout issue

Authored by O2Scale"
```

**Example with multiple issues**:
```bash
git commit -m "handoff({epic}.{story}): Create Developer handoff - 3 E2E failures

Authored by O2Scale"
```

---

**3. Completion Handoff** (QA → Dev):
```bash
git add docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-completion-handoff.md \
        docs/qa/gates/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}.yml
git commit -m "handoff({epic}.{story}): Create Completion handoff - all tests PASS

Authored by O2Scale"
```

---

**4. Story Handoff** (Orchestrator → Dev):
```bash
git add docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-story-handoff.md
git commit -m "handoff({epic}.{story}): Create Story handoff - ready for development

Authored by O2Scale"
```

---

**5. Test Review Handoff** (Orchestrator → QA/Dev):
```bash
git add docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-test-review-handoff.md
git commit -m "handoff({epic}.{story}): Create Test Review handoff - APPROVE

Authored by O2Scale"
```

**Or if REVISE**:
```bash
git commit -m "handoff({epic}.{story}): Create Test Review handoff - REVISE

Authored by O2Scale"
```

---

**6. Story Completion Summary** (Dev → Orchestrator):
```bash
git add docs/handoffs/sprint-{N}/epics/epic-{N}/{epic}.{story}-{slug}-completion-summary.md
git commit -m "handoff({epic}.{story}): Create Story Completion Summary - story complete

Authored by O2Scale"
```

---

### Why Separate Handoff Commits?

**Lost Without Git**:
- ❌ No audit trail: Can't see what bugs QA found on Nov 4 vs Nov 15
- ❌ No version history: Can't revert to previous handoff version
- ❌ No blame/attribution: Can't track who created/modified handoffs when
- ❌ No diff comparison: Can't compare what changed between handoff iterations
- ❌ Breaks handoff intent: Handoffs are "permanent records" but aren't permanent without git

**Gained With Git**:
- ✅ Complete audit trail of all agent communication
- ✅ Version history for all handoffs (can diff between versions)
- ✅ Blame/attribution tracking (git blame shows who wrote what when)
- ✅ Handoff evolution visible in git log
- ✅ Can revert to previous handoff version if needed

**Example Workflow**:
```bash
# Story 2.2 lifecycle with handoffs

# Orchestrator creates Story Handoff
git log --oneline --grep="handoff"
# → a1b2c3d handoff(2.2): Create Story handoff - ready for development

# Dev implements, creates QA Handoff
# → d4e5f6g feat(story-2.2): Implement media transcription (Commit Point 1)
# → h7i8j9k handoff(2.2): Create QA handoff - implementation complete

# QA finds bugs, creates Developer Handoff
# → l0m1n2o handoff(2.2): Create Developer handoff - Gemini API timeout

# Dev fixes, creates updated QA Handoff
# → p3q4r5s fix(story-2.2): Fix Gemini API timeout handling (Commit Point 2)
# → t6u7v8w handoff(2.2): Create QA handoff - fixes applied

# QA approves, creates Completion Handoff
# → x9y0z1a handoff(2.2): Create Completion handoff - all tests PASS

# Dev creates Story Completion Summary
# → b2c3d4e handoff(2.2): Create Story Completion Summary - story complete
```

**Git Diff Usefulness**:
```bash
# Compare what changed in QA Handoff between first submission and after fixes
git diff h7i8j9k t6u7v8w -- docs/handoffs/sprint-2/epics/epic-2/2.2-transcription-qa-handoff.md

# See what QA originally found vs final findings
git diff l0m1n2o x9y0z1a -- docs/handoffs/sprint-2/epics/epic-2/2.2-transcription-developer-handoff.md
```

---

## Commit Message Prefixes

Use conventional commit prefixes:

| Prefix | Usage | Example |
|--------|-------|---------|
| `feat` | New feature implementation | `feat(story-1.3): Add user authentication` |
| `fix` | Bug fixes, addressing QA findings | `fix(story-1.3): Fix password validation` |
| `chore` | Story completion, quality gates | `chore(story-1.3): Story complete - QA approved` |
| `handoff` | Handoff document creation/updates | `handoff(1.3): Create QA handoff - implementation complete` |
| `docs` | Documentation-only changes | `docs(story-1.3): Update API documentation` |
| `test` | Test-only additions/fixes | `test(story-1.3): Add edge case tests` |
| `refactor` | Code refactoring (no feature change) | `refactor(story-1.3): Extract auth logic to service` |

---

## Push Strategy

### During Development

**Push after each commit**:
```bash
git push origin story/1.3-user-authentication
```

**Why**: Backs up work, enables collaboration, visible progress

### After QA PASS

**Merge to develop**:
```bash
# Update develop
git checkout develop
git pull origin develop

# Merge story branch (use --no-ff to preserve story branch history)
git merge --no-ff story/1.3-user-authentication -m "Merge story 1.3: User Authentication (QA PASS)"

# Push to develop
git push origin develop

# Optionally delete story branch
git branch -d story/1.3-user-authentication
git push origin --delete story/1.3-user-authentication
```

---

## Integration with BMad Workflow

### Dev Agent Workflow (Updated)

```
1. Read story → Create story branch
2. Implement tasks → Write tests
3. All tests pass → **COMMIT** (feat: Implementation complete)
4. Restart backend (if needed)
5. Create QA Handoff → HALT
```

### QA Agent Workflow (Updated)

```
1. Read QA Handoff
2. Run tests → Validate
3. Create Quality Gate

IF PASS:
  - **COMMIT** (chore: Story complete - QA approved)
  - Create Completion Handoff with merge instructions
  - HALT (user merges to develop)

IF FAIL/CONCERNS:
  - Create Developer Handoff
  - HALT (Dev addresses issues, commits fixes)
```

### Merge to Main/Production

**Timing**: End of sprint or release

**Process**:
```bash
git checkout main
git pull origin main
git merge --no-ff develop -m "Release Sprint N: {summary}"
git tag -a v1.0.0 -m "Sprint N Release"
git push origin main --tags
```

---

## Git Commands Reference

### Story Branch Creation
```bash
# Start new story
git checkout develop
git pull origin develop
git checkout -b story/{epic}.{story}-{slug}
git push -u origin story/{epic}.{story}-{slug}
```

### Commit with Message
```bash
# Stage all changes
git add .

# Commit with detailed message (use HEREDOC for multi-line)
git commit -m "$(cat <<'EOF'
feat(story-1.3): Implement user authentication system

Implementation complete:
- JWT token generation and validation
- Login/logout endpoints
- Session management

Tests: 12 unit + 5 E2E
Files: 8 created/modified

Status: Ready for QA
Story: docs/stories/1.3.story.md

Authored by O2Scale
EOF
)"

# Push to remote
git push origin story/1.3-user-authentication
```

### Check Status
```bash
# See what's changed
git status

# See commit history
git log --oneline --graph --decorate --all

# See diff before committing
git diff
```

### When to Use Git Diff (Compare Branches)

**Use `git diff` to compare branches in these situations:**

**1. Before Merging to Develop** (Pre-Merge Review)
```bash
# See all changes that will be merged
git checkout develop
git pull origin develop
git diff develop..story/1.3-user-authentication

# Review the diff - should match expectations from QA Handoff
```
**Why**: Verify exactly what code is being merged, catch unexpected changes

**2. When Resuming Work After Context Switch** (Orientation Check)
```bash
# See what you changed since branching from develop
git diff develop...HEAD

# See uncommitted changes in current branch
git diff
```
**Why**: Quickly orient yourself to what's been done, avoid duplicating work

**3. When QA Reports Unexpected Behavior** (Troubleshooting)
```bash
# Compare story branch vs develop to see what changed
git diff develop..story/1.3-user-authentication -- path/to/file.js

# Compare specific commits
git diff <commit-hash-1>..<commit-hash-2>
```
**Why**: Identify what code introduced the issue, narrow down root cause

**4. Before Creating Commit Point 1** (Pre-Commit Validation)
```bash
# See all unstaged changes
git diff

# See staged changes (what will be committed)
git diff --staged
```
**Why**: Review exactly what you're committing, prevent accidental commits

**5. When Merge Conflicts Occur** (Conflict Resolution)
```bash
# See conflicted files
git diff

# After resolving, see remaining diffs
git diff --check
```
**Why**: Understand what conflicts exist, verify resolution is correct

**Git Diff Command Reference**:
```bash
# Compare branches (what's in story-branch that's not in develop)
git diff develop..story/1.3-user-authentication

# Compare branches (what changed since branching)
git diff develop...story/1.3-user-authentication

# Compare specific file
git diff develop..story/1.3-user-authentication -- src/auth.js

# See only file names changed
git diff --name-only develop..story/1.3-user-authentication

# See summary stats
git diff --stat develop..story/1.3-user-authentication
```

### Merge Story to Develop (After QA PASS)
```bash
git checkout develop
git pull origin develop
git merge --no-ff story/1.3-user-authentication -m "Merge story 1.3: User Authentication (QA PASS)"
git push origin develop
```

---

## What NOT to Commit

**NEVER commit**:
- ❌ `.env` files (secrets, credentials)
- ❌ `node_modules/` (dependencies)
- ❌ `.DS_Store` (OS files)
- ❌ IDE config files (`.vscode/`, `.idea/`)
- ❌ Build artifacts (`dist/`, `build/`, `*.log`)
- ❌ Temporary files (`*.tmp`, `*.cache`)

**Ensure `.gitignore` includes**:
```gitignore
# Environment
.env
.env.local
.env.*.local

# Dependencies
node_modules/
vendor/

# Build
dist/
build/
*.log

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db
```

---

## Commit Safety Protocol

**CRITICAL: NEVER commit**:
- Secrets (API keys, passwords, tokens)
- Credentials (database URLs, service account keys)
- Personal info (emails, phone numbers, addresses)

**Before committing, check**:
```bash
# Search for potential secrets
git diff | grep -iE "(api[_-]?key|password|secret|token|credential)"

# If found, DO NOT COMMIT
# Use environment variables or secret management instead
```

**If accidentally committed**:
```bash
# Remove from Git history (DANGEROUS - do before pushing)
git rm --cached <file>
git commit --amend -m "Remove sensitive file"

# If already pushed, consider the secret compromised
# Rotate credentials immediately
```

---

## Troubleshooting

### Problem: Merge Conflicts

**Symptoms**: Git reports conflicts during merge

**Solution**:
```bash
# See conflicted files
git status

# Edit files to resolve conflicts (look for <<<<<<<, =======, >>>>>>>)
# Remove conflict markers, choose correct version

# Stage resolved files
git add <resolved-file>

# Continue merge
git commit
```

### Problem: Need to Undo Last Commit

**If not pushed yet**:
```bash
# Undo commit, keep changes
git reset --soft HEAD~1

# Undo commit, discard changes (DANGEROUS)
git reset --hard HEAD~1
```

**If already pushed** (avoid if possible):
```bash
# Create new commit that undoes previous
git revert HEAD
git push
```

### Problem: Wrong Branch

**Symptoms**: Committed to wrong branch

**Solution**:
```bash
# Save commit hash
COMMIT_HASH=$(git rev-parse HEAD)

# Go to correct branch
git checkout correct-branch

# Cherry-pick the commit
git cherry-pick $COMMIT_HASH

# Go back to wrong branch and undo
git checkout wrong-branch
git reset --hard HEAD~1
```

---

## Best Practices

1. ✅ **Commit early, commit often** - Small, focused commits are better than large ones
2. ✅ **Write clear commit messages** - Future you will thank you
3. ✅ **Push after each commit** - Backs up your work
4. ✅ **Review diff before committing** - `git diff` to see what's changed
5. ✅ **Keep commits atomic** - One logical change per commit
6. ✅ **Use branches for stories** - Never commit directly to main/develop
7. ✅ **Delete merged branches** - Keeps repository clean
8. ✅ **Tag releases** - Use semantic versioning (v1.0.0, v1.1.0, v2.0.0)

---

## Example Complete Workflow

**Scenario**: Story 1.3 - User Authentication

```bash
# 1. Start story
git checkout develop
git pull origin develop
git checkout -b story/1.3-user-authentication
git push -u origin story/1.3-user-authentication

# 2. Dev implements (code, tests, validation)

# 3. Dev commits implementation
git add .
git commit -m "$(cat <<'EOF'
feat(story-1.3): Implement user authentication system

Implementation complete:
- JWT token generation and validation
- Login/logout endpoints with bcrypt
- Session management with Redis

Tests: 12 unit + 5 E2E scenarios
Files: 8 created/modified

Status: Ready for QA
Story: docs/stories/1.3.story.md

Authored by O2Scale
EOF
)"
git push origin story/1.3-user-authentication

# 4. Dev creates QA Handoff → HALTS

# 5. QA validates, finds issues → Developer Handoff

# 6. Dev fixes issues, commits fixes
git add .
git commit -m "$(cat <<'EOF'
fix(story-1.3): Address QA findings on authentication

QA findings addressed:
- Fixed password validation (special chars required)
- Added rate limiting (5 attempts/15 min)
- Improved error messages for expired tokens

Tests: 15 unit + 7 E2E scenarios
Quality Gate: CONCERNS → Ready for re-review

Authored by O2Scale
EOF
)"
git push origin story/1.3-user-authentication

# 7. QA re-validates → PASS

# 8. QA commits completion marker
git add docs/qa/gates/sprint-1/epics/epic-1/1.3-user-authentication.yml
git commit -m "$(cat <<'EOF'
chore(story-1.3): Story complete - QA approved

Quality Gate: PASS ✅
QA Approval: 2025-11-08 14:30:00

All acceptance criteria validated:
- User registration works
- Login/logout secure
- Password reset functional
- Session management persistent

Evidence: docs/qa/gates/sprint-1/epics/epic-1/1.3-user-authentication.yml
Story Status: Complete

Authored by O2Scale
EOF
)"
git push origin story/1.3-user-authentication

# 9. User merges to develop
git checkout develop
git pull origin develop
git merge --no-ff story/1.3-user-authentication -m "Merge story 1.3: User Authentication (QA PASS)"
git push origin develop

# 10. Clean up
git branch -d story/1.3-user-authentication
git push origin --delete story/1.3-user-authentication
```

---

## Summary

**Key Points**:
1. **Branch per story**: `story/{epic}.{story}-{slug}`
2. **Commit after dev**: feat(story-X.Y): Implementation complete
3. **Commit after fixes**: fix(story-X.Y): Address QA findings
4. **Commit after QA PASS**: chore(story-X.Y): Story complete - QA approved
5. **Merge to develop**: After QA PASS (user or automation)
6. **Push frequently**: After each commit

**Benefits**:
- ✅ Clear history (see what was done when)
- ✅ Easy rollback (revert specific commits)
- ✅ Collaboration-ready (multiple devs can work)
- ✅ QA traceability (commits linked to quality gates)
- ✅ Audit trail (who did what, when, why)

---

**Document Version:** 1.0
**Status:** Production-Ready
**Last Updated:** 2025-11-08
