---
name: security-audit
description: Java security checklist covering OWASP Top 10, input validation, injection prevention, and secure coding. Works with Spring, Quarkus, Jakarta EE, and plain Java. Use when reviewing code security, before releases, or when user asks about vulnerabilities.
---

# Security Audit Skill

Security checklist for Java applications based on OWASP Top 10 and secure coding practices.

## When to Use
- Security code review
- Before production releases
- User asks about "security", "vulnerability", "OWASP"
- Reviewing authentication/authorization code
- Checking for injection vulnerabilities

---

## OWASP Top 10 Quick Reference

| # | Risk | Java Mitigation |
|---|------|-----------------|
| A01 | Broken Access Control | Role-based checks, deny by default |
| A02 | Cryptographic Failures | Use strong algorithms, no hardcoded secrets |
| A03 | Injection | Parameterized queries, input validation |
| A04 | Insecure Design | Threat modeling, secure defaults |
| A05 | Security Misconfiguration | Disable debug, secure headers |
| A06 | Vulnerable Components | Dependency scanning, updates |
| A07 | Authentication Failures | Strong passwords, MFA, session management |
| A08 | Data Integrity Failures | Verify signatures, secure deserialization |
| A09 | Logging Failures | Log security events, no sensitive data |
| A10 | SSRF | Validate URLs, allowlist domains |

---

## Input Validation (All Frameworks)

### Bean Validation (JSR 380)

Works in Spring, Quarkus, Jakarta EE, and standalone.

```java
// ✅ GOOD: Validate at boundary
public class CreateUserRequest {

    @NotNull(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be 3-50 characters")
    @Pattern(regexp = "^[a-zA-Z0-9_]+$", message = "Username can only contain letters, numbers, underscore")
    private String username;

    @NotNull
    @Email(message = "Invalid email format")
    private String email;

    @NotNull
    @Size(min = 8, max = 100)
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).*$",
             message = "Password must contain uppercase, lowercase, and number")
    private String password;

    @Min(value = 0, message = "Age cannot be negative")
    @Max(value = 150, message = "Invalid age")
    private Integer age;
}

// Controller/Resource - trigger validation
public Response createUser(@Valid CreateUserRequest request) {
    // request is already validated
}
```

### Custom Validators

```java
// Custom annotation
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = SafeHtmlValidator.class)
public @interface SafeHtml {
    String message() default "Contains unsafe HTML";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}

// Validator implementation
public class SafeHtmlValidator implements ConstraintValidator<SafeHtml, String> {

    private static final Pattern DANGEROUS_PATTERN = Pattern.compile(
        "<script|javascript:|on\\w+\\s*=", Pattern.CASE_INSENSITIVE
    );

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null) return true;
        return !DANGEROUS_PATTERN.matcher(value).find();
    }
}
```

### Allowlist vs Blocklist

```java
// ❌ BAD: Blocklist (attackers find bypasses)
if (input.contains("<script>")) {
    throw new ValidationException("Invalid input");
}

// ✅ GOOD: Allowlist (only permit known-good)
private static final Pattern SAFE_NAME = Pattern.compile("^[a-zA-Z\\s'-]{1,100}$");

if (!SAFE_NAME.matcher(input).matches()) {
    throw new ValidationException("Invalid name format");
}
```

---

## SQL Injection Prevention

### JPA/Hibernate (All Frameworks)

```java
// ✅ GOOD: Parameterized queries
@Query("SELECT u FROM User u WHERE u.email = :email")
Optional<User> findByEmail(@Param("email") String email);

// ✅ GOOD: Criteria API
CriteriaBuilder cb = entityManager.getCriteriaBuilder();
CriteriaQuery<User> query = cb.createQuery(User.class);
Root<User> user = query.from(User.class);
query.where(cb.equal(user.get("email"), email));  // Safe

// ✅ GOOD: Named parameters
TypedQuery<User> query = entityManager.createQuery(
    "SELECT u FROM User u WHERE u.status = :status", User.class);
query.setParameter("status", status);  // Safe

// ❌ BAD: String concatenation
String jpql = "SELECT u FROM User u WHERE u.email = '" + email + "'";  // VULNERABLE!
```

### Native Queries

```java
// ✅ GOOD: Parameterized native query
@Query(value = "SELECT * FROM users WHERE email = ?1", nativeQuery = true)
User findByEmailNative(String email);

// ❌ BAD: Concatenated native query
String sql = "SELECT * FROM users WHERE email = '" + email + "'";  // VULNERABLE!
```

### JDBC (Plain Java)

