# claude-code-java

> Reusable AI development infrastructure for Java projects, optimized for Claude Code

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

*This project is not affiliated with Anthropic.*

## What is this?

A collection of reusable components for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) - Anthropic's agentic coding tool. The core of this project is a set of **skills** (structured markdown files that provide Claude with domain knowledge and workflows), but it also includes project templates, MCP server configurations, and setup scripts.

**Who is this for?** Java developers using Claude Code who want consistent, high-quality AI assistance for common tasks like code reviews, testing, commits, and architecture decisions.

## Purpose

AI-powered development workflows with focus on:
- **Token efficiency** - Reduce AI token consumption by 30%+
- **Reproducible patterns** - Reusable workflows across projects
- **Java ecosystem** - Tailored for Java/Maven development
- **Incremental adoption** - Start small, expand as needed

## Quick Start

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
| **git-commit** | "commit these changes", "create commit" |
| **changelog-generator** | "generate changelog", "what changed since release" |
| **issue-triage** | "triage issues", "check open issues" |

### Code Quality
| Skill | Trigger Examples |
|-------|------------------|
| **java-code-review** | "review this code", "check this PR" |
| **api-contract-review** | "review API", "check REST endpoints" |
| **concurrency-review** | "check thread safety", "review async code" |
| **performance-smell-detection** | "check performance", "find slow code" |
| **test-quality** | "add tests", "improve coverage" |
| **maven-dependency-audit** | "check dependencies", "audit deps" |
| **security-audit** | "security review", "check OWASP", "vulnerabilities" |

### Architecture & Design
| Skill | Trigger Examples |
|-------|------------------|
| **architecture-review** | "review architecture", "check package structure" |
| **solid-principles** | "check SOLID", "single responsibility" |
| **design-patterns** | "use factory pattern", "implement strategy" |
| **clean-code** | "clean this code", "refactor" |

### Framework & Data
| Skill | Trigger Examples |
|-------|------------------|
| **spring-boot-patterns** | "create controller", "Spring Boot help" |
| **java-migration** | "upgrade to Java 21", "migrate from Java 8" |
| **jpa-patterns** | "N+1 problem", "LazyInitializationException" |
| **logging-patterns** | "add logging", "debug this flow", "analyze logs" |

See [.claude/skills/README.md](.claude/skills/README.md) for full documentation and [docs/SCRIPTS.md](docs/SCRIPTS.md) for setup script options.

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

- **Token reduction**: Target 30%+ vs manual workflows
- **Time savings**: Measure before/after per task
- **Reusability**: Number of projects using skills
- **Quality**: Code review feedback, test coverage

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- Java 11+ projects (Java 17+ recommended)
- Git for version control
- Maven or Gradle build tool
- (Optional) [GitHub MCP server](https://github.com/github/github-mcp-server) for issue management

## What's Included

- 18 skills (workflow, code quality, architecture, frameworks)
- Setup automation scripts
- Project templates
- YAML frontmatter for automatic skill detection

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

## License

MIT License - Use freely, modify as needed.

