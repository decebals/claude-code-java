# Logging Patterns

**Load**: `view .claude/skills/logging-patterns/SKILL.md`

---

## Description

Java logging best practices with SLF4J, structured logging (JSON), and MDC for request tracing. Includes AI-friendly log formats optimized for Claude Code analysis.

---

## Use Cases

- "Add logging to this service"
- "Debug this flow" (AI reads logs)
- "Setup structured logging"
- "Why is this request failing?" (analyze logs)
- "Add request tracing"

---

## Key Insight: JSON for AI

**JSON logs are better for AI/Claude Code analysis:**

| Aspect | Text Logs | JSON Logs |
|--------|-----------|-----------|
| Parsing | Regex interpretation | Direct field access |
| Tokens | Higher | Lower |
| Filtering | grep patterns | jq queries |

```bash
# AI can easily filter JSON
cat app.log | jq 'select(.requestId == "abc123")'
```

---

## Topics Covered

| Topic | Description |
|-------|-------------|
| **AI-Friendly Logging** | JSON formats optimized for Claude Code |
| **Spring Boot 3.4+** | Native structured logging support |
| **Logstash Encoder** | For Spring Boot < 3.4 |
| **SLF4J/MDC** | Request context, correlation IDs |
| **Log Levels** | When to use ERROR, WARN, INFO, DEBUG |
| **What to Log** | Business events, timing, flow steps |
| **What NOT to Log** | Passwords, PII, sensitive data |

---

## Quick Setup (Spring Boot 3.4+)

```yaml
logging:
  structured:
    format:
      console: logstash
```

No extra dependencies needed!

---

## Related Skills

- `spring-boot-patterns` - Spring configuration
- `jpa-patterns` - Database logging

---

## Resources

- [Structured Logging in Spring Boot 3.4 (spring.io)](https://spring.io/blog/2024/08/23/structured-logging-in-spring-boot-3-4/)
- [Structured Logging in Spring Boot (Baeldung)](https://www.baeldung.com/spring-boot-structured-logging)
- [10 Best Practices for Logging in Java (Better Stack)](https://betterstack.com/community/guides/logging/how-to-start-logging-with-java/)
- [Booking.com - Structured Logging](https://medium.com/booking-com-development/unlocking-observability-structured-logging-in-spring-boot-c81dbabfb9e7)
- [SLF4J Manual](https://www.slf4j.org/manual.html)
