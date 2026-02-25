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

# Check if in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_color "$RED" "Error: Not a git repository"
    exit 1
fi

# Get current branch
CURRENT=$(git rev-parse --abbrev-ref HEAD)

# Header
echo ""
print_color "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$BLUE" "Git Flow Repository Status"
print_color "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Current branch
print_color "$CYAN" "Current Branch:"
if [[ "$CURRENT" == "develop" ]]; then
    print_color "$GREEN" "  ➤ $CURRENT (development)"
elif [[ "$CURRENT" == "main" ]] || [[ "$CURRENT" == "master" ]]; then
    print_color "$YELLOW" "  ➤ $CURRENT (production)"
elif [[ "$CURRENT" == feature/* ]]; then
    print_color "$CYAN" "  ➤ $CURRENT (feature)"
elif [[ "$CURRENT" == release/* ]]; then
    print_color "$CYAN" "  ➤ $CURRENT (release)"
elif [[ "$CURRENT" == hotfix/* ]]; then
    print_color "$RED" "  ➤ $CURRENT (hotfix)"
else
    echo "  ➤ $CURRENT"
fi
echo ""

# Main branches
print_color "$CYAN" "Main Branches:"

if git show-ref --verify --quiet refs/heads/main 2>/dev/null; then
    MAIN_COMMIT=$(git log -1 --pretty=format:"%h - %s" main 2>/dev/null || echo "N/A")
    echo "  main/master: $MAIN_COMMIT"
elif git show-ref --verify --quiet refs/heads/master 2>/dev/null; then
    MASTER_COMMIT=$(git log -1 --pretty=format:"%h - %s" master 2>/dev/null || echo "N/A")
    echo "  master: $MASTER_COMMIT"
else
    print_color "$YELLOW" "  main/master: (not found - run git flow init)"
fi

if git show-ref --verify --quiet refs/heads/develop 2>/dev/null; then
    DEV_COMMIT=$(git log -1 --pretty=format:"%h - %s" develop 2>/dev/null || echo "N/A")
    echo "  develop: $DEV_COMMIT"
else
    print_color "$YELLOW" "  develop: (not found - run git flow init)"
fi

echo ""

# Feature branches
print_color "$CYAN" "Feature Branches:"
FEATURES=$(git show-ref --heads | grep "refs/heads/feature/" || true)
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
RELEASES=$(git show-ref --heads | grep "refs/heads/release/" || true)
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
HOTFIXES=$(git show-ref --heads | grep "refs/heads/hotfix/" || true)
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
