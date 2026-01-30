---
name: logging-patterns
description: Java logging best practices with SLF4J, structured logging (JSON), and MDC for request tracing. Includes AI-friendly log formats for Claude Code debugging. Use when user asks about logging, debugging application flow, or analyzing logs.
---

# Logging Patterns Skill

Effective logging for Java applications with focus on structured, AI-parsable formats.

## When to Use
- User says "add logging" / "improve logs" / "debug this"
- Analyzing application flow from logs
- Setting up structured logging (JSON)
- Request tracing with correlation IDs
- AI/Claude Code needs to analyze application behavior

---

## AI-Friendly Logging

> **Key insight:** JSON logs are better for AI analysis - faster parsing, fewer tokens, direct field access.

### Why JSON for AI/Claude Code?

```
# Text format - AI must "interpret" the string
2026-01-29 10:15:30 INFO OrderService - Order 12345 created for user-789, total: 99.99

# JSON format - AI extracts fields directly
{"timestamp":"2026-01-29T10:15:30Z","level":"INFO","orderId":12345,"userId":"user-789","total":99.99}
```

| Aspect | Text | JSON |
|--------|------|------|
| Parsing | Regex/interpretation | Direct field access |
| Token usage | Higher (repeated patterns) | Lower (structured) |
| Error extraction | Parse stack trace text | `exception` field |
| Filtering | grep patterns | `jq` queries |

### Recommended Setup for AI-Assisted Development

```yaml
# application.yml - JSON by default
logging:
  structured:
    format:
      console: logstash  # Spring Boot 3.4+

# When YOU need to read logs manually:
# Option 1: Use jq
# tail -f app.log | jq .

# Option 2: Switch profile temporarily
# java -jar app.jar --spring.profiles.active=human-logs
```

### Log Format Optimized for AI Analysis

```json
{
  "timestamp": "2026-01-29T10:15:30.123Z",
  "level": "INFO",
  "logger": "com.example.OrderService",
  "message": "Order created",
  "requestId": "req-abc123",
  "traceId": "trace-xyz",
  "orderId": 12345,
  "userId": "user-789",
  "duration_ms": 45,
  "step": "payment_completed"
}
```

**Key fields for AI debugging:**
- `requestId` - group all logs from same request
- `step` - track progress through flow
- `duration_ms` - identify slow operations
- `level` - quick filter for errors

### Reading Logs with AI/Claude Code

When asking AI to analyze logs:

```bash
# Get recent errors
cat app.log | jq 'select(.level == "ERROR")' | tail -20

# Follow specific request
cat app.log | jq 'select(.requestId == "req-abc123")'

# Find slow operations
cat app.log | jq 'select(.duration_ms > 1000)'
```

AI can then:
1. Parse JSON directly (no guessing)
2. Follow request flow via requestId
3. Identify exactly where errors occurred
4. Measure timing between steps

---

## Quick Setup (Spring Boot 3.4+)

### Native Structured Logging

Spring Boot 3.4+ has built-in support - no extra dependencies!

```yaml
# application.yml
logging:
  structured:
    format:
      console: logstash    # or "ecs" for Elastic Common Schema

# Supported formats: logstash, ecs, gelf
```

### Profile-Based Switching

```yaml
# application.yml (default - JSON for AI/prod)
spring:
  profiles:
    default: json-logs

---
spring:
  config:
    activate:
      on-profile: json-logs
logging:
  structured:
    format:
      console: logstash

---
spring:
  config:
    activate:
      on-profile: human-logs
# No structured format = human-readable default
logging:
  pattern:
    console: "%d{HH:mm:ss.SSS} %-5level [%thread] %logger{36} - %msg%n"
```

**Usage:**
```bash
# Default: JSON (for AI, CI/CD, production)
./mvnw spring-boot:run

# Human-readable when needed
./mvnw spring-boot:run -Dspring.profiles.active=human-logs
```

---

## Setup for Spring Boot < 3.4

### Logstash Logback Encoder

**pom.xml:**
```xml
<dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
    <version>7.4</version>
</dependency>
```

