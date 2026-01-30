---
name: design-patterns
description: Common design patterns with Java examples (Factory, Builder, Strategy, Observer, Decorator, etc.). Use when user asks "implement pattern", "use factory", "strategy pattern", or when designing extensible components.
---

# Design Patterns Skill

Practical design patterns reference for Java with modern examples.

## When to Use
- User asks to implement a specific pattern
- Designing extensible/flexible components
- Refactoring rigid code structures
- Code review suggests pattern usage

---

## Quick Reference: When to Use What

| Problem | Pattern |
|---------|---------|
| Complex object construction | **Builder** |
| Create objects without specifying class | **Factory** |
| Multiple algorithms, swap at runtime | **Strategy** |
| Add behavior without changing class | **Decorator** |
| Notify multiple objects of changes | **Observer** |
| Ensure single instance | **Singleton** |
| Convert incompatible interfaces | **Adapter** |
| Define algorithm skeleton | **Template Method** |

---

## Creational Patterns

### Builder

**Use when:** Object has many parameters, some optional.

```java
// ❌ Telescoping constructor antipattern
public class User {
    public User(String name) { }
    public User(String name, String email) { }
    public User(String name, String email, int age) { }
    public User(String name, String email, int age, String phone) { }
    // ... explosion of constructors
}

// ✅ Builder pattern
public class User {
    private final String name;      // required
    private final String email;     // required
    private final int age;          // optional
    private final String phone;     // optional
    private final String address;   // optional

    private User(Builder builder) {
        this.name = builder.name;
        this.email = builder.email;
        this.age = builder.age;
        this.phone = builder.phone;
        this.address = builder.address;
    }

    public static Builder builder(String name, String email) {
        return new Builder(name, email);
    }

    public static class Builder {
        // Required
        private final String name;
        private final String email;
        // Optional with defaults
        private int age = 0;
        private String phone = "";
        private String address = "";

        private Builder(String name, String email) {
            this.name = name;
            this.email = email;
        }

        public Builder age(int age) {
            this.age = age;
            return this;
        }

        public Builder phone(String phone) {
            this.phone = phone;
            return this;
        }

        public Builder address(String address) {
            this.address = address;
            return this;
        }

        public User build() {
            return new User(this);
        }
    }
}

// Usage
User user = User.builder("John", "john@example.com")
    .age(30)
    .phone("+1234567890")
    .build();
```

**With Lombok:**
```java
@Builder
@Getter
public class User {
    private final String name;
    private final String email;
    @Builder.Default private int age = 0;
    private String phone;
}
```

---

### Factory Method

**Use when:** Need to create objects without specifying exact class.

```java
// ✅ Factory Method pattern
public interface Notification {
    void send(String message);
}

public class EmailNotification implements Notification {
    @Override
    public void send(String message) {
        System.out.println("Email: " + message);
    }
}

public class SmsNotification implements Notification {
    @Override
    public void send(String message) {
        System.out.println("SMS: " + message);
    }
}

public class PushNotification implements Notification {
    @Override
    public void send(String message) {
        System.out.println("Push: " + message);
    }
}

// Factory
public class NotificationFactory {

    public static Notification create(String type) {
        return switch (type.toUpperCase()) {
            case "EMAIL" -> new EmailNotification();
            case "SMS" -> new SmsNotification();
            case "PUSH" -> new PushNotification();
            default -> throw new IllegalArgumentException("Unknown type: " + type);
        };
    }
}

// Usage
Notification notification = NotificationFactory.create("EMAIL");
notification.send("Hello!");
```

**With Spring (preferred):**
```java
public interface NotificationSender {
    void send(String message);
    String getType();
}

@Component
public class EmailSender implements NotificationSender {
    @Override public void send(String message) { /* ... */ }
    @Override public String getType() { return "EMAIL"; }
}

@Component
public class SmsSender implements NotificationSender {
    @Override public void send(String message) { /* ... */ }
    @Override public String getType() { return "SMS"; }
}

@Component
public class NotificationFactory {
    private final Map<String, NotificationSender> senders;

    public NotificationFactory(List<NotificationSender> senderList) {
        this.senders = senderList.stream()
            .collect(Collectors.toMap(
                NotificationSender::getType,
                Function.identity()
            ));
    }

    public NotificationSender getSender(String type) {
        return Optional.ofNullable(senders.get(type))
            .orElseThrow(() -> new IllegalArgumentException("Unknown: " + type));
    }
}
```

