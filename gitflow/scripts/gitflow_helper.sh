#!/usr/bin/env bash
#
# Git Flow Interactive Helper (Pure Git Implementation)
# Provides menu-driven interface for common Git Flow operations
# Uses native git commands only - no git-flow-avh dependency
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored message
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Print header
print_header() {
    echo ""
    print_color "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_color "$BLUE" "$1"
    print_color "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Detect production branch name (main or master)
get_prod_branch() {
    # First check .gitflow config
    if [[ -f ".gitflow" ]]; then
        local from_config=$(grep '^\[gitflow "branch"\]' -A 10 .gitflow 2>/dev/null | grep "master =" | cut -d'=' -f2 | xargs)
        if [[ -n "$from_config" ]]; then
            echo "$from_config"
            return
        fi
    fi
    # Fallback to detection
    if git show-ref --verify --quiet refs/heads/main 2>/dev/null; then
        echo "main"
    elif git show-ref --verify --quiet refs/heads/master 2>/dev/null; then
        echo "master"
    else
        echo "main"  # Default
    fi
}

# Read .gitflow config, fallback to default
get_config() {
    local section=$1  # e.g., "branch", "prefix"
    local key=$2      # e.g., "master", "develop", "feature"
    local default=$3  # fallback value

    if [[ -f ".gitflow" ]]; then
        # Parse gitflow config file
        local value=$(grep "^\[gitflow \"$section\"\]" -A 10 .gitflow 2>/dev/null | grep "^    $key =" | cut -d'=' -f2 | xargs)
        echo "${value:-$default}"
    else
        echo "$default"
    fi
}

# Check if git flow is initialized
check_gitflow() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_color "$RED" "Error: Not a git repository"
        exit 1
    fi

    # Get develop branch name from config or default
    local dev_branch=$(get_config "branch" "develop" "develop")

    # Check for git flow branches
    if ! git show-ref --verify --quiet "refs/heads/$dev_branch" 2>/dev/null; then
        print_color "$YELLOW" "Warning: Git Flow not initialized. $dev_branch branch not found."
        return 1
    fi
    return 0
}

# Get current branch
current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# Show current Git Flow status
show_status() {
    print_header "Git Flow Status"

    # Get config values
    local dev_branch=$(get_config "branch" "develop" "develop")
    local feature_prefix=$(get_config "prefix" "feature" "feature/")
    local release_prefix=$(get_config "prefix" "release" "release/")
    local hotfix_prefix=$(get_config "prefix" "hotfix" "hotfix/")

    local current=$(current_branch)
    print_color "$GREEN" "Current branch: $current"

    echo ""
    echo "Main branches:"
    git show-ref --heads | grep -E "(refs/heads/(main|master|$dev_branch))" || echo "  No main branches found"

    echo ""
    echo "Feature branches:"
    git show-ref --heads | grep "refs/heads/$feature_prefix" | sed 's|refs/heads/|  |' || echo "  None"

    echo ""
    echo "Release branches:"
    git show-ref --heads | grep "refs/heads/$release_prefix" | sed 's|refs/heads/|  |' || echo "  None"

    echo ""
    echo "Hotfix branches:"
    git show-ref --heads | grep "refs/heads/$hotfix_prefix" | sed 's|refs/heads/|  |' || echo "  None"
}

# Start feature (pure git)
start_feature() {
    local dev_branch=$(get_config "branch" "develop" "develop")
    local feature_prefix=$(get_config "prefix" "feature" "feature/")

    echo ""
    read -p "Enter feature name: " name
    if [[ -n "$name" ]]; then
        print_color "$GREEN" "Starting feature: $name"
        git checkout "$dev_branch" 2>/dev/null || git switch "$dev_branch"
        git checkout -b "${feature_prefix}$name" 2>/dev/null || git switch -c "${feature_prefix}$name"
        print_color "$GREEN" "✓ Created ${feature_prefix}$name from $dev_branch"
    fi
}

# Finish feature (pure git)
finish_feature() {
    local dev_branch=$(get_config "branch" "develop" "develop")
    local feature_prefix=$(get_config "prefix" "feature" "feature/")

    echo ""
    local features=$(git show-ref --heads | grep "refs/heads/$feature_prefix" | sed "s|refs/heads/$feature_prefix||" | sed 's| .*||')

    if [[ -z "$features" ]]; then
        print_color "$YELLOW" "No feature branches found"
        return
    fi

    echo "Available features:"
    echo "$features" | nl -w2 -s'. '
    echo ""
    read -p "Select feature number or enter name: " input

    local name
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        name=$(echo "$features" | sed -n "${input}p")
    else
        name="$input"
    fi

    if [[ -n "$name" ]]; then
        print_color "$GREEN" "Finishing feature: $name"
        local branch="${feature_prefix}$name"

        # Switch to develop
        git checkout "$dev_branch" 2>/dev/null || git switch "$dev_branch"

        # Merge with --no-ff
        git merge --no-ff "$branch"

        # Delete the feature branch
        git branch -d "$branch"

        print_color "$GREEN" "✓ Merged ${feature_prefix}$name to $dev_branch and deleted branch"
    fi
}

