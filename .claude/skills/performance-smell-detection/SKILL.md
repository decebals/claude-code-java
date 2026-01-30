---
name: performance-smell-detection
description: Detect potential code-level performance smells in Java - streams, collections, boxing, regex, object creation. Provides awareness, not absolutes - always measure before optimizing. For JPA/database performance, use jpa-patterns instead.
---

# Performance Smell Detection Skill

Identify **potential** code-level performance issues in Java code.

## Philosophy

> "Premature optimization is the root of all evil" - Donald Knuth

This skill helps you **notice** potential performance smells, not blindly "fix" them. Modern JVMs (Java 21/25) are highly optimized. Always:

1. **Measure first** - Use JMH, profilers, or production metrics
2. **Focus on hot paths** - 90% of time spent in 10% of code
3. **Consider readability** - Clear code often matters more than micro-optimizations

## When to Use
- Reviewing performance-critical code paths
- Investigating measured performance issues
- Learning about Java performance patterns
- Code review with performance awareness

## Scope

**This skill:** Code-level performance (streams, collections, objects)
**For database:** Use `jpa-patterns` skill (N+1, lazy loading, pagination)
**For architecture:** Use `architecture-review` skill

---

## Quick Reference: Potential Smells

| Smell | Severity | Context |
|-------|----------|---------|
| Regex compile in loop | 🔴 High | Always worth fixing |
| String concat in loop | 🟡 Medium | Still valid in Java 21/25 |
| Stream in tight loop | 🟡 Medium | Depends on collection size |
| Boxing in hot path | 🟡 Medium | Measure first |
| Unbounded collection | 🔴 High | Memory risk |
| Missing collection capacity | 🟢 Low | Minor, measure if critical |

---

## String Operations (Java 9+ / 21 / 25)

### What Changed

Since **Java 9** (JEP 280), string concatenation with `+` uses `invokedynamic`, not StringBuilder. The JVM optimizes simple concatenation well.

**Java 25** adds String::hashCode constant folding for additional optimization in Map lookups with String keys.

### Still Valid: StringBuilder in Loops

```java
// 🔴 Still problematic - new String each iteration
String result = "";
for (String s : items) {
    result += s;  // O(n²) - creates n strings
}

// ✅ StringBuilder for loops
StringBuilder sb = new StringBuilder();
for (String s : items) {
    sb.append(s);
}
String result = sb.toString();

// ✅ Or use String.join / Collectors.joining
String result = String.join("", items);
```

### Now Fine: Simple Concatenation

```java
// ✅ Fine in Java 9+ - JVM optimizes this
String message = "User " + name + " logged in at " + timestamp;

// ✅ Also fine
return "Error: " + code + " - " + description;
```

### Avoid in Hot Paths: String.format

```java
// 🟡 String.format has parsing overhead
log.debug(String.format("Processing %s with id %d", name, id));

// ✅ Parameterized logging (SLF4J)
log.debug("Processing {} with id {}", name, id);
```

---

## Stream API (Nuanced View)

### The Reality

Streams have overhead, but it's **often acceptable**:
- **< 100 items**: Streams can be 2-5x slower (but still microseconds)
- **1K-10K items**: Difference narrows significantly
- **> 10K items**: Often within 50% of loops
- **GraalVM**: Can optimize streams to match loops

**Recommendation**: Prefer streams for readability. Optimize to loops only when profiling shows a bottleneck.

### When Streams Are Problematic

```java
// 🔴 Stream created per iteration in hot loop
for (int i = 0; i < 1_000_000; i++) {
    boolean found = items.stream()
        .anyMatch(item -> item.getId() == i);
}

// ✅ Pre-compute lookup structure
Set<Integer> itemIds = items.stream()
    .map(Item::getId)
    .collect(Collectors.toSet());

for (int i = 0; i < 1_000_000; i++) {
    boolean found = itemIds.contains(i);
}
```

### When Streams Are Fine

```java
// ✅ Single pass, readable, not in tight loop
List<String> names = users.stream()
    .filter(User::isActive)
    .map(User::getName)
    .sorted()
    .collect(Collectors.toList());

// ✅ Primitive streams avoid boxing
int sum = numbers.stream()
    .mapToInt(Integer::intValue)
    .sum();
```

### Parallel Streams: Use Carefully

```java
// 🔴 Parallel on small collection - overhead > benefit
smallList.parallelStream().map(...);  // < 10K items

// 🔴 Parallel with shared mutable state
List<String> results = new ArrayList<>();
items.parallelStream()
    .forEach(results::add);  // Race condition!

// ✅ Parallel for CPU-intensive + large collections
List<Result> results = largeDataset.parallelStream()  // > 10K items
    .map(this::expensiveCpuComputation)
    .collect(Collectors.toList());
```

---

## Boxing/Unboxing

### Still a Real Issue