```java
// ✅ GOOD: PreparedStatement
String sql = "SELECT * FROM users WHERE email = ? AND status = ?";
try (PreparedStatement stmt = connection.prepareStatement(sql)) {
    stmt.setString(1, email);
    stmt.setString(2, status);
    ResultSet rs = stmt.executeQuery();
}

// ❌ BAD: Statement with concatenation
String sql = "SELECT * FROM users WHERE email = '" + email + "'";  // VULNERABLE!
Statement stmt = connection.createStatement();
stmt.executeQuery(sql);
```

---

## XSS Prevention

### Output Encoding

```java
// ✅ GOOD: Use templating engine's auto-escaping

// Thymeleaf - auto-escapes by default
<p th:text="${userInput}">...</p>  // Safe

// To display HTML (dangerous, use carefully):
<p th:utext="${trustedHtml}">...</p>  // Only for trusted content!

// ✅ GOOD: Manual encoding when needed
import org.owasp.encoder.Encode;

String safe = Encode.forHtml(userInput);
String safeJs = Encode.forJavaScript(userInput);
String safeUrl = Encode.forUriComponent(userInput);
```

**Maven dependency for OWASP Encoder:**
```xml
<dependency>
    <groupId>org.owasp.encoder</groupId>
    <artifactId>encoder</artifactId>
    <version>1.2.3</version>
</dependency>
```

### Content Security Policy

```java
// Add CSP header to prevent inline scripts

// Spring Boot
@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.headers(headers -> headers
            .contentSecurityPolicy(csp -> csp
                .policyDirectives("default-src 'self'; script-src 'self'; style-src 'self'")
            )
        );
        return http.build();
    }
}

// Servlet Filter (works everywhere)
@WebFilter("/*")
public class SecurityHeadersFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletResponse response = (HttpServletResponse) res;
        response.setHeader("Content-Security-Policy", "default-src 'self'");
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("X-Frame-Options", "DENY");
        response.setHeader("X-XSS-Protection", "1; mode=block");
        chain.doFilter(req, res);
    }
}
```

---

## CSRF Protection

### Spring Security

```java
// CSRF enabled by default for browser clients
@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // For REST APIs with JWT (stateless) - can disable CSRF
            .csrf(csrf -> csrf.disable())

            // For browser apps with sessions - keep CSRF enabled
            .csrf(csrf -> csrf
                .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
            );
        return http.build();
    }
}
```

### Quarkus

```properties
# application.properties
quarkus.http.csrf.enabled=true
quarkus.http.csrf.cookie-name=XSRF-TOKEN
```

---

## Authentication & Authorization

### Password Storage

```java
// ✅ GOOD: Use BCrypt or Argon2
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.argon2.Argon2PasswordEncoder;

// BCrypt (widely supported)
PasswordEncoder encoder = new BCryptPasswordEncoder(12);  // strength 12
String hash = encoder.encode(rawPassword);
boolean matches = encoder.matches(rawPassword, hash);

// Argon2 (recommended for new projects)
PasswordEncoder encoder = Argon2PasswordEncoder.defaultsForSpringSecurity_v5_8();
String hash = encoder.encode(rawPassword);

// ❌ BAD: MD5, SHA1, SHA256 without salt
String hash = DigestUtils.md5Hex(password);  // NEVER for passwords!
```

### Authorization Checks

```java
// ✅ GOOD: Check authorization at service layer
@Service
public class DocumentService {

    public Document getDocument(Long documentId, User currentUser) {
        Document doc = documentRepository.findById(documentId)
            .orElseThrow(() -> new NotFoundException("Document not found"));

        // Authorization check
        if (!doc.getOwnerId().equals(currentUser.getId()) &&
            !currentUser.hasRole("ADMIN")) {
            throw new AccessDeniedException("Not authorized to access this document");
        }

        return doc;
    }
}

// ❌ BAD: Only check at controller level, trust user input
@GetMapping("/documents/{id}")
public Document getDocument(@PathVariable Long id) {
    return documentRepository.findById(id).orElseThrow();  // No auth check!
}
```

### Spring Security Annotations

```java
@PreAuthorize("hasRole('ADMIN')")
public void adminOnly() { }

@PreAuthorize("hasRole('USER') and #userId == authentication.principal.id")
public void ownDataOnly(Long userId) { }

@PreAuthorize("@authService.canAccess(#documentId, authentication)")
public Document getDocument(Long documentId) { }
```

---

## Secrets Management

### Never Hardcode Secrets

```java
// ❌ BAD: Hardcoded secrets
private static final String API_KEY = "sk-1234567890abcdef";
private static final String DB_PASSWORD = "admin123";

// ✅ GOOD: Environment variables
String apiKey = System.getenv("API_KEY");

// ✅ GOOD: External configuration
@Value("${api.key}")
private String apiKey;

// ✅ GOOD: Secrets manager
@Autowired
private SecretsManager secretsManager;
String apiKey = secretsManager.getSecret("api-key");
```

