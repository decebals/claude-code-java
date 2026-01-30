---
name: concurrency-review
description: Review Java concurrency code for thread safety, race conditions, deadlocks, and modern patterns (Virtual Threads, CompletableFuture, @Async). Use when user asks "check thread safety", "concurrency review", "async code review", or when reviewing multi-threaded code.
---

# Concurrency Review Skill

Review Java concurrent code for correctness, safety, and modern best practices.

## Why This Matters

> Nearly 60% of multithreaded applications encounter issues due to improper management of shared resources. - ACM Study

Concurrency bugs are:
- **Hard to reproduce** - timing-dependent
- **Hard to test** - may only appear under load
- **Hard to debug** - non-deterministic behavior

This skill helps catch issues **before** they reach production.

## When to Use
- Reviewing code with `synchronized`, `volatile`, `Lock`
- Checking `@Async`, `CompletableFuture`, `ExecutorService`
- Validating thread safety of shared state
- Reviewing Virtual Threads / Structured Concurrency code
- Any code accessed by multiple threads

---

## Modern Java (21/25): Virtual Threads

### When to Use Virtual Threads

```java
// ✅ Perfect for I/O-bound tasks (HTTP, DB, file I/O)
try (ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor()) {
    for (Request request : requests) {
        executor.submit(() -> callExternalApi(request));
    }
}

// ❌ Not beneficial for CPU-bound tasks
// Use platform threads / ForkJoinPool instead
```

**Rule of thumb**: If your app never has 10,000+ concurrent tasks, virtual threads may not provide significant benefit.

### Java 25: Synchronized Pinning Fixed

In Java 21-23, virtual threads became "pinned" when entering `synchronized` blocks with blocking operations. **Java 25 fixes this** (JEP 491).

```java
// In Java 21-23: ⚠️ Could cause pinning
synchronized (lock) {
    blockingIoCall();  // Virtual thread pinned to carrier
}

// In Java 25: ✅ No longer an issue
// But consider ReentrantLock for explicit control anyway
```

### ScopedValue Over ThreadLocal

```java
// ❌ ThreadLocal problematic with virtual threads
private static final ThreadLocal<User> currentUser = new ThreadLocal<>();

// ✅ ScopedValue (Java 21+ preview, improved in 25)
private static final ScopedValue<User> CURRENT_USER = ScopedValue.newInstance();

ScopedValue.where(CURRENT_USER, user).run(() -> {
    // CURRENT_USER.get() available here and in child virtual threads
    processRequest();
});
```

### Structured Concurrency (Java 25 Preview)

```java
// ✅ Structured concurrency - tasks tied to scope lifecycle
try (StructuredTaskScope.ShutdownOnFailure scope = new StructuredTaskScope.ShutdownOnFailure()) {
    Subtask<User> userTask = scope.fork(() -> fetchUser(id));
    Subtask<Orders> ordersTask = scope.fork(() -> fetchOrders(id));

    scope.join();            // Wait for all
    scope.throwIfFailed();   // Propagate exceptions

    return new Profile(userTask.get(), ordersTask.get());
}
// All subtasks automatically cancelled if scope exits
```

---

## Spring @Async Pitfalls

### 1. Forgetting @EnableAsync

```java
// ❌ @Async silently ignored
@Service
public class EmailService {
    @Async
    public void sendEmail(String to) { }
}

// ✅ Enable async processing
@Configuration
@EnableAsync
public class AsyncConfig { }
```

### 2. Calling Async from Same Class

```java
@Service
public class OrderService {

    // ❌ Bypasses proxy - runs synchronously!
    public void processOrder(Order order) {
        sendConfirmation(order);  // Direct call, not async
    }

    @Async
    public void sendConfirmation(Order order) { }
}

// ✅ Inject self or use separate service
@Service
public class OrderService {
    @Autowired
    private EmailService emailService;  // Separate bean

    public void processOrder(Order order) {
        emailService.sendConfirmation(order);  // Proxy call, async works
    }
}
```

### 3. @Async on Non-Public Methods

```java
// ❌ Non-public methods - proxy can't intercept
@Async
private void processInBackground() { }

@Async
protected void processInBackground() { }

// ✅ Must be public
@Async
public void processInBackground() { }
```

