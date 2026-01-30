# Performance Smell Detection Skill

> Identify potential code-level performance issues - with nuance, not absolutes

## What It Does

Helps notice **potential** performance smells in Java code:
- Stream API usage patterns
- Boxing/unboxing overhead
- Regex compilation costs
- Collection inefficiencies
- String operations

**Philosophy**: "Measure first, optimize second" - modern JVMs are highly optimized.

## When to Use

- "Check for performance issues"
- "Review this hot path"
- "Is this code efficient?"
- Investigating measured slowness

## Java Version Awareness

This skill accounts for modern Java optimizations:

| Topic | Java 9+ Change |
|-------|----------------|
| String `+` | Uses invokedynamic, well optimized outside loops |
| StringBuilder | Still best for loops |
| Virtual Threads | Java 21+ for I/O-bound work |
| String hashCode | Java 25 constant folding |

## Severity Levels

| Level | Meaning | Action |
|-------|---------|--------|
| 🔴 High | Usually worth fixing | Fix proactively |
| 🟡 Medium | Measure first | Profile before changing |
| 🟢 Low | Nice to have | Only if critical path |

## What It Checks

1. **Strings** - Concatenation in loops (still valid concern)
2. **Streams** - Overhead in tight loops, parallel misuse
3. **Boxing** - Primitive wrappers in hot paths
4. **Regex** - Pattern.compile in loops
5. **Collections** - Wrong type, unbounded queries
6. **Modern patterns** - Virtual threads, structured concurrency

## What It Does NOT Check

- **JPA/Database** - Use `jpa-patterns` skill
- **Architecture** - Use `architecture-review` skill
- **JVM tuning** - Out of scope (GC, heap, etc.)

## Example Usage

```
You: Check this code for performance issues

Claude: [Identifies potential smells]
        [Rates severity: 🔴/🟡/🟢]
        [Recommends measuring before changing]
        [Suggests modern alternatives if applicable]
```

## Related Skills

- `jpa-patterns` - Database performance (N+1, pagination)
- `java-code-review` - General code quality
- `concurrency-review` - Thread safety and async patterns

## References

- [Inside.java - JDK 25 Performance](https://inside.java/2025/10/20/jdk-25-performance-improvements/)
- [Java 25 Features - InfoQ](https://www.infoq.com/news/2025/09/java25-released/)
- [Baeldung - Streams vs Loops](https://www.baeldung.com/java-streams-vs-loops)
- [Baeldung - String Concatenation](https://www.baeldung.com/java-string-concatenation-methods)