# Start release (pure git)
start_release() {
    local dev_branch=$(get_config "branch" "develop" "develop")
    local release_prefix=$(get_config "prefix" "release" "release/")

    echo ""
    read -p "Enter release version (e.g., 1.2.0): " version
    if [[ -n "$version" ]]; then
        print_color "$GREEN" "Starting release: $version"
        git checkout "$dev_branch" 2>/dev/null || git switch "$dev_branch"
        git checkout -b "${release_prefix}$version" 2>/dev/null || git switch -c "${release_prefix}$version"
        print_color "$GREEN" "✓ Created ${release_prefix}$version from $dev_branch"
    fi
}

# Finish release (pure git)
finish_release() {
    local dev_branch=$(get_config "branch" "develop" "develop")
    local release_prefix=$(get_config "prefix" "release" "release/")

    echo ""
    local releases=$(git show-ref --heads | grep "refs/heads/$release_prefix" | sed "s|refs/heads/$release_prefix||" | sed 's| .*||')

    if [[ -z "$releases" ]]; then
        print_color "$YELLOW" "No release branches found"
        return
    fi

    echo "Available releases:"
    echo "$releases" | nl -w2 -s'. '
    echo ""
    read -p "Select release number or enter version: " input

    local version
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        version=$(echo "$releases" | sed -n "${input}p")
    else
        version="$input"
    fi

    if [[ -n "$version" ]]; then
        print_color "$GREEN" "Finishing release: $version"
        local branch="${release_prefix}$version"
        local prod_branch=$(get_prod_branch)

        # Merge to production branch
        git checkout "$prod_branch" 2>/dev/null || git switch "$prod_branch"
        git merge --no-ff "$branch"

        # Tag the release
        git tag -a "$version" -m "Release $version"

        # Merge back to develop
        git checkout "$dev_branch" 2>/dev/null || git switch "$dev_branch"
        git merge --no-ff "$branch"

        # Delete the release branch
        git branch -d "$branch"

        print_color "$GREEN" "✓ Merged ${release_prefix}$version to $prod_branch and $dev_branch, tagged as $version"
    fi
}

# Start hotfix (pure git)
start_hotfix() {
    local hotfix_prefix=$(get_config "prefix" "hotfix" "hotfix/")

    echo ""
    read -p "Enter hotfix version (e.g., 1.2.1): " version
    if [[ -n "$version" ]]; then
        print_color "$GREEN" "Starting hotfix: $version"
        local prod_branch=$(get_prod_branch)
        git checkout "$prod_branch" 2>/dev/null || git switch "$prod_branch"
        git checkout -b "${hotfix_prefix}$version" 2>/dev/null || git switch -c "${hotfix_prefix}$version"
        print_color "$GREEN" "✓ Created ${hotfix_prefix}$version from $prod_branch"
    fi
}

# Finish hotfix (pure git) - with release branch exception
finish_hotfix() {
    local dev_branch=$(get_config "branch" "develop" "develop")
    local hotfix_prefix=$(get_config "prefix" "hotfix" "hotfix/")
    local release_prefix=$(get_config "prefix" "release" "release/")

    echo ""
    local hotfixes=$(git show-ref --heads | grep "refs/heads/$hotfix_prefix" | sed "s|refs/heads/$hotfix_prefix||" | sed 's| .*||')

    if [[ -z "$hotfixes" ]]; then
        print_color "$YELLOW" "No hotfix branches found"
        return
    fi

    echo "Available hotfixes:"
    echo "$hotfixes" | nl -w2 -s'. '
    echo ""
    read -p "Select hotfix number or enter version: " input

    local version
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        version=$(echo "$hotfixes" | sed -n "${input}p")
    else
        version="$input"
    fi

    if [[ -n "$version" ]]; then
        print_color "$GREEN" "Finishing hotfix: $version"
        local branch="${hotfix_prefix}$version"
        local prod_branch=$(get_prod_branch)

        # Merge to production branch
        git checkout "$prod_branch" 2>/dev/null || git switch "$prod_branch"
        git merge --no-ff "$branch"

        # Tag the hotfix
        git tag -a "$version" -m "Hotfix $version"

        # Check for active release branch (hotfix exception rule)
        local release_branch=$(git show-ref --heads | grep "refs/heads/$release_prefix" | sed "s|refs/heads/||" | sed 's| .*||' | head -1)

        if [[ -n "$release_branch" ]]; then
            # Merge to release branch instead of develop
            git checkout "$release_branch" 2>/dev/null || git switch "$release_branch"
            git merge --no-ff "$branch"
            print_color "$GREEN" "✓ Merged ${hotfix_prefix}$version to $prod_branch and $release_branch, tagged as $version"
        else
            # No release branch, merge to develop
            git checkout "$dev_branch" 2>/dev/null || git switch "$dev_branch"
            git merge --no-ff "$branch"
            print_color "$GREEN" "✓ Merged ${hotfix_prefix}$version to $prod_branch and $dev_branch, tagged as $version"
        fi

        # Delete the hotfix branch
        git branch -d "$branch"
    fi
}

