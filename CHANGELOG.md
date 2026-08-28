# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-08-28

First tagged release. Within a major version, skill names and directory layout stay
put, which is what copying or symlinking a skill folder depends on.

### Added

- 18 skills covering workflow, code quality, architecture and frameworks. The
  [skills README](.claude/skills/README.md) lists them.
- Setup scripts: `setup-project.sh`, `link-skills.sh`, `generate-claude-md.sh`,
  `configure-mcp.sh`, `configure-settings.sh`, `test-all.sh`.
- Templates for `CLAUDE.md`, MCP configuration and Claude Code settings.
- Skill review workflow that evaluates changed skills against `docs/SKILL_GUIDELINES.md`.
- [#5]: Compliance with the [Agent Skills specification](https://agentskills.io/specification).
  `scripts/validate-skills.sh` checks the hard requirements with no dependencies, and CI
  also runs the reference validator from the spec authors.
- [#5]: `license: MIT` in every skill's frontmatter, so the license travels with a folder
  copied out of this repo.
- [#5]: `Test` workflow running the script suite and spec validation on pull requests and
  on `main`.

### Changed

- [#5]: The README describes the project by the open format it follows rather than by one
  client. Claude Code remains where the skills are developed and tested.
- [#5]: The skill review prompt no longer checks structure, which the validators now do
  deterministically and for less.

### Fixed

- [#5]: The `check` example in `docs/TESTING.md` had its arguments reversed, so following
  it produced a test that always reported the wrong result.

[#5]: https://github.com/decebals/claude-code-java/issues/5
[Unreleased]: https://github.com/decebals/claude-code-java/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/decebals/claude-code-java/releases/tag/v1.0.0
