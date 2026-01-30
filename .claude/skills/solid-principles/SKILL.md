---
name: solid-principles
description: SOLID principles checklist with Java examples. Use when reviewing classes, refactoring code, or when user asks about Single Responsibility, Open/Closed, Liskov, Interface Segregation, or Dependency Inversion.
---

# SOLID Principles Skill

Review and apply SOLID principles in Java code.

## When to Use
- User says "check SOLID" / "SOLID review" / "is this class doing too much?"
- Reviewing class design
- Refactoring large classes
- Code review focusing on design

---

## Quick Reference

| Letter | Principle | One-liner |
|--------|-----------|-----------|
| **S** | Single Responsibility | One class = one reason to change |
| **O** | Open/Closed | Open for extension, closed for modification |
| **L** | Liskov Substitution | Subtypes must be substitutable for base types |
| **I** | Interface Segregation | Many specific interfaces > one general interface |
| **D** | Dependency Inversion | Depend on abstractions, not concretions |

---

## S - Single Responsibility Principle (SRP)

> "A class should have only one reason to change."

### Violation

```java
// ❌ BAD: UserService does too much
public class UserService {

    public User createUser(String name, String email) {
        // validation logic
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("Invalid email");
        }

        // persistence logic
        User user = new User(name, email);
        entityManager.persist(user);

        // notification logic
        String subject = "Welcome!";
        String body = "Hello " + name;
        emailClient.send(email, subject, body);

        // audit logic
        auditLog.log("User created: " + email);

        return user;
    }
}
```

**Problems:**
- Validation changes? Modify UserService
- Email template changes? Modify UserService
- Audit format changes? Modify UserService
- Hard to test each concern separately

### Refactored

```java
// ✅ GOOD: Each class has one responsibility

public class UserValidator {
    public void validate(String name, String email) {
        if (email == null || !email.contains("@")) {
            throw new ValidationException("Invalid email");
        }
    }
}

public class UserRepository {
    public User save(User user) {
        entityManager.persist(user);
        return user;
    }
}

public class WelcomeEmailSender {
    public void sendWelcome(User user) {
        String subject = "Welcome!";
        String body = "Hello " + user.getName();
        emailClient.send(user.getEmail(), subject, body);
    }
}

public class UserAuditLogger {
    public void logCreation(User user) {
        auditLog.log("User created: " + user.getEmail());
    }
}

public class UserService {
    private final UserValidator validator;
    private final UserRepository repository;
    private final WelcomeEmailSender emailSender;
    private final UserAuditLogger auditLogger;

    public User createUser(String name, String email) {
        validator.validate(name, email);
        User user = repository.save(new User(name, email));
        emailSender.sendWelcome(user);
        auditLogger.logCreation(user);
        return user;
    }
}
```

### How to Detect SRP Violations

- Class has many `import` statements from different domains
- Class name contains "And" or "Manager" or "Handler" (often)
- Methods operate on unrelated data
- Changes in one area require touching unrelated methods
- Hard to name the class concisely

### Quick Check Questions

1. Can you describe the class purpose in one sentence without "and"?
2. Would different stakeholders request changes to this class?
3. Are there methods that don't use most of the class fields?

---

## O - Open/Closed Principle (OCP)

> "Software entities should be open for extension, but closed for modification."

### Violation

```java
// ❌ BAD: Must modify class to add new discount type
public class DiscountCalculator {

    public double calculate(Order order, String discountType) {
        if (discountType.equals("PERCENTAGE")) {
            return order.getTotal() * 0.1;
        } else if (discountType.equals("FIXED")) {
            return 50.0;
        } else if (discountType.equals("LOYALTY")) {
            return order.getTotal() * order.getCustomer().getLoyaltyRate();
        }
        // Every new discount type = modify this class
        return 0;
    }
}
```

### Refactored

```java
// ✅ GOOD: Add new discounts without modifying existing code

public interface DiscountStrategy {
    double calculate(Order order);
    boolean supports(String discountType);
}

public class PercentageDiscount implements DiscountStrategy {
    @Override
    public double calculate(Order order) {
        return order.getTotal() * 0.1;
    }

    @Override
    public boolean supports(String discountType) {
        return "PERCENTAGE".equals(discountType);
    }
}

public class FixedDiscount implements DiscountStrategy {
    @Override
    public double calculate(Order order) {
        return 50.0;
    }

    @Override
    public boolean supports(String discountType) {
        return "FIXED".equals(discountType);
    }
}

public class LoyaltyDiscount implements DiscountStrategy {
    @Override
    public double calculate(Order order) {
        return order.getTotal() * order.getCustomer().getLoyaltyRate();
    }

    @Override
    public boolean supports(String discountType) {
        return "LOYALTY".equals(discountType);
    }
}

// New discount? Just add new class, no modification needed
public class SeasonalDiscount implements DiscountStrategy {
    @Override
    public double calculate(Order order) {
        return order.getTotal() * 0.2;
    }

    @Override
    public boolean supports(String discountType) {
        return "SEASONAL".equals(discountType);
    }
}

public class DiscountCalculator {
    private final List<DiscountStrategy> strategies;

    public DiscountCalculator(List<DiscountStrategy> strategies) {
        this.strategies = strategies;
    }

    public double calculate(Order order, String discountType) {
        return strategies.stream()
            .filter(s -> s.supports(discountType))
            .findFirst()
            .map(s -> s.calculate(order))
            .orElse(0.0);
    }
}
```

