# Spring Boot Patterns

**Load**: `view .claude/skills/spring-boot-patterns/SKILL.md`

---

## Description

Best practices and patterns for Spring Boot applications. Covers project structure, layered architecture, DTOs, exception handling, configuration, and testing.

---

## Use Cases

- "Create a REST controller for products"
- "Add service layer for user management"
- "Setup global exception handling"
- "How should I structure this Spring Boot project?"

---

## Examples

```
> view .claude/skills/spring-boot-patterns/SKILL.md
> "Create UserController with CRUD endpoints"
→ Generates controller following REST conventions with proper status codes
```

---

## Patterns Covered

| Layer | Topics |
|-------|--------|
| Controller | REST conventions, validation, status codes |
| Service | Interface + Impl, transactions, mappers |
| Repository | JPA queries, derived methods, optimization |
| DTO | Request/Response records, MapStruct |
| Exception | Custom exceptions, global handler |
| Config | Properties, profiles, validation |
| Testing | MockMvc, Mockito, Testcontainers |

---

## Notes / Tips

- Use constructor injection (Lombok `@RequiredArgsConstructor`)
- Default `@Transactional(readOnly = true)` at service class level
- Never expose entities directly - use DTOs
- Prefer records for DTOs (Java 17+)
