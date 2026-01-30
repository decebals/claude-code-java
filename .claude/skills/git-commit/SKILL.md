---
name: git-commit
description: Generate conventional commit messages for Java projects. Use when user says "commit", "create commit", "commit changes", or after completing code changes that need to be committed.
---

# Git Commit Message Skill

Generate conventional, informative commit messages for Java projects.

## When to Use
- After making code changes
- User says "commit this" / "commit changes" / "create commit"
- Before creating PRs

## Format Standard

Use Conventional Commits format:
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types (Java context)
- **feat**: New feature (new API, new functionality)
- **fix**: Bug fix
- **refactor**: Code refactoring (no functional change)
- **test**: Add/update tests
- **docs**: Documentation only
- **perf**: Performance improvement
- **build**: Maven/Gradle changes
- **chore**: Maintenance (dependency updates, etc)

### Scope Examples (Java specific)
- Module name: `core`, `api`, `plugin-loader`
- Component: `PluginManager`, `ExtensionFactory`
- Area: `lifecycle`, `dependencies`, `security`

### Subject Rules
- Imperative mood: "Add support" not "Added support"
- No period at end
- Max 50 chars
- Lowercase after type

### Body (optional but recommended)
- Explain WHAT and WHY, not HOW
- Wrap at 72 chars
- Reference issues: "Fixes #123" / "Relates to #456"

## Examples

### Simple fix
```
fix(plugin-loader): prevent NPE when plugin directory is missing

Check for null before accessing plugin directory to avoid
NullPointerException during initialization.

Fixes #234
```

### Feature with breaking change
```
feat(api): add support for plugin dependencies versioning

BREAKING CHANGE: PluginDescriptor now requires semantic versioning
format (x.y.z) instead of free-form version strings.

Closes #567
```

### Refactoring
```
refactor(core): extract plugin validation logic

Move validation logic from PluginManager to separate
PluginValidator class for better testability and separation
of concerns.
```

### Test addition
```
test(plugin-loader): add integration tests for plugin loading

Add comprehensive integration tests covering:
- Loading from directory
- Loading from JAR
- Error handling for invalid plugins
```

### Build/dependency update
```
build(deps): upgrade Spring Boot to 3.2.1

Update Spring Boot from 3.1.0 to 3.2.1 for security patches
and performance improvements.
```

## Workflow

1. **Analyze changes** using `git diff --staged`
2. **Identify scope** from modified files
3. **Determine type** based on change nature
4. **Generate message** following format
5. **Execute commit**: `git commit -m "message"`

## Token Optimization

- Read staged changes ONCE: `git diff --staged --stat` + targeted file diffs
- Don't read entire files unless necessary
- Use concise body - aim for 2-3 lines max
- Batch multiple small changes into logical commits

## Anti-patterns

❌ Avoid:
- "fix stuff" / "update code" / "changes"
- "WIP" commits (unless explicitly requested)
- Mixing unrelated changes (use separate commits)
- Over-detailed technical implementation in message

✅ Good commits:
- Single logical change
- Clear, searchable subject
- References issues when applicable
- Explains business value

## Integration with GitHub

After commit, suggest next steps:
- "Push changes?" 
- "Create PR for issue #X?"
- "Continue with next task?"

## Common Patterns for Java Projects

### Adding new functionality
```
feat(extension): add support for prioritized extensions

Allow extensions to specify priority order for execution.
Extensions with higher priority run first.

Closes #123
```

### Fixing bugs
```
fix(classloader): resolve resource lookup in nested JARs

ClassLoader.getResource() was failing for resources in
JARs loaded from plugin JARs (nested JARs). Fixed by
implementing proper resource resolution chain.

Fixes #456
```

### Dependency updates
```
build(deps): bump slf4j from 1.7.30 to 2.0.9

Updates SLF4J to latest stable version. No API changes
required as we use only stable APIs.
```

### Documentation improvements
```
docs(readme): add plugin development quickstart guide

Add step-by-step guide for creating first plugin:
- Project setup
- Implementing Plugin interface
- Building and testing
```

### Performance optimizations
```
perf(plugin-loader): cache plugin descriptors

Cache parsed plugin descriptors to avoid repeated I/O
and parsing. Reduces plugin loading time by ~40%.

Related to #789
```

## Multi-file Changes

When changes span multiple components:

```
refactor(core): reorganize plugin lifecycle management

- Extract lifecycle state machine to separate class
- Move validation logic to validators package
- Update tests to reflect new structure

This refactoring improves testability and separation
of concerns without changing external APIs.

Related to #111, #222
```

## Breaking Changes

Always use BREAKING CHANGE footer:

```
feat(api)!: replace Plugin.start() with Plugin.initialize()

BREAKING CHANGE: The Plugin.start() method has been renamed
to Plugin.initialize() for better semantic clarity. All
plugin implementations must update their code.

Migration guide: Replace @Override start() with @Override
initialize() in all Plugin implementations.

Closes #999
```

## Quick Reference Card

| Change Type | Type | Example Scope |
|-------------|------|---------------|
| New feature | feat | api, core, loader |
| Bug fix | fix | plugin-loader, lifecycle |
| Refactoring | refactor | core, utils |
| Tests | test | integration, unit |
| Docs | docs | readme, javadoc |
| Build | build | maven, deps |
| Performance | perf | classloader, cache |
| Maintenance | chore | ci, tooling |

## References

- [Conventional Commits Specification](https://www.conventionalcommits.org/)
