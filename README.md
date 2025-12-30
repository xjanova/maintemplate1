# Project Template

> A professional development template with auto-release, auto-deploy, and Claude integration.

## Features

- **Auto Versioning** - Automatic semantic versioning based on commit messages
- **Auto Release** - GitHub releases created automatically on merge to main
- **Auto Deploy** - Automatic deployment to your server
- **Smart Deploy Script** - Detects project type and deploys accordingly
- **Claude Integration** - Optimized for AI-assisted development
- **Professional Workflow** - Conventional commits, PR templates, and documentation

## Quick Start

### 1. Use This Template

Click "Use this template" on GitHub to create your repository.

### 2. Setup Server Connection

On your deployment server:

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
chmod +x install.sh
./install.sh
```

Follow the prompts to configure deployment.

### 3. Add GitHub Secrets

Add the secrets shown by `install.sh` to your GitHub repository:
- Settings → Secrets and variables → Actions → New repository secret

See [docs/GITHUB_SECRETS_SETUP.md](docs/GITHUB_SECRETS_SETUP.md) for details.

### 4. Start Developing

```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes and commit
git add .
git commit -m "feat: add new feature"

# Push and create PR
git push -u origin feature/my-feature
gh pr create
```

### 5. Deploy

Merge PR to `main` → Auto release → Auto deploy

## Project Structure

```
.
├── .github/workflows/    # GitHub Actions
│   ├── release.yml       # Auto-release workflow
│   └── deploy.yml        # Auto-deploy workflow
├── .claude/commands/     # Claude slash commands
├── docs/                 # Documentation
├── deploy.sh             # Smart deploy script
├── install.sh            # Server setup wizard
├── CLAUDE.md             # Claude's project guide
└── README.md             # This file
```

## Documentation

- [Development Guide](docs/DEVELOPMENT.md) - How to develop
- [GitHub Secrets Setup](docs/GITHUB_SECRETS_SETUP.md) - Server connection setup
- [Task Tracker](docs/TASKS.md) - Current development tasks

## Commit Convention

| Prefix | Description | Version Bump |
|--------|-------------|--------------|
| `feat:` | New feature | Minor (1.x.0) |
| `fix:` | Bug fix | Patch (1.0.x) |
| `feat!:` | Breaking change | Major (x.0.0) |
| `docs:` | Documentation | None |
| `chore:` | Maintenance | None |

## Supported Project Types

The deploy script auto-detects:

- **Node.js** - Next.js, React, Vue, Express
- **Python** - Django, Flask, FastAPI
- **PHP** - Laravel, WordPress
- **Static** - HTML/CSS/JS

## For Claude

See [CLAUDE.md](CLAUDE.md) for Claude-specific instructions.

## License

MIT
