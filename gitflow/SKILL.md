---
name: gitflow
description: "Git Flow branching model workflow automation for creating features, managing releases, handling hotfixes, repository setup, and branch merging with --no-ff flag"
---

# Git Flow

Git Flow is a branching model for projects with explicit versioned releases and scheduled delivery cycles.

## Quick Start

**For new repository setup:** See "Initialize Repository" below

**For daily workflow:** Use the workflow decision tree to determine which operation to perform

## Workflow Decision Tree

```
Need to work on Git Flow repository?
│
├─ New feature? → Feature Workflow
├─ Prepare release? → Release Workflow
├─ Fix production bug? → Hotfix Workflow
└─ New repository? → Initialize Repository
```

## Initialize Repository

Set up a new repository with Git Flow branches:

```bash
# Initialize Git Flow (default branch names: main/master, develop)
git flow init

# Or with custom branch names
git flow init -d

# Answer prompts for branch names:
# - Production branch: main (or master)
# - Development branch: develop
# - Feature branch prefix: feature/
# - Release branch prefix: release/
# - Hotfix branch prefix: hotfix/
# - Support branch prefix: support/ (optional)
```

**After initialization, you will be on the `develop` branch.**

## Feature Workflow

Use feature branches for developing new features for upcoming releases.

### Start a Feature

```bash
# Start a new feature (creates and checks out feature/<name>)
git flow feature start <feature-name>

# Example
git flow feature start user-authentication
```

This creates `feature/user-authentication` from `develop`.

### Finish a Feature

```bash
# Finish feature (merges to develop, deletes feature branch)
git flow feature finish <feature-name>

# Example
git flow feature finish user-authentication
```

This:
- Merges `feature/user-authentication` to `develop` using `--no-ff`
- Tags the merge (optional, configurable)
- Deletes the feature branch
- Switches back to `develop`

### Publish a Feature (Team Collaboration)

```bash
# Publish feature to remote
git flow feature publish <feature-name>

# Checkout feature from remote
git flow feature checkout <feature-name>

# Pull latest changes
git flow feature pull origin <feature-name>
```

### Track a Feature

```bash
# Track a remote feature branch
git flow feature track <feature-name>
```

## Release Workflow

Use release branches when preparing for a new production release. This allows bug fixes and version bumping.

### Start a Release

```bash
# Start a release (creates from develop)
git flow release start <version>

# Example
git flow release start 1.2.0
```

This creates `release/1.2.0` from `develop`.

### Publish a Release

```bash
# Publish release to remote (allows team collaboration)
git flow release publish <version>

# Example
git flow release publish 1.2.0
```

### Finish a Release

```bash
# Finish release (merges to main AND develop, tags, cleanup)
git flow release finish <version>

# Example with message
git flow release finish 1.2.0 -m "Release version 1.2.0"

# Finish without signing tag
git flow release finish 1.2.0 -n
```

This:
- Merges `release/1.2.0` to `main` using `--no-ff`
- Tags the merge with version name
- Merges `release/1.2.0` back to `develop` using `--no-ff`
- Deletes the release branch
- Switches back to `develop`

## Hotfix Workflow

Use hotfix branches to fix critical production bugs immediately.

### Start a Hotfix

```bash
# Start a hotfix (creates from main/master)
git flow hotfix start <version>

# Example
git flow hotfix start 1.2.1
```

This creates `hotfix/1.2.1` from `main/master`.

### Finish a Hotfix

```bash
# Finish hotfix (merges to main AND develop, tags, cleanup)
git flow hotfix finish <version>

# Example with message
git flow hotfix finish 1.2.1 -m "Hotfix: Fix critical login bug"
```

This:
- Merges `hotfix/1.2.1` to `main/master` using `--no-ff`
- Tags the merge with version name
- Merges `hotfix/1.2.1` back to `develop` using `--no-ff`
- Deletes the hotfix branch
- Switches back to `develop`

**Exception:** If a release branch exists, merge the hotfix into that release branch instead of develop.

## Helper Scripts

This skill includes helper scripts for common Git Flow operations:

- `scripts/gitflow_helper.sh` - Comprehensive Git Flow helper with menu
- `scripts/setup_gitflow.sh` - Initialize Git Flow repository
- `scripts/gitflow_status.sh` - Show current Git Flow status

**Usage:**

```bash
# Run interactive helper
bash scripts/gitflow_helper.sh

# Check Git Flow status
bash scripts/gitflow_status.sh

# Setup new Git Flow repository
bash scripts/setup_gitflow.sh
```

## Branch Summary

| Branch Type | Branch From | Merge To | Naming Convention | Lifetime |
|-------------|-------------|----------|-------------------|----------|
| **main/master** | - | - | `main` or `master` | Indefinite |
| **develop** | - | - | `develop` | Indefinite |
| **feature** | `develop` | `develop` | `feature/*` | Short-term |
| **release** | `develop` | `develop`, `main` | `release/*` | Short-term |
| **hotfix** | `main` | `develop`, `main` | `hotfix/*` | Short-term |

## Best Practices

1. **Always use `--no-ff`** when merging - preserves feature history and enables easy reversion
2. **Keep feature branches focused** - one feature per branch
3. **Write descriptive commit messages** - explain what and why, not just how
4. **Tag releases** - use semantic versioning (e.g., `1.2.0`)
5. **Pull before starting** - ensure `develop` is up-to-date before starting features
6. **Finish work properly** - always use `git flow feature finish` instead of manual merging

## Common Issues

**Issue:** "Not a gitflow repository"
- **Solution:** Run `git flow init` first

**Issue:** Merge conflicts during finish
- **Solution:** Resolve conflicts, then `git add` the files, commit, and retry

**Issue:** Feature branch name contains invalid characters
- **Solution:** Use alphanumeric and hyphens only (e.g., `user-auth` not `user_auth`)

## When NOT to Use Git Flow

Git Flow is NOT ideal for:
- **Continuous delivery** teams - consider GitHub Flow or trunk-based development instead
- **Single developer** projects - overhead may not be justified
- **Web services** with frequent deployments - simpler workflows work better

Git Flow IS ideal for:
- Versioned software releases
- Projects with scheduled release cycles
- Teams supporting multiple production versions
- Mobile apps with app store review processes

## References

See [references/workflow.md](references/workflow.md) for detailed workflow diagrams and advanced patterns.
