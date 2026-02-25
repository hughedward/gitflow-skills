#!/usr/bin/env bash
#
# Git Flow Interactive Helper
# Provides menu-driven interface for common Git Flow operations
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

# Check if git flow is initialized
check_gitflow() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_color "$RED" "Error: Not a git repository"
        exit 1
    fi

    # Check for git flow branches
    if ! git show-ref --verify --quiet refs/heads/develop 2>/dev/null; then
        print_color "$YELLOW" "Warning: Git Flow not initialized. Run 'git flow init' first."
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

    local current=$(current_branch)
    print_color "$GREEN" "Current branch: $current"

    echo ""
    echo "Main branches:"
    git show-ref --heads | grep -E "(refs/heads/(main|master|develop))" || echo "  No main branches found"

    echo ""
    echo "Feature branches:"
    git show-ref --heads | grep "refs/heads/feature/" | sed 's|refs/heads/|  |' || echo "  None"

    echo ""
    echo "Release branches:"
    git show-ref --heads | grep "refs/heads/release/" | sed 's|refs/heads/|  |' || echo "  None"

    echo ""
    echo "Hotfix branches:"
    git show-ref --heads | grep "refs/heads/hotfix/" | sed 's|refs/heads/|  |' || echo "  None"
}

# Start feature
start_feature() {
    echo ""
    read -p "Enter feature name: " name
    if [[ -n "$name" ]]; then
        print_color "$GREEN" "Starting feature: $name"
        git flow feature start "$name"
    fi
}

# Finish feature
finish_feature() {
    echo ""
    local features=$(git show-ref --heads | grep "refs/heads/feature/" | sed 's|refs/heads/feature/||' | sed 's| .*||')

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
        git flow feature finish "$name"
    fi
}

# Start release
start_release() {
    echo ""
    read -p "Enter release version (e.g., 1.2.0): " version
    if [[ -n "$version" ]]; then
        print_color "$GREEN" "Starting release: $version"
        git flow release start "$version"
    fi
}

# Finish release
finish_release() {
    echo ""
    local releases=$(git show-ref --heads | grep "refs/heads/release/" | sed 's|refs/heads/release/||' | sed 's| .*||')

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
        git flow release finish "$version"
    fi
}

# Start hotfix
start_hotfix() {
    echo ""
    read -p "Enter hotfix version (e.g., 1.2.1): " version
    if [[ -n "$version" ]]; then
        print_color "$GREEN" "Starting hotfix: $version"
        git flow hotfix start "$version"
    fi
}

# Finish hotfix
finish_hotfix() {
    echo ""
    local hotfixes=$(git show-ref --heads | grep "refs/heads/hotfix/" | sed 's|refs/heads/hotfix/||' | sed 's| .*||')

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
        git flow hotfix finish "$version"
    fi
}

# Publish branch
publish_branch() {
    echo ""
    echo "Publish options:"
    echo "  1) Feature"
    echo "  2) Release"
    echo ""
    read -p "Select branch type: " type

    case $type in
        1|f|feature)
            read -p "Enter feature name: " name
            [[ -n "$name" ]] && git flow feature publish "$name"
            ;;
        2|r|release)
            read -p "Enter release version: " version
            [[ -n "$version" ]] && git flow release publish "$version"
            ;;
    esac
}

# Main menu
show_menu() {
    print_header "Git Flow Helper"

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
        9|init)
            print_color "$GREEN" "Initializing Git Flow..."
            git flow init -d
            ;;
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
