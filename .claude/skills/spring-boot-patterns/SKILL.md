---
name: spring-boot-patterns
description: Spring Boot best practices and patterns. Use when creating controllers, services, repositories, or when user asks about Spring Boot architecture, REST APIs, exception handling, or JPA patterns.
---

# Spring Boot Patterns Skill

Best practices and patterns for Spring Boot applications.

## When to Use
- User says "create controller" / "add service" / "Spring Boot help"
- Reviewing Spring Boot code
- Setting up new Spring Boot project structure

## Project Structure

```
src/main/java/com/example/myapp/
├── MyAppApplication.java          # @SpringBootApplication
├── config/                        # Configuration classes
│   ├── SecurityConfig.java
│   └── WebConfig.java
├── controller/                    # REST controllers
│   └── UserController.java
├── service/                       # Business logic
│   ├── UserService.java
│   └── impl/
│       └── UserServiceImpl.java
├── repository/                    # Data access
│   └── UserRepository.java
├── model/                         # Entities
│   └── User.java
├── dto/                           # Data transfer objects
│   ├── request/
│   │   └── CreateUserRequest.java
│   └── response/
│       └── UserResponse.java
├── exception/                     # Custom exceptions
│   ├── ResourceNotFoundException.java
│   └── GlobalExceptionHandler.java
└── util/                          # Utilities
    └── DateUtils.java
```

---

## Controller Patterns

### REST Controller Template
```java
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor  // Lombok for constructor injection
public class UserController {

    private final UserService userService;

    @GetMapping
    public ResponseEntity<List<UserResponse>> getAll() {
        return ResponseEntity.ok(userService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.findById(id));
    }

    @PostMapping
    public ResponseEntity<UserResponse> create(
            @Valid @RequestBody CreateUserRequest request) {
        UserResponse created = userService.create(request);
        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
            .path("/{id}")
            .buildAndExpand(created.getId())
            .toUri();
        return ResponseEntity.created(location).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserResponse> update(
            @PathVariable Long id,
            @Valid @RequestBody UpdateUserRequest request) {
        return ResponseEntity.ok(userService.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        userService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
```

### Controller Best Practices

| Practice | Example |
|----------|---------|
| Versioned API | `/api/v1/users` |
| Plural nouns | `/users` not `/user` |
| HTTP methods | GET=read, POST=create, PUT=update, DELETE=delete |
| Status codes | 200=OK, 201=Created, 204=NoContent, 404=NotFound |
| Validation | `@Valid` on request body |

### ❌ Anti-patterns
```java
// ❌ Business logic in controller
@PostMapping
public User create(@RequestBody User user) {
    user.setCreatedAt(LocalDateTime.now());  // Logic belongs in service
    return userRepository.save(user);         // Direct repo access
}

// ❌ Returning entity directly (exposes internals)
@GetMapping("/{id}")
public User getById(@PathVariable Long id) {
    return userRepository.findById(id).get();
}
```

---

## Service Patterns

### Service Interface + Implementation
```java
// Interface
public interface UserService {
    List<UserResponse> findAll();
    UserResponse findById(Long id);
    UserResponse create(CreateUserRequest request);
    UserResponse update(Long id, UpdateUserRequest request);
    void delete(Long id);
}

// Implementation
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)  // Default read-only
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;

    @Override
    public List<UserResponse> findAll() {
        return userRepository.findAll().stream()
            .map(userMapper::toResponse)
            .toList();
    }

    @Override
    public UserResponse findById(Long id) {
        return userRepository.findById(id)
            .map(userMapper::toResponse)
            .orElseThrow(() -> new ResourceNotFoundException("User", id));
    }

    @Override
    @Transactional  // Write transaction
    public UserResponse create(CreateUserRequest request) {
        User user = userMapper.toEntity(request);
        User saved = userRepository.save(user);
        return userMapper.toResponse(saved);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        if (!userRepository.existsById(id)) {
            throw new ResourceNotFoundException("User", id);
        }
        userRepository.deleteById(id);
    }
}
```

### Service Best Practices

- Interface + Impl for testability
- `@Transactional(readOnly = true)` at class level
- `@Transactional` for write methods
- Throw domain exceptions, not generic ones
- Use mappers (MapStruct) for entity ↔ DTO conversion

---

## Repository Patterns

### JPA Repository
```java
public interface UserRepository extends JpaRepository<User, Long> {

    // Derived query
    Optional<User> findByEmail(String email);

    List<User> findByActiveTrue();

    // Custom query
    @Query("SELECT u FROM User u WHERE u.department.id = :deptId")
    List<User> findByDepartmentId(@Param("deptId") Long departmentId);

    // Native query (use sparingly)
    @Query(value = "SELECT * FROM users WHERE created_at > :date",
           nativeQuery = true)
    List<User> findRecentUsers(@Param("date") LocalDate date);

    // Exists check (more efficient than findBy)
    boolean existsByEmail(String email);

    // Count
    long countByActiveTrue();
}
```