# Publish branch (pure git)
publish_branch() {
    local feature_prefix=$(get_config "prefix" "feature" "feature/")
    local release_prefix=$(get_config "prefix" "release" "release/")
    local hotfix_prefix=$(get_config "prefix" "hotfix" "hotfix/")

    echo ""
    echo "Publish options:"
    echo "  1) Feature"
    echo "  2) Release"
    echo "  3) Hotfix"
    echo ""
    read -p "Select branch type: " type

    local branch=""
    case $type in
        1|f|feature)
            read -p "Enter feature name: " name
            branch="${feature_prefix}$name"
            ;;
        2|r|release)
            read -p "Enter release version: " version
            branch="${release_prefix}$version"
            ;;
        3|h|hotfix)
            read -p "Enter hotfix version: " version
            branch="${hotfix_prefix}$version"
            ;;
        *)
            print_color "$RED" "Invalid option"
            return
            ;;
    esac

    if [[ -z "$branch" ]]; then
        print_color "$RED" "No branch specified"
        return
    fi

    # Validate branch exists locally
    if ! git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
        print_color "$RED" "Error: Branch '$branch' does not exist locally"
        return
    fi

    # Publish
    git push -u origin "$branch"
    print_color "$GREEN" "✓ Published $branch to origin"
}

# Initialize Git Flow (pure git)
initialize_gitflow() {
    print_header "Initialize Git Flow (Pure Git)"

    local prod_branch=$(get_prod_branch)
    local dev_branch=$(get_config "branch" "develop" "develop")

    # Check if develop exists
    if git show-ref --verify --quiet "refs/heads/$dev_branch" 2>/dev/null; then
        print_color "$YELLOW" "! $dev_branch branch already exists"
        git checkout "$dev_branch" 2>/dev/null || git switch "$dev_branch"
        print_color "$GREEN" "✓ Switched to $dev_branch"
    else
        # Create develop from production branch
        git checkout "$prod_branch" 2>/dev/null || git switch "$prod_branch"
        git checkout -b "$dev_branch" 2>/dev/null || git switch -c "$dev_branch"
        print_color "$GREEN" "✓ Created $dev_branch branch from $prod_branch"
    fi

    echo ""
    print_color "$GREEN" "Git Flow initialized!"
    print_color "$BLUE" "Production branch: $prod_branch"
    print_color "$BLUE" "Development branch: $dev_branch"
    print_color "$BLUE" ""
    print_color "$BLUE" "Next: Create your first feature"
}

# Main menu
show_menu() {
    print_header "Git Flow Helper (Pure Git)"

    cat << 'EOF'
  1) Show status
  2) Start feature
  3) Finish feature
  4) Start release
  5) Finish release
  6) Start hotfix
  7) Finish hotfix
  8) Publish branch
  9) Initialize Git Flow
  0) Exit
EOF

    echo ""
    read -p "Select option: " choice

    case $choice in
        1|s|status) show_status ;;
        2|sf) start_feature ;;
        3|ff) finish_feature ;;
        4|sr) start_release ;;
        5|fr) finish_release ;;
        6|sh) start_hotfix ;;
        7|fh) finish_hotfix ;;
        8|pb) publish_branch ;;
        9|init) initialize_gitflow ;;
        0|q|e|exit) exit 0 ;;
        *)
            print_color "$RED" "Invalid option"
            ;;
    esac
}

# Main loop
main() {
    check_gitflow || true

    while true; do
        show_menu
        echo ""
        read -p "Press Enter to continue..."
    done
}

main
