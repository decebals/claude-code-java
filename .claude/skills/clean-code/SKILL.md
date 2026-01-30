---
name: clean-code
description: Clean Code principles (DRY, KISS, YAGNI), naming conventions, function design, and refactoring. Use when user says "clean this code", "refactor", "improve readability", or when reviewing code quality.
---

# Clean Code Skill

Write readable, maintainable code following Clean Code principles.

## When to Use
- User says "clean this code" / "refactor" / "improve readability"
- Code review focusing on maintainability
- Reducing complexity
- Improving naming

---

## Core Principles

| Principle | Meaning | Violation Sign |
|-----------|---------|----------------|
| **DRY** | Don't Repeat Yourself | Copy-pasted code blocks |
| **KISS** | Keep It Simple, Stupid | Over-engineered solutions |
| **YAGNI** | You Aren't Gonna Need It | Features "just in case" |

---

## DRY - Don't Repeat Yourself

> "Every piece of knowledge must have a single, unambiguous representation in the system."

### Violation

```java
// ❌ BAD: Same validation logic repeated
public class UserController {

    public void createUser(UserRequest request) {
        if (request.getEmail() == null || request.getEmail().isBlank()) {
            throw new ValidationException("Email is required");
        }
        if (!request.getEmail().contains("@")) {
            throw new ValidationException("Invalid email format");
        }
        // ... create user
    }

    public void updateUser(UserRequest request) {
        if (request.getEmail() == null || request.getEmail().isBlank()) {
            throw new ValidationException("Email is required");
        }
        if (!request.getEmail().contains("@")) {
            throw new ValidationException("Invalid email format");
        }
        // ... update user
    }
}
```

### Refactored

```java
// ✅ GOOD: Single source of truth
public class EmailValidator {

    public void validate(String email) {
        if (email == null || email.isBlank()) {
            throw new ValidationException("Email is required");
        }
        if (!email.contains("@")) {
            throw new ValidationException("Invalid email format");
        }
    }
}

public class UserController {
    private final EmailValidator emailValidator;

    public void createUser(UserRequest request) {
        emailValidator.validate(request.getEmail());
        // ... create user
    }

    public void updateUser(UserRequest request) {
        emailValidator.validate(request.getEmail());
        // ... update user
    }
}
```

### DRY Exceptions

Not all duplication is bad. Avoid premature abstraction:

```java
// These look similar but serve different purposes - OK to duplicate
public BigDecimal calculateShippingCost(Order order) {
    return order.getWeight().multiply(SHIPPING_RATE);
}

public BigDecimal calculateInsuranceCost(Order order) {
    return order.getValue().multiply(INSURANCE_RATE);
}
// Don't force these into one method - they'll evolve differently
```

---

## KISS - Keep It Simple

> "The simplest solution is usually the best."

### Violation

```java
// ❌ BAD: Over-engineered for simple task
public class StringUtils {

    public boolean isEmpty(String str) {
        return Optional.ofNullable(str)
            .map(String::trim)
            .map(String::isEmpty)
            .orElseGet(() -> Boolean.TRUE);
    }
}
```

### Refactored

```java
// ✅ GOOD: Simple and clear
public class StringUtils {

    public boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }

    // Or use existing library
    // return StringUtils.isBlank(str);  // Apache Commons
    // return str == null || str.isBlank();  // Java 11+
}
```

### KISS Checklist

- Can a junior developer understand this in 30 seconds?
- Is there a simpler way using standard libraries?
- Am I adding complexity for edge cases that may never happen?

---

## YAGNI - You Aren't Gonna Need It

> "Don't add functionality until it's necessary."

### Violation

```java
// ❌ BAD: Building for hypothetical future
public interface Repository<T, ID> {
    T findById(ID id);
    List<T> findAll();
    List<T> findAll(Pageable pageable);
    List<T> findAll(Sort sort);
    List<T> findAllById(Iterable<ID> ids);
    T save(T entity);
    List<T> saveAll(Iterable<T> entities);
    void delete(T entity);
    void deleteById(ID id);
    void deleteAll(Iterable<T> entities);
    void deleteAll();
    boolean existsById(ID id);
    long count();
    // ... 20 more methods "just in case"
}

// Current usage: only findById and save
```

### Refactored

```java
// ✅ GOOD: Only what's needed now
public interface UserRepository {
    Optional<User> findById(Long id);
    User save(User user);
}

// Add methods when actually needed, not before
```

### YAGNI Signs