### 4. Default Executor Creates Thread Per Task

```java
// ❌ Default SimpleAsyncTaskExecutor - creates new thread each time!
// Can cause OutOfMemoryError under load

// ✅ Configure proper thread pool
@Configuration
@EnableAsync
public class AsyncConfig {

    @Bean
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(10);
        executor.setMaxPoolSize(50);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("async-");
        executor.setRejectedExecutionHandler(new CallerRunsPolicy());
        executor.initialize();
        return executor;
    }
}
```

### 5. SecurityContext Not Propagating

```java
// ❌ SecurityContextHolder is ThreadLocal-bound
@Async
public void auditAction() {
    // SecurityContextHolder.getContext() is NULL here!
    String user = SecurityContextHolder.getContext().getAuthentication().getName();
}

// ✅ Use DelegatingSecurityContextAsyncTaskExecutor
@Bean
public Executor taskExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
    // ... configure ...
    return new DelegatingSecurityContextAsyncTaskExecutor(executor);
}
```

---

## CompletableFuture Patterns

### Error Handling

```java
// ❌ Exception silently swallowed
CompletableFuture.supplyAsync(() -> riskyOperation());
// If riskyOperation throws, nobody knows

// ✅ Always handle exceptions
CompletableFuture.supplyAsync(() -> riskyOperation())
    .exceptionally(ex -> {
        log.error("Operation failed", ex);
        return fallbackValue;
    });

// ✅ Or use handle() for both success and failure
CompletableFuture.supplyAsync(() -> riskyOperation())
    .handle((result, ex) -> {
        if (ex != null) {
            log.error("Failed", ex);
            return fallbackValue;
        }
        return result;
    });
```

### Timeout Handling (Java 9+)

```java
// ✅ Fail after timeout
CompletableFuture.supplyAsync(() -> slowOperation())
    .orTimeout(5, TimeUnit.SECONDS);  // Throws TimeoutException

// ✅ Return default after timeout
CompletableFuture.supplyAsync(() -> slowOperation())
    .completeOnTimeout(defaultValue, 5, TimeUnit.SECONDS);
```

### Combining Futures

```java
// ✅ Wait for all
CompletableFuture.allOf(future1, future2, future3)
    .thenRun(() -> log.info("All completed"));

// ✅ Wait for first
CompletableFuture.anyOf(future1, future2, future3)
    .thenAccept(result -> log.info("First result: {}", result));

// ✅ Combine results
future1.thenCombine(future2, (r1, r2) -> merge(r1, r2));
```

### Use Appropriate Executor

```java
// ❌ CPU-bound task in ForkJoinPool.commonPool (default)
CompletableFuture.supplyAsync(() -> cpuIntensiveWork());

// ✅ Custom executor for blocking/I/O operations
ExecutorService ioExecutor = Executors.newFixedThreadPool(20);
CompletableFuture.supplyAsync(() -> blockingIoCall(), ioExecutor);

// ✅ In Java 21+, virtual threads for I/O
ExecutorService virtualExecutor = Executors.newVirtualThreadPerTaskExecutor();
CompletableFuture.supplyAsync(() -> blockingIoCall(), virtualExecutor);
```

---

## Classic Concurrency Issues

### Race Conditions: Check-Then-Act

```java
// ❌ Race condition
if (!map.containsKey(key)) {
    map.put(key, computeValue());  // Another thread may have added it
}

// ✅ Atomic operation
map.computeIfAbsent(key, k -> computeValue());

// ❌ Race condition with counter
if (count < MAX) {
    count++;  // Read-check-write is not atomic
}

// ✅ Atomic counter
AtomicInteger count = new AtomicInteger();
count.updateAndGet(c -> c < MAX ? c + 1 : c);
```

### Visibility: Missing volatile

```java
// ❌ Other threads may never see the update
private boolean running = true;

public void stop() {
    running = false;  // May not be visible to other threads
}

public void run() {
    while (running) { }  // May loop forever
}

// ✅ Volatile ensures visibility
private volatile boolean running = true;
```

### Non-Atomic long/double

