# Development Guide

## Getting Started

### Prerequisites

- Git
- Your project's runtime (Node.js, Python, etc.)
- GitHub CLI (`gh`) - recommended

### Clone and Setup

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

# Install dependencies (auto-detected)
# For Node.js: npm install
# For Python: pip install -r requirements.txt
# For PHP: composer install
```

## Development Workflow

### 1. Create Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes

- Write code
- Write tests
- Update documentation

### 3. Commit Changes

Use conventional commit messages:

```bash
# Feature
git commit -m "feat: add user authentication"

# Bug fix
git commit -m "fix: resolve login timeout issue"

# Documentation
git commit -m "docs: add API documentation"

# Breaking change
git commit -m "feat!: redesign user API"
```

### 4. Push and Create PR

```bash
git push -u origin feature/your-feature-name
gh pr create --title "feat: Your Feature" --body "Description"
```

### 5. Merge and Deploy

After PR approval:
1. Merge to `main`
2. Auto-release creates new version
3. Auto-deploy updates the server

## Commit Convention

| Type | Description | Version Bump |
|------|-------------|--------------|
| `feat` | New feature | Minor |
| `fix` | Bug fix | Patch |
| `docs` | Documentation only | None |
| `style` | Code style (formatting) | None |
| `refactor` | Code refactoring | Patch |
| `perf` | Performance improvement | Patch |
| `test` | Adding tests | None |
| `chore` | Maintenance tasks | None |
| `ci` | CI/CD changes | None |

### Breaking Changes

Add `!` after type or include `BREAKING CHANGE:` in body:

```bash
git commit -m "feat!: change API response format"

# Or
git commit -m "feat: redesign API

BREAKING CHANGE: Response format changed from XML to JSON"
```

## Code Review Guidelines

### For Reviewers

- Check for functionality
- Verify tests pass
- Review code style
- Ensure documentation is updated

### For Authors

- Keep PRs small and focused
- Write clear descriptions
- Respond to feedback promptly
- Update based on review comments

## Testing

### Running Tests

```bash
# Auto-detected based on project type
npm test          # Node.js
pytest            # Python
php artisan test  # Laravel
```

### Test Coverage

Aim for:
- Unit tests for business logic
- Integration tests for APIs
- E2E tests for critical flows

## Deployment

### Automatic Deployment

Merging to `main` triggers:
1. **Version Release** - Creates Git tag and GitHub release
2. **Server Deploy** - Updates production server

### Manual Deployment

```bash
# On server
./deploy.sh
```

### Rollback

```bash
# On server - reset to previous version
git checkout v1.2.3
./deploy.sh
```

## Environment Configuration

### Local Development

Create `.env.local` for local overrides:

```bash
cp .env.example .env.local
# Edit .env.local with your settings
```

### Production

Configure via GitHub Secrets or server environment.

## Troubleshooting

### Build Fails

1. Check error logs
2. Verify dependencies
3. Check environment variables

### Deploy Fails

1. Check `.deploy-feedback.json`
2. Review GitHub Actions logs
3. Check server logs

### Tests Fail

1. Run locally to reproduce
2. Check test environment
3. Review recent changes

## Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [GitHub Actions](https://docs.github.com/en/actions)