### Repository Best Practices

- Use derived queries when possible
- `Optional` for single results
- `existsBy` instead of `findBy` for existence checks
- Avoid native queries unless necessary
- Use `@EntityGraph` for fetch optimization

---

## DTO Patterns

### Request/Response DTOs
```java
// Request DTO with validation
public record CreateUserRequest(
    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100)
    String name,

    @NotBlank
    @Email(message = "Invalid email format")
    String email,

    @NotNull
    @Min(18)
    Integer age
) {}

// Response DTO
public record UserResponse(
    Long id,
    String name,
    String email,
    LocalDateTime createdAt
) {}
```

### MapStruct Mapper
```java
@Mapper(componentModel = "spring")
public interface UserMapper {

    UserResponse toResponse(User entity);

    List<UserResponse> toResponseList(List<User> entities);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    User toEntity(CreateUserRequest request);
}
```

---

## Exception Handling

### Custom Exceptions
```java
public class ResourceNotFoundException extends RuntimeException {

    public ResourceNotFoundException(String resource, Long id) {
        super(String.format("%s not found with id: %d", resource, id));
    }
}

public class BusinessException extends RuntimeException {

    private final String code;

    public BusinessException(String code, String message) {
        super(message);
        this.code = code;
    }
}
```

### Global Exception Handler
```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
        log.warn("Resource not found: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse("NOT_FOUND", ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(
            MethodArgumentNotValidException ex) {
        List<String> errors = ex.getBindingResult().getFieldErrors().stream()
            .map(e -> e.getField() + ": " + e.getDefaultMessage())
            .toList();
        return ResponseEntity.badRequest()
            .body(new ErrorResponse("VALIDATION_ERROR", errors.toString()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneric(Exception ex) {
        log.error("Unexpected error", ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(new ErrorResponse("INTERNAL_ERROR", "An unexpected error occurred"));
    }
}

public record ErrorResponse(String code, String message) {}
```

---

## Configuration Patterns

### Application Properties
```yaml
# application.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: ${DB_USER}
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate  # Never 'create' in production!
    show-sql: false

app:
  jwt:
    secret: ${JWT_SECRET}
    expiration: 86400000
```

### Configuration Properties Class
```java
@Configuration
@ConfigurationProperties(prefix = "app.jwt")
@Validated
public class JwtProperties {

    @NotBlank
    private String secret;

    @Min(60000)
    private long expiration;

    // getters and setters
}
```

### Profile-Specific Configuration
```
src/main/resources/
├── application.yml           # Common config
├── application-dev.yml       # Development
├── application-test.yml      # Testing
└── application-prod.yml      # Production
```

---

## Common Annotations Quick Reference

| Annotation | Purpose |
|------------|---------|
| `@RestController` | REST controller (combines @Controller + @ResponseBody) |
| `@Service` | Business logic component |
| `@Repository` | Data access component |
| `@Configuration` | Configuration class |
| `@RequiredArgsConstructor` | Lombok: constructor injection |
| `@Transactional` | Transaction management |
| `@Valid` | Trigger validation |
| `@ConfigurationProperties` | Bind properties to class |
| `@Profile("dev")` | Profile-specific bean |
| `@Scheduled` | Scheduled tasks |

---

## Testing Patterns

### Controller Test (MockMvc)
```java
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Test
    void shouldReturnUser() throws Exception {
        when(userService.findById(1L))
            .thenReturn(new UserResponse(1L, "John", "john@example.com", null));

        mockMvc.perform(get("/api/v1/users/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("John"));
    }
}
```

### Service Test
```java
@ExtendWith(MockitoExtension.class)
class UserServiceImplTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private UserMapper userMapper;

    @InjectMocks
    private UserServiceImpl userService;

    @Test
    void shouldThrowWhenUserNotFound() {
        when(userRepository.findById(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.findById(1L))
            .isInstanceOf(ResourceNotFoundException.class);
    }
}
```

### Integration Test
```java
@SpringBootTest
@AutoConfigureMockMvc
@Testcontainers
class UserIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");

    @Autowired
    private MockMvc mockMvc;

    @Test
    void shouldCreateUser() throws Exception {
        mockMvc.perform(post("/api/v1/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {"name": "John", "email": "john@example.com", "age": 25}
                    """))
            .andExpect(status().isCreated());
    }
}
```

---

## Quick Reference Card

| Layer | Responsibility | Annotations |
|-------|---------------|-------------|
| Controller | HTTP handling, validation | `@RestController`, `@Valid` |
| Service | Business logic, transactions | `@Service`, `@Transactional` |
| Repository | Data access | `@Repository`, extends `JpaRepository` |
| DTO | Data transfer | Records with validation annotations |
| Config | Configuration | `@Configuration`, `@ConfigurationProperties` |
| Exception | Error handling | `@RestControllerAdvice` |