- "We might need this later"
- "Let's make it configurable just in case"
- "What if we need to support X in the future?"
- Abstract classes with one implementation

---

## Naming Conventions

### Variables

```java
// ❌ BAD
int d;                  // What is d?
String s;               // Meaningless
List<User> list;        // What kind of list?
Map<String, Object> m;  // What does it map?

// ✅ GOOD
int elapsedTimeInDays;
String customerName;
List<User> activeUsers;
Map<String, Object> sessionAttributes;
```

### Booleans

```java
// ❌ BAD
boolean flag;
boolean status;
boolean check;

// ✅ GOOD - Use is/has/can/should prefix
boolean isActive;
boolean hasPermission;
boolean canEdit;
boolean shouldNotify;
```

### Methods

```java
// ❌ BAD
void process();           // Process what?
void handle();            // Handle what?
void doIt();              // Do what?
User get();               // Get from where?

// ✅ GOOD - Verb + noun, descriptive
void processPayment();
void handleLoginRequest();
void sendWelcomeEmail();
User findByEmail(String email);
List<Order> fetchPendingOrders();
```

### Classes

```java
// ❌ BAD
class Data { }           // Too vague
class Info { }           // Too vague
class Manager { }        // Often a god class
class Helper { }         // Often a dumping ground
class Utils { }          // Static method dumping ground

// ✅ GOOD - Noun, specific responsibility
class User { }
class OrderProcessor { }
class EmailValidator { }
class PaymentGateway { }
class ShippingCalculator { }
```

### Naming Conventions Table

| Element | Convention | Example |
|---------|------------|---------|
| Class | PascalCase, noun | `OrderService` |
| Interface | PascalCase, adjective or noun | `Comparable`, `List` |
| Method | camelCase, verb | `calculateTotal()` |
| Variable | camelCase, noun | `customerEmail` |
| Constant | UPPER_SNAKE | `MAX_RETRY_COUNT` |
| Package | lowercase | `com.example.orders` |

---

## Functions / Methods

### Keep Functions Small

```java
// ❌ BAD: 50+ line method doing multiple things
public void processOrder(Order order) {
    // validate order (10 lines)
    // calculate totals (15 lines)
    // apply discounts (10 lines)
    // update inventory (10 lines)
    // send notifications (10 lines)
    // ... and more
}

// ✅ GOOD: Small, focused methods
public void processOrder(Order order) {
    validateOrder(order);
    calculateTotals(order);
    applyDiscounts(order);
    updateInventory(order);
    sendNotifications(order);
}
```

### Single Level of Abstraction

```java
// ❌ BAD: Mixed abstraction levels
public void processOrder(Order order) {
    validateOrder(order);  // High level

    // Low level mixed in
    BigDecimal total = BigDecimal.ZERO;
    for (OrderItem item : order.getItems()) {
        total = total.add(item.getPrice().multiply(
            BigDecimal.valueOf(item.getQuantity())));
    }

    sendEmail(order);  // High level again
}

// ✅ GOOD: Consistent abstraction level
public void processOrder(Order order) {
    validateOrder(order);
    calculateTotal(order);
    sendConfirmation(order);
}

private BigDecimal calculateTotal(Order order) {
    return order.getItems().stream()
        .map(item -> item.getPrice().multiply(
            BigDecimal.valueOf(item.getQuantity())))
        .reduce(BigDecimal.ZERO, BigDecimal::add);
}
```

### Limit Parameters

```java
// ❌ BAD: Too many parameters
public User createUser(String firstName, String lastName,
                       String email, String phone,
                       String address, String city,
                       String country, String zipCode) {
    // ...
}

// ✅ GOOD: Use parameter object
public User createUser(CreateUserRequest request) {
    // ...
}

// Or builder
public User createUser(UserBuilder builder) {
    // ...
}
```

### Avoid Flag Arguments

```java
// ❌ BAD: Boolean flag changes behavior
public void sendMessage(String message, boolean isUrgent) {
    if (isUrgent) {
        // send immediately
    } else {
        // queue for later
    }
}

// ✅ GOOD: Separate methods
public void sendUrgentMessage(String message) {
    // send immediately
}

public void queueMessage(String message) {
    // queue for later
}
```

---

## Comments

### Avoid Obvious Comments

```java
// ❌ BAD: Noise comments
// Set the user's name
user.setName(name);

// Increment counter
counter++;

// Check if user is null
if (user != null) {
    // ...
}
```

