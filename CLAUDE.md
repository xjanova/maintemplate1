# Claude Project Guide

> This file helps Claude understand and work with this project effectively.

## Project Overview

This is a **GitHub Template Repository** designed for professional development workflow with:
- Automatic versioning and releases
- Auto-deployment to server
- CI/CD pipeline
- Claude-optimized documentation

## Quick Reference

### Project Structure

```
.
├── .github/
│   └── workflows/
│       ├── release.yml      # Auto-release on merge to main
│       └── deploy.yml       # Auto-deploy on merge to main
├── .claude/
│   └── commands/            # Slash commands for Claude
├── docs/
│   ├── DEVELOPMENT.md       # Development guidelines
│   ├── TASKS.md             # Task tracking (Claude writes here)
│   └── GITHUB_SECRETS_SETUP.md
├── deploy.sh                # Smart deploy script with feedback
├── install.sh               # Server setup wizard
├── CLAUDE.md                # This file (Claude's guide)
├── CHANGELOG.md             # Auto-generated changelog
└── README.md                # Project documentation
```

### Key Files for Claude

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Main guide (this file) - read first |
| `docs/TASKS.md` | Current tasks and progress tracking |
| `docs/DEVELOPMENT.md` | Development rules and patterns |
| `.deploy-feedback.json` | Deploy results (check after deploy) |
| `CHANGELOG.md` | Version history |

## Development Workflow

### 1. Understanding a Task

When given a task:
1. Read `docs/TASKS.md` to understand context
2. Check existing code patterns
3. Plan the implementation
4. Document in `docs/TASKS.md`

### 2. Making Changes

```bash
# Create feature branch
git checkout -b feature/description

# Make changes...

# Commit with conventional commits
git commit -m "feat: add new feature"
git commit -m "fix: resolve bug"
git commit -m "docs: update documentation"

# Create PR to main
```

### 3. Commit Message Convention

Use these prefixes for automatic versioning:

| Prefix | Version Bump | Example |
|--------|--------------|---------|
| `feat:` | Minor (1.x.0) | `feat: add user authentication` |
| `fix:` | Patch (1.0.x) | `fix: resolve login error` |
| `feat!:` or `BREAKING CHANGE:` | Major (x.0.0) | `feat!: redesign API` |
| `docs:` | No bump | `docs: update README` |
| `chore:` | No bump | `chore: update dependencies` |
| `refactor:` | Patch | `refactor: simplify logic` |

### 4. Merging and Deployment

When PR is merged to `main`:
1. **release.yml** runs → Creates new version tag and release
2. **deploy.yml** runs → Deploys to server automatically

## Deployment

### Checking Deploy Status

After merging to main, check:

1. **GitHub Actions** - See workflow run status
2. **`.deploy-feedback.json`** - Detailed deploy feedback
3. **Site URL** - Verify the changes are live

### Deploy Feedback Format

```json
{
  "status": "success|failed",
  "project_type": "detected type",
  "steps": ["completed steps"],
  "errors": ["any errors"],
  "warnings": ["any warnings"],
  "urls_to_check": ["/", "/api/health"],
  "suggestions": ["fix suggestions if failed"]
}
```

### If Deployment Fails

1. Check `.deploy-feedback.json` for errors
2. Review GitHub Actions logs
3. Fix the issue in code
4. Create new commit and push
5. Deployment will retry automatically

## For Claude: How to Complete Tasks

### Standard Workflow

```
1. User requests feature/fix
2. Claude reads CLAUDE.md (this file)
3. Claude checks docs/TASKS.md for context
4. Claude implements the change
5. Claude updates docs/TASKS.md with progress
6. Claude commits with proper message
7. Claude creates PR or merges to main
8. Auto-release creates new version
9. Auto-deploy updates the server
10. Claude verifies by checking feedback
```

### Creating a PR

```bash
# After making changes
git add .
git commit -m "feat: implement feature X"
git push -u origin feature/description

# Create PR using gh CLI
gh pr create --title "feat: Feature X" --body "Description..."
```

### Merging to Main

```bash
# If authorized to merge directly
git checkout main
git merge feature/description
git push origin main
```

### After Deploy: Verify Changes

1. Check GitHub Actions completed successfully
2. Read deploy feedback:
   ```bash
   cat .deploy-feedback.json
   ```
3. Visit the URLs mentioned in `urls_to_check`
4. If errors, check `errors` and `suggestions` fields

## Project-Specific Information

### Site URL
Check `.deploy.config` or GitHub Secrets for `SITE_URL`

### Server Details
- Host: Configured in `SERVER_HOST` secret
- User: Configured in `SERVER_USER` secret
- Path: Configured in `DEPLOY_PATH` secret

### Tech Stack
> Update this section based on actual project

- Framework: [Detected automatically by deploy.sh]
- Database: [If applicable]
- Other: [Any specific details]

## Task Documentation

### docs/TASKS.md Format

```markdown
# Current Tasks

## In Progress
- [ ] Task description
  - Status: Working on X
  - Branch: feature/task-name

## Completed
- [x] Previous task
  - Completed: 2024-01-01
  - Version: v1.2.0

## Backlog
- [ ] Future task
```

### Updating Task Status

When working on tasks, update `docs/TASKS.md`:
1. Move task to "In Progress"
2. Add status notes
3. When done, move to "Completed"
4. Add completion date and version

## Troubleshooting Guide

### Common Issues

| Issue | Solution |
|-------|----------|
| Deploy fails with SSH error | Check `SSH_PRIVATE_KEY` secret |
| Health check fails | Verify `SITE_URL` is correct |
| Build fails | Check project dependencies |
| Permission denied | Check `DEPLOY_PATH` permissions |

### Reading Deploy Logs

```bash
# On server
cat .deploy.log

# Or check GitHub Actions artifacts
# Download deploy-log-{run_number}
```

## Claude Slash Commands

Available in `.claude/commands/`:

| Command | Description |
|---------|-------------|
| `/deploy-status` | Check deployment status |
| `/new-feature` | Start new feature workflow |
| `/fix-bug` | Start bug fix workflow |
| `/release` | Prepare release notes |

## Important Notes for Claude

1. **Always read this file first** when starting work
2. **Check docs/TASKS.md** for current context
3. **Use conventional commits** for proper versioning
4. **Update documentation** when making changes
5. **Verify deployment** after merging to main
6. **Report issues** if deployment fails

## Human Setup Required

Before Claude can fully automate deployments, humans must:

1. **Run `./install.sh` on the server** to generate SSH keys
2. **Add GitHub Secrets** (SSH_PRIVATE_KEY, SERVER_HOST, etc.)
3. **Ensure server has required dependencies** (Node.js, Python, etc.)

See `docs/GITHUB_SECRETS_SETUP.md` for detailed instructions.