### How to Detect OCP Violations

- `if/else` or `switch` on type/status that grows over time
- Enum-based dispatching with frequent new values
- Changes require modifying core classes

### Common OCP Patterns

| Pattern | Use When |
|---------|----------|
| Strategy | Multiple algorithms for same operation |
| Template Method | Same structure, different steps |
| Decorator | Add behavior dynamically |
| Factory | Create objects without specifying class |

---

## L - Liskov Substitution Principle (LSP)

> "Subtypes must be substitutable for their base types."

### Violation

```java
// ❌ BAD: Square violates Rectangle contract
public class Rectangle {
    protected int width;
    protected int height;

    public void setWidth(int width) {
        this.width = width;
    }

    public void setHeight(int height) {
        this.height = height;
    }

    public int getArea() {
        return width * height;
    }
}

public class Square extends Rectangle {
    @Override
    public void setWidth(int width) {
        this.width = width;
        this.height = width;  // Violates expected behavior!
    }

    @Override
    public void setHeight(int height) {
        this.width = height;  // Violates expected behavior!
        this.height = height;
    }
}

// This test fails for Square!
void testRectangle(Rectangle r) {
    r.setWidth(5);
    r.setHeight(4);
    assert r.getArea() == 20;  // Square returns 16!
}
```

### Refactored

```java
// ✅ GOOD: Separate abstractions

public interface Shape {
    int getArea();
}

public class Rectangle implements Shape {
    private final int width;
    private final int height;

    public Rectangle(int width, int height) {
        this.width = width;
        this.height = height;
    }

    @Override
    public int getArea() {
        return width * height;
    }
}

public class Square implements Shape {
    private final int side;

    public Square(int side) {
        this.side = side;
    }

    @Override
    public int getArea() {
        return side * side;
    }
}
```

### LSP Rules

| Rule | Meaning |
|------|---------|
| Preconditions | Subclass cannot strengthen (require more) |
| Postconditions | Subclass cannot weaken (promise less) |
| Invariants | Subclass must maintain parent's invariants |
| History | Subclass cannot modify inherited state unexpectedly |

### How to Detect LSP Violations

- Subclass throws exception parent doesn't
- Subclass returns null where parent returns object
- Subclass ignores or overrides parent behavior unexpectedly
- `instanceof` checks before calling methods
- Empty or throwing implementations of interface methods

### Quick Check

```java
// If you see this, LSP might be violated
if (bird instanceof Penguin) {
    // don't call fly()
} else {
    bird.fly();
}
```

---

## I - Interface Segregation Principle (ISP)

> "Clients should not be forced to depend on interfaces they do not use."

### Violation

```java
// ❌ BAD: Fat interface forces unnecessary implementations
public interface Worker {
    void work();
    void eat();
    void sleep();
    void attendMeeting();
    void writeReport();
}

// Robot can't eat or sleep!
public class Robot implements Worker {
    @Override public void work() { /* OK */ }
    @Override public void eat() { /* Can't eat! */ }
    @Override public void sleep() { /* Can't sleep! */ }
    @Override public void attendMeeting() { /* OK */ }
    @Override public void writeReport() { /* Maybe */ }
}

// Intern doesn't attend meetings or write reports
public class Intern implements Worker {
    @Override public void work() { /* OK */ }
    @Override public void eat() { /* OK */ }
    @Override public void sleep() { /* OK */ }
    @Override public void attendMeeting() { /* Not allowed! */ }
    @Override public void writeReport() { /* Not expected! */ }
}
```

### Refactored

```java
// ✅ GOOD: Segregated interfaces

public interface Workable {
    void work();
}

public interface Feedable {
    void eat();
    void sleep();
}

public interface Manageable {
    void attendMeeting();
    void writeReport();
}

// Combine what you need
public class Employee implements Workable, Feedable, Manageable {
    @Override public void work() { /* ... */ }
    @Override public void eat() { /* ... */ }
    @Override public void sleep() { /* ... */ }
    @Override public void attendMeeting() { /* ... */ }
    @Override public void writeReport() { /* ... */ }
}

public class Robot implements Workable {
    @Override public void work() { /* ... */ }
    // No unnecessary methods!
}

public class Intern implements Workable, Feedable {
    @Override public void work() { /* ... */ }
    @Override public void eat() { /* ... */ }
    @Override public void sleep() { /* ... */ }
    // No meeting/report methods!
}
```

### How to Detect ISP Violations

- Implementations with empty methods or `throw new UnsupportedOperationException()`
- Interface has 10+ methods
- Different clients use completely different subsets of methods
- Changes to interface affect unrelated implementations

