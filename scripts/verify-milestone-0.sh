#!/bin/bash

# Milestone 0 Verification Script
# This script verifies that all Milestone 0 acceptance criteria are met

set -e

echo "🔍 Verifying Milestone 0 Completion..."
echo ""

ERRORS=0
WARNINGS=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅${NC} $1"
    else
        echo -e "${RED}❌${NC} $1"
        ERRORS=$((ERRORS + 1))
    fi
}

warn() {
    echo -e "${YELLOW}⚠️${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

# M0-T1: Monorepo Structure
echo "📁 M0-T1: Monorepo Structure"
[ -d "apps/public" ] && [ -d "apps/client" ] && [ -d "apps/admin" ] && check "All app directories exist"
[ -d "apps-api/workers" ] && check "apps-api/workers directory exists"
[ -d "infra/cloudflare" ] && [ -d "infra/100ge" ] && check "Infrastructure directories exist"
[ -d "db/migrations" ] && [ -d "db/schema" ] && check "Database directories exist"
[ -d "docs" ] && check "Docs directory exists"

# Check for placeholder files
[ -f "apps/public/.gitkeep" ] || [ -f "apps/public/README.md" ] || [ "$(ls -A apps/public 2>/dev/null)" ] && check "apps/public has placeholder or content"
[ -f "apps/client/.gitkeep" ] || [ -f "apps/client/README.md" ] || [ "$(ls -A apps/client 2>/dev/null)" ] && check "apps/client has placeholder or content"
[ -f "apps/admin/.gitkeep" ] || [ -f "apps/admin/README.md" ] || [ "$(ls -A apps/admin 2>/dev/null)" ] && check "apps/admin has placeholder or content"
[ -f "apps-api/workers/.gitkeep" ] || [ -f "apps-api/workers/README.md" ] || [ "$(ls -A apps-api/workers 2>/dev/null)" ] && check "apps-api/workers has placeholder or content"
[ -f "infra/100ge/.gitkeep" ] || [ -f "infra/100ge/README.md" ] || [ "$(ls -A infra/100ge 2>/dev/null)" ] && check "infra/100ge has placeholder or content"
[ -f "db/migrations/.gitkeep" ] || [ "$(ls -A db/migrations 2>/dev/null)" ] && check "db/migrations has placeholder or content"
[ -f "db/schema/.gitkeep" ] || [ "$(ls -A db/schema 2>/dev/null)" ] && check "db/schema has placeholder or content"

echo ""

# M0-T2: Agent Documentation
echo "📚 M0-T2: Agent Documentation"
[ -f "docs/AGENTS.md" ] && check "docs/AGENTS.md exists"

# Check if AGENTS.md has required content
if [ -f "docs/AGENTS.md" ]; then
    grep -q "Cloudflare IaC Agent" docs/AGENTS.md && check "Cloudflare IaC Agent defined"
    grep -q "1.00.ge Infra Agent" docs/AGENTS.md && check "1.00.ge Infra Agent defined"
    grep -q "API & Workflow Agent" docs/AGENTS.md && check "API & Workflow Agent defined"
    grep -q "Frontend UX / Flows Agent" docs/AGENTS.md && check "Frontend UX / Flows Agent defined"
    grep -q "QA & Compliance Agent" docs/AGENTS.md && check "QA & Compliance Agent defined"
    grep -q "Observability & Alerts Agent" docs/AGENTS.md && check "Observability & Alerts Agent defined"
fi

# Check references in ARCHITECTURE.md
if [ -f "docs/ARCHITECTURE.md" ]; then
    grep -q "AGENTS.md" docs/ARCHITECTURE.md && check "ARCHITECTURE.md references AGENTS.md" || warn "ARCHITECTURE.md should reference AGENTS.md"
fi

# Check references in Cursor rules
[ -f ".cursor/rules/00-global.mdc" ] && grep -q "AGENTS.md" .cursor/rules/00-global.mdc && check "Cursor rules reference AGENTS.md"
[ -f ".cursor/rules/01-escriturashoy.mdc" ] && grep -q "AGENTS.md" .cursor/rules/01-escriturashoy.mdc && check "Escriturashoy rules reference AGENTS.md"

echo ""

# M0-T3: Base CI Pipeline
echo "🔧 M0-T3: Base CI Pipeline"
[ -f ".github/workflows/ci.yml" ] && check "CI workflow exists (.github/workflows/ci.yml)"

if [ -f ".github/workflows/ci.yml" ]; then
    grep -q "pull_request" .github/workflows/ci.yml && check "CI runs on pull requests"
    grep -q "npm test\|pnpm test\|yarn test" .github/workflows/ci.yml && check "CI includes test command"
    grep -q "lint" .github/workflows/ci.yml && check "CI includes lint command"
fi

echo ""

# M0-T4: Cursor Rules Wiring
echo "🎯 M0-T4: Cursor Rules Wiring"
[ -d ".cursor/rules" ] && check ".cursor/rules directory exists"
[ -f ".cursor/rules/00-global.mdc" ] && check "Global cursor rules exist"
[ -f ".cursor/rules/01-escriturashoy.mdc" ] && check "Escriturashoy cursor rules exist"
[ -f ".cursor/rules/infra-cloudflare.mdc" ] && check "Cloudflare infra rules exist"
[ -f ".cursor/rules/infra-100ge.mdc" ] && check "1.00.ge infra rules exist"
[ -f ".cursor/rules/apps.mdc" ] && check "Apps rules exist"
[ -f ".cursor/rules/apps-api.mdc" ] && check "Apps-api rules exist"
[ -f ".cursor/rules/tests.mdc" ] && check "Tests rules exist"
[ -f "docs/DEVELOPING-WITH-CURSOR.md" ] && check "DEVELOPING-WITH-CURSOR.md exists"

if [ -f "docs/DEVELOPING-WITH-CURSOR.md" ]; then
    grep -q "AGENTS.md" docs/DEVELOPING-WITH-CURSOR.md && check "DEVELOPING-WITH-CURSOR.md references AGENTS.md"
    grep -q "agent" docs/DEVELOPING-WITH-CURSOR.md && check "DEVELOPING-WITH-CURSOR.md explains agent usage"
fi

echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! Milestone 0 is complete.${NC}"
    echo ""
    echo "⚠️  Manual Verification Required:"
    echo "   - Branch protection on 'main' must be enabled in GitHub settings"
    echo "   - CI status checks should appear on PRs (test by creating a PR)"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  All critical checks passed, but there are $WARNINGS warning(s).${NC}"
    echo ""
    echo "⚠️  Manual Verification Required:"
    echo "   - Branch protection on 'main' must be enabled in GitHub settings"
    echo "   - CI status checks should appear on PRs (test by creating a PR)"
    exit 0
else
    echo -e "${RED}❌ Found $ERRORS error(s) and $WARNINGS warning(s).${NC}"
    echo ""
    echo "Please fix the errors above before considering Milestone 0 complete."
    exit 1
fi

