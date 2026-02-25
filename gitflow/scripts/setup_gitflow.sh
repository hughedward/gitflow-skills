#!/usr/bin/env bash
#
# Git Flow Setup Script
# Initializes a new repository with Git Flow branching model
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}    Git Flow Repository Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if already a git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}Already a git repository${NC}"
else
    read -p "Initialize new git repository? (y/n) " init_git
    if [[ "$init_git" =~ ^[Yy]$ ]]; then
        git init
        echo -e "${GREEN}✓ Git repository initialized${NC}"
    fi
fi

echo ""

# Check for existing branches
has_develop=false
has_main=false

if git show-ref --verify --quiet refs/heads/develop 2>/dev/null; then
    has_develop=true
    echo -e "${YELLOW}! Develop branch already exists${NC}"
fi

if git show-ref --verify --quiet refs/heads/main 2>/dev/null; then
    has_main=true
    echo -e "${YELLOW}! Main branch already exists${NC}"
elif git show-ref --verify --quiet refs/heads/master 2>/dev/null; then
    has_main=true
    echo -e "${YELLOW}! Master branch already exists${NC}"
fi

echo ""

# Prompt for branch names
read -p "Production branch name [main]: " prod_branch
prod_branch=${prod_branch:-main}

read -p "Development branch name [develop]: " dev_branch
dev_branch=${dev_branch:-develop}

read -p "Feature branch prefix [feature/]: " feature_prefix
feature_prefix=${feature_prefix:-feature/}

read -p "Release branch prefix [release/]: " release_prefix
release_prefix=${release_prefix:-release/}

read -p "Hotfix branch prefix [hotfix/]: " hotfix_prefix
hotfix_prefix=${hotfix_prefix:-hotfix/}

echo ""
echo -e "${BLUE}Configuration:${NC}"
echo "  Production:  $prod_branch"
echo "  Development: $dev_branch"
echo "  Feature:     $feature_prefix"
echo "  Release:     $release_prefix"
echo "  Hotfix:      $hotfix_prefix"
echo ""

read -p "Continue? (y/n) " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Setup cancelled"
    exit 0
fi

echo ""

# Create branches if they don't exist
if ! "$has_main" && ! "$has_develop"; then
    # Create initial commit if needed
    if [[ -z "$(git ls-files)" ]]; then
        # Create a placeholder README
        echo "# Project" > README.md
        git add README.md
        git commit -m "Initial commit"
        echo -e "${GREEN}✓ Initial commit created${NC}"
    fi

    # Create main/master branch
    git branch "$prod_branch"
    echo -e "${GREEN}✓ Created $prod_branch branch${NC}"

    # Create develop branch
    git checkout -b "$dev_branch"
    echo -e "${GREEN}✓ Created $dev_branch branch${NC}"
elif ! "$has_develop"; then
    # Only create develop
    git checkout "$prod_branch"
    git checkout -b "$dev_branch"
    echo -e "${GREEN}✓ Created $dev_branch branch${NC}"
else
    # Both exist, just switch to develop
    git checkout "$dev_branch" 2>/dev/null || git checkout "$dev_branch"
fi

# Create .gitflow config if not exists
if [[ ! -f ".gitflow" ]]; then
    cat > .gitflow << EOF
[gitflow "branch"]
    master = $prod_branch
    develop = $dev_branch
[gitflow "prefix"]
    feature = $feature_prefix
    release = $release_prefix
    hotfix = $hotfix_prefix
    versiontag =
EOF
    echo -e "${GREEN}✓ Created .gitflow config${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}    Git Flow setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Next steps:"
echo "  1. Create your first feature:"
echo "     git flow feature start <name>"
echo ""
echo "  2. Or run the helper:"
echo "     bash scripts/gitflow_helper.sh"
echo ""
