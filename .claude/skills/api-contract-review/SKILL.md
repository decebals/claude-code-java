---
name: api-contract-review
description: Review REST API contracts for HTTP semantics, versioning, backward compatibility, and response consistency. Use when user asks "review API", "check endpoints", "REST review", or before releasing API changes.
---

# API Contract Review Skill

Audit REST API design for correctness, consistency, and compatibility.

## When to Use
- User asks "review this API" / "check REST endpoints"
- Before releasing API changes
- Reviewing PR with controller changes
- Checking backward compatibility

---

## Quick Reference: Common Issues

| Issue | Symptom | Impact |
|-------|---------|--------|
| Wrong HTTP verb | POST for idempotent operation | Confusion, caching issues |
| Missing versioning | `/users` instead of `/v1/users` | Breaking changes affect all clients |
| Entity leak | JPA entity in response | Exposes internals, N+1 risk |
| 200 with error | `{"status": 200, "error": "..."}` | Breaks error handling |
| Inconsistent naming | `/getUsers` vs `/users` | Hard to learn API |

---

## HTTP Verb Semantics

### Verb Selection Guide

| Verb | Use For | Idempotent | Safe | Request Body |
|------|---------|------------|------|--------------|
| GET | Retrieve resource | Yes | Yes | No |
| POST | Create new resource | No | No | Yes |
| PUT | Replace entire resource | Yes | No | Yes |
| PATCH | Partial update | No* | No | Yes |
| DELETE | Remove resource | Yes | No | Optional |

*PATCH can be idempotent depending on implementation

### Common Mistakes

```java
// ❌ POST for retrieval
@PostMapping("/users/search")
public List<User> searchUsers(@RequestBody SearchCriteria criteria) { }

// ✅ GET with query params (or POST only if criteria is very complex)
@GetMapping("/users")
public List<User> searchUsers(
    @RequestParam String name,
    @RequestParam(required = false) String email) { }

// ❌ GET for state change
@GetMapping("/users/{id}/activate")
public void activateUser(@PathVariable Long id) { }

// ✅ POST or PATCH for state change
@PostMapping("/users/{id}/activate")
public ResponseEntity<Void> activateUser(@PathVariable Long id) { }

// ❌ POST for idempotent update
@PostMapping("/users/{id}")
public User updateUser(@PathVariable Long id, @RequestBody UserDto dto) { }

// ✅ PUT for full replacement, PATCH for partial
@PutMapping("/users/{id}")
public User replaceUser(@PathVariable Long id, @RequestBody UserDto dto) { }

@PatchMapping("/users/{id}")
public User updateUser(@PathVariable Long id, @RequestBody UserPatchDto dto) { }
```

---

## API Versioning

### Strategies

| Strategy | Example | Pros | Cons |
|----------|---------|------|------|
| URL path | `/v1/users` | Clear, easy routing | URL changes |
| Header | `Accept: application/vnd.api.v1+json` | Clean URLs | Hidden, harder to test |
| Query param | `/users?version=1` | Easy to add | Easy to forget |

### Recommended: URL Path

```java
// ✅ Versioned endpoints
@RestController
@RequestMapping("/api/v1/users")
public class UserControllerV1 { }

@RestController
@RequestMapping("/api/v2/users")
public class UserControllerV2 { }

// ❌ No versioning
@RestController
@RequestMapping("/api/users")  // Breaking changes affect everyone
public class UserController { }
```

### Version Checklist
- [ ] All public APIs have version in path
- [ ] Internal APIs documented as internal (or versioned too)
- [ ] Deprecation strategy defined for old versions

---

## Request/Response Design

### DTO vs Entity

```java
// ❌ Entity in response (leaks internals)
@GetMapping("/{id}")
public User getUser(@PathVariable Long id) {
    return userRepository.findById(id).orElseThrow();
    // Exposes: password hash, internal IDs, lazy collections
}

// ✅ DTO response
@GetMapping("/{id}")
public UserResponse getUser(@PathVariable Long id) {
    User user = userService.findById(id);
    return UserResponse.from(user);  // Only public fields
}
```

### Response Consistency

```java
// ❌ Inconsistent responses
@GetMapping("/users")
public List<User> getUsers() { }  // Returns array

@GetMapping("/users/{id}")
public User getUser(@PathVariable Long id) { }  // Returns object

@GetMapping("/users/count")
public int countUsers() { }  // Returns primitive

// ✅ Consistent wrapper (optional but recommended for large APIs)
@GetMapping("/users")
public ApiResponse<List<UserResponse>> getUsers() {
    return ApiResponse.success(userService.findAll());
}

// Or at minimum, consistent structure:
// - Collections: always wrapped or always raw (pick one)
// - Single items: always object
// - Counts/stats: always object { "count": 42 }
```

### Pagination

```java
// ❌ No pagination on collections
@GetMapping("/users")
public List<User> getAllUsers() {
    return userRepository.findAll();  // Could be millions
}

// ✅ Paginated
@GetMapping("/users")
public Page<UserResponse> getUsers(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "20") int size) {
    return userService.findAll(PageRequest.of(page, size));
}
```

---

## HTTP Status Codes

### Success Codes

| Code | When to Use | Response Body |
|------|-------------|---------------|
| 200 OK | Successful GET, PUT, PATCH | Resource or result |
| 201 Created | Successful POST (created) | Created resource + Location header |
| 204 No Content | Successful DELETE, or PUT with no body | Empty |

### Error Codes

