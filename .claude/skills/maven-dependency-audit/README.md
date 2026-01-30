# Maven Dependency Audit

**Load**: `view .claude/skills/maven-dependency-audit/SKILL.md`

---

## Description

Audit Maven dependencies for outdated versions, security vulnerabilities, and conflicts. Uses standard Maven plugins - no additional tooling required.

---

## Use Cases

- "Check for outdated dependencies"
- "Audit dependencies before release"
- "Find security vulnerabilities in pom.xml"
- "Why is commons-logging in my project?"

---

## Examples

```
> view .claude/skills/maven-dependency-audit/SKILL.md
> "Audit dependencies for pf4j"
→ Runs checks, categorizes updates by severity, generates report
```

---

## Tools Used

| Tool | Purpose |
|------|---------|
| `mvn versions:display-dependency-updates` | Find outdated dependencies |
| `mvn dependency:tree` | Analyze dependency graph |
| `mvn dependency:analyze` | Find unused dependencies |
| `mvn dependency-check:check` | Security vulnerability scan (OWASP) |

---

## Notes / Tips

- Run monthly or before each release
- Patch updates are usually safe; major updates need review
- Use `-Dincludes=groupId` to filter large dependency trees
- Consider enabling GitHub Dependabot for automated alerts
