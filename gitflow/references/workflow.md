# Git Flow Detailed Workflow Reference

> **Note on Branch Names**: Examples use default Git Flow naming (`main`, `develop`, `feature/*`, `release/*`, `hotfix/*`).
> If your `.gitflow` config uses custom names (e.g., `dev` instead of `develop`), substitute accordingly.

Complete reference for Git Flow branching model operations and workflows.

> **Philosophy-First**: Git Flow is a branching model, not a tool. All operations can be done with pure git commands.
> The git-flow-avh CLI is optional. This reference shows both approaches.

## Branch Overview

```
                    (hotfix)
                       │
           ┌───────────┴───────────┐
           ▼                       ▼
    ┌────────────┐           ┌────────────┐
    │   main     │◄──────────┤  hotfix/*  │
    └────────────┘           └────────────┘
           │                       │
           │ (release)             │
           │                       │
           ▼                       ▼
    ┌────────────┐           ┌────────────┐
    │ develop    │◄──────────┤ release/*  │
    └────────────┘           └────────────┘
           │
           │ (feature)
           │
           ▼
    ┌────────────┐
    │ feature/*  │
    └────────────┘
```

## Branch Types in Detail

### main/master (Production Branch)

- **Purpose**: Contains production-ready code
- **Stability**: Every commit is a potential production release
- **Protection**: Should be protected from direct pushes
- **Tags**: Each merge is tagged with version number

### develop (Development Branch)

- **Purpose**: Integration branch for next release
- **Source**: All feature branches branch from here
- **Destination**: All feature branches merge back here
- **Builds**: Used for nightly/continuous builds

### feature/* (Feature Branches)

- **Purpose**: Develop new features
- **Lifetime**: Short-term (days to weeks)
- **Location**: Developer local only (not pushed to origin)
- **Rules**:
  - Branch from: `develop`
  - Merge back to: `develop`
  - Use `--no-ff` flag when merging

### release/* (Release Branches)

- **Purpose**: Prepare new production release
- **Activities**: Bug fixes, version bumping, metadata updates
- **Lifetime**: Short-term (hours to days)
- **Rules**:
  - Branch from: `develop`
  - Merge to: `develop` AND `main/master`
  - Tag the merge on `main/master`

### hotfix/* (Hotfix Branches)

- **Purpose**: Emergency production bug fixes
- **Lifetime**: Very short-term (hours)
- **Rules**:
  - Branch from: `main/master`
  - Merge to: `develop` AND `main/master`
  - **Exception**: If release branch exists, merge there instead of develop

## Command Reference

> **Note**: Pure git commands work everywhere. The git-flow tool is optional.

### Initialization

| Pure Git | git-flow Tool (Optional) |
|----------|--------------------------|
| ```bash<br># Create develop from main<br>git checkout main<br>git checkout -b develop<br>git push -u origin develop<br>``` | ```bash<br># Interactive setup<br>git flow init<br><br># Defaults (no prompts)<br>git flow init -d<br>``` |

### Feature Commands

| Pure Git | git-flow Tool (Optional) |
|----------|--------------------------|
| ```bash<br># Start new feature<br>git checkout develop<br>git checkout -b feature/<name><br>``` | ```bash<br>git flow feature start <name><br>``` |
| ```bash<br># Finish feature<br>git checkout develop<br>git merge --no-ff feature/<name><br>git branch -d feature/<name><br>``` | ```bash<br>git flow feature finish <name><br>``` |
| ```bash<br># Publish feature to remote<br>git push -u origin feature/<name><br>``` | ```bash<br>git flow feature publish <name><br>``` |

| ```bash<br># Track remote feature<br>git fetch origin<br>git checkout feature/<name><br>``` | ```bash<br>git flow feature track <name><br>``` |

| ```bash<br># List features<br>git branch | grep feature/<br>``` | ```bash<br>git flow feature list<br>``` |

### Release Commands

| Pure Git | git-flow Tool (Optional) |
|----------|--------------------------|
| ```bash<br># Start new release<br>git checkout develop<br>git checkout -b release/<version><br>``` | ```bash<br>git flow release start <version><br>``` |
| ```bash<br># Finish release<br>git checkout main<br>git merge --no-ff release/<version><br>git tag -a <version> -m "Release"<br>git checkout develop<br>git merge --no-ff release/<version><br>git branch -d release/<version><br>``` | ```bash<br>git flow release finish <version><br>``` |
| ```bash<br># Publish release<br>git push -u origin release/<version><br>``` | ```bash<br>git flow release publish <version><br>``` |
| ```bash<br># List releases<br>git branch | grep release/<br>``` | ```bash<br>git flow release list<br>``` |

### Hotfix Commands

| Pure Git | git-flow Tool (Optional) |
|----------|--------------------------|
| ```bash<br># Start new hotfix<br>git checkout main<br>git checkout -b hotfix/<version><br>``` | ```bash<br>git flow hotfix start <version><br>``` |
| ```bash<br># Finish hotfix<br>git checkout main<br>git merge --no-ff hotfix/<version><br>git tag -a <version> -m "Hotfix"<br>git checkout develop<br>git merge --no-ff hotfix/<version><br>git branch -d hotfix/<version><br>``` | ```bash<br>git flow hotfix finish <version><br>``` |
| ```bash<br># Publish hotfix<br>git push -u origin hotfix/<version><br>``` | ```bash<br>git flow hotfix publish <version><br>``` |

> **Hotfix Exception**: If a release branch is active, merge hotfix to release instead of develop.

## Common Workflows

### 1. Daily Feature Development

