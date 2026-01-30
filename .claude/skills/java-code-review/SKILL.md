---
name: java-code-review
description: Systematic code review for Java with null safety, exception handling, concurrency, and performance checks. Use when user says "review code", "check this PR", "code review", or before merging changes.
---

# Java Code Review Skill

Systematic code review checklist for Java projects.

## When to Use
- User says "review this code" / "check this PR" / "code review"
- Before merging a PR
- After implementing a feature

## Review Strategy

1. **Quick scan** - Understand intent, identify scope
2. **Checklist pass** - Go through each category below
3. **Summary** - List findings by severity (Critical → Minor)

## Output Format

```markdown
## Code Review: [file/feature name]

### Critical
- [Issue description + line reference + suggestion]

### Improvements
- [Suggestion + rationale]

### Minor/Style
- [Nitpicks, optional improvements]

### Good Practices Observed
- [Positive feedback - important for morale]
```

---

## Review Checklist

### 1. Null Safety

**Check for:**
```java
// ❌ NPE risk
String name = user.getName().toUpperCase();

// ✅ Safe
String name = Optional.ofNullable(user.getName())
    .map(String::toUpperCase)
    .orElse("");

// ✅ Also safe (early return)
if (user.getName() == null) {
    return "";
}
return user.getName().toUpperCase();
```

**Flags:**
- Chained method calls without null checks
- Missing `@Nullable` / `@NonNull` annotations on public APIs
- `Optional.get()` without `isPresent()` check
- Returning `null` from methods that could return `Optional` or empty collection

**Suggest:**
- Use `Optional` for return types that may be absent
- Use `Objects.requireNonNull()` for constructor/method params
- Return empty collections instead of null: `Collections.emptyList()`

### 2. Exception Handling

**Check for:**
```java
// ❌ Swallowing exceptions
try {
    process();
} catch (Exception e) {
    // silently ignored
}

// ❌ Catching too broad
catch (Exception e) { }
catch (Throwable t) { }

// ❌ Losing stack trace
catch (IOException e) {
    throw new RuntimeException(e.getMessage());
}

// ✅ Proper handling
catch (IOException e) {
    log.error("Failed to process file: {}", filename, e);
    throw new ProcessingException("File processing failed", e);
}
```

**Flags:**
- Empty catch blocks
- Catching `Exception` or `Throwable` broadly
- Losing original exception (not chaining)
- Using exceptions for flow control
- Checked exceptions leaking through API boundaries

**Suggest:**
- Log with context AND stack trace
- Use specific exception types
- Chain exceptions with `cause`
- Consider custom exceptions for domain errors

### 3. Collections & Streams

**Check for:**
```java
// ❌ Modifying while iterating
for (Item item : items) {
    if (item.isExpired()) {
        items.remove(item);  // ConcurrentModificationException
    }
}

// ✅ Use removeIf
items.removeIf(Item::isExpired);

// ❌ Stream for simple operations
list.stream().forEach(System.out::println);

// ✅ Simple loop is cleaner
for (Item item : list) {
    System.out.println(item);
}

// ❌ Collecting to modify
List<String> names = users.stream()
    .map(User::getName)
    .collect(Collectors.toList());
names.add("extra");  // Might be immutable!

// ✅ Explicit mutable list
List<String> names = users.stream()
    .map(User::getName)
    .collect(Collectors.toCollection(ArrayList::new));
```

**Flags:**
- Modifying collections during iteration
- Overusing streams for simple operations
- Assuming `Collectors.toList()` returns mutable list
- Not using `List.of()`, `Set.of()`, `Map.of()` for immutable collections
- Parallel streams without understanding implications

**Suggest:**
- `List.copyOf()` for defensive copies
- `removeIf()` instead of iterator removal
- Streams for transformations, loops for side effects

### 4. Concurrency

**Check for:**
```java
// ❌ Not thread-safe
private Map<String, User> cache = new HashMap<>();

// ✅ Thread-safe
private Map<String, User> cache = new ConcurrentHashMap<>();

// ❌ Check-then-act race condition
if (!map.containsKey(key)) {
    map.put(key, computeValue());
}

// ✅ Atomic operation
map.computeIfAbsent(key, k -> computeValue());

// ❌ Double-checked locking (broken without volatile)
if (instance == null) {
    synchronized(this) {
        if (instance == null) {
            instance = new Instance();
        }
    }
}
```

**Flags:**
- Shared mutable state without synchronization
- Check-then-act patterns without atomicity
- Missing `volatile` on shared variables
- Synchronized on non-final objects
- Thread-unsafe lazy initialization

**Suggest:**
- Prefer immutable objects
- Use `java.util.concurrent` classes
- `AtomicReference`, `AtomicInteger` for simple cases
- Consider `@ThreadSafe` / `@NotThreadSafe` annotations

### 5. Java Idioms

