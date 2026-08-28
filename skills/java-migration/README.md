# Java Migration

**Load**: `view .claude/skills/java-migration/SKILL.md`

---

## Description

Step-by-step guide for upgrading Java projects between major LTS versions (8→11→17→21→25). Includes breaking changes, removed APIs, new features to adopt, and framework-specific migrations (Spring Boot, Hibernate).

---

## Use Cases

- "Upgrade project to Java 25"
- "Migrate from Java 21 to 25"
- "Spring Boot 3 migration"
- "What breaks when upgrading to Java 25?"
- "Fix javax.xml.bind not found"

---

## Examples

```
> view .claude/skills/java-migration/SKILL.md
> "Upgrade this project from Java 11 to 21"
→ Analyzes code, identifies breaking changes, provides step-by-step fixes
```

---

## Migration Paths Covered

| From | To | Key Changes |
|------|-----|-------------|
| Java 8 | Java 11 | JAXB removed, module system, internal APIs |
| Java 11 | Java 17 | Records, sealed classes, strong encapsulation |
| Java 17 | Java 21 | Virtual threads, pattern matching, sequenced collections |
| Java 21 | Java 25 | Security Manager removed, Unsafe removed, Scoped Values final |
| Spring Boot 2.x | 3.x | javax.* → jakarta.*, Java 17 required |
| Hibernate 5 | 6 | Query API changes, ID generation |

---

## Tools Used

| Tool | Purpose |
|------|---------|
| `grep` | Find deprecated API usage |
| `mvn compile` | Identify compilation errors |
| OpenRewrite | Automated Spring Boot 3 migration |
| `--add-opens` | Fix reflection access issues |

---

## Notes / Tips

- Always migrate LTS → LTS (8→11→17→21→25)
- Update Lombok, Mockito to latest versions first
- Use OpenRewrite for automated migrations
- Test thoroughly after each step
- Java 25 LTS support until September 2033

## References

- [Oracle JDK 25 Migration Guide](https://docs.oracle.com/en/java/javase/25/migrate/)
- [Oracle JDK 25 Release Notes](https://www.oracle.com/java/technologies/javase/25-relnote-issues.html)
- [OpenRewrite Java Migration Recipes](https://docs.openrewrite.org/recipes/java/migrate)
- [Spring Boot 3.0 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide)
