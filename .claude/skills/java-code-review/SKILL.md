---
name: java-code-review
description: Evidence-driven review of Java changes for correctness, contracts, concurrency, resource safety, and maintainability. Use when the user asks to review Java code or a PR, or when deciding whether Java changes are ready to merge. Repository-local rules take precedence over this generic checklist.
---

# Java Code Review

Review the behavior introduced by a change, not just whether individual lines resemble a preferred style. Report only findings that are concrete, actionable, and supported by the diff plus surrounding code.

## Scope and Composition

Use this skill for a general Java review. Add a focused skill when the change is dominated by one of these areas:

- REST compatibility: `api-contract-review`
- Threading, Reactor, `@Async`, or virtual threads: `concurrency-review`
- Authentication, authorization, injection, or secrets: `security-audit`
- Hot paths, database access, allocations, or latency: `performance-smell-detection`
- JUnit test design: `test-quality`
- Spring configuration and component behavior: `spring-boot-patterns`
- JPA/Hibernate: `jpa-patterns`
- Package/module boundaries: `architecture-review`

Do not repeat the same finding from multiple checklists. Keep the version with the clearest proof and impact.

## Review Workflow

1. Establish the target: requested files or PR, comparison base, intended behavior, Java version, framework, and build tool.
2. Inspect the diff first, then read enough surrounding code, callers, tests, configuration, migrations, and public contracts to prove or dismiss a concern. Changed lines are the starting point, not a boundary on reasoning.
3. Read repository instructions and local standards before applying this generic checklist. Existing formatter, static analysis, CI, compatibility rules, and approved project decisions are authoritative.
4. Trace important paths end to end: input → validation/authorization → state or external call → response/event → observability. Check normal, boundary, failure, retry, cancellation, and concurrent paths as applicable.
5. Run the narrowest useful automated checks. Prefer targeted tests, then compile/static analysis; expand only when risk justifies it. State exactly what was and was not verified.
6. Report findings by severity. Do not turn preferences, speculative cleanup, or unrelated legacy debt into findings on the change.

## High-Signal Checklist

### 1. Correctness and State

- Does the change meet the stated behavior on success, empty/boundary input, partial failure, retry, cancellation, and repeated calls?
- Are state transitions, idempotency, transaction boundaries, and cleanup correct when an operation stops midway?
- Could ordering, stale state, aliasing, integer overflow, precision, or time-zone behavior change results?

### 2. Nullability and Value Semantics

- Trace nullable data across external input, deserialization, database/client results, collection elements, and unboxing.
- Flag unsafe dereferences or inconsistent API contracts, not the mere absence of `Optional` or nullability annotations.
- For `equals`/`hashCode`, records, collection keys, and defensive copies, check whether later mutation can break identity or ownership.

### 3. Exceptions, Responses, and Logging

- Preserve the original cause and classify failures narrowly enough for the required response, retry, rollback, and alert behavior.
- Reject swallowed failures, misleading fallbacks, duplicate logging, sensitive details in responses/logs, and broad catches that collapse distinct outcomes.
- Verify exception handlers and reactive error paths at the actual boundary where the failure occurs.

### 4. Collections and Streams

- Check mutation during iteration, duplicate-key behavior, null rejection, ordering assumptions, view-backed collections, and mutable versus unmodifiable results.
- Use streams only when their evaluation, side effects, and short-circuit behavior remain clear. Review parallel streams as concurrency, not syntax.

### 5. Concurrency and Reactive Execution

- Identify shared mutable state and prove compound operations are atomic; a concurrent collection alone may not protect multi-step invariants.
- Check publication, lock ordering, blocking calls, scheduler/executor ownership, cancellation, context propagation, and shutdown.
- Match advice to the configured Java version. Virtual threads and Reactor event loops have different constraints from pooled platform threads.

### 6. Resources and External Calls

- Ensure files, streams, JDBC objects, clients, executors, and subscriptions have explicit ownership and close/cancel on every path.
- Verify timeouts, bounded retries, backoff, circuit/degradation behavior, and safe handling of downstream 4xx/5xx and malformed payloads.

### 7. API and Compatibility

- Check input validation, authorization at the object/action level, response shape, HTTP/protocol semantics, serialization, and backward compatibility.
- Treat public signatures, persisted schemas, event formats, prompts, generated bytes, and configuration keys as contracts when consumers depend on them.

### 8. Performance and Capacity

- Look for N+1 I/O, unbounded queries/queues/caches/batches, blocking on event loops, repeated regex or serialization work, and accidental quadratic behavior.
- Require evidence before claiming a micro-optimization. Prioritize capacity limits and I/O shape over cosmetic allocation advice.

### 9. Security and Privacy

- Verify trusted identity sources, authorization before side effects, parameterized queries, controlled redirects/SSRF targets, request limits, rate limits, and secret handling.
- Check that logs, metrics, traces, exceptions, fixtures, and `toString` output do not expose credentials or sensitive user/downstream data.

### 10. Tests and Operability

- Tests should prove changed behavior and meaningful failure/boundary paths with deterministic assertions; coverage percentage alone is not evidence.
- Check configuration defaults, startup behavior, migration/rollback implications, health signals, metrics, and alerts for new failure modes.

## Avoid Mechanical Findings

Do not create a finding solely because code lacks `Optional`, a builder, an interface plus `Impl`, `toString`, a `default` branch, or a stream/loop conversion. Those choices depend on the repository contract, Java version, mutation needs, and actual risk. Formatter or Checkstyle issues are findings only when confirmed by the configured tool or an explicit repository rule.

## Severity

| Severity | Criteria |
| --- | --- |
| Critical | Exploitable security issue, data loss/corruption, or a release-blocking production failure with broad impact |
| High | Likely functional defect, authorization/contract break, race, resource leak, or major availability/performance regression |
| Medium | Real edge-case defect, inadequate failure handling/test coverage, or maintainability issue likely to cause future errors |
| Low | Bounded issue with small impact; never use Low for pure taste or optional cleanup |

## Output

Lead with findings, highest severity first. Each finding must include:

- severity and concise title;
- file and precise line;
- the triggering path or evidence;
- user/production impact;
- the smallest safe fix and relevant verification.

Then list validation performed and residual risks. If no actionable findings remain, say so directly and still disclose tests not run or contracts not verified. Positive observations are optional and must not obscure findings.

## Token Efficiency

- Start from the diff and review high-risk paths first.
- Group repeated instances under one finding with representative locations.
- Cite code instead of pasting it.
- Skip generated artifacts and fixtures unless they are the contract under review.
- Stop specialist passes early when the change does not touch their risk area.