### Good Comments

```java
// ✅ GOOD: Explain WHY, not WHAT

// Retry with exponential backoff to avoid overwhelming the server
// during high load periods (see incident #1234)
for (int attempt = 0; attempt < MAX_RETRIES; attempt++) {
    Thread.sleep((long) Math.pow(2, attempt) * 1000);
    // ...
}

// TODO: Replace with Redis cache after infrastructure upgrade (Q2 2026)
private Map<String, User> userCache = new ConcurrentHashMap<>();

// WARNING: Order matters! Discounts must be applied before tax calculation
applyDiscounts(order);
calculateTax(order);
```

### Let Code Speak

```java
// ❌ BAD: Comment explaining bad code
// Check if the user is an admin or has special permission
// and the action is allowed for their role
if ((user.getRole() == 1 || user.getRole() == 2) &&
    (action == 3 || action == 4 || action == 7)) {
    // ...
}

// ✅ GOOD: Self-documenting code
if (user.hasAdminPrivileges() && action.isAllowedFor(user.getRole())) {
    // ...
}
```

---

## Common Code Smells

| Smell | Description | Refactoring |
|-------|-------------|-------------|
| **Long Method** | Method > 20 lines | Extract Method |
| **Long Parameter List** | > 3 parameters | Parameter Object |
| **Duplicate Code** | Same code in multiple places | Extract Method/Class |
| **Dead Code** | Unused code | Delete it |
| **Magic Numbers** | Unexplained literals | Named Constants |
| **God Class** | Class doing too much | Extract Class |
| **Feature Envy** | Method uses another class's data | Move Method |
| **Primitive Obsession** | Primitives instead of objects | Value Objects |

### Magic Numbers

```java
// ❌ BAD
if (user.getAge() >= 18) { }
if (order.getTotal() > 100) { }
Thread.sleep(86400000);

// ✅ GOOD
private static final int ADULT_AGE = 18;
private static final BigDecimal FREE_SHIPPING_THRESHOLD = new BigDecimal("100");
private static final long ONE_DAY_MS = TimeUnit.DAYS.toMillis(1);

if (user.getAge() >= ADULT_AGE) { }
if (order.getTotal().compareTo(FREE_SHIPPING_THRESHOLD) > 0) { }
Thread.sleep(ONE_DAY_MS);
```

### Primitive Obsession

```java
// ❌ BAD: Primitives everywhere
public void createUser(String email, String phone, String zipCode) {
    // No validation, easy to mix up parameters
}

createUser("12345", "john@email.com", "555-1234");  // Wrong order, compiles!

// ✅ GOOD: Value objects
public record Email(String value) {
    public Email {
        if (!value.contains("@")) {
            throw new IllegalArgumentException("Invalid email");
        }
    }
}

public record PhoneNumber(String value) {
    // validation
}

public void createUser(Email email, PhoneNumber phone, ZipCode zipCode) {
    // Type-safe, self-validating
}
```

---

## Refactoring Quick Reference

| From | To | Technique |
|------|-----|-----------|
| Long method | Short methods | Extract Method |
| Duplicate code | Single method | Extract Method |
| Complex conditional | Polymorphism | Replace Conditional with Polymorphism |
| Many parameters | Object | Introduce Parameter Object |
| Temp variables | Query method | Replace Temp with Query |
| Comments explaining code | Self-documenting code | Rename, Extract |
| Nested conditionals | Early return | Guard Clauses |

### Guard Clauses

```java
// ❌ BAD: Deeply nested
public void processOrder(Order order) {
    if (order != null) {
        if (order.isValid()) {
            if (order.hasItems()) {
                // actual logic buried here
            }
        }
    }
}

// ✅ GOOD: Guard clauses
public void processOrder(Order order) {
    if (order == null) return;
    if (!order.isValid()) return;
    if (!order.hasItems()) return;

    // actual logic at top level
}
```

---

## Clean Code Checklist

When reviewing code, check:

- [ ] Are names meaningful and pronounceable?
- [ ] Are functions small and focused?
- [ ] Is there any duplicated code?
- [ ] Are there magic numbers or strings?
- [ ] Are comments explaining "why" not "what"?
- [ ] Is the code at consistent abstraction level?
- [ ] Can any code be simplified?
- [ ] Is there dead/unused code?

---

## Related Skills

- `solid-principles` - Design principles for class structure
- `design-patterns` - Common solutions to recurring problems
- `java-code-review` - Comprehensive review checklist