### Java Standard Library Violations

```java
// java.util.List has many methods - but this is acceptable for collections
// However, be careful with your own interfaces!

// ❌ This interface is too fat for most use cases
public interface Repository<T> {
    T findById(Long id);
    List<T> findAll();
    T save(T entity);
    void delete(T entity);
    void deleteById(Long id);
    List<T> findByExample(T example);
    Page<T> findAll(Pageable pageable);
    List<T> findAllById(Iterable<Long> ids);
    long count();
    boolean existsById(Long id);
    // ... 20 more methods
}

// ✅ Better: Split by use case
public interface ReadRepository<T> {
    Optional<T> findById(Long id);
    List<T> findAll();
}

public interface WriteRepository<T> {
    T save(T entity);
    void delete(T entity);
}
```

---

## D - Dependency Inversion Principle (DIP)

> "High-level modules should not depend on low-level modules. Both should depend on abstractions."

### Violation

```java
// ❌ BAD: High-level depends on low-level directly
public class OrderService {
    private MySqlOrderRepository repository;  // Concrete class!
    private SmtpEmailSender emailSender;      // Concrete class!

    public OrderService() {
        this.repository = new MySqlOrderRepository();  // Hard dependency
        this.emailSender = new SmtpEmailSender();      // Hard dependency
    }

    public void createOrder(Order order) {
        repository.save(order);
        emailSender.send(order.getCustomerEmail(), "Order confirmed");
    }
}
```

**Problems:**
- Cannot test without real MySQL database
- Cannot swap email provider
- OrderService knows about MySQL, SMTP details

### Refactored

```java
// ✅ GOOD: Depend on abstractions

// Abstractions (interfaces)
public interface OrderRepository {
    void save(Order order);
    Optional<Order> findById(Long id);
}

public interface NotificationSender {
    void send(String recipient, String message);
}

// High-level module depends on abstractions
public class OrderService {
    private final OrderRepository repository;
    private final NotificationSender notificationSender;

    // Dependencies injected
    public OrderService(OrderRepository repository,
                        NotificationSender notificationSender) {
        this.repository = repository;
        this.notificationSender = notificationSender;
    }

    public void createOrder(Order order) {
        repository.save(order);
        notificationSender.send(order.getCustomerEmail(), "Order confirmed");
    }
}

// Low-level modules implement abstractions
public class MySqlOrderRepository implements OrderRepository {
    @Override
    public void save(Order order) { /* MySQL specific */ }

    @Override
    public Optional<Order> findById(Long id) { /* MySQL specific */ }
}

public class SmtpEmailSender implements NotificationSender {
    @Override
    public void send(String recipient, String message) { /* SMTP specific */ }
}

// Easy to test with mocks!
public class InMemoryOrderRepository implements OrderRepository {
    private Map<Long, Order> orders = new HashMap<>();

    @Override
    public void save(Order order) {
        orders.put(order.getId(), order);
    }

    @Override
    public Optional<Order> findById(Long id) {
        return Optional.ofNullable(orders.get(id));
    }
}
```

### DIP with Spring

```java
// Spring handles dependency injection automatically

@Service
public class OrderService {
    private final OrderRepository repository;
    private final NotificationSender notificationSender;

    // Constructor injection (recommended)
    public OrderService(OrderRepository repository,
                        NotificationSender notificationSender) {
        this.repository = repository;
        this.notificationSender = notificationSender;
    }
}

@Repository
public class JpaOrderRepository implements OrderRepository {
    // Spring provides implementation
}

@Component
@Profile("production")
public class SmtpEmailSender implements NotificationSender { }

@Component
@Profile("test")
public class MockEmailSender implements NotificationSender { }
```

### How to Detect DIP Violations

- `new ConcreteClass()` inside business logic
- Import statements include implementation packages (e.g., `com.mysql`, `org.apache.http`)
- Cannot easily swap implementations
- Tests require real infrastructure (database, network)

---

## SOLID Review Checklist

When reviewing code, check:

| Principle | Question |
|-----------|----------|
| **SRP** | Does this class have more than one reason to change? |
| **OCP** | Will adding a new type/feature require modifying this class? |
| **LSP** | Can subclasses be used wherever parent is expected? |
| **ISP** | Are there empty or throwing method implementations? |
| **DIP** | Does high-level code depend on concrete implementations? |

---

## Common Refactoring Patterns

| Violation | Refactoring |
|-----------|-------------|
| SRP - God class | Extract Class, Move Method |
| OCP - Type switching | Strategy Pattern, Factory |
| LSP - Broken inheritance | Composition over Inheritance, Extract Interface |
| ISP - Fat interface | Split Interface, Role Interface |
| DIP - Hard dependencies | Dependency Injection, Abstract Factory |

---

## Related Skills

- `design-patterns` - Implementation patterns (Factory, Strategy, Observer, etc.)
- `clean-code` - Code-level principles (DRY, KISS, naming)
- `java-code-review` - Comprehensive review checklist
