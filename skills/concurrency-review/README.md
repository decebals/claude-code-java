# Concurrency Review Skill

> Review Java concurrent code for thread safety, race conditions, and modern patterns

## What It Does

Reviews multi-threaded Java code for:
- Race conditions and visibility issues
- Deadlock potential
- Modern patterns (Virtual Threads, Structured Concurrency)
- Spring @Async pitfalls
- CompletableFuture error handling
- Thread pool configuration

## Why It Matters

> Nearly 60% of multithreaded applications encounter issues due to improper management of shared resources.

Concurrency bugs are hard to reproduce, hard to test, and hard to debug. Catching them in code review is far better than finding them in production.

## When to Use

- "Review this for thread safety"
- "Check concurrency issues"
- "Is this async code correct?"
- Reviewing code with `synchronized`, `volatile`, `@Async`
- Checking `CompletableFuture` or `ExecutorService` usage

## Key Topics Covered

### Modern Java (21/25)
| Topic | What to Check |
|-------|---------------|
| Virtual Threads | Use for I/O-bound, not CPU-bound |
| Structured Concurrency | Proper scope management |
| ScopedValue | Prefer over ThreadLocal |

### Spring @Async
| Pitfall | Issue |
|---------|-------|
| Same-class call | Bypasses proxy, runs sync |
| Non-public method | Proxy can't intercept |
| Default executor | Creates thread per task (OOM risk) |
| SecurityContext | ThreadLocal doesn't propagate |

### Classic Issues
| Issue | Example |
|-------|---------|
| Race condition | Check-then-act without sync |
| Visibility | Missing volatile |
| Deadlock | Inconsistent lock ordering |

## Example Usage

```
You: Review this service for thread safety

Claude: [Checks shared mutable state]
        [Validates synchronization]
        [Reviews @Async configuration]
        [Checks CompletableFuture error handling]
        [Suggests modern alternatives if applicable]
```

## Severity Levels

| Level | Meaning |
|-------|---------|
| 🔴 High | Likely bug - race condition, deadlock risk |
| 🟡 Medium | Potential issue - measure/verify |
| 🟢 Modern | Opportunity for Java 21/25 patterns |

## Related Skills

- `performance-smell-detection` - Performance issues (not thread safety)
- `java-code-review` - General code review (includes basic concurrency)
- `spring-boot-patterns` - Spring patterns (includes @Async basics)

## References

- [Java Concurrency Code Review Checklist](https://github.com/code-review-checklists/java-concurrency)
- [Baeldung - Common Concurrency Pitfalls](https://www.baeldung.com/java-common-concurrency-pitfalls)
- [Oracle - Virtual Threads](https://docs.oracle.com/en/java/javase/21/core/virtual-threads.html)
- [JavaPro - Java 25 Virtual Threads](https://javapro.io/2025/12/23/java-25-getting-the-most-out-of-virtual-threads-with-structured-task-scopes-and-scoped-values/)
- [Spring @Async Problems](https://serdaralkancode.medium.com/problems-and-solutions-when-using-async-in-spring-boot-e383f9d3b45d)
- Book: "Java Concurrency in Practice" by Brian Goetz