```java
// ❌ 64-bit read/write is non-atomic on 32-bit JVMs
private long counter;

public void increment() {
    counter++;  // Not atomic!
}

// ✅ Use AtomicLong or synchronization
private AtomicLong counter = new AtomicLong();

// ✅ Or volatile (for single-writer scenarios)
private volatile long counter;
```

### Double-Checked Locking

```java
// ❌ Broken without volatile
private static Singleton instance;

public static Singleton getInstance() {
    if (instance == null) {
        synchronized (Singleton.class) {
            if (instance == null) {
                instance = new Singleton();  // May be seen partially constructed
            }
        }
    }
    return instance;
}

// ✅ Correct with volatile
private static volatile Singleton instance;

// ✅ Or use holder class idiom
private static class Holder {
    static final Singleton INSTANCE = new Singleton();
}

public static Singleton getInstance() {
    return Holder.INSTANCE;
}
```

### Deadlocks: Lock Ordering

```java
// ❌ Potential deadlock
// Thread 1: lock(A) -> lock(B)
// Thread 2: lock(B) -> lock(A)

public void transfer(Account from, Account to, int amount) {
    synchronized (from) {
        synchronized (to) {
            // Transfer logic
        }
    }
}

// ✅ Consistent lock ordering
public void transfer(Account from, Account to, int amount) {
    Account first = from.getId() < to.getId() ? from : to;
    Account second = from.getId() < to.getId() ? to : from;

    synchronized (first) {
        synchronized (second) {
            // Transfer logic
        }
    }
}
```

---

## Thread-Safe Collections

### Choose the Right Collection

| Use Case | Wrong | Right |
|----------|-------|-------|
| Concurrent reads/writes | `HashMap` | `ConcurrentHashMap` |
| Frequent iteration | `ConcurrentHashMap` | `CopyOnWriteArrayList` |
| Producer-consumer | `ArrayList` | `BlockingQueue` |
| Sorted concurrent | `TreeMap` | `ConcurrentSkipListMap` |

### ConcurrentHashMap Pitfalls

```java
// ❌ Non-atomic compound operation
if (!map.containsKey(key)) {
    map.put(key, value);
}

// ✅ Atomic
map.putIfAbsent(key, value);
map.computeIfAbsent(key, k -> createValue());

// ❌ Nested compute can deadlock
map.compute(key1, (k, v) -> {
    return map.compute(key2, ...);  // Deadlock risk!
});
```

---

## Concurrency Review Checklist

### 🔴 High Severity (Likely Bugs)
- [ ] No check-then-act on shared state without synchronization
- [ ] No `synchronized` calling external/unknown code (deadlock risk)
- [ ] `volatile` present for double-checked locking
- [ ] Non-volatile fields not read in loops waiting for updates
- [ ] `ConcurrentHashMap.compute()` doesn't call other map operations
- [ ] @Async methods are public and called from different beans

### 🟡 Medium Severity (Potential Issues)
- [ ] Thread pools properly sized and named
- [ ] CompletableFuture exceptions handled (exceptionally/handle)
- [ ] SecurityContext propagated to async tasks if needed
- [ ] `ExecutorService` properly shut down
- [ ] `Lock.unlock()` in finally block
- [ ] Thread-safe collections used for shared data

### 🟢 Modern Patterns (Java 21/25)
- [ ] Virtual threads used for I/O-bound concurrent tasks
- [ ] ScopedValue considered over ThreadLocal
- [ ] Structured concurrency for related subtasks
- [ ] Timeouts on CompletableFuture operations

### 📝 Documentation
- [ ] Thread safety documented on shared classes
- [ ] Locking order documented for nested locks
- [ ] Each `volatile` usage justified

---

## Analysis Commands

```bash
# Find synchronized blocks
grep -rn "synchronized" --include="*.java"

# Find @Async methods
grep -rn "@Async" --include="*.java"

# Find volatile fields
grep -rn "volatile" --include="*.java"

# Find thread pool creation
grep -rn "Executors\.\|ThreadPoolExecutor\|ExecutorService" --include="*.java"

# Find CompletableFuture without error handling
grep -rn "CompletableFuture\." --include="*.java" | grep -v "exceptionally\|handle\|whenComplete"

# Find ThreadLocal (consider ScopedValue in Java 21+)
grep -rn "ThreadLocal" --include="*.java"
```
