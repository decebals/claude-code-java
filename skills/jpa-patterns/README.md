# JPA Patterns

**Load**: `view .claude/skills/jpa-patterns/SKILL.md`

---

## Description

JPA/Hibernate patterns and common pitfalls for Spring applications. Covers N+1 problem, lazy loading, transactions, entity relationships, and query optimization.

---

## Use Cases

- "Too many SQL queries executing"
- "LazyInitializationException error"
- "N+1 problem in my code"
- "How to optimize JPA queries?"
- "EAGER vs LAZY fetch type"
- "Entity relationship best practices"

---

## Examples

```
> view .claude/skills/jpa-patterns/SKILL.md
> "I see 100 queries when loading 10 orders"
→ Identifies N+1 problem, suggests JOIN FETCH or @EntityGraph
```

---

## Topics Covered

| Topic | Key Points |
|-------|------------|
| **N+1 Problem** | JOIN FETCH, @EntityGraph, @BatchSize |
| **Lazy Loading** | FetchType.LAZY, LazyInitializationException solutions |
| **Transactions** | @Transactional, propagation, read-only |
| **Relationships** | OneToMany, ManyToMany, bidirectional sync |
| **Optimization** | Pagination, DTO projections, bulk operations |
| **Locking** | @Version, OptimisticLockException |

---

## Common Mistakes Addressed

- CascadeType.ALL on @ManyToOne
- Missing database indexes
- toString() triggering lazy loads
- Calling @Transactional from same class

---

## Related Skills

- `spring-boot-patterns` - Spring Boot patterns
- `java-code-review` - Code review checklist

---

## Resources

- [Hibernate ORM Documentation](https://hibernate.org/orm/documentation/)
- [Spring Data JPA Reference](https://docs.spring.io/spring-data/jpa/docs/current/reference/html/)
- [Vlad Mihalcea's Blog](https://vladmihalcea.com/) - JPA/Hibernate deep dives
- [High-Performance Java Persistence](https://vladmihalcea.com/books/high-performance-java-persistence/)
