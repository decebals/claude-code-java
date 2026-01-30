---
name: architecture-review
description: Analyze Java project architecture at macro level - package structure, module boundaries, dependency direction, and layering. Use when user asks "review architecture", "check structure", "package organization", or when evaluating if a codebase follows clean architecture principles.
---

# Architecture Review Skill

Analyze project structure at the macro level - packages, modules, layers, and boundaries.

## When to Use
- User asks "review the architecture" / "check project structure"
- Evaluating package organization
- Checking dependency direction between layers
- Identifying architectural violations
- Assessing clean/hexagonal architecture compliance

---

## Quick Reference: Architecture Smells

| Smell | Symptom | Impact |
|-------|---------|--------|
| Package-by-layer bloat | `service/` with 50+ classes | Hard to find related code |
| Domain → Infra dependency | Entity imports `@Repository` | Core logic tied to framework |
| Circular dependencies | A → B → C → A | Untestable, fragile |
| God package | `util/` or `common/` growing | Dump for misplaced code |
| Leaky abstractions | Controller knows SQL | Layer boundaries violated |

---

## Package Organization Strategies

### Package-by-Layer (Traditional)

```
com.example.app/
├── controller/
│   ├── UserController.java
│   ├── OrderController.java
│   └── ProductController.java
├── service/
│   ├── UserService.java
│   ├── OrderService.java
│   └── ProductService.java
├── repository/
│   ├── UserRepository.java
│   ├── OrderRepository.java
│   └── ProductRepository.java
└── model/
    ├── User.java
    ├── Order.java
    └── Product.java
```

**Pros**: Familiar, simple for small projects
**Cons**: Scatters related code, doesn't scale, hard to extract modules

### Package-by-Feature (Recommended)

```
com.example.app/
├── user/
│   ├── UserController.java
│   ├── UserService.java
│   ├── UserRepository.java
│   └── User.java
├── order/
│   ├── OrderController.java
│   ├── OrderService.java
│   ├── OrderRepository.java
│   └── Order.java
└── product/
    ├── ProductController.java
    ├── ProductService.java
    ├── ProductRepository.java
    └── Product.java
```

**Pros**: Related code together, easy to extract, clear boundaries
**Cons**: May need shared kernel for cross-cutting concerns

### Hexagonal/Clean Architecture

```
com.example.app/
├── domain/                    # Pure business logic (no framework imports)
│   ├── model/
│   │   └── User.java
│   ├── port/
│   │   ├── in/               # Use cases (driven)
│   │   │   └── CreateUserUseCase.java
│   │   └── out/              # Repositories (driving)
│   │       └── UserRepository.java
│   └── service/
│       └── UserDomainService.java
├── application/               # Use case implementations
│   └── CreateUserService.java
├── adapter/
│   ├── in/
│   │   └── web/
│   │       └── UserController.java
│   └── out/
│       └── persistence/
│           ├── UserJpaRepository.java
│           └── UserEntity.java
└── config/
    └── BeanConfiguration.java
```

**Key rule**: Dependencies point inward (adapters → application → domain)

---

## Dependency Direction Rules

### The Golden Rule

```
┌─────────────────────────────────────────┐
│              Frameworks                 │  ← Outer (volatile)
├─────────────────────────────────────────┤
│           Adapters (Web, DB)            │
├─────────────────────────────────────────┤
│         Application Services            │
├─────────────────────────────────────────┤
│          Domain (Core Logic)            │  ← Inner (stable)
└─────────────────────────────────────────┘

Dependencies MUST point inward only.
Inner layers MUST NOT know about outer layers.
```

### Violations to Flag

```java
// ❌ Domain depends on infrastructure
package com.example.domain.model;

import org.springframework.data.jpa.repository.JpaRepository;  // Framework leak!
import javax.persistence.Entity;  // JPA in domain!

@Entity
public class User {
    // Domain polluted with persistence concerns
}

// ❌ Domain depends on adapter
package com.example.domain.service;

import com.example.adapter.out.persistence.UserJpaRepository;  // Wrong direction!

// ✅ Domain defines port, adapter implements
package com.example.domain.port.out;

public interface UserRepository {  // Pure interface, no JPA
    User findById(UserId id);
    void save(User user);
}
```

---

## Architecture Review Checklist

