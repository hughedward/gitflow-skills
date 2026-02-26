#!/usr/bin/env bash
#
# Git Flow Setup Script
# Initializes a new repository with Git Flow branching model
#
# Branch Naming Strategy:
# - Default production branch: main (recommended standard)
# - Legacy master branches will be renamed to main for consistency
# - You can choose 'master' during setup if needed for your team
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
    else
        echo "Setup cancelled: Git repository required"
        exit 1
    fi
fi

echo ""

# Read existing .gitflow config if exists
existing_prod=""
existing_dev="develop"
existing_feature="feature/"
existing_release="release/"
existing_hotfix="hotfix/"

if [[ -f ".gitflow" ]]; then
    existing_prod=$(grep '^\[gitflow "branch"\]' -A 10 .gitflow 2>/dev/null | grep "master =" | cut -d'=' -f2 | xargs)
    existing_dev=$(grep '^\[gitflow "branch"\]' -A 10 .gitflow 2>/dev/null | grep "develop =" | cut -d'=' -f2 | xargs)
    existing_feature=$(grep '^\[gitflow "prefix"\]' -A 10 .gitflow 2>/dev/null | grep "feature =" | cut -d'=' -f2 | xargs)
    existing_release=$(grep '^\[gitflow "prefix"\]' -A 10 .gitflow 2>/dev/null | grep "release =" | cut -d'=' -f2 | xargs)
    existing_hotfix=$(grep '^\[gitflow "prefix"\]' -A 10 .gitflow 2>/dev/null | grep "hotfix =" | cut -d'=' -f2 | xargs)
    echo -e "${YELLOW}! Found existing .gitflow config${NC}"
fi

# Set defaults from existing config or detection
: "${existing_prod:=main}"
: "${existing_dev:=develop}"
: "${existing_feature:=feature/}"
: "${existing_release:=release/}"
: "${existing_hotfix:=hotfix/}"

# Detect actual production branch if existing_prod doesn't match reality
if git show-ref --verify --quiet refs/heads/main 2>/dev/null; then
    [[ -z "$existing_prod" || "$existing_prod" == "master" ]] && existing_prod="main"
elif git show-ref --verify --quiet refs/heads/master 2>/dev/null; then
    [[ -z "$existing_prod" || "$existing_prod" == "main" ]] && existing_prod="master"
fi

echo ""

# Prompt for branch names (using existing config as defaults)
read -p "Production branch name [$existing_prod]: " prod_branch
prod_branch=${prod_branch:-$existing_prod}

read -p "Development branch name [$existing_dev]: " dev_branch
dev_branch=${dev_branch:-$existing_dev}

read -p "Feature branch prefix [$existing_feature]: " feature_prefix
feature_prefix=${feature_prefix:-$existing_feature}

read -p "Release branch prefix [$existing_release]: " release_prefix
release_prefix=${release_prefix:-$existing_release}

read -p "Hotfix branch prefix [$existing_hotfix]: " hotfix_prefix
hotfix_prefix=${hotfix_prefix:-$existing_hotfix}

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

# Check for existing branches (with user's final choices)
has_dev_branch=false
has_main=false

if git show-ref --verify --quiet "refs/heads/$dev_branch" 2>/dev/null; then
    has_dev_branch=true
    echo -e "${YELLOW}! $dev_branch branch already exists${NC}"
fi

if git show-ref --verify --quiet "refs/heads/$prod_branch" 2>/dev/null; then
    has_main=true
    echo -e "${YELLOW}! $prod_branch branch already exists${NC}"
fi

echo ""

# Create branches if they don't exist
if ! "$has_main" && ! "$has_dev_branch"; then
    # Create initial commit if needed
    if [[ -z "$(git ls-files)" ]]; then
        if [[ ! -f README.md ]]; then
            # No README exists, create placeholder
            echo "# Project" > README.md
            git add README.md
        else
            # README exists (untracked), add it as-is
            git add README.md
        fi
        git commit -m "Initial commit"
        echo -e "${GREEN}✓ Initial commit created${NC}"
    fi

    # Handle main/master branch - rename existing if needed
    if git symbolic-ref --quiet HEAD >/dev/null 2>&1; then
        current_head=$(git symbolic-ref --short HEAD)
        if [[ "$current_head" != "$prod_branch" ]]; then
            git branch -m "$current_head" "$prod_branch"
            echo -e "${GREEN}✓ Renamed '$current_head' to '$prod_branch' (standardizing branch names)${NC}"
        else
            echo -e "${GREEN}✓ Using existing $prod_branch branch${NC}"
        fi
    else
        # No branch yet (detached HEAD or empty repo), create branch
        git branch "$prod_branch"
        echo -e "${GREEN}✓ Created $prod_branch branch${NC}"
    fi

    # Create develop branch
    git checkout -b "$dev_branch"
    echo -e "${GREEN}✓ Created $dev_branch branch${NC}"
elif ! "$has_dev_branch"; then
    # Only create develop
    git checkout "$prod_branch"
    git checkout -b "$dev_branch"
    echo -e "${GREEN}✓ Created $dev_branch branch${NC}"
else
    # Both exist, just switch to develop
    git checkout "$dev_branch" 2>/dev/null || git checkout "$dev_branch"
fi

# Always create/update .gitflow config
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
echo -e "${GREEN}✓ Saved .gitflow config (helper scripts will use these settings)${NC}"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}    Git Flow setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Your Configuration:${NC}"
echo "  Production branch:  $prod_branch"
echo "  Development branch: $dev_branch"
echo "  Feature prefix:     $feature_prefix"
echo "  Release prefix:     $release_prefix"
echo "  Hotfix prefix:      $hotfix_prefix"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Create your first feature:"
echo "     git checkout $dev_branch && git checkout -b ${feature_prefix}<name>"
echo ""
echo "  2. Or run the interactive helper:"
echo "     bash scripts/gitflow_helper.sh"
echo ""
echo -e "${BLUE}Current branch:${NC} $dev_branch"
echo ""