---

### Singleton

**Use when:** Exactly one instance needed (use sparingly!).

```java
// ✅ Modern singleton (enum-based, thread-safe)
public enum DatabaseConnection {
    INSTANCE;

    private Connection connection;

    DatabaseConnection() {
        // Initialize connection
    }

    public Connection getConnection() {
        return connection;
    }
}

// Usage
Connection conn = DatabaseConnection.INSTANCE.getConnection();
```

**With Spring (preferred):**
```java
@Component  // Default scope is singleton
public class DatabaseConnection {
    // Spring manages single instance
}
```

**Warning:** Singletons can be problematic:
- Hard to test (global state)
- Hidden dependencies
- Consider dependency injection instead

---

## Behavioral Patterns

### Strategy

**Use when:** Multiple algorithms for same operation, need to swap at runtime.

```java
// ✅ Strategy pattern
public interface PaymentStrategy {
    void pay(BigDecimal amount);
}

public class CreditCardPayment implements PaymentStrategy {
    private final String cardNumber;

    public CreditCardPayment(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    @Override
    public void pay(BigDecimal amount) {
        System.out.println("Paid " + amount + " with card " + cardNumber);
    }
}

public class PayPalPayment implements PaymentStrategy {
    private final String email;

    public PayPalPayment(String email) {
        this.email = email;
    }

    @Override
    public void pay(BigDecimal amount) {
        System.out.println("Paid " + amount + " via PayPal: " + email);
    }
}

public class CryptoPayment implements PaymentStrategy {
    private final String walletAddress;

    public CryptoPayment(String walletAddress) {
        this.walletAddress = walletAddress;
    }

    @Override
    public void pay(BigDecimal amount) {
        System.out.println("Paid " + amount + " to wallet: " + walletAddress);
    }
}

// Context
public class ShoppingCart {
    private PaymentStrategy paymentStrategy;

    public void setPaymentStrategy(PaymentStrategy strategy) {
        this.paymentStrategy = strategy;
    }

    public void checkout(BigDecimal total) {
        paymentStrategy.pay(total);
    }
}

// Usage
ShoppingCart cart = new ShoppingCart();
cart.setPaymentStrategy(new CreditCardPayment("4111-1111-1111-1111"));
cart.checkout(new BigDecimal("99.99"));

// Change strategy at runtime
cart.setPaymentStrategy(new PayPalPayment("user@example.com"));
cart.checkout(new BigDecimal("49.99"));
```

**With Java 8+ (functional):**
```java
// Strategy as functional interface
@FunctionalInterface
public interface PaymentStrategy {
    void pay(BigDecimal amount);
}

// Usage with lambdas
PaymentStrategy creditCard = amount ->
    System.out.println("Card payment: " + amount);

PaymentStrategy paypal = amount ->
    System.out.println("PayPal payment: " + amount);

cart.setPaymentStrategy(creditCard);
```

---

### Observer

**Use when:** Objects need to be notified of changes in another object.

