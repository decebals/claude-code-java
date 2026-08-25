# Java Code Review

Evidence-driven review of Java changes, with repository-local standards taking precedence over generic advice.

## What It Does

The skill reviews a diff in its real execution context: callers, tests, configuration, public contracts, failure paths, and relevant project rules. It prioritizes correctness and production impact, then reports only concrete findings with severity, location, evidence, impact, and a minimal fix.

It also routes deep security, API, concurrency, performance, test, Spring, JPA, and architecture concerns to the focused skills already present in this repository.

## When to Use

- “Review this Java change.”
- “Check this PR before merge.”
- “Find regressions in this service change.”
- “Review the Java 21/WebFlux behavior.”

## Key Behavior

- Reads repository instructions and build configuration before applying generic advice.
- Inspects surrounding code and contracts instead of reviewing changed lines in isolation.
- Avoids mechanical findings such as demanding `Optional`, builders, `toString`, interface/`Impl` pairs, or `default` branches without an actual defect.
- Uses one consistent Critical/High/Medium/Low severity model.
- Reports validation performed and residual risks even when there are no findings.

## Example Output

```markdown
## Findings

- **High — Blocking JDBC call remains on the event loop** (`ExampleService.java:84`)
  The new `map` branch calls a synchronous repository before switching schedulers, so concurrent requests can stall the Netty worker. Move the complete blocking operation behind the repository's configured blocking boundary and verify it with the project's blocking-call test.

## Validation

- Targeted unit test: passed
- Full integration suite: not run (database container unavailable)
```

## Related Skills

- [API contract review](../api-contract-review/)
- [Concurrency review](../concurrency-review/)
- [Security audit](../security-audit/)
- [Performance smell detection](../performance-smell-detection/)
- [Test quality](../test-quality/)
- [Spring Boot patterns](../spring-boot-patterns/)
