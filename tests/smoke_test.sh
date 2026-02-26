#!/usr/bin/env bash
#
# Git Flow Smoke Test
# Minimal regression test covering key scenarios
#
# Usage: bash tests/smoke_test.sh
#

set -e

# Get script directory (for absolute paths to other scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SETUP_SCRIPT="$PROJECT_ROOT/skills/gitflow/scripts/setup_gitflow.sh"
STATUS_SCRIPT="$PROJECT_ROOT/skills/gitflow/scripts/gitflow_status.sh"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

pass_count=0
fail_count=0

print_result() {
    local result=$1
    local name=$2
    if [[ "$result" == "pass" ]]; then
        echo -e "${GREEN}✓ PASS${NC}: $name"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $name"
        fail_count=$((fail_count + 1))
    fi
}

cleanup() {
    cd /tmp
    rm -rf "$TEST_DIR"
}

echo -e "${BLUE}=== Git Flow Smoke Test ===${NC}"
echo ""

# Test 1: New repo with defaultBranch=main
echo -e "${BLUE}Test 1: New repo (init.defaultBranch=main)${NC}"
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
git init -b main > /dev/null 2>&1
bash "$SETUP_SCRIPT" > /dev/null 2>&1 << INPUT
main
develop
feature/
release/
hotfix/
y
INPUT
if git show-ref --verify --quiet refs/heads/main && git show-ref --verify --quiet refs/heads/develop; then
    print_result "pass" "New repo with main default"
else
    print_result "fail" "New repo with main default"
fi
cleanup
echo ""

# Test 2: New repo with defaultBranch=master
echo -e "${BLUE}Test 2: New repo (init.defaultBranch=master)${NC}"
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
git init -b master > /dev/null 2>&1
bash "$SETUP_SCRIPT" > /dev/null 2>&1 << INPUT
main
develop
feature/
release/
hotfix/
y
INPUT
# Should rename master to main, create develop
if git show-ref --verify --quiet refs/heads/main && git show-ref --verify --quiet refs/heads/develop; then
    if ! git show-ref --verify --quiet refs/heads/master 2>/dev/null; then
        print_result "pass" "New repo with master default (renamed to main)"
    else
        print_result "fail" "New repo with master default (master not renamed)"
    fi
else
    print_result "fail" "New repo with master default"
fi
cleanup
echo ""

# Test 3: Custom branch names and prefixes
echo -e "${BLUE}Test 3: Custom branch names (.gitflow config)${NC}"
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
git init -b main > /dev/null 2>&1
# Setup with custom names
bash "$SETUP_SCRIPT" > /dev/null 2>&1 << INPUT
main
dev
feat/
rel/
fix/
y
INPUT
# Check .gitflow config
if grep -q "develop = dev" .gitflow && grep -q "feature = feat/" .gitflow; then
    # Check gitflow_status recognizes custom config
    bash "$STATUS_SCRIPT" | grep -q "dev" && print_result "pass" "Custom branch names recognized"
else
    print_result "fail" "Custom .gitflow config not created"
fi
cleanup
echo ""

# Test 4: Empty repo with untracked README.md
echo -e "${BLUE}Test 4: Empty repo with untracked README.md${NC}"
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
git init > /dev/null 2>&1
echo "# My Custom README" > README.md
bash "$SETUP_SCRIPT" > /dev/null 2>&1 << INPUT
main
develop
feature/
release/
hotfix/
y
INPUT
# Verify: should have valid HEAD and branches
if git show-ref --verify --quiet refs/heads/main && git show-ref --verify --quiet refs/heads/develop; then
    if [[ "$(git rev-parse --abbrev-ref HEAD)" == "develop" ]]; then
        print_result "pass" "Empty repo with untracked README handled correctly"
    else
        print_result "fail" "HEAD not on develop branch"
    fi
else
    print_result "fail" "Branches not created properly"
fi
cleanup
echo ""

# Test 5: gitflow_status.sh on empty repo
echo -e "${BLUE}Test 5: gitflow_status.sh on empty repo${NC}"
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
git init > /dev/null 2>&1
if bash "$STATUS_SCRIPT" 2>&1 | grep -q "No commits found"; then
    print_result "pass" "gitflow_status.sh handles unborn HEAD gracefully"
else
    print_result "fail" "gitflow_status.sh should detect unborn HEAD"
fi
cleanup
echo ""

# Summary
echo -e "${BLUE}=== Summary ===${NC}"
echo -e "Passed: ${GREEN}$pass_count${NC}"
echo -e "Failed: ${RED}$fail_count${NC}"

if [[ $fail_count -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
