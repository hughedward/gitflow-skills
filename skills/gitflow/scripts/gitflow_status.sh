#!/usr/bin/env bash
#
# Git Flow Status Checker
# Shows current Git Flow repository status and active branches
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Print colored output
print_color() {
    echo -e "${1}${2}${NC}"
}

# Read .gitflow config, fallback to default
get_config() {
    local section=$1
    local key=$2
    local default=$3

    if [[ -f ".gitflow" ]]; then
        local value=$(grep "^\[gitflow \"$section\"\]" -A 10 .gitflow 2>/dev/null | grep "^    $key =" | cut -d'=' -f2 | xargs)
        echo "${value:-$default}"
    else
        echo "$default"
    fi
}

# Check if in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_color "$RED" "Error: Not a git repository"
    exit 1
fi

# Get current branch
CURRENT=$(git rev-parse --abbrev-ref HEAD)

# Get config values
DEV_BRANCH=$(get_config "branch" "develop" "develop")
PROD_BRANCH=$(get_config "branch" "master" "main")
FEATURE_PREFIX=$(get_config "prefix" "feature" "feature/")
RELEASE_PREFIX=$(get_config "prefix" "release" "release/")
HOTFIX_PREFIX=$(get_config "prefix" "hotfix" "hotfix/")

# Header
echo ""
print_color "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$BLUE" "Git Flow Repository Status"
print_color "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Current branch
print_color "$CYAN" "Current Branch:"
if [[ "$CURRENT" == "$DEV_BRANCH" ]]; then
    print_color "$GREEN" "  ➤ $CURRENT (development)"
elif [[ "$CURRENT" == "$PROD_BRANCH" ]]; then
    print_color "$YELLOW" "  ➤ $CURRENT (production)"
elif [[ "$CURRENT" == ${FEATURE_PREFIX}* ]]; then
    print_color "$CYAN" "  ➤ $CURRENT (feature)"
elif [[ "$CURRENT" == ${RELEASE_PREFIX}* ]]; then
    print_color "$CYAN" "  ➤ $CURRENT (release)"
elif [[ "$CURRENT" == ${HOTFIX_PREFIX}* ]]; then
    print_color "$RED" "  ➤ $CURRENT (hotfix)"
else
    echo "  ➤ $CURRENT"
fi
echo ""

# Main branches
print_color "$CYAN" "Main Branches:"

if git show-ref --verify --quiet "refs/heads/$PROD_BRANCH" 2>/dev/null; then
    PROD_COMMIT=$(git log -1 --pretty=format:"%h - %s" "$PROD_BRANCH" 2>/dev/null || echo "N/A")
    echo "  $PROD_BRANCH: $PROD_COMMIT"
else
    print_color "$YELLOW" "  $PROD_BRANCH: (not found - initialize with: git checkout -b $DEV_BRANCH)"
fi

if git show-ref --verify --quiet "refs/heads/$DEV_BRANCH" 2>/dev/null; then
    DEV_COMMIT=$(git log -1 --pretty=format:"%h - %s" "$DEV_BRANCH" 2>/dev/null || echo "N/A")
    echo "  $DEV_BRANCH: $DEV_COMMIT"
else
    print_color "$YELLOW" "  $DEV_BRANCH: (not found - initialize with: git checkout -b $DEV_BRANCH)"
fi

echo ""

# Feature branches
print_color "$CYAN" "Feature Branches:"
FEATURES=$(git show-ref --heads | grep "refs/heads/$FEATURE_PREFIX" || true)
if [[ -n "$FEATURES" ]]; then
    echo "$FEATURES" | while read -r line; do
        branch=$(echo "$line" | sed 's|.*refs/heads/||')
        hash=$(echo "$line" | cut -d' ' -f1)
        msg=$(git log -1 --pretty=format:"%s" "$hash" 2>/dev/null || echo "N/A")
        echo "  $branch: $msg"
    done
else
    print_color "$YELLOW" "  (none)"
fi

echo ""

# Release branches
print_color "$CYAN" "Release Branches:"
RELEASES=$(git show-ref --heads | grep "refs/heads/$RELEASE_PREFIX" || true)
if [[ -n "$RELEASES" ]]; then
    echo "$RELEASES" | while read -r line; do
        branch=$(echo "$line" | sed 's|.*refs/heads/||')
        hash=$(echo "$line" | cut -d' ' -f1)
        msg=$(git log -1 --pretty=format:"%s" "$hash" 2>/dev/null || echo "N/A")
        echo "  $branch: $msg"
    done
else
    print_color "$YELLOW" "  (none)"
fi

echo ""

# Hotfix branches
print_color "$CYAN" "Hotfix Branches:"
HOTFIXES=$(git show-ref --heads | grep "refs/heads/$HOTFIX_PREFIX" || true)
if [[ -n "$HOTFIXES" ]]; then
    echo "$HOTFIXES" | while read -r line; do
        branch=$(echo "$line" | sed 's|.*refs/heads/||')
        hash=$(echo "$line" | cut -d' ' -f1)
        msg=$(git log -1 --pretty=format:"%s" "$hash" 2>/dev/null || echo "N/A")
        echo "  $branch: $msg"
    done
else
    print_color "$YELLOW" "  (none)"
fi

echo ""

# Recent tags
print_color "$CYAN" "Recent Tags:"
TAGS=$(git tag --sort=-creatordate | head -5 || true)
if [[ -n "$TAGS" ]]; then
    echo "$TAGS" | while read -r tag; do
        msg=$(git tag -l "$tag" --format="%(contents:subject)" 2>/dev/null || echo "")
        if [[ -n "$msg" ]]; then
            echo "  $tag: $msg"
        else
            echo "  $tag"
        fi
    done
else
    print_color "$YELLOW" "  (none)"
fi

echo ""

# Footer
print_color "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
