#!/bin/bash
# Pre-QA Handoff Validation Script
# Ensures Dev completed all mandatory steps before creating QA Handoff
# Usage: Run from project root: bash .bmad-core/scripts/validate-pre-qa-handoff.sh

set -e  # Exit on error

echo ""
echo "🔍 PRE-QA HANDOFF VALIDATION"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# ============================================
# CHECK 1: Uncommitted Changes
# ============================================
echo "CHECK 1: Implementation Committed"
echo "-----------------------------------"

if [[ -n $(git status --porcelain | grep -v "^??") ]]; then
  echo -e "${RED}❌ FAIL: Uncommitted changes detected${NC}"
  echo ""
  echo "Modified/staged files that MUST be committed:"
  git status --short | grep -v "^??"
  echo ""
  echo -e "${YELLOW}ACTION: Commit implementation files BEFORE creating QA Handoff${NC}"
  echo "Command: git add . && git commit -m 'feat(story-X.Y): Implementation complete'"
  echo ""
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}✅ PASS: All implementation files committed${NC}"
fi

echo ""

# ============================================
# CHECK 2: Implementation Commit Exists
# ============================================
echo "CHECK 2: Implementation Commit Format"
echo "--------------------------------------"

LAST_COMMIT=$(git log -1 --pretty=format:"%s")
if [[ $LAST_COMMIT =~ ^feat\(story-[0-9]+\.[0-9]+\): ]]; then
  echo -e "${GREEN}✅ PASS: Recent implementation commit found${NC}"
  echo "Last commit: $LAST_COMMIT"
elif [[ $LAST_COMMIT =~ ^docs\(story-[0-9]+\.[0-9]+\): ]]; then
  echo -e "${GREEN}✅ PASS: Test Insights commit found (implementation likely committed before)${NC}"
  echo "Last commit: $LAST_COMMIT"
else
  echo -e "${YELLOW}⚠️  WARNING: Last commit doesn't match expected format${NC}"
  echo "Last commit: $LAST_COMMIT"
  echo "Expected: feat(story-X.Y): Implementation complete"
  echo ""
  WARNINGS=$((WARNINGS + 1))
fi

echo ""

# ============================================
# CHECK 3: Test Insights Document Exists
# ============================================
echo "CHECK 3: Test Insights Document"
echo "---------------------------------"

# Find most recent story number from git log
STORY_NUM=$(git log -10 --pretty=format:"%s" | grep -oP 'story-\K[0-9]+\.[0-9]+' | head -1)

if [[ -z "$STORY_NUM" ]]; then
  echo -e "${YELLOW}⚠️  WARNING: Cannot determine current story number from git log${NC}"
  WARNINGS=$((WARNINGS + 1))
else
  # Try to find Test Insights document
  TEST_INSIGHTS_PATTERN="docs/qa/test-insights/**/*$STORY_NUM*.md"
  TEST_INSIGHTS_FILES=$(find docs/qa/test-insights -name "*$STORY_NUM*test-insights.md" 2>/dev/null || echo "")

  if [[ -n "$TEST_INSIGHTS_FILES" ]]; then
    echo -e "${GREEN}✅ PASS: Test Insights document exists${NC}"
    echo "Found: $TEST_INSIGHTS_FILES"
  else
    echo -e "${YELLOW}⚠️  WARNING: Test Insights document not found for story $STORY_NUM${NC}"
    echo "Expected location: docs/qa/test-insights/sprint-N/epics/epic-N/$STORY_NUM-*-test-insights.md"
    WARNINGS=$((WARNINGS + 1))
  fi
fi

echo ""

# ============================================
# CHECK 4: Vitest Tests Passed (if exist)
# ============================================
echo "CHECK 4: Vitest Tests Status"
echo "------------------------------"

if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
  echo "Vitest tests configured. Checking if they pass..."
  echo -e "${YELLOW}NOTE: Run 'npm run test' manually to verify all tests pass${NC}"
  WARNINGS=$((WARNINGS + 1))
else
  echo "No Vitest tests configured (this is OK if story has no complex logic)"
fi

echo ""

# ============================================
# CHECK 5: Background Processes Running
# ============================================
echo "CHECK 5: Background Processes"
echo "------------------------------"

# Check common development ports
FRONTEND_PORT=5173
BACKEND_PORT=8000

FRONTEND_RUNNING=$(netstat -an 2>/dev/null | grep ":$FRONTEND_PORT.*LISTEN" || echo "")
BACKEND_RUNNING=$(netstat -an 2>/dev/null | grep ":$BACKEND_PORT.*LISTEN" || echo "")

if [[ -n "$FRONTEND_RUNNING" ]]; then
  echo -e "${GREEN}✅ Frontend running on port $FRONTEND_PORT${NC}"
else
  echo -e "${YELLOW}⚠️  Frontend not detected on port $FRONTEND_PORT${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

if [[ -n "$BACKEND_RUNNING" ]]; then
  echo -e "${GREEN}✅ Backend running on port $BACKEND_PORT${NC}"
else
  echo -e "${YELLOW}⚠️  Backend not detected on port $BACKEND_PORT${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

echo ""

# ============================================
# FINAL SUMMARY
# ============================================
echo "================================"
echo "VALIDATION SUMMARY"
echo "================================"
echo ""

if [[ $ERRORS -eq 0 ]]; then
  echo -e "${GREEN}✅ VALIDATION PASSED${NC}"
  echo ""
  echo "All critical checks passed. You may proceed with QA Handoff creation."
  echo ""
  if [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  $WARNINGS warning(s) found - review above${NC}"
  fi
  exit 0
else
  echo -e "${RED}❌ VALIDATION FAILED${NC}"
  echo ""
  echo "Found $ERRORS critical error(s) and $WARNINGS warning(s)."
  echo ""
  echo -e "${RED}DO NOT CREATE QA HANDOFF until errors are resolved.${NC}"
  echo ""
  exit 1
fi