```bash
# Morning: Pull latest develop
git checkout develop
git pull origin develop

# Start new feature
git checkout develop
git checkout -b feature/new-auth-system

# Work... (make commits)

# End of day: Push feature (for backup/team sharing)
git push -u origin feature/new-auth-system

# When done: Finish feature
git checkout develop
git merge --no-ff feature/new-auth-system
git branch -d feature/new-auth-system
# This merges to develop with --no-ff, deletes feature branch
```

### 2. Release Cycle

```bash
# When develop is ready for release
git checkout develop
git checkout -b release/2.0.0

# Update version files
./bump-version.sh 2.0.0
git commit -am "Bump version to 2.0.0"

# Fix bugs found during testing...
# Make commits...

# When ready: Finish release
git checkout main
git merge --no-ff release/2.0.0
git tag -a 2.0.0 -m "Release version 2.0.0"
git checkout develop
git merge --no-ff release/2.0.0
git branch -d release/2.0.0
# This:
# 1. Merges release/2.0.0 to main
# 2. Tags main as 2.0.0
# 3. Merges release/2.0.0 back to develop
# 4. Deletes release branch
```

### 3. Production Hotfix

```bash
# Critical bug found in production
git checkout main
git checkout -b hotfix/2.0.1

# Fix the bug...
git commit -am "Fix critical login bug"

# When tested and ready
git checkout main
git merge --no-ff hotfix/2.0.1
git tag -a 2.0.1 -m "Hotfix: Fix critical login bug"
git checkout develop
git merge --no-ff hotfix/2.0.1
git branch -d hotfix/2.0.1
# This:
# 1. Merges hotfix/2.0.1 to main
# 2. Tags main as 2.0.1
# 3. Merges hotfix/2.0.1 back to develop
# 4. Deletes hotfix branch
```

### 4. Team Collaboration

```bash
# Developer A: Start and publish feature
git checkout develop
git checkout -b feature/payment-gateway
# ... work ...
git push -u origin feature/payment-gateway

# Developer B: Track and contribute
git fetch origin
git checkout feature/payment-gateway
# ... work ...
git push origin feature/payment-gateway

# Developer A: Finish when ready
git checkout develop
git merge --no-ff feature/payment-gateway
git branch -d feature/payment-gateway
```

## Version Numbering

Use semantic versioning:

```
MAJOR.MINOR.PATCH

Example: 2.1.3
  2 = Major version (incompatible API changes)
  1 = Minor version (new features, backward compatible)
  3 = Patch version (bug fixes, backward compatible)
```

### Release vs Hotfix Versioning

- **Release**: Increment MINOR (or MAJOR) - `1.2.0`, `2.0.0`
- **Hotfix**: Increment PATCH - `1.2.1`, `1.2.2`

## The --no-ff Flag

Always use `--no-ff` (no fast-forward) when merging in Git Flow:

```bash
# Bad (fast-forward - loses feature history)
git merge feature-branch

# Good (preserves feature history)
git merge --no-ff feature-branch
```

**Why use --no-ff?**
1. Preserves feature branch history
2. Shows which commits belonged to which feature
3. Makes it easy to revert entire features
4. Creates clearer merge commits

Git Flow commands automatically use `--no-ff`.

## Troubleshooting

### "fatal: Not a gitflow repository"

**Cause**: Git Flow branches not initialized

**Solution**:
```bash
git flow init -d
```

### Merge Conflicts During Finish

**Cause**: Branches have diverged

**Solution**:
```bash
# During finish, Git will pause on conflicts
# Edit conflicted files
vim conflicted_file.txt
# Mark as resolved
git add conflicted_file.txt
# Continue merge
git commit
# Retry finish
git flow feature finish <name>
```

### "Branch 'feature/x' already exists"

**Cause**: Feature branch already exists locally

**Solution**:
```bash
# If work is done, finish it
git flow feature finish <name>

# If want to restart, delete first
git branch -D feature/<name>
git flow feature start <name>
```

### Cannot Delete Branch (Checked Out)

**Cause**: Trying to delete currently checked out branch

**Solution**:
```bash
# Checkout another branch first
git checkout develop

# Then delete
git branch -D feature/<name>
```

## Configuration Files

### .git/config (Git Flow section)

```ini
[gitflow "branch"]
    master = main
    develop = develop
[gitflow "prefix"]
    feature = feature/
    release = release/
    hotfix = hotfix/
    versiontag =
[gitflow "path"]
    .gitflow = .gitflow
```

### .gitflow (Optional separate config)

Same format as above, allows separate config file.

## Hooks and Automation

### Git Hooks for Git Flow

Place in `.git/hooks/`:

**post-flow-feature-finish**: Notify team, update issue tracker
**post-flow-release-finish**: Deploy to staging, create GitHub release
**post-flow-hotfix-finish**: Deploy to production, alert team

### Example Hook: Auto-deploy on release

```bash
#!/bin/bash
# .git/hooks/post-flow-release-finish

VERSION=$1
echo "Deploying version $VERSION to staging..."
./deploy-staging.sh $VERSION
```

## Best Practices

1. **Never commit directly to main/master** - always use release/hotfix
2. **Keep features small** - large features are hard to merge
3. **Write descriptive names** - `feature/user-auth` not `feature/f1`
4. **Finish features promptly** - don't let them accumulate
5. **Test releases thoroughly** - they become production
6. **Communicate releases** - team needs to know when release branches exist
7. **Use tags consistently** - all main/master merges should be tagged
8. **Protect main branches** - use GitHub/GitLab branch protection rules

## IDE Integration

### VS Code Extensions

- "GitFlow" by Adjectif (provides Git Flow commands)
- "GitLens" (enhanced Git visualization)

### JetBrains IDEs

- Built-in Git Flow support in IntelliJ IDEA, PyCharm, etc.
- VCS → Git → Git Flow Operations

### Git Clients with Git Flow

- SourceTree
- GitKraken
- Tower
- Fork
