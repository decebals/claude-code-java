# claude-code-java

> Agent Skills for Java projects, following the open Agent Skills specification

[![Test](https://github.com/decebals/claude-code-java/actions/workflows/test.yml/badge.svg)](https://github.com/decebals/claude-code-java/actions/workflows/test.yml)
[![Release](https://img.shields.io/github/v/release/decebals/claude-code-java)](https://github.com/decebals/claude-code-java/releases/latest)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-spec%20compliant-blue)](https://agentskills.io/specification)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

*This project is not affiliated with Anthropic.*

## What is this?

A collection of reusable **skills** (structured markdown files that give an AI agent domain knowledge and workflows), plus project templates, MCP server configurations, and setup scripts.

The skills follow the [Agent Skills specification](https://agentskills.io/specification), an open format read by a growing number of agents. They are developed and tested with [Claude Code](https://docs.anthropic.com/en/docs/claude-code), and every skill is validated against the spec in CI.

**Who is this for?** Java developers who want consistent, high-quality AI assistance for common tasks like code reviews, testing, commits, and architecture decisions.

## Routing is tested

An agent picks a skill from its name and description and nothing else. With eighteen of
them the descriptions compete, and the failure is quiet: the wrong skill loads and answers
plausibly anyway, so nobody notices.

`scripts/eval-routing.sh` runs a set of prompts against the same list an agent receives and
reports where one lands somewhere other than expected. It found a real defect the first
time it ran: "this class does too much, split it" reached `clean-code` rather than
`solid-principles`. Sharpening three descriptions took the set from 17 of 18 prompts routed
correctly to 20 of 20.

Every skill has at least one case, enforced by `scripts/validate-skills.sh` so the cases
cannot fall behind the skills. The check runs against any OpenAI-compatible endpoint,
including a local model. See [docs/SCRIPTS.md](docs/SCRIPTS.md#check-routing).

## Purpose

AI-powered development workflows with focus on:
- **Token efficiency** - Designed for fewer iterations and lower token usage
- **Reproducible patterns** - Reusable workflows across projects
- **Java ecosystem** - Tailored for Java/Maven development
- **Incremental adoption** - Start small, expand as needed

## Quick Start

### Skills only

```bash
npx skills@latest add decebals/claude-code-java
```

No clone, no setup script. Add `--list` to see the skills first, `--skill <name>` to install
only some of them, `--global` to install at user level instead of the current project, or
`--copy` to get files instead of symlinks.

For the skills plus `CLAUDE.md` generation, MCP configuration and project settings, continue
below.

### 1. Clone this workspace
```bash
git clone https://github.com/decebals/claude-code-java.git ~/projects/claude-code-java
cd ~/projects/claude-code-java
chmod +x scripts/*.sh
```

### 2. Setup your Java project
```bash
./scripts/setup-project.sh ~/projects/your-java-project
```

This creates `.claude/` with symlinked skills, generates `CLAUDE.md`, and configures settings.

**Prefer manual setup?** Just copy or symlink the skills you want:
```bash
mkdir -p your-project/.claude/skills

# Copy specific skills
cp -r ~/projects/claude-code-java/skills/java-code-review your-project/.claude/skills/

# Or symlink all skills
ln -s ~/projects/claude-code-java/skills/* your-project/.claude/skills/
```

### 3. Use with Claude Code
```bash
cd ~/projects/your-java-project
claude

# Skills load automatically based on context, or invoke directly:
> /git-commit
> /java-code-review
```

## Available Skills (18)

Skills are automatically loaded by Claude Code based on context.

### Workflow
| Skill | Trigger Examples |
|-------|------------------|
| [**git-commit**](skills/git-commit/) | "commit these changes", "create commit" |
| [**changelog-generator**](skills/changelog-generator/) | "generate changelog", "what changed since release" |
| [**issue-triage**](skills/issue-triage/) | "triage issues", "check open issues" |

### Code Quality
| Skill | Trigger Examples |
|-------|------------------|
| [**java-code-review**](skills/java-code-review/) | "review this code", "check this PR" |
| [**api-contract-review**](skills/api-contract-review/) | "review API", "check REST endpoints" |
| [**concurrency-review**](skills/concurrency-review/) | "check thread safety", "review async code" |
| [**performance-smell-detection**](skills/performance-smell-detection/) | "check performance", "find slow code" |
| [**test-quality**](skills/test-quality/) | "add tests", "improve coverage" |
| [**maven-dependency-audit**](skills/maven-dependency-audit/) | "check dependencies", "audit deps" |
| [**security-audit**](skills/security-audit/) | "security review", "check OWASP", "vulnerabilities" |

### Architecture & Design
| Skill | Trigger Examples |
|-------|------------------|
| [**architecture-review**](skills/architecture-review/) | "review architecture", "check package structure" |
| [**solid-principles**](skills/solid-principles/) | "check SOLID", "single responsibility" |
| [**design-patterns**](skills/design-patterns/) | "use factory pattern", "implement strategy" |
| [**clean-code**](skills/clean-code/) | "clean this code", "refactor" |

### Framework & Data
| Skill | Trigger Examples |
|-------|------------------|
| [**spring-boot-patterns**](skills/spring-boot-patterns/) | "create controller", "Spring Boot help" |
| [**java-migration**](skills/java-migration/) | "upgrade to Java 21", "migrate from Java 8" |
| [**jpa-patterns**](skills/jpa-patterns/) | "N+1 problem", "LazyInitializationException" |
| [**logging-patterns**](skills/logging-patterns/) | "add logging", "debug this flow", "analyze logs" |

See [skills/README.md](skills/README.md) for full documentation and [docs/SCRIPTS.md](docs/SCRIPTS.md) for setup script options.

## Project Structure

```
claude-code-java/
├── README.md                    # This file
├── LICENSE                      # MIT license
├── .gitignore                   # Git ignore rules
├── .claude/
│   └── skills/                  # 18 reusable skills (see Available Skills above)
├── docs/                        # Guidelines and best practices
│   ├── DESIGN_PRINCIPLES.md     # Core philosophy
│   ├── RED_FLAGS.md             # Warning signs to watch for
│   ├── SAFE_WORKFLOWS.md        # Step-by-step safe workflows
│   ├── SCRIPTS.md               # Scripts documentation
│   ├── SKILL_GUIDELINES.md      # How to create new skills
│   └── TESTING.md               # Testing strategy
├── templates/
│   ├── CLAUDE.md.template       # Template for projects
│   ├── mcp-config.json.template # MCP configuration template
│   ├── MCP_CONFIG.md.template   # MCP documentation template
│   └── settings.json.template   # Claude Code settings (pre-approved commands)
└── scripts/
    ├── setup-project.sh         # Full project setup (orchestrator)
    ├── link-skills.sh           # Symlink skills to project
    ├── generate-claude-md.sh    # Generate CLAUDE.md
    ├── configure-mcp.sh         # Configure MCP servers
    └── test-all.sh              # Run all tests
```

## Typical Workflow

1. **Link skills** to your Java project
2. **Start Claude Code** in project directory
3. **Load skill** relevant to current task
4. **Execute workflow** with natural language
5. **Measure results** (tokens used, time saved)

## Success Metrics

Track these to validate effectiveness:

- **Token reduction**: Track your improvement vs manual workflows
- **Time savings**: Measure before/after per task
- **Reusability**: Number of projects using skills
- **Quality**: Code review feedback, test coverage

## Requirements

- An agent that reads Agent Skills. Developed and tested with the [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- Java 11+ projects (Java 17+ recommended)
- Git for version control
- Maven or Gradle build tool
- (Optional) [GitHub MCP server](https://github.com/github/github-mcp-server) for issue management

## What's Included

- 18 skills (workflow, code quality, architecture, frameworks)
- Setup automation scripts
- Project templates
- Agent Skills spec compliance, enforced in CI by `scripts/validate-skills.sh` and the reference validator

## Used in automated code review

These skills are not just for code generation — they are also used as the **single source of truth** for automated code review via [`skill-review`](https://github.com/decebals/skill-review), a reusable GitHub Actions workflow that evaluates pull requests against the same skills that Claude Code uses during development.

Same skills. From generation to review. See [`skill-review-sandbox`](https://github.com/decebals/skill-review-sandbox) for a working example.

## Contributing

Skills are evolving based on real-world usage. Try them, open issues, share what works.

1. Try the skills in your projects
2. Open issues for suggestions
3. Share token savings/improvements

## Documentation

See [docs/](docs/) for detailed guides:
- [DESIGN_PRINCIPLES.md](docs/DESIGN_PRINCIPLES.md) - Core philosophy
- [SAFE_WORKFLOWS.md](docs/SAFE_WORKFLOWS.md) - Recommended workflows
- [RED_FLAGS.md](docs/RED_FLAGS.md) - Warning signs to watch for
- [SKILL_GUIDELINES.md](docs/SKILL_GUIDELINES.md) - How to create new skills
- [RELEASING.md](docs/RELEASING.md) - Versioning and how a release is cut

## License

MIT License - Use freely, modify as needed.

