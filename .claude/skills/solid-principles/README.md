# SOLID Principles

**Load**: `view .claude/skills/solid-principles/SKILL.md`

---

## Description

SOLID principles checklist with detailed Java examples. Each principle includes violation examples, refactored solutions, and detection patterns.

---

## Use Cases

- "Check this class for SOLID violations"
- "Is this class doing too much?" (SRP)
- "How do I add new types without modifying code?" (OCP)
- "Why shouldn't Square extend Rectangle?" (LSP)
- "This interface is too big" (ISP)
- "How to make this testable?" (DIP)

---

## Examples

```
> view .claude/skills/solid-principles/SKILL.md
> "Review this UserService for SOLID principles"
→ Identifies SRP violation, suggests extraction of validation and notification
```

---

## Principles Covered

| Principle | Key Question |
|-----------|--------------|
| **S**ingle Responsibility | Does it have one reason to change? |
| **O**pen/Closed | Can I extend without modifying? |
| **L**iskov Substitution | Can subtypes replace base types? |
| **I**nterface Segregation | Are clients forced to implement unused methods? |
| **D**ependency Inversion | Does it depend on abstractions? |

---

## Related Skills

- `design-patterns` - Implementation patterns
- `clean-code` - DRY, KISS, YAGNI
- `java-code-review` - Full review checklist

---

## Resources

- [SOLID (Wikipedia)](https://en.wikipedia.org/wiki/SOLID)
- [Clean Code by Robert C. Martin](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
- [SOLID Principles in Java (Baeldung)](https://www.baeldung.com/solid-principles)
