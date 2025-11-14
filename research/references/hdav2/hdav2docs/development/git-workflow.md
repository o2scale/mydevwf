# Git Workflow Guide - HDA v2

**Document Version**: 1.0
**Last Updated**: 2025-10-03
**Status**: Active

---

## Overview

This document defines the Git branching strategy and workflow for the HDA v2 project, optimized for parallel feature development while maintaining code quality and deployment safety.

---

## Branch Structure

```
main (production-ready, protected)
├── feature/story-1.6-translation-pipeline (backend)
├── feature/story-1.7-ui-ux-integration (frontend)
├── feature/story-X.Y-description (future stories)
└── hotfix/critical-bug-name (emergency fixes)
```

---

## Branch Naming Conventions

### Feature Branches
```bash
feature/story-{number}-{short-description}
```

**Examples**:
- `feature/story-1.6-translation-pipeline`
- `feature/story-1.7-ui-ux-integration`
- `feature/story-2.1-user-authentication`

### Hotfix Branches
```bash
hotfix/{issue-id}-{short-description}
```

**Examples**:
- `hotfix/gh-42-pdf-upload-timeout`
- `hotfix/critical-worker-crash`

### Release Branches (Future)
```bash
release/v{major}.{minor}.{patch}
```

**Examples**:
- `release/v1.0.0`
- `release/v1.1.0`

---

## Commit Message Format

Follow conventional commits specification for clear, scannable history.

### Format
```
<type>(story-X.Y): <description>

[optional body]

[optional footer]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring (no feature change)
- `test`: Adding or updating tests
- `chore`: Build process, dependencies, tooling

### Examples

**Good Commit Messages**:
```bash
feat(story-1.6): Add translation worker with async pool
fix(story-1.6): Handle connection timeout in long-running jobs
docs(story-1.5): Update parallel workers architecture guide
test(story-1.7): Add Playwright tests for queue monitoring page
refactor(story-1.6): Extract batch creation into utility function
chore(story-1.6): Add google-cloud-translate dependency
```

**Bad Commit Messages** (avoid these):
```bash
# Too vague
fix bug
update code
WIP

# No story reference
Add translation feature
Fix timeout issue

# Not descriptive
feat(story-1.6): changes
fix(story-1.7): stuff
```

---

## Workflow Steps

### 1. Starting a New Feature

```bash
# Ensure main is up to date
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/story-X.Y-description

# Verify branch
git status
```

### 2. Development Cycle

```bash
# Make changes
# ... edit files ...

# Stage changes
git add <files>

# Commit with descriptive message
git commit -m "feat(story-X.Y): Add feature description"

# Push to remote (first time)
git push -u origin feature/story-X.Y-description

# Push subsequent commits
git push
```

### 3. Keeping Branch Updated

**Option A: Merge main into feature** (recommended for long-running branches)
```bash
git checkout feature/story-X.Y-description
git merge main

# Resolve conflicts if any
# ... fix conflicts ...
git add <resolved-files>
git commit -m "chore(story-X.Y): Merge main into feature branch"
git push
```

**Option B: Rebase on main** (for clean history)
```bash
git checkout feature/story-X.Y-description
git rebase main

# Resolve conflicts if any
# ... fix conflicts ...
git add <resolved-files>
git rebase --continue
git push --force-with-lease
```

⚠️ **Warning**: Only use rebase if you're the only developer on the branch.

### 4. Pre-Merge Testing

Before merging to main, ensure all tests pass:

```bash
# Backend tests (if applicable)
cd backend
pytest

# Frontend tests (if applicable)
cd frontend
npm run test
npm run lint

# Integration tests (Playwright)
npm run test:playwright

# Manual testing checklist
# - Upload flow working
# - API endpoints responding
# - No console errors
# - Queue monitoring working
```

### 5. Creating Pull Request

```bash
# Push final changes
git push

# Create PR via GitHub CLI
gh pr create \
  --title "Story X.Y: Feature description" \
  --body "$(cat <<'EOF'
## Summary
- Bullet point summary of changes
- Key features implemented
- Related issues

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing complete
- [ ] No console errors

## Screenshots
[Add screenshots if UI changes]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Or create PR manually on GitHub:
1. Go to repository on GitHub
2. Click "Pull Requests" → "New Pull Request"
3. Select your branch
4. Fill in title and description
5. Request reviews
6. Link related issues

### 6. Merging to Main

**After PR approval**:

**Option A: Squash and Merge** (recommended for clean history)
- All commits squashed into one
- Clean main branch history
- Loses detailed commit history (preserved in PR)

**Option B: Merge Commit** (preserves all commits)
- All feature branch commits preserved
- More detailed history
- Can be noisy with many small commits

**Option C: Rebase and Merge** (linear history)
- Replays commits on top of main
- Clean linear history
- Requires force-push, riskier

```bash
# After merge via GitHub, update local main
git checkout main
git pull origin main

# Delete merged feature branch
git branch -d feature/story-X.Y-description
git push origin --delete feature/story-X.Y-description
```

---

## Parallel Development Guidelines

### Current Active Branches

**Story 1.6 (Translation Pipeline)** - Backend
- Branch: `feature/story-1.6-translation-pipeline`
- Focus: Translation workers, API endpoints, Vertex AI integration
- Testing: API tests (curl, pytest)
- Dependencies: None (independent)

**Story 1.7 (UI/UX Integration)** - Frontend
- Branch: `feature/story-1.7-ui-ux-integration`
- Focus: UI polish, component refinement, Playwright tests
- Testing: Playwright (extensive)
- Dependencies: None (independent)

### Rules for Parallel Development

1. **No Shared File Edits**: Stories should touch different files
   - Story 1.6: `backend/workers/`, `backend/api/routers/translations.py`
   - Story 1.7: `frontend/src/components/`, `frontend/src/pages/`

2. **Communicate Conflicts Early**: If both stories need to edit the same file:
   - Coordinate via `.ai/devnotes.md`
   - One story waits for the other to merge first
   - Or split the change into a separate micro-story

3. **Merge Order**: If stories finish at different times:
   - Story 1.6 finishes first → Merge immediately
   - Story 1.7 still in progress → Continue on branch
   - Story 1.7 finishes → Merge after rebasing on updated main

4. **Integration Testing**: After both stories merged:
   - Test combined functionality
   - Verify no regression
   - Playwright tests cover full flow

---

## Conflict Resolution

### Common Conflict Scenarios

**Scenario 1: Both branches modify the same file**
```bash
# Story 1.6 merged first, Story 1.7 has conflict
git checkout feature/story-1.7-ui-ux-integration
git merge main

# Conflict in frontend/src/App.tsx
# Fix manually in editor
git add frontend/src/App.tsx
git commit -m "chore(story-1.7): Resolve merge conflict with story 1.6"
git push
```

**Scenario 2: Database schema changes**
```bash
# Story 1.6 adds translation table
# Story 1.7 adds user preferences table
# Both modify database/schema.sql

# Solution: Coordinate via devnotes
# Story 1.6 merges first
# Story 1.7 adds their table below Story 1.6's changes
```

**Scenario 3: Package.json conflicts**
```bash
# Both stories add different dependencies
# Story 1.6: google-cloud-translate
# Story 1.7: new UI library

# After merge conflict:
git checkout --theirs package.json  # Take their version
npm install  # Re-add your dependencies
git add package.json package-lock.json
git commit -m "chore(story-1.7): Resolve package.json conflict"
```

---

## Emergency Hotfixes

For critical production bugs:

```bash
# Create hotfix branch from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-worker-crash

# Fix the bug
# ... edit files ...
git commit -m "fix(hotfix): Prevent worker crash on null document"

# Push and create PR
git push -u origin hotfix/critical-worker-crash
gh pr create --title "Hotfix: Worker crash on null document" --label "hotfix"

# After merge, delete branch
git checkout main
git pull origin main
git branch -d hotfix/critical-worker-crash
```

---

## CI/CD Integration (Future)

When GitHub Actions or CI/CD is set up:

### Pre-Merge Checks
- ✅ All tests pass (pytest, Jest, Playwright)
- ✅ Linting passes (flake8, ESLint)
- ✅ Build succeeds
- ✅ No security vulnerabilities
- ✅ Code coverage threshold met (e.g., 80%)

### Branch Protection Rules
- Require PR review (1+ approvals)
- Require CI checks to pass
- No direct pushes to main
- Require up-to-date branches

---

## Best Practices

### Do ✅
- Commit frequently with descriptive messages
- Keep commits focused (one logical change per commit)
- Test before pushing
- Pull main regularly to avoid drift
- Use `.ai/devnotes.md` for coordination
- Delete merged branches

### Don't ❌
- Commit directly to main
- Force push to shared branches (use `--force-with-lease`)
- Commit sensitive data (.env files, API keys)
- Make commits with "WIP" or "fix" as the only message
- Leave stale branches unmerged for weeks

---

## Tools and Commands

### Useful Git Aliases

Add to `~/.gitconfig`:

```ini
[alias]
    # Quick status
    st = status -sb

    # Prettier log
    lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit

    # Undo last commit (keep changes)
    undo = reset HEAD~1 --soft

    # Amend last commit
    amend = commit --amend --no-edit

    # List branches by date
    branches = branch --sort=-committerdate
```

### GitHub CLI Commands

```bash
# View PR status
gh pr status

# Checkout PR locally
gh pr checkout 42

# Review PR
gh pr review 42 --approve

# Merge PR
gh pr merge 42 --squash
```

---

## Troubleshooting

### "Your branch is behind 'origin/main'"
```bash
git pull origin main
# Or if you have local commits:
git pull --rebase origin main
```

### "Merge conflict in file.txt"
```bash
# Option 1: Accept their changes
git checkout --theirs file.txt

# Option 2: Accept your changes
git checkout --ours file.txt

# Option 3: Manually resolve in editor
# ... edit file.txt ...
git add file.txt
git commit
```

### "fatal: refusing to merge unrelated histories"
```bash
# Rare issue, usually from fresh clone
git pull origin main --allow-unrelated-histories
```

### "Permission denied (publickey)"
```bash
# Check SSH key
ssh -T git@github.com

# If failed, add SSH key to GitHub:
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
# Copy and add to GitHub Settings → SSH Keys
```

---

## References

- **Conventional Commits**: https://www.conventionalcommits.org/
- **GitHub Flow**: https://guides.github.com/introduction/flow/
- **Git Best Practices**: https://git-scm.com/book/en/v2
- **DevNotes Communication**: `.ai/devnotes.md`

---

## Changelog

### 2025-10-03 - v1.0
- Initial git workflow guide created
- Defined branch naming conventions
- Documented parallel development strategy
- Added commit message format
- Created troubleshooting section

---

**Document Owner**: DEV Team
**Review Cycle**: Quarterly or when workflow changes
**Feedback**: Update via PR to `docs/development/git-workflow.md`