```java
// ✅ Observer pattern (modern Java)
public interface OrderObserver {
    void onOrderPlaced(Order order);
}

public class OrderService {
    private final List<OrderObserver> observers = new ArrayList<>();

    public void addObserver(OrderObserver observer) {
        observers.add(observer);
    }

    public void removeObserver(OrderObserver observer) {
        observers.remove(observer);
    }

    public void placeOrder(Order order) {
        // Process order
        saveOrder(order);

        // Notify all observers
        observers.forEach(observer -> observer.onOrderPlaced(order));
    }
}

// Observers
public class InventoryService implements OrderObserver {
    @Override
    public void onOrderPlaced(Order order) {
        // Reduce inventory
        order.getItems().forEach(item ->
            reduceStock(item.getProductId(), item.getQuantity())
        );
    }
}

public class EmailNotificationService implements OrderObserver {
    @Override
    public void onOrderPlaced(Order order) {
        sendConfirmationEmail(order.getCustomerEmail(), order);
    }
}

public class AnalyticsService implements OrderObserver {
    @Override
    public void onOrderPlaced(Order order) {
        trackOrderEvent(order);
    }
}

// Setup
OrderService orderService = new OrderService();
orderService.addObserver(new InventoryService());
orderService.addObserver(new EmailNotificationService());
orderService.addObserver(new AnalyticsService());
```

**With Spring Events (preferred):**
```java
// Event
public record OrderPlacedEvent(Order order) {}

// Publisher
@Service
public class OrderService {
    private final ApplicationEventPublisher eventPublisher;

    public void placeOrder(Order order) {
        saveOrder(order);
        eventPublisher.publishEvent(new OrderPlacedEvent(order));
    }
}

// Listeners (observers)
@Component
public class InventoryListener {
    @EventListener
    public void handleOrderPlaced(OrderPlacedEvent event) {
        // Reduce inventory
    }
}

@Component
public class EmailListener {
    @EventListener
    public void handleOrderPlaced(OrderPlacedEvent event) {
        // Send email
    }

    @EventListener
    @Async  // Async processing
    public void handleOrderPlacedAsync(OrderPlacedEvent event) {
        // Send email asynchronously
    }
}
```

---

### Template Method

**Use when:** Define algorithm skeleton, let subclasses fill in steps.

```java
// ✅ Template Method pattern
public abstract class DataProcessor {

    // Template method - defines the algorithm
    public final void process() {
        readData();
        processData();
        writeData();
        if (shouldNotify()) {
            notifyCompletion();
        }
    }

    // Steps to be implemented by subclasses
    protected abstract void readData();
    protected abstract void processData();
    protected abstract void writeData();

    // Hook - optional override
    protected boolean shouldNotify() {
        return true;
    }

    protected void notifyCompletion() {
        System.out.println("Processing completed!");
    }
}

public class CsvDataProcessor extends DataProcessor {
    @Override
    protected void readData() {
        System.out.println("Reading CSV file...");
    }

    @Override
    protected void processData() {
        System.out.println("Processing CSV data...");
    }

    @Override
    protected void writeData() {
        System.out.println("Writing to database...");
    }
}

public class ApiDataProcessor extends DataProcessor {
    @Override
    protected void readData() {
        System.out.println("Fetching from API...");
    }

    @Override
    protected void processData() {
        System.out.println("Transforming API response...");
    }

    @Override
    protected void writeData() {
        System.out.println("Writing to cache...");
    }

    @Override
    protected boolean shouldNotify() {
        return false;  // Override hook
    }
}

// Usage
DataProcessor csvProcessor = new CsvDataProcessor();
csvProcessor.process();

DataProcessor apiProcessor = new ApiDataProcessor();
apiProcessor.process();
```

---

## Structural Patterns

### Decorator

**Use when:** Add behavior dynamically without modifying existing classes.

