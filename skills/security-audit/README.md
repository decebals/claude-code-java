# Security Audit

**Load**: `view .claude/skills/security-audit/SKILL.md`

---

## Description

Java security checklist based on OWASP Top 10 and secure coding practices. Framework-agnostic core with specific sections for Spring, Quarkus, and Jakarta EE.

---

## Use Cases

- "Review this code for security issues"
- "Check for SQL injection vulnerabilities"
- "Is this authentication secure?"
- "Security audit before release"
- "OWASP compliance check"

---

## Topics Covered

| Topic | Applies To |
|-------|------------|
| **Input Validation** | All Java (Bean Validation JSR 380) |
| **SQL Injection** | JPA, Hibernate, JDBC |
| **XSS Prevention** | Web applications |
| **CSRF Protection** | Spring, Quarkus |
| **Authentication** | All frameworks |
| **Secrets Management** | All applications |
| **Secure Deserialization** | All Java |
| **Dependency Security** | Maven, Gradle |
| **Security Headers** | Web applications |

---

## OWASP Top 10 Coverage

| Risk | Covered |
|------|---------|
| A01 Broken Access Control | ✅ |
| A02 Cryptographic Failures | ✅ |
| A03 Injection | ✅ |
| A04 Insecure Design | ✅ |
| A05 Security Misconfiguration | ✅ |
| A06 Vulnerable Components | ✅ |
| A07 Authentication Failures | ✅ |
| A08 Data Integrity Failures | ✅ |
| A09 Logging Failures | ✅ |
| A10 SSRF | ✅ |

---

## Related Skills

- `java-code-review` - General review
- `maven-dependency-audit` - Dependency scanning
- `logging-patterns` - Secure logging

---

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Java Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Java_Security_Cheat_Sheet.html)
- [Spring Boot Security Best Practices (Snyk)](https://snyk.io/blog/spring-boot-security-best-practices/)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)