### Configuration Files

```yaml
# ✅ GOOD: Reference environment variables
spring:
  datasource:
    password: ${DB_PASSWORD}

api:
  key: ${API_KEY}

# ❌ BAD: Hardcoded in application.yml
spring:
  datasource:
    password: admin123  # NEVER!
```

### .gitignore

```gitignore
# Never commit these
.env
*.pem
*.key
*credentials*
*secret*
application-local.yml
```

---

## Secure Deserialization

### Avoid Java Serialization

```java
// ❌ DANGEROUS: Java ObjectInputStream
ObjectInputStream ois = new ObjectInputStream(untrustedInput);
Object obj = ois.readObject();  // Remote Code Execution risk!

// ✅ GOOD: Use JSON with Jackson
ObjectMapper mapper = new ObjectMapper();
// Disable dangerous features
mapper.disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
mapper.activateDefaultTyping(
    LaissezFaireSubTypeValidator.instance,
    ObjectMapper.DefaultTyping.NON_FINAL
);  // Be careful with polymorphic types!

User user = mapper.readValue(json, User.class);
```

### Jackson Security

```java
// ✅ Configure Jackson safely
@Configuration
public class JacksonConfig {

    @Bean
    public ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();

        // Prevent unknown properties exploitation
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

        // Don't allow class type in JSON (prevents gadget attacks)
        mapper.deactivateDefaultTyping();

        return mapper;
    }
}
```

---

## Dependency Security

### OWASP Dependency Check

**Maven:**
```xml
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>9.0.7</version>
    <executions>
        <execution>
            <goals>
                <goal>check</goal>
            </goals>
        </execution>
    </executions>
    <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>  <!-- Fail on high severity -->
    </configuration>
</plugin>
```

**Run:**
```bash
mvn dependency-check:check
# Report: target/dependency-check-report.html
```

### Keep Dependencies Updated

```bash
# Check for updates
mvn versions:display-dependency-updates

# Update to latest
mvn versions:use-latest-releases
```

---

## Security Headers

### Recommended Headers

| Header | Value | Purpose |
|--------|-------|---------|
| `Content-Security-Policy` | `default-src 'self'` | Prevent XSS |
| `X-Content-Type-Options` | `nosniff` | Prevent MIME sniffing |
| `X-Frame-Options` | `DENY` | Prevent clickjacking |
| `Strict-Transport-Security` | `max-age=31536000` | Force HTTPS |
| `X-XSS-Protection` | `1; mode=block` | Legacy XSS filter |

### Spring Boot Configuration

```java
@Bean
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http.headers(headers -> headers
        .contentSecurityPolicy(csp -> csp.policyDirectives("default-src 'self'"))
        .frameOptions(frame -> frame.deny())
        .httpStrictTransportSecurity(hsts -> hsts.maxAgeInSeconds(31536000))
        .contentTypeOptions(Customizer.withDefaults())
    );
    return http.build();
}
```

---

## Logging Security Events

```java
// ✅ Log security-relevant events
log.info("User login successful", kv("userId", userId), kv("ip", clientIp));
log.warn("Failed login attempt", kv("username", username), kv("ip", clientIp), kv("attempt", attemptCount));
log.warn("Access denied", kv("userId", userId), kv("resource", resourceId), kv("action", action));
log.error("Authentication failure", kv("reason", reason), kv("ip", clientIp));

// ❌ NEVER log sensitive data
log.info("Login: user={}, password={}", username, password);  // NEVER!
log.debug("Request body: {}", requestWithCreditCard);  // NEVER!
```

---

## Security Checklist

### Code Review

- [ ] Input validated with allowlist patterns
- [ ] SQL queries use parameters (no concatenation)
- [ ] Output encoded for context (HTML, JS, URL)
- [ ] Authorization checked at service layer
- [ ] No hardcoded secrets
- [ ] Passwords hashed with BCrypt/Argon2
- [ ] Sensitive data not logged
- [ ] CSRF protection enabled (for browser apps)

### Configuration

- [ ] HTTPS enforced
- [ ] Security headers configured
- [ ] Debug/dev features disabled in production
- [ ] Default credentials changed
- [ ] Error messages don't leak internal details

### Dependencies

- [ ] No known vulnerabilities (OWASP check)
- [ ] Dependencies up to date
- [ ] Unnecessary dependencies removed

---

## Related Skills

- `java-code-review` - General code review
- `maven-dependency-audit` - Dependency vulnerability scanning
- `logging-patterns` - Secure logging practices