```java
// ✅ Decorator pattern
public interface Coffee {
    String getDescription();
    BigDecimal getCost();
}

public class SimpleCoffee implements Coffee {
    @Override
    public String getDescription() {
        return "Coffee";
    }

    @Override
    public BigDecimal getCost() {
        return new BigDecimal("2.00");
    }
}

// Base decorator
public abstract class CoffeeDecorator implements Coffee {
    protected final Coffee coffee;

    public CoffeeDecorator(Coffee coffee) {
        this.coffee = coffee;
    }

    @Override
    public String getDescription() {
        return coffee.getDescription();
    }

    @Override
    public BigDecimal getCost() {
        return coffee.getCost();
    }
}

// Concrete decorators
public class MilkDecorator extends CoffeeDecorator {
    public MilkDecorator(Coffee coffee) {
        super(coffee);
    }

    @Override
    public String getDescription() {
        return coffee.getDescription() + ", Milk";
    }

    @Override
    public BigDecimal getCost() {
        return coffee.getCost().add(new BigDecimal("0.50"));
    }
}

public class SugarDecorator extends CoffeeDecorator {
    public SugarDecorator(Coffee coffee) {
        super(coffee);
    }

    @Override
    public String getDescription() {
        return coffee.getDescription() + ", Sugar";
    }

    @Override
    public BigDecimal getCost() {
        return coffee.getCost().add(new BigDecimal("0.20"));
    }
}

public class WhippedCreamDecorator extends CoffeeDecorator {
    public WhippedCreamDecorator(Coffee coffee) {
        super(coffee);
    }

    @Override
    public String getDescription() {
        return coffee.getDescription() + ", Whipped Cream";
    }

    @Override
    public BigDecimal getCost() {
        return coffee.getCost().add(new BigDecimal("0.70"));
    }
}

// Usage - compose decorators
Coffee coffee = new SimpleCoffee();
coffee = new MilkDecorator(coffee);
coffee = new SugarDecorator(coffee);
coffee = new WhippedCreamDecorator(coffee);

System.out.println(coffee.getDescription());  // Coffee, Milk, Sugar, Whipped Cream
System.out.println(coffee.getCost());         // 3.40
```

**Java I/O uses Decorator:**
```java
// Classic example from Java
BufferedReader reader = new BufferedReader(
    new InputStreamReader(
        new FileInputStream("file.txt")
    )
);
```

---

### Adapter

**Use when:** Make incompatible interfaces work together.

```java
// ✅ Adapter pattern

// Existing interface our code uses
public interface MediaPlayer {
    void play(String filename);
}

// Legacy/third-party interface
public class LegacyAudioPlayer {
    public void playMp3(String filename) {
        System.out.println("Playing MP3: " + filename);
    }
}

public class AdvancedVideoPlayer {
    public void playMp4(String filename) {
        System.out.println("Playing MP4: " + filename);
    }

    public void playAvi(String filename) {
        System.out.println("Playing AVI: " + filename);
    }
}

// Adapters
public class Mp3PlayerAdapter implements MediaPlayer {
    private final LegacyAudioPlayer legacyPlayer = new LegacyAudioPlayer();

    @Override
    public void play(String filename) {
        legacyPlayer.playMp3(filename);
    }
}

public class VideoPlayerAdapter implements MediaPlayer {
    private final AdvancedVideoPlayer videoPlayer = new AdvancedVideoPlayer();

    @Override
    public void play(String filename) {
        if (filename.endsWith(".mp4")) {
            videoPlayer.playMp4(filename);
        } else if (filename.endsWith(".avi")) {
            videoPlayer.playAvi(filename);
        }
    }
}

// Usage
MediaPlayer mp3Player = new Mp3PlayerAdapter();
mp3Player.play("song.mp3");

MediaPlayer videoPlayer = new VideoPlayerAdapter();
videoPlayer.play("movie.mp4");
```

---

## Pattern Selection Guide

| Situation | Consider |
|-----------|----------|
| Object creation is complex | Builder, Factory |
| Need to add features dynamically | Decorator |
| Multiple implementations of algorithm | Strategy |
| React to state changes | Observer |
| Integrate with legacy code | Adapter |
| Common algorithm, varying steps | Template Method |
| Need single instance | Singleton (use sparingly) |

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Better Approach |
|--------------|---------|-----------------|
| Singleton abuse | Global state, hard to test | Dependency Injection |
| Factory everywhere | Over-engineering | Simple `new` if type is known |
| Deep decorator chains | Hard to debug | Keep chains short, consider composition |
| Observer with many events | Spaghetti notifications | Event bus, clear event hierarchy |

---

## Related Skills

- `solid-principles` - Design principles that patterns help implement
- `clean-code` - Code-level best practices
- `spring-boot-patterns` - Spring-specific implementations
