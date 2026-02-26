# Git Flow Skill

> A philosophy-first Git Flow branching model implementation using pure git commands — no external tools required.

## Overview

This skill provides a complete Git Flow branching model workflow that emphasizes **the philosophy over the tool**. Git Flow is a branching strategy protocol, not a dependency on the `git-flow-avh` CLI. All operations can be performed with native git commands, giving you full control and portability.

## Features

- 🚀 **Pure Git Implementation** — Works anywhere git is installed, no additional tools needed
- ⚙️ **Custom Configuration** — Support for custom branch names and prefixes via `.gitflow` config
- 📊 **Interactive Helper** — Menu-driven script for common Git Flow operations
- 📈 **Status Display** — Visual overview of your Git Flow repository state
- 🧪 **Regression Tests** — Built-in smoke test covering key scenarios

## Quick Start

### Basic Setup

```bash
# Clone or download this skill
cd gitflow/

# Run the interactive setup
bash scripts/setup_gitflow.sh

# Or use pure git manually
git checkout main
git checkout -b develop
git push -u origin develop
```

### Create Your First Feature

```bash
# Using the helper (recommended)
bash scripts/gitflow_helper.sh

# Or use pure git
git checkout develop
git checkout -b feature/my-feature

# ... work on your feature ...

# Finish the feature
git checkout develop
git merge --no-ff feature/my-feature
git branch -d feature/my-feature
```

## Project Structure

```
gitflow/
├── SKILL.md                 # Complete skill documentation
├── scripts/
│   ├── gitflow_helper.sh    # Interactive helper (main tool)
│   ├── setup_gitflow.sh     # Repository setup
│   ├── gitflow_status.sh    # Status checker
│   └── smoke_test.sh        # Regression tests
└── references/
    └── workflow.md          # Detailed workflow reference
```

## Scripts

### gitflow_helper.sh
Interactive menu-driven helper for all Git Flow operations:
- Start/finish features
- Start/finish releases
- Start/finish hotfixes
- Publish branches
- Show status

### setup_gitflow.sh
Initialize a new repository with Git Flow:
- Creates `develop` branch from `main`/`master`
- Generates `.gitflow` config file
- Supports custom branch names and prefixes

### gitflow_status.sh
Display current Git Flow repository state:
- Current branch
- Main branches (main/master, develop)
- Feature/release/hotfix branches
- Recent tags

### smoke_test.sh
Regression test covering:
- New repo with `init.defaultBranch=main`
- New repo with `init.defaultBranch=master` (auto-renamed to main)
- Custom branch names and prefixes

## Branch Model

| Branch | Purpose | Source | Merge To |
|--------|---------|--------|----------|
| `main`/`master` | Production | - | - |
| `develop` | Integration | `main` | - |
| `feature/*` | New features | `develop` | `develop` |
| `release/*` | Release prep | `develop` | `develop`, `main` |
| `hotfix/*` | Production fixes | `main` | `develop`, `main` |

> **Note**: Examples use default naming. If your `.gitflow` config uses custom names (e.g., `dev` instead of `develop`), substitute accordingly.

## Configuration

The `.gitflow` file stores your branch naming preferences:

```ini
[gitflow "branch"]
    master = main
    develop = develop
[gitflow "prefix"]
    feature = feature/
    release = release/
    hotfix = hotfix/
```

All helper scripts automatically read and respect this configuration.

## Usage Examples

### Start a Feature
```bash
git checkout develop && git checkout -b feature/user-auth
```

### Finish a Feature
```bash
git checkout develop && git merge --no-ff feature/user-auth && git branch -d feature/user-auth
```

### Start a Release
```bash
git checkout develop && git checkout -b release/1.0.0
```

### Finish a Release
```bash
git checkout main && git merge --no-ff release/1.0.0 && git tag -a 1.0.0
git checkout develop && git merge --no-ff release/1.0.0 && git branch -d release/1.0.0
```

### Start a Hotfix
```bash
git checkout main && git checkout -b hotfix/1.0.1
```

### Finish a Hotfix
```bash
git checkout main && git merge --no-ff hotfix/1.0.1 && git tag -a 1.0.1
git checkout develop && git merge --no-ff hotfix/1.0.1 && git branch -d hotfix/1.0.1
```

## Requirements

- Git 2.0+
- Bash 4.0+

## Installation

Simply clone or download this repository. The scripts are self-contained and don't require any installation.

```bash
# Make scripts executable (optional, already set)
chmod +x gitflow/scripts/*.sh

# Run the setup
bash gitflow/scripts/setup_gitflow.sh
```

## Testing

Run the regression test suite:

```bash
bash gitflow/scripts/smoke_test.sh
```

Expected output:
```
=== Git Flow Smoke Test ===

Test 1: New repo (init.defaultBranch=main)
✓ PASS: New repo with main default

Test 2: New repo (init.defaultBranch=master)
✓ PASS: New repo with master default (renamed to main)

Test 3: Custom branch names (.gitflow config)
✓ PASS: Custom branch names recognized

=== Summary ===
Passed: 3
Failed: 0
All tests passed!
```

## Philosophy

> **Git Flow is a branching model, NOT a tool.**

The git-flow-avh CLI is just a wrapper around native git commands. Understanding the underlying git commands gives you:
- **No dependencies** — works anywhere git is installed
- **Full control** — understand and customize each operation
- **Debugging** — know exactly what's happening
- **Portability** — not tied to a specific tool

## License

MIT License - feel free to use and modify for your projects.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Credits

Based on the original [Git Flow](http://nvie.com/posts/a-successful-git-branching-model/) by Vincent Driessen.