**logback-spring.xml:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>

    <!-- JSON (default) -->
    <springProfile name="!human-logs">
        <appender name="JSON" class="ch.qos.logback.core.ConsoleAppender">
            <encoder class="net.logstash.logback.encoder.LogstashEncoder">
                <includeMdcKeyName>requestId</includeMdcKeyName>
                <includeMdcKeyName>userId</includeMdcKeyName>
            </encoder>
        </appender>
        <root level="INFO">
            <appender-ref ref="JSON"/>
        </root>
    </springProfile>

    <!-- Human-readable (optional) -->
    <springProfile name="human-logs">
        <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
            <encoder>
                <pattern>%d{HH:mm:ss.SSS} %-5level [%thread] %logger{36} - %msg%n</pattern>
            </encoder>
        </appender>
        <root level="INFO">
            <appender-ref ref="CONSOLE"/>
        </root>
    </springProfile>

</configuration>
```

### Adding Custom Fields (Logstash Encoder)

```java
import static net.logstash.logback.argument.StructuredArguments.kv;

// Fields appear as separate JSON keys
log.info("Order created",
    kv("orderId", order.getId()),
    kv("userId", user.getId()),
    kv("total", order.getTotal()),
    kv("step", "order_created")
);

// Output:
// {"message":"Order created","orderId":123,"userId":"u-456","total":99.99,"step":"order_created"}
```

---

## SLF4J Basics

### Logger Declaration

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class OrderService {
    private static final Logger log = LoggerFactory.getLogger(OrderService.class);
}

// Or with Lombok
@Slf4j
@Service
public class OrderService {
    // use `log` directly
}
```

### Parameterized Logging

```java
// ✅ GOOD: Evaluated only if level enabled
log.debug("Processing order {} for user {}", orderId, userId);

// ❌ BAD: Always concatenates
log.debug("Processing order " + orderId + " for user " + userId);

// ✅ For expensive operations
if (log.isDebugEnabled()) {
    log.debug("Full order details: {}", order.toJson());
}
```

---

## Log Levels

| Level | When | Example |
|-------|------|---------|
| **ERROR** | Failures needing attention | Unhandled exception, service down |
| **WARN** | Unexpected but handled | Retry succeeded, deprecated API used |
| **INFO** | Business events | Order created, payment processed |
| **DEBUG** | Technical details | Method params, SQL queries |
| **TRACE** | Very detailed | Loop iterations (rarely used) |

```java
log.error("Payment failed", kv("orderId", id), kv("reason", reason), exception);
log.warn("Retry succeeded", kv("attempt", 3), kv("orderId", id));
log.info("Order shipped", kv("orderId", id), kv("trackingNumber", tracking));
log.debug("Fetching from DB", kv("query", "findById"), kv("id", id));
```

---

## MDC (Mapped Diagnostic Context)

MDC adds context to every log entry in a request - essential for tracing.

### Request ID Filter

```java
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class RequestContextFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {
        try {
            String requestId = Optional.ofNullable(request.getHeader("X-Request-ID"))
                .filter(s -> !s.isBlank())
                .orElse(UUID.randomUUID().toString().substring(0, 8));

            MDC.put("requestId", requestId);
            response.setHeader("X-Request-ID", requestId);

            chain.doFilter(request, response);
        } finally {
            MDC.clear();
        }
    }
}
```

### Add User Context

```java
// After authentication
MDC.put("userId", authentication.getName());

// All subsequent logs include userId automatically
log.info("User action performed");  // {"userId":"john123","message":"User action performed"}
```

### MDC in Async Operations

```java
// MDC doesn't auto-propagate to new threads!

// ✅ Copy MDC context
Map<String, String> context = MDC.getCopyOfContextMap();

CompletableFuture.runAsync(() -> {
    try {
        if (context != null) MDC.setContextMap(context);
        log.info("Async task running");  // Has requestId, userId
    } finally {
        MDC.clear();
    }
});
```

---

## What to Log

### Business Events (INFO)

```java
// Include key identifiers and state
log.info("Order created",
    kv("orderId", id),
    kv("userId", userId),
    kv("total", total),
    kv("itemCount", items.size()),
    kv("step", "order_created"));

log.info("Payment processed",
    kv("orderId", id),
    kv("amount", amount),
    kv("method", "card"),
    kv("step", "payment_completed"));
```