| Code | When to Use | Common Mistake |
|------|-------------|----------------|
| 400 Bad Request | Invalid input, validation failed | Using for "not found" |
| 401 Unauthorized | Not authenticated | Confusing with 403 |
| 403 Forbidden | Authenticated but not allowed | Using 401 instead |
| 404 Not Found | Resource doesn't exist | Using 400 |
| 409 Conflict | Duplicate, concurrent modification | Using 400 |
| 422 Unprocessable | Semantic error (valid syntax, invalid meaning) | Using 400 |
| 500 Internal Error | Unexpected server error | Exposing stack traces |

### Anti-Pattern: 200 with Error Body

```java
// ❌ NEVER DO THIS
@GetMapping("/{id}")
public ResponseEntity<Map<String, Object>> getUser(@PathVariable Long id) {
    try {
        User user = userService.findById(id);
        return ResponseEntity.ok(Map.of("status", "success", "data", user));
    } catch (NotFoundException e) {
        return ResponseEntity.ok(Map.of(  // Still 200!
            "status", "error",
            "message", "User not found"
        ));
    }
}

// ✅ Use proper status codes
@GetMapping("/{id}")
public ResponseEntity<UserResponse> getUser(@PathVariable Long id) {
    return userService.findById(id)
        .map(ResponseEntity::ok)
        .orElse(ResponseEntity.notFound().build());
}
```

---

## Error Response Format

### Consistent Error Structure

```java
// ✅ Standard error response
public class ErrorResponse {
    private String code;        // Machine-readable: "USER_NOT_FOUND"
    private String message;     // Human-readable: "User with ID 123 not found"
    private Instant timestamp;
    private String path;
    private List<FieldError> errors;  // For validation errors
}

// In GlobalExceptionHandler
@ExceptionHandler(ResourceNotFoundException.class)
public ResponseEntity<ErrorResponse> handleNotFound(
        ResourceNotFoundException ex, HttpServletRequest request) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND)
        .body(ErrorResponse.builder()
            .code("RESOURCE_NOT_FOUND")
            .message(ex.getMessage())
            .timestamp(Instant.now())
            .path(request.getRequestURI())
            .build());
}
```

### Security: Don't Expose Internals

```java
// ❌ Exposes stack trace
@ExceptionHandler(Exception.class)
public ResponseEntity<String> handleAll(Exception ex) {
    return ResponseEntity.status(500)
        .body(ex.getStackTrace().toString());  // Security risk!
}

// ✅ Generic message, log details server-side
@ExceptionHandler(Exception.class)
public ResponseEntity<ErrorResponse> handleAll(Exception ex) {
    log.error("Unexpected error", ex);  // Full details in logs
    return ResponseEntity.status(500)
        .body(ErrorResponse.of("INTERNAL_ERROR", "An unexpected error occurred"));
}
```

---

## Backward Compatibility

### Breaking Changes (Avoid in Same Version)

| Change | Breaking? | Migration |
|--------|-----------|-----------|
| Remove endpoint | Yes | Deprecate first, remove in next version |
| Remove field from response | Yes | Keep field, return null/default |
| Add required field to request | Yes | Make optional with default |
| Change field type | Yes | Add new field, deprecate old |
| Rename field | Yes | Support both temporarily |
| Change URL path | Yes | Redirect old to new |

### Non-Breaking Changes (Safe)

- Add optional field to request
- Add field to response
- Add new endpoint
- Add new optional query parameter

### Deprecation Pattern

```java
@RestController
@RequestMapping("/api/v1/users")
public class UserControllerV1 {

    @Deprecated
    @GetMapping("/by-email")  // Old endpoint
    public UserResponse getByEmailOld(@RequestParam String email) {
        return getByEmail(email);  // Delegate to new
    }

    @GetMapping(params = "email")  // New pattern
    public UserResponse getByEmail(@RequestParam String email) {
        return userService.findByEmail(email);
    }
}
```

---

## API Review Checklist

### 1. HTTP Semantics
- [ ] GET for retrieval only (no side effects)
- [ ] POST for creation (returns 201 + Location)
- [ ] PUT for full replacement (idempotent)
- [ ] PATCH for partial updates
- [ ] DELETE for removal (idempotent)

### 2. URL Design
- [ ] Versioned (`/v1/`, `/v2/`)
- [ ] Nouns, not verbs (`/users`, not `/getUsers`)
- [ ] Plural for collections (`/users`, not `/user`)
- [ ] Hierarchical for relationships (`/users/{id}/orders`)
- [ ] Consistent naming (kebab-case or camelCase, pick one)

### 3. Request Handling
- [ ] Validation with `@Valid`
- [ ] Clear error messages for validation failures
- [ ] Request DTOs (not entities)
- [ ] Reasonable size limits

### 4. Response Design
- [ ] Response DTOs (not entities)
- [ ] Consistent structure across endpoints
- [ ] Pagination for collections
- [ ] Proper status codes (not 200 for errors)

### 5. Error Handling
- [ ] Consistent error format
- [ ] Machine-readable error codes
- [ ] Human-readable messages
- [ ] No stack traces exposed
- [ ] Proper 4xx vs 5xx distinction

### 6. Compatibility
- [ ] No breaking changes in current version
- [ ] Deprecated endpoints documented
- [ ] Migration path for breaking changes

---

## Token Optimization

For large APIs:
1. List all controllers: `find . -name "*Controller.java"`
2. Sample 2-3 controllers for pattern analysis
3. Check `@ExceptionHandler` configuration once
4. Grep for specific anti-patterns:
   ```bash
   # Find potential entity leaks
   grep -r "public.*Entity.*@GetMapping" --include="*.java"

   # Find 200 with error patterns
   grep -r "ResponseEntity.ok.*error" --include="*.java"

   # Find unversioned APIs
   grep -r "@RequestMapping.*api" --include="*.java" | grep -v "/v[0-9]"
   ```