**equals/hashCode:**
```java
// ❌ Only equals without hashCode
@Override
public boolean equals(Object o) { ... }
// Missing hashCode!

// ❌ Mutable fields in hashCode
@Override
public int hashCode() {
    return Objects.hash(id, mutableField);  // Breaks HashMap
}

// ✅ Use immutable fields, implement both
@Override
public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof User user)) return false;
    return Objects.equals(id, user.id);
}

@Override
public int hashCode() {
    return Objects.hash(id);
}
```

**toString:**
```java
// ❌ Missing - hard to debug
// No toString()

// ❌ Including sensitive data
return "User{password='" + password + "'}";

// ✅ Useful for debugging
@Override
public String toString() {
    return "User{id=" + id + ", name='" + name + "'}";
}
```

**Builders:**
```java
// ✅ For classes with many optional parameters
User user = User.builder()
    .name("John")
    .email("john@example.com")
    .build();
```

**Flags:**
- `equals` without `hashCode`
- Mutable fields in `hashCode`
- Missing `toString` on domain objects
- Constructors with > 3-4 parameters (suggest builder)
- Not using `instanceof` pattern matching (Java 16+)

### 6. Resource Management

**Check for:**
```java
// ❌ Resource leak
FileInputStream fis = new FileInputStream(file);
// ... might throw before close

// ✅ Try-with-resources
try (FileInputStream fis = new FileInputStream(file)) {
    // ...
}

// ❌ Multiple resources, wrong order
try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
    // FileWriter might not be closed if BufferedWriter fails
}

// ✅ Separate declarations
try (FileWriter fw = new FileWriter(file);
     BufferedWriter writer = new BufferedWriter(fw)) {
    // Both properly closed
}
```

**Flags:**
- Not using try-with-resources for `Closeable`/`AutoCloseable`
- Resources opened but not in try-with-resources
- Database connections/statements not properly closed

### 7. API Design

**Check for:**
```java
// ❌ Boolean parameters
process(data, true, false);  // What do these mean?

// ✅ Use enums or builder
process(data, ProcessMode.ASYNC, ErrorHandling.STRICT);

// ❌ Returning null for "not found"
public User findById(Long id) {
    return users.get(id);  // null if not found
}

// ✅ Return Optional
public Optional<User> findById(Long id) {
    return Optional.ofNullable(users.get(id));
}

// ❌ Accepting null collections
public void process(List<Item> items) {
    if (items == null) items = Collections.emptyList();
}

// ✅ Require non-null, accept empty
public void process(List<Item> items) {
    Objects.requireNonNull(items, "items must not be null");
}
```

**Flags:**
- Boolean parameters (prefer enums)
- Methods with > 3 parameters (consider parameter object)
- Inconsistent null handling across similar methods
- Missing validation on public API inputs

### 8. Performance Considerations

**Check for:**
```java
// ❌ String concatenation in loop
String result = "";
for (String s : strings) {
    result += s;  // Creates new String each iteration
}

// ✅ StringBuilder
StringBuilder sb = new StringBuilder();
for (String s : strings) {
    sb.append(s);
}

// ❌ Regex compilation in loop
for (String line : lines) {
    if (line.matches("pattern.*")) { }  // Compiles regex each time
}

// ✅ Pre-compiled pattern
private static final Pattern PATTERN = Pattern.compile("pattern.*");
for (String line : lines) {
    if (PATTERN.matcher(line).matches()) { }
}

// ❌ N+1 in loops
for (User user : users) {
    List<Order> orders = orderRepo.findByUserId(user.getId());
}

// ✅ Batch fetch
Map<Long, List<Order>> ordersByUser = orderRepo.findByUserIds(userIds);
```

**Flags:**
- String concatenation in loops
- Regex compilation in loops
- N+1 query patterns
- Creating objects in tight loops that could be reused
- Not using primitive streams (`IntStream`, `LongStream`)

### 9. Testing Hints

**Suggest tests for:**
- Null inputs
- Empty collections
- Boundary values
- Exception cases
- Concurrent access (if applicable)

---

## Severity Guidelines

| Severity | Criteria |
|----------|----------|
| **Critical** | Security vulnerability, data loss risk, production crash |
| **High** | Bug likely, significant performance issue, breaks API contract |
| **Medium** | Code smell, maintainability issue, missing best practice |
| **Low** | Style, minor optimization, suggestion |

## Token Optimization

- Focus on changed lines (use `git diff`)
- Don't repeat obvious issues - group similar findings
- Reference line numbers, not full code quotes
- Skip files that are auto-generated or test fixtures

## Quick Reference Card

| Category | Key Checks |
|----------|------------|
| Null Safety | Chained calls, Optional misuse, null returns |
| Exceptions | Empty catch, broad catch, lost stack trace |
| Collections | Modification during iteration, stream vs loop |
| Concurrency | Shared mutable state, check-then-act |
| Idioms | equals/hashCode pair, toString, builders |
| Resources | try-with-resources, connection leaks |
| API | Boolean params, null handling, validation |
| Performance | String concat, regex in loop, N+1 |
