# BMad System Consolidation Plan

**Date**: 2025-10-28 22:20:00
**Priority**: CRITICAL - Integration Validation
**Context**: Based on comprehensive system architecture analysis

---

## SITUATION

We've made significant updates to:
- ✅ Agent personas (Context7 integration)
- ✅ Data files (testing-stack-guide.md, test-levels-framework.md)
- ✅ Task files (create-next-story, review-story, test-design)
- ✅ Architecture templates (4 templates updated)

BUT we haven't verified:
- ❌ If our changes align with workflow expectations
- ❌ If all agent commands reference correct tasks
- ❌ If all data file references are correct
- ❌ If testing-stack-guide.md location is properly configured

---

## CRITICAL ISSUES TO ADDRESS

### 🔥 CRITICAL (Must Fix Immediately)

#### 1. **Testing Stack Guide Location**
**Issue**: We updated tasks to reference `testing-stack-guide.md` but:
- Location assumed: `docs/architecture/testing-stack-guide.md`
- NOT in core-config.yaml
- create-next-story expects: `.bmad-core/data/testing-stack-guide.md`
- **CONFLICT!**

**Impact**: Story creation will fail when trying to load testing guidance

**Fix Required**:
```
Option A: Move testing-stack-guide.md to docs/architecture/
Option B: Update create-next-story to load from .bmad-core/data/
Option C: Add testing guide path to core-config.yaml

RECOMMENDATION: Option B (keep in .bmad-core/data, it's framework data)
```

**Action**:
1. Verify current location of testing-stack-guide.md
2. Update create-next-story.md line 49 reference
3. Update review-story.md line 135 reference
4. Ensure all tasks reference correct location

---

#### 2. **Dev Agent File Loading Conflict**
**Issue**: core-config.yaml defines:
```yaml
devLoadAlwaysFiles:
  - docs/architecture/coding-standards.md
  - docs/architecture/tech-stack.md
  - docs/architecture/source-tree.md
```

BUT create-next-story.md line 49 says:
```markdown
**For ALL Stories:** tech-stack.md, unified-project-structure.md,
coding-standards.md, testing-stack-guide.md
```

**Conflicts**:
- source-tree.md vs unified-project-structure.md (different names)
- testing-stack-guide.md missing from devLoadAlwaysFiles

**Impact**: Dev agent loads different files than story expects

**Fix Required**:
```yaml
# Update core-config.yaml
devLoadAlwaysFiles:
  - docs/architecture/coding-standards.md
  - docs/architecture/tech-stack.md
  - docs/architecture/unified-project-structure.md
  - docs/architecture/testing-stack-guide.md (or .bmad-core/data/testing-stack-guide.md)
```

**Action**:
1. Clarify file naming convention (source-tree vs unified-project-structure)
2. Add testing-stack-guide.md to devLoadAlwaysFiles
3. Document which files dev actually needs

---

#### 3. **Story Location Pattern Migration**
**Issue**: System is transitioning from v3 to v4 pattern:
- **v3**: `docs/stories/{epic}.{story}.story.md`
- **v4**: `docs/sprint-N/epics/epic-N/story-N.md`

**Current Config**:
```yaml
devStoryLocation: docs/stories  # Still v3!
```

**Impact**: Story files created in wrong location if config not updated

**Fix Required**:
1. Document v4 migration path
2. Update core-config.yaml if using v4
3. Ensure create-next-story handles both patterns

**Action**:
1. Check if this project is using v3 or v4
2. Update core-config.yaml accordingly
3. Add version detection to create-next-story.md

---

### 🟡 HIGH PRIORITY (Fix This Week)

#### 4. **Verify All Agent Commands**
**Missing Verification**: We haven't checked if all agent commands reference correct tasks

**Tasks**:
- [ ] Read analyst.md - verify commands
- [ ] Read dev.md - verify commands
- [ ] Read sm.md - verify commands
- [ ] Verify all commands map to existing tasks
- [ ] Update BMAD-SYSTEM-ARCHITECTURE-MAP.md with findings

---

#### 5. **Data Directory Audit**
**Missing Exploration**: We haven't fully explored `.bmad-core/data/`

**Known Files**:
- technical-preferences.md ✅
- documentation-standards.md ✅
- testing-stack-guide.md ✅
- test-levels-framework.md ✅
- test-priorities-matrix.md ✅
- handoff-templates.md ✅
- bmad-kb.md ✅
- brainstorming-techniques.md ✅
- elicitation-methods.md ❓ (referenced but not verified)

**Tasks**:
- [ ] List all files in .bmad-core/data/
- [ ] Verify elicitation-methods exists
- [ ] Check for orphaned files
- [ ] Document all data files

---

#### 6. **Checklist Command Standardization**
**Issue**: Inconsistent checklist invocation

**Agents with *execute-checklist**:
- architect ✅
- pm ❓
- po ✅
- sm ✅

**Agents missing *execute-checklist**:
- analyst ❓
- ux-expert ❓
- dev ❓
- qa ❓

**Action**:
- [ ] Review all agent files
- [ ] Add *execute-checklist where appropriate
- [ ] Document which checklists each agent uses

---

###  📊 MEDIUM PRIORITY (Next Week)

#### 7. **Architecture File References Consolidation**
**Issue**: Tasks reference architecture files with different patterns

**create-next-story references**:
```markdown
docs/architecture/tech-stack.md
docs/architecture/unified-project-structure.md
docs/architecture/coding-standards.md
docs/architecture/testing-stack-guide.md
docs/architecture/data-models.md
docs/architecture/database-schema.md
...
```

**But core-config says**:
```yaml
architecture:
  architectureSharded: true
  architectureShardedLocation: docs/architecture
```

**Action**:
- [ ] Verify all architecture section file names
- [ ] Create architecture file index
- [ ] Update tasks with correct file names
- [ ] Document expected architecture structure

---

#### 8. **Template Testing**
**Issue**: We updated 4 architecture templates but haven't tested them

**Actions**:
- [ ] Test fullstack-architecture-tmpl.yaml generation
- [ ] Test architecture-tmpl.yaml generation
- [ ] Test front-end-architecture-tmpl.yaml generation
- [ ] Test brownfield-architecture-tmpl.yaml generation
- [ ] Verify testing sections render correctly

---

#### 9. **Workflow Integration Verification**
**Issue**: We updated tasks but haven't verified workflow expectations

**Actions**:
- [ ] Review greenfield-fullstack.yaml expectations
- [ ] Review brownfield-fullstack.yaml expectations
- [ ] Verify agent commands match workflow calls
- [ ] Test end-to-end workflow execution

---

## IMMEDIATE ACTION PLAN

### Phase 1: Critical Path Validation (TODAY)

**1.1 Fix Testing Stack Guide References**
```bash
# 1. Verify location
ls .bmad-core/data/testing-stack-guide.md
ls docs/architecture/testing-stack-guide.md

# 2. Update create-next-story.md
#    Change line 49: testing-strategy.md → correct path

# 3. Update review-story.md
#    Change line 135: docs/testing-strategy.md → correct path

# 4. Commit fix
```

**1.2 Resolve Dev File Loading Conflict**
```yaml
# Update core-config.yaml
devLoadAlwaysFiles:
  - docs/architecture/coding-standards.md
  - docs/architecture/tech-stack.md
  - docs/architecture/unified-project-structure.md  # Verify name
  - .bmad-core/data/testing-stack-guide.md  # Or architecture location
```

**1.3 Clarify Story Location Pattern**
```yaml
# Check current pattern being used
# Update core-config.yaml if needed
devStoryLocation: docs/stories  # v3
# OR
devStoryLocation: docs/sprint-N/epics/epic-N  # v4
```

---

### Phase 2: Agent Verification (THIS WEEK)

**2.1 Read All Agent Files**
```bash
# Read and verify
.bmad-core/agents/analyst.md
.bmad-core/agents/dev.md
.bmad-core/agents/sm.md
.bmad-core/agents/po.md
```

**2.2 Create Agent Command Matrix**
```
Agent → Commands → Tasks → Templates → Data Files
```

**2.3 Verify All References**
```bash
# For each agent:
- Verify all tasks exist
- Verify all templates exist
- Verify all data files exist
- Verify all commands match workflow expectations
```

---

### Phase 3: Data Directory Audit (THIS WEEK)

**3.1 Complete Data Inventory**
```bash
ls -la .bmad-core/data/
# Document every file
# Verify all references
# Check for orphans
```

**3.2 Create Data File Index**
```markdown
# .bmad-core/data/DATA-FILES-INDEX.md
- testing-stack-guide.md: Testing workflow reference
- test-levels-framework.md: Test level decision framework
- ...
```

---

### Phase 4: Integration Testing (NEXT WEEK)

**4.1 Test Story Creation Flow**
```bash
# Simulate full story creation
1. Create PRD
2. Shard PRD
3. Create architecture
4. Shard architecture
5. Create story
6. Verify all file references work
```

**4.2 Test Architecture Template Generation**
```bash
# Test each template
1. Generate fullstack architecture
2. Verify testing sections render
3. Verify all placeholders filled
4. Check for broken references
```

---

## SUCCESS CRITERIA

### ✅ Phase 1 Complete When:
- [ ] All testing-stack-guide.md references point to correct location
- [ ] devLoadAlwaysFiles matches story expectations
- [ ] Story location pattern is consistent
- [ ] No broken file references in critical tasks

### ✅ Phase 2 Complete When:
- [ ] All agent files read and verified
- [ ] Agent command matrix created
- [ ] All task references validated
- [ ] All template references validated
- [ ] All data file references validated

### ✅ Phase 3 Complete When:
- [ ] Data directory fully documented
- [ ] All data files have descriptions
- [ ] No orphaned files
- [ ] All references verified

### ✅ Phase 4 Complete When:
- [ ] Full story creation flow tested
- [ ] All architecture templates tested
- [ ] End-to-end workflow executed successfully
- [ ] No integration errors

---

## RISK ASSESSMENT

### 🔴 HIGH RISK

**Testing Stack Guide Location Mismatch**
- **Risk**: Story creation fails
- **Impact**: Development blocked
- **Mitigation**: Fix immediately (Phase 1.1)

**Dev File Loading Conflict**
- **Risk**: Dev loads wrong files
- **Impact**: Missing context, incorrect implementation
- **Mitigation**: Fix immediately (Phase 1.2)

### 🟡 MEDIUM RISK

**Agent Command Verification**
- **Risk**: Workflows call non-existent commands
- **Impact**: Workflow execution fails
- **Mitigation**: Verify this week (Phase 2)

**Architecture File Names**
- **Risk**: Tasks reference wrong file names
- **Impact**: File not found errors
- **Mitigation**: Verify this week (Phase 3)

### 🟢 LOW RISK

**Template Testing**
- **Risk**: Templates generate incorrect documents
- **Impact**: Manual fixing required
- **Mitigation**: Test next week (Phase 4)

---

## NEXT STEPS

1. **Execute Phase 1.1** - Fix testing-stack-guide references (15 min)
2. **Execute Phase 1.2** - Update core-config.yaml (10 min)
3. **Execute Phase 1.3** - Clarify story location (5 min)
4. **Commit Phase 1 fixes** - Create consolidation commit
5. **Move to Phase 2** - Agent verification
6. **Report findings** - Update this document with discoveries

---

**Updated**: 2025-10-28 22:20:00