### 1. Package Structure
- [ ] Clear organization strategy (by-layer, by-feature, or hexagonal)
- [ ] Consistent naming across modules
- [ ] No `util/` or `common/` packages growing unbounded
- [ ] Feature packages are cohesive (related code together)

### 2. Dependency Direction
- [ ] Domain has ZERO framework imports (Spring, JPA, Jackson)
- [ ] Adapters depend on domain, not vice versa
- [ ] No circular dependencies between packages
- [ ] Clear dependency hierarchy

### 3. Layer Boundaries
- [ ] Controllers don't contain business logic
- [ ] Services don't know about HTTP (no HttpServletRequest)
- [ ] Repositories don't leak into controllers
- [ ] DTOs at boundaries, domain objects inside

### 4. Module Boundaries
- [ ] Each module has clear public API
- [ ] Internal classes are package-private
- [ ] Cross-module communication through interfaces
- [ ] No "reaching across" modules for internals

### 5. Scalability Indicators
- [ ] Could extract a feature to separate service? (microservice-ready)
- [ ] Are boundaries enforced or just conventional?
- [ ] Does adding a feature require touching many packages?

---

## Common Anti-Patterns

### 1. The Big Ball of Mud

```
src/main/java/com/example/
└── app/
    ├── User.java
    ├── UserController.java
    ├── UserService.java
    ├── UserRepository.java
    ├── Order.java
    ├── OrderController.java
    ├── ... (100+ files in one package)
```

**Fix**: Introduce package structure (start with by-feature)

### 2. The Util Dumping Ground

```
util/
├── StringUtils.java
├── DateUtils.java
├── ValidationUtils.java
├── SecurityUtils.java
├── EmailUtils.java      # Should be in notification module
├── OrderCalculator.java # Should be in order domain
└── UserHelper.java      # Should be in user domain
```

**Fix**: Move domain logic to appropriate modules, keep only truly generic utils

### 3. Anemic Domain Model

```java
// Domain object is just data
public class Order {
    private Long id;
    private List<OrderLine> lines;
    private BigDecimal total;
    // Only getters/setters, no behavior
}

// All logic in "service"
public class OrderService {
    public void addLine(Order order, Product product, int qty) { ... }
    public void calculateTotal(Order order) { ... }
    public void applyDiscount(Order order, Discount discount) { ... }
}
```

**Fix**: Move behavior to domain objects (rich domain model)

### 4. Framework Coupling in Domain

```java
package com.example.domain;

@Entity  // JPA
@Data    // Lombok
@JsonIgnoreProperties(ignoreUnknown = true)  // Jackson
public class User {
    @Id @GeneratedValue
    private Long id;

    @NotBlank  // Validation
    private String email;
}
```

**Fix**: Separate domain model from persistence/API models

---

## Analysis Commands

When reviewing architecture, examine:

```bash
# Package structure overview
find src/main/java -type d | head -30

# Largest packages (potential god packages)
find src/main/java -name "*.java" | xargs dirname | sort | uniq -c | sort -rn | head -10

# Check for framework imports in domain
grep -r "import org.springframework" src/main/java/*/domain/ 2>/dev/null
grep -r "import javax.persistence" src/main/java/*/domain/ 2>/dev/null

# Find circular dependencies (look for bidirectional imports)
# Check if package A imports from B and B imports from A
```

---

## Recommendations Format

When reporting findings:

```markdown
## Architecture Review: [Project Name]

### Structure Assessment
- **Organization**: Package-by-layer / Package-by-feature / Hexagonal
- **Clarity**: Clear / Mixed / Unclear

### Findings

| Severity | Issue | Location | Recommendation |
|----------|-------|----------|----------------|
| High | Domain imports Spring | `domain/model/User.java` | Extract pure domain model |
| Medium | God package | `util/` (23 classes) | Distribute to feature modules |
| Low | Inconsistent naming | `service/` vs `services/` | Standardize to `service/` |

### Dependency Analysis
[Describe dependency flow, violations found]

### Recommendations
1. [Highest priority fix]
2. [Second priority]
3. [Nice to have]
```

---

## Token Optimization

For large codebases:
1. Start with `find` to understand structure
2. Check only domain package for framework imports
3. Sample 2-3 features for pattern analysis
4. Don't read every file - look for patterns
