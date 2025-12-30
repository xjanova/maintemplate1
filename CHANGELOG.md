# Changelog

## [v1.1.0] - 2025-12-30


### Features
* feat: add user authorization for Claude AI access (7e93ea4)
* feat: make Claude API optional - notification mode fallback (3057465)
* feat: add LINE OA + Claude AI bidirectional chat integration (38749f5)
* feat: use LINE push message API with user ID instead of broadcast (e0392ad)
* feat: migrate from LINE Notify to LINE OA Messaging API (1aecd5f)
* feat: comprehensive install wizard for beginners (572ec42)

### Bug Fixes
* fix: workflow errors in deploy.yml and test.yml (6aa1f34)
* fix: YAML syntax error in deploy.yml Line Notify conditions (8fd1b88)

### Other Changes
* Merge pull request #13 from xjanova/claude/fix-test-workflow-9Ow9x (fcc2412)
* docs: update CHANGELOG.md for v1.0.0 [skip ci] (37e9271)

---
**Full Changelog**: https://github.com/xjanova/maintemplate1/compare/v1.0.0...v1.1.0

## [v1.0.0] - 2025-12-30


### Features
* feat: add installation wizard script (37e59d8)
* feat!: transform into Xclaude Framework (f71b0ff)
* feat: create professional GitHub template with auto-deploy (792e431)

### Bug Fixes
* fix: resolve workflow failures and add claude/main branch support (c19b580)
* fix: prevent workflow loops and handle missing configs (2cfacd0)
* fix: resolve test workflow failures (43f158b)
* fix: skip layout for API routes (f15b414)

### Other Changes
* Merge pull request #12 from xjanova/claude/fix-test-workflow-9Ow9x (9566ec0)
* Merge pull request #11 from xjanova/claude/fix-test-workflow-9Ow9x (d1aedd3)
* Merge pull request #10 from xjanova/claude/fix-test-workflow-9Ow9x (bc395a0)
* Merge pull request #9 from xjanova/claude/main (dad54e6)
* Merge pull request #8 from xjanova/claude/fix-test-workflow-9Ow9x (9504634)
* Merge pull request #7 from xjanova/claude/main (da25006)
* Merge pull request #6 from xjanova/claude/fix-test-workflow-9Ow9x (dea6d9a)
* Merge pull request #5 from xjanova/claude/main (35ad800)
* Merge pull request #4 from xjanova/claude/fix-test-workflow-9Ow9x (30c66d5)
* Merge pull request #3 from xjanova/claude/main (3c99a1e)
* Merge pull request #2 from xjanova/claude/fix-test-workflow-9Ow9x (51c07fe)
* Merge pull request #1 from xjanova/claude/github-template-setup-WDpNk (516139d)

---
**Full Changelog**: https://github.com/xjanova/maintemplate1/compare/v0.0.0...v1.0.0

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial template structure
- Auto-release workflow with semantic versioning
- Auto-deploy workflow with server deployment
- Smart deploy script with project type detection
- Installation wizard for server setup
- Claude integration with CLAUDE.md
- Documentation system
- Slash commands for Claude

---

*This changelog is automatically updated when releases are created.*
