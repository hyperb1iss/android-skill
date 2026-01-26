# LineageOS Gerrit Workflow

## Setup

### SSH Key

```bash
# Generate key if needed
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to Gerrit:
# 1. Go to https://review.lineageos.org/settings/#SSHKeys
# 2. Add your public key
```

### Git Config

```bash
git config --global user.email "your_email@example.com"
git config --global user.name "Your Name"
git config --global review.review.lineageos.org.username YOUR_GERRIT_USERNAME
```

### Test Connection

```bash
ssh -p 29418 YOUR_USERNAME@review.lineageos.org
```

---

## Submitting Changes

### Create Branch

```bash
cd <project_directory>
repo start my-feature-branch .
```

### Make Changes

```bash
# Edit files...
git add -A
git commit
```

### Commit Message

```
component: Short summary (50 chars max)

Detailed explanation of the change. Wrap at 72 characters.
Explain the problem this solves and why this approach was chosen.

- Bullet points are OK
- Keep them concise

Test: Describe how you tested this
Bug: https://jira.lineageos.org/browse/XXXX (if applicable)

Change-Id: I1234567890abcdef (auto-generated, don't edit)
```

### Push for Review

```bash
git push ssh://YOUR_USERNAME@review.lineageos.org:29418/LineageOS/<project> HEAD:refs/for/<branch>

# Example:
git push ssh://bliss@review.lineageos.org:29418/LineageOS/android_frameworks_base HEAD:refs/for/lineage-21.0
```

---

## repopick Commands

### Basic Usage

```bash
repopick <change_number>
repopick 12345
```

### Multiple Changes

```bash
repopick 12345 12346 12347
```

### By Topic

```bash
repopick -t my-topic
```

### Options

| Flag | Purpose |
|------|---------|
| `-f` | Force (overwrite local changes) |
| `-n` | Dry run (show what would happen) |
| `-Q` | Include dependencies |
| `-i` | Interactive (prompt for each) |
| `-c` | Check only (don't apply) |
| `-t <topic>` | Pick all changes in topic |

### Common Patterns

```bash
# Pick change and its dependencies
repopick -Q 12345

# Force pick (ignore local changes)
repopick -f 12345

# Preview without applying
repopick -n 12345

# Pick entire topic
repopick -t bluetooth-fixes
```

---

## Updating Changes

### Amend and Re-push

```bash
# Make more changes
git add -A
git commit --amend

# Push update (same Change-Id = same review)
git push ssh://YOUR_USERNAME@review.lineageos.org:29418/LineageOS/<project> HEAD:refs/for/<branch>
```

### Rebase on Latest

```bash
repo sync .
git rebase lineage-21.0
# Resolve conflicts if any
git push ssh://... HEAD:refs/for/lineage-21.0
```

---

## Code Review

### Voting

| Score | Meaning |
|-------|---------|
| +2 | Approved (can merge) |
| +1 | Looks good to me |
| 0 | No opinion |
| -1 | Needs improvement |
| -2 | Do not merge |

### Verified

| Score | Meaning |
|-------|---------|
| +1 | Builds and works |
| 0 | Not tested |
| -1 | Doesn't build or breaks something |

---

## Common Issues

### Rejected - Not Up to Date

```bash
repo sync .
git rebase lineage-21.0
git push ...
```

### Missing Change-Id

```bash
# Install hook
scp -p -P 29418 YOUR_USERNAME@review.lineageos.org:hooks/commit-msg .git/hooks/

# Amend to add Change-Id
git commit --amend
```

### Merge Conflict

```bash
repo sync .
git rebase lineage-21.0
# Fix conflicts
git add <fixed_files>
git rebase --continue
git push ...
```

---

## Project Names

Common projects and their paths:

| Project | Path |
|---------|------|
| `LineageOS/android_frameworks_base` | frameworks/base |
| `LineageOS/android_packages_apps_Settings` | packages/apps/Settings |
| `LineageOS/android_system_core` | system/core |
| `LineageOS/android_vendor_lineage` | vendor/lineage |
| `LineageOS/android_device_*` | device/* |

Find project name:
```bash
cd <directory>
git remote -v
# Origin URL contains project name
```

---

## Quick Reference

```bash
# Start work
repo start my-fix .

# Commit
git add -A && git commit

# Push
git push ssh://user@review.lineageos.org:29418/LineageOS/project HEAD:refs/for/lineage-21.0

# Pick someone else's change
repopick 12345

# Update your change
git commit --amend && git push ...
```
