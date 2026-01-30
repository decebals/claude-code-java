# API Contract Review Skill

> Audit REST APIs for HTTP semantics, versioning, and consistency

## What It Does

Reviews REST API design for:
- HTTP verb correctness (GET vs POST vs PUT vs PATCH)
- API versioning strategy
- Request/response structure (DTOs vs entities)
- Status code usage (no 200 with error body)
- Backward compatibility concerns

## When to Use

- "Review this API" / "Check REST endpoints"
- Before releasing API changes
- Reviewing controller PRs
- Checking if API follows REST best practices

## Key Concepts

### Audit vs Template

| spring-boot-patterns | api-contract-review |
|---------------------|---------------------|
| How to write controllers | Review existing APIs |
| Templates and examples | Checklist and anti-patterns |
| Creating new code | Auditing existing code |

### Common Issues Caught

| Issue | Example |
|-------|---------|
| Wrong verb | POST for search instead of GET |
| No versioning | `/users` instead of `/v1/users` |
| Entity leak | JPA entity returned directly |
| 200 with error | `{"status": "error"}` with HTTP 200 |
| Breaking change | Required field added to request |

## Example Usage

```
You: Review the API in UserController

Claude: [Checks HTTP verb usage]
        [Validates versioning]
        [Looks for entity leaks]
        [Reviews error handling]
        [Identifies breaking changes]
```

## What It Checks

1. **HTTP Semantics** - Correct verb for operation
2. **URL Design** - Versioning, naming conventions
3. **Request Handling** - Validation, DTOs
4. **Response Design** - DTOs, pagination, consistency
5. **Error Handling** - Status codes, error format
6. **Compatibility** - Breaking vs non-breaking changes

## Related Skills

- `spring-boot-patterns` - Templates for writing controllers (this skill audits them)
- `security-audit` - Security aspects of APIs
- `java-code-review` - General code review (this skill is API-specific)

## References

- [REST API Design Best Practices](https://restfulapi.net/)
- [HTTP Status Codes](https://httpstatuses.com/)
- [API Versioning](https://www.baeldung.com/rest-versioning)
