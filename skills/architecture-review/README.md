# Architecture Review Skill

> Macro-level analysis of Java project structure, packages, and dependency direction

## What It Does

Analyzes project architecture at a high level:
- Package organization (by-layer vs by-feature vs hexagonal)
- Dependency direction between layers
- Module boundaries and coupling
- Architectural anti-patterns (god packages, anemic domain, etc.)

## When to Use

- "Review the architecture of this project"
- "Is this package structure good?"
- "Check if we follow clean architecture"
- "Find architectural violations"
- Before major refactoring efforts

## Key Concepts

### Package Strategies

| Strategy | Best For | Trade-off |
|----------|----------|-----------|
| By-layer | Small projects, quick start | Scatters related code |
| By-feature | Medium projects, clear modules | Need shared kernel |
| Hexagonal | Complex domains, testability | More ceremony |

### Dependency Direction

```
Outer (Framework) → Adapters → Application → Domain (Inner)

Rule: Dependencies point INWARD only
```

## Example Usage

```
You: Review the architecture of this project

Claude: [Analyzes package structure]
        [Checks dependency direction]
        [Identifies violations]
        [Provides prioritized recommendations]
```

## What It Checks

1. **Package Structure** - Organization, naming consistency
2. **Dependency Direction** - Domain isolation, no framework leaks
3. **Layer Boundaries** - Proper separation of concerns
4. **Module Boundaries** - Clear APIs, encapsulation
5. **Scalability** - Could features be extracted?

## Related Skills

- `solid-principles` - Class-level design (this skill is package/module level)
- `design-patterns` - Implementation patterns (this skill is structural)
- `clean-code` - Code quality (this skill is architectural quality)

## References

- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/)
- [Package by Feature](https://phauer.com/2020/package-by-feature/)