### External Calls (with timing)

```java
long start = System.currentTimeMillis();
try {
    Result result = externalService.call(params);
    log.info("External call succeeded",
        kv("service", "PaymentGateway"),
        kv("operation", "charge"),
        kv("duration_ms", System.currentTimeMillis() - start));
    return result;
} catch (Exception e) {
    log.error("External call failed",
        kv("service", "PaymentGateway"),
        kv("operation", "charge"),
        kv("duration_ms", System.currentTimeMillis() - start),
        e);
    throw e;
}
```

### Flow Steps (for AI tracing)

```java
public Order processOrder(CreateOrderRequest request) {
    log.info("Processing started", kv("step", "start"), kv("requestData", request.summary()));

    Order order = createOrder(request);
    log.info("Order created", kv("step", "order_created"), kv("orderId", order.getId()));

    validateInventory(order);
    log.info("Inventory validated", kv("step", "inventory_ok"), kv("orderId", order.getId()));

    processPayment(order);
    log.info("Payment processed", kv("step", "payment_done"), kv("orderId", order.getId()));

    log.info("Processing completed", kv("step", "complete"), kv("orderId", order.getId()));
    return order;
}
```

---

## What NOT to Log

```java
// ❌ NEVER log sensitive data
log.info("Login", kv("password", password));           // Passwords
log.info("Payment", kv("cardNumber", card));           // Full card numbers
log.info("Request", kv("token", jwtToken));            // Tokens
log.info("User", kv("ssn", socialSecurity));           // PII

// ✅ Safe alternatives
log.info("Login attempted", kv("userId", userId));
log.info("Payment", kv("cardLast4", last4));
log.info("Token validated", kv("subject", sub), kv("exp", expiry));
```

---

## Exception Logging

### Log Once at Boundary

```java
// ❌ BAD: Logs same exception multiple times
void methodA() {
    try { methodB(); }
    catch (Exception e) { log.error("Error", e); throw e; }  // Log #1
}
void methodB() {
    try { methodC(); }
    catch (Exception e) { log.error("Error", e); throw e; }  // Log #2
}

// ✅ GOOD: Log at service boundary only
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<?> handle(Exception e, HttpServletRequest request) {
        log.error("Request failed",
            kv("path", request.getRequestURI()),
            kv("method", request.getMethod()),
            kv("errorType", e.getClass().getSimpleName()),
            e);  // Full stack trace
        return ResponseEntity.status(500).body(errorResponse);
    }
}
```

### Include Context

```java
// ❌ Useless
log.error("Error occurred", e);

// ✅ Useful for debugging
log.error("Order processing failed",
    kv("orderId", orderId),
    kv("step", "payment"),
    kv("userId", userId),
    kv("attemptNumber", attempt),
    e);
```

---

## Quick Reference

```java
// === Setup ===
private static final Logger log = LoggerFactory.getLogger(MyClass.class);

// === Logging with structured fields ===
import static net.logstash.logback.argument.StructuredArguments.kv;

log.info("Event", kv("key1", value1), kv("key2", value2));
log.error("Failed", kv("context", ctx), exception);

// === MDC ===
MDC.put("requestId", requestId);
MDC.put("userId", userId);
// ... all logs now include these
MDC.clear();  // cleanup

// === Levels ===
log.error()  // Failures
log.warn()   // Handled issues
log.info()   // Business events
log.debug()  // Technical details
```

---

## Analyzing Logs (AI/Human)

```bash
# Pretty print JSON logs
tail -f app.log | jq .

# Filter errors
cat app.log | jq 'select(.level == "ERROR")'

# Follow request flow
cat app.log | jq 'select(.requestId == "abc123")'

# Find slow operations (>1s)
cat app.log | jq 'select(.duration_ms > 1000)'

# Get timeline of steps
cat app.log | jq 'select(.requestId == "abc123") | {time: .timestamp, step: .step, message: .message}'
```

---

## Related Skills

- `spring-boot-patterns` - Spring Boot configuration
- `jpa-patterns` - Database logging (SQL queries)
- Future: `observability-patterns` - Metrics, tracing, full observability
