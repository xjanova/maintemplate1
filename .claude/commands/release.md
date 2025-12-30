# Prepare Release

Prepare release notes and ensure everything is ready for release.

## Steps

1. Check current version:
   ```bash
   git describe --tags --abbrev=0
   ```

2. Review commits since last release:
   ```bash
   git log $(git describe --tags --abbrev=0)..HEAD --oneline
   ```

3. Categorize changes:
   - Features (feat:)
   - Bug fixes (fix:)
   - Breaking changes (feat!: or BREAKING CHANGE)
   - Other changes

4. Ensure all tests pass

5. Ensure documentation is updated

6. Report to user:
   - Next version number (based on changes)
   - Summary of changes
   - Any breaking changes
   - Confirmation to proceed with merge to main

7. If user confirms, merge to main to trigger release