Boxing creates objects on heap, adds GC pressure. JVM caches small values (-128 to 127) but not larger ones.

> **Future**: Project Valhalla will improve this significantly.

```java
// 🔴 Boxing in tight loop - creates millions of objects
Long sum = 0L;
for (int i = 0; i < 1_000_000; i++) {
    sum += i;  // Unbox, add, box
}

// ✅ Primitive
long sum = 0L;
for (int i = 0; i < 1_000_000; i++) {
    sum += i;
}
```

### Use Primitive Streams

```java
// 🟡 Boxing overhead
int sum = list.stream()
    .reduce(0, Integer::sum);

// ✅ Primitive stream
int sum = list.stream()
    .mapToInt(Integer::intValue)
    .sum();
```

---

## Regex

### Always Pre-compile in Loops

This advice is **not outdated** - Pattern.compile is expensive.

```java
// 🔴 Compiles pattern every iteration
for (String input : inputs) {
    if (input.matches("\\d{3}-\\d{4}")) {  // Compiles regex!
        process(input);
    }
}

// ✅ Pre-compile
private static final Pattern PHONE = Pattern.compile("\\d{3}-\\d{4}");

for (String input : inputs) {
    if (PHONE.matcher(input).matches()) {
        process(input);
    }
}
```

---

## Collections

### Capacity Hint (Minor Optimization)

```java
// 🟢 Low severity - but free optimization if size known
List<User> users = new ArrayList<>(expectedSize);
Map<String, User> map = new HashMap<>(expectedSize * 4 / 3 + 1);
```

### Right Collection for the Job

```java
// 🟡 O(n) lookup in loop
List<String> allowed = getAllowed();
for (Request r : requests) {
    if (allowed.contains(r.getId())) { }  // O(n) each time
}

// ✅ O(1) lookup
Set<String> allowed = new HashSet<>(getAllowed());
for (Request r : requests) {
    if (allowed.contains(r.getId())) { }  // O(1)
}
```

### Unbounded Collections

```java
// 🔴 Memory risk - could grow unbounded
@GetMapping("/users")
public List<User> getAllUsers() {
    return userRepository.findAll();  // Millions of rows?
}

// ✅ Pagination
@GetMapping("/users")
public Page<User> getUsers(Pageable pageable) {
    return userRepository.findAll(pageable);
}
```

---

## Modern Java (21/25) Patterns

### Virtual Threads for I/O (Java 21+)

```java
// 🟡 Traditional thread pool for I/O - wastes OS threads
ExecutorService executor = Executors.newFixedThreadPool(100);
for (Request request : requests) {
    executor.submit(() -> callExternalApi(request));  // Blocks OS thread
}

// ✅ Virtual threads - millions of concurrent I/O operations
try (ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor()) {
    for (Request request : requests) {
        executor.submit(() -> callExternalApi(request));
    }
}
```

### Structured Concurrency (Java 21+ Preview)

```java
// ✅ Structured concurrency for parallel I/O
try (StructuredTaskScope.ShutdownOnFailure scope = new StructuredTaskScope.ShutdownOnFailure()) {
    Future<User> user = scope.fork(() -> fetchUser(id));
    Future<Orders> orders = scope.fork(() -> fetchOrders(id));

    scope.join();
    scope.throwIfFailed();

    return new UserProfile(user.resultNow(), orders.resultNow());
}
```

---

## Performance Review Checklist

### 🔴 High Severity (Usually Worth Fixing)
- [ ] Regex Pattern.compile in loops
- [ ] Unbounded queries without pagination
- [ ] String concatenation in loops (StringBuilder still valid)
- [ ] Parallel streams with shared mutable state

### 🟡 Medium Severity (Measure First)
- [ ] Streams in tight loops (>100K iterations)
- [ ] Boxing in hot paths
- [ ] List.contains() in loops (use Set)
- [ ] Traditional threads for I/O (consider Virtual Threads)

### 🟢 Low Severity (Nice to Have)
- [ ] Collection initial capacity
- [ ] Minor stream optimizations
- [ ] toArray(new T[0]) vs toArray(new T[size])

---

## When NOT to Optimize

- **Not a hot path** - Setup code, config, admin endpoints
- **No measured problem** - "Looks slow" is not a measurement
- **Readability suffers** - Clear code > micro-optimization
- **Small collections** - 100 items processed in microseconds anyway

---

## Analysis Commands

```bash
# Find regex in loops (potential compile overhead)
grep -rn "\.matches(\|\.split(" --include="*.java"

# Find potential boxing (Long/Integer as variables)
grep -rn "Long\s\|Integer\s\|Double\s" --include="*.java" | grep "= 0\|+="

# Find ArrayList without capacity
grep -rn "new ArrayList<>()" --include="*.java"

# Find findAll without pagination
grep -rn "findAll()" --include="*.java"
```