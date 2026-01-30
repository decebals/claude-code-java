# Skills

Skills are reusable prompts that teach Claude specific patterns for Java development.

## Structure Convention

Each skill folder contains:

| File | Purpose | Audience |
|------|---------|----------|
| `SKILL.md` | Instructions for Claude | AI (loaded with `view`) |
| `README.md` | Documentation, examples, tips | Humans (onboarding) |

## Available Skills

### Workflow
| Skill | Description |
|-------|-------------|
| git-commit | Conventional commit messages for Java projects |
| changelog-generator | Generate changelogs from git commits |
| issue-triage | GitHub issue triage and categorization |

### Code Quality
| Skill | Description |
|-------|-------------|
| java-code-review | Systematic Java code review checklist |
| api-contract-review | REST API audit: HTTP semantics, versioning, compatibility |
| concurrency-review | Thread safety, race conditions, @Async, Virtual Threads |
| performance-smell-detection | Code-level performance smells (streams, boxing, regex) |
| test-quality | JUnit 5 + AssertJ testing patterns |
| maven-dependency-audit | Audit dependencies for updates and vulnerabilities |
| security-audit | OWASP Top 10, input validation, injection prevention |

### Architecture & Design
| Skill | Description |
|-------|-------------|
| architecture-review | Macro-level review: packages, modules, layers, boundaries |
| solid-principles | S.O.L.I.D. principles with Java examples |
| design-patterns | Factory, Builder, Strategy, Observer, Decorator, etc. |
| clean-code | DRY, KISS, YAGNI, naming, refactoring |

### Framework & Data
| Skill | Description |
|-------|-------------|
| spring-boot-patterns | Spring Boot best practices |
| java-migration | Java version upgrade guide (8→11→17→21) |
| jpa-patterns | JPA/Hibernate patterns (N+1, lazy loading, transactions) |
| logging-patterns | Structured logging (JSON), SLF4J, MDC, AI-friendly formats |

## Adding a New Skill

### Before You Start

Validate your skill idea against existing skills:

- [ ] **No significant overlap** - Check the table above for similar skills
- [ ] **Clear level** - Micro (functions) / Meso (classes) / Macro (packages) / Framework / Cross-cutting
- [ ] **Clear type** - Audit (review existing code) or Template (show how to write)
- [ ] **Unique value** - What does it add that doesn't exist?
- [ ] **Focused scope** - Can be applied in one session (<15 checklist items)

> 📖 **Full guidelines:** [docs/SKILL_GUIDELINES.md](../../docs/SKILL_GUIDELINES.md)

### Implementation Steps

1. Create folder: `.claude/skills/<skill-name>/`
2. Create `SKILL.md` with instructions for Claude
3. Create `README.md` with human documentation (use existing READMEs as template)
4. Update this table
5. Update main README.md

## Usage

Skills are automatically loaded by Claude Code based on context. You can also invoke them directly:

```bash
# Automatic - Claude detects when to use skills
> "Commit these changes"        # Loads git-commit
> "Review this code for SOLID"  # Loads solid-principles

# Manual - invoke with slash command
> /git-commit
> /solid-principles
```

## Learn More

- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills) - Official guide on creating and using skills
