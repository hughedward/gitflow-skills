# Git Flow Detailed Workflow Reference

Complete reference for Git Flow branching model operations and workflows.

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

### Initialization

```bash
# Interactive setup
git flow init

# Defaults (no prompts)
git flow init -d

# Custom config
git flow init
# Production branch name: main
# Development branch name: develop
# Feature branches prefix: feature/
# Release branches prefix: release/
# Hotfix branches prefix: hotfix/
# Support branches prefix: support/
```

### Feature Commands

```bash
# Start new feature
git flow feature start <name>

# Finish feature (merge to develop)
git flow feature finish <name>

# Publish feature to remote
git flow feature publish <name>

# Pull feature from remote
git flow feature pull origin <name>

# Track remote feature branch
git flow feature track <name>

# Checkout existing feature
git flow feature checkout <name>

# Delete feature branch
git flow feature delete <name>

# List all features
git flow feature list
```

### Release Commands

```bash
# Start new release
git flow release start <version>

# Finish release (merge to main and develop)
git flow release finish <version>

# Finish with custom message
git flow release finish <version> -m "Release message"

# Finish without signing tag
git flow release finish <version> -n

# Publish release to remote
git flow release publish <version>

# Track remote release
git flow release track <version>

# List all releases
git flow release list
```

### Hotfix Commands

```bash
# Start new hotfix
git flow hotfix start <version>

# Start hotfix with specific base
git flow hotfix start <version> [base_commit]

# Finish hotfix
git flow hotfix finish <version>

# Finish with custom message
git flow hotfix finish <version> -m "Hotfix message"

# Publish hotfix
git flow hotfix publish <version>

# Track remote hotfix
git flow hotfix track <version>

# List all hotfixes
git flow hotfix list
```

## Common Workflows

### 1. Daily Feature Development

```bash
# Morning: Pull latest develop
git checkout develop
git pull origin develop

# Start new feature
git flow feature start new-auth-system

# Work... (make commits)

# End of day: Push feature (for backup/team sharing)
git flow feature publish new-auth-system

# When done: Finish feature
git flow feature finish new-auth-system
# This merges to develop with --no-ff, deletes feature branch
```

### 2. Release Cycle

```bash
# When develop is ready for release
git flow release start 2.0.0

# Update version files
./bump-version.sh 2.0.0
git commit -am "Bump version to 2.0.0"

# Fix bugs found during testing...
# Make commits...

# When ready: Finish release
git flow release finish 2.0.0 -m "Release version 2.0.0"
# This:
# 1. Merges release/2.0.0 to main
# 2. Tags main as 2.0.0
# 3. Merges release/2.0.0 back to develop
# 4. Deletes release branch
```

### 3. Production Hotfix

```bash
# Critical bug found in production
git flow hotfix start 2.0.1

# Fix the bug...
git commit -am "Fix critical login bug"

# When tested and ready
git flow hotfix finish 2.0.1 -m "Hotfix: Fix critical login bug"
# This:
# 1. Merges hotfix/2.0.1 to main
# 2. Tags main as 2.0.1
# 3. Merges hotfix/2.0.1 back to develop
# 4. Deletes hotfix branch
```

### 4. Team Collaboration

```bash
# Developer A: Start and publish feature
git flow feature start payment-gateway
# ... work ...
git flow feature publish payment-gateway

# Developer B: Track and contribute
git flow feature track payment-gateway
# ... work ...
git push origin feature/payment-gateway

# Developer A: Finish when ready
git flow feature finish payment-gateway
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
