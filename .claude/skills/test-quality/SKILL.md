---
name: test-quality
description: Write high-quality JUnit 5 tests with AssertJ assertions. Use when user says "add tests", "write tests", "improve test coverage", or when reviewing/creating test classes for Java code.
---

# Test Quality Skill (JUnit 5 + AssertJ)

Write high-quality, maintainable tests for Java projects using modern best practices.

## When to Use
- Writing new test classes
- Reviewing/improving existing tests
- User asks to "add tests" / "improve test coverage"
- Code review mentions missing tests

## Framework Preferences

### JUnit 5 (Jupiter)
```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import static org.assertj.core.api.Assertions.*;
```

### AssertJ over standard assertions
✅ **Use AssertJ**:
```java
assertThat(plugin.getState())
    .as("Plugin should be started after initialization")
    .isEqualTo(PluginState.STARTED);

assertThat(plugins)
    .hasSize(3)
    .extracting(Plugin::getId)
    .containsExactly("plugin1", "plugin2", "plugin3");
```

❌ **Avoid JUnit assertions**:
```java
assertEquals(PluginState.STARTED, plugin.getState()); // Less readable
assertTrue(plugins.size() == 3); // Less descriptive failures
```

## Test Structure (AAA Pattern)

Always use Arrange-Act-Assert pattern:

```java
@Test
@DisplayName("Should load plugin from valid directory")
void shouldLoadPluginFromValidDirectory() {
    // Arrange - Setup test data and dependencies
    Path pluginDir = Paths.get("test-plugins/valid-plugin");
    PluginLoader loader = new DefaultPluginLoader();
    
    // Act - Execute the behavior being tested
    Plugin plugin = loader.load(pluginDir);
    
    // Assert - Verify results
    assertThat(plugin)
        .isNotNull()
        .extracting(Plugin::getId, Plugin::getVersion)
        .containsExactly("test-plugin", "1.0.0");
}
```

## Naming Conventions

### Test class names
```java
// Class under test: PluginManager
PluginManagerTest           // ✅ Simple, standard
PluginManagerShould         // ✅ BDD style (if team prefers)
TestPluginManager           // ❌ Avoid
```

### Test method names

**Option 1: should_expectedBehavior_when_condition** (descriptive)
```java
@Test
void should_throwException_when_pluginDirectoryNotFound() { }

@Test  
void should_returnEmptyList_when_noPluginsAvailable() { }

@Test
void should_loadPluginsInDependencyOrder_when_multipleDependencies() { }
```

**Option 2: Natural language with @DisplayName** (cleaner code)
```java
@Test
@DisplayName("Should load all plugins from directory")
void loadAllPlugins() { }

@Test
@DisplayName("Should throw exception when plugin descriptor is invalid")
void invalidPluginDescriptor() { }
```

## AssertJ Power Features

### Collection assertions
```java
// Basic collection checks
assertThat(plugins)
    .isNotEmpty()
    .hasSize(2)
    .doesNotContainNull();

// Advanced filtering and extraction
assertThat(plugins)
    .filteredOn(p -> p.getState() == PluginState.STARTED)
    .extracting(Plugin::getId)
    .containsExactlyInAnyOrder("plugin-a", "plugin-b");

// All elements match condition
assertThat(plugins)
    .allMatch(p -> p.getVersion() != null, "All plugins have version");
```

### Exception assertions
```java
// Basic exception check
assertThatThrownBy(() -> loader.load(invalidPath))
    .isInstanceOf(PluginException.class)
    .hasMessageContaining("Invalid plugin descriptor");

// Detailed exception verification
assertThatThrownBy(() -> manager.startPlugin("missing-plugin"))
    .isInstanceOf(PluginException.class)
    .hasMessageContaining("Plugin not found")
    .hasCauseInstanceOf(IllegalArgumentException.class)
    .hasNoCause(); // or verify cause chain

// With assertThatExceptionOfType (more readable)
assertThatExceptionOfType(PluginException.class)
    .isThrownBy(() -> loader.load(invalidPath))
    .withMessageContaining("Invalid")
    .withMessageMatching("Invalid .* descriptor");
```

### Object assertions
```java
// Extract and verify multiple properties
assertThat(plugin)
    .isNotNull()
    .extracting("id", "version", "state")
    .containsExactly("my-plugin", "1.0", PluginState.STARTED);

// Using method references (type-safe)
assertThat(plugin)
    .extracting(Plugin::getId, Plugin::getVersion, Plugin::getState)
    .containsExactly("my-plugin", "1.0", PluginState.STARTED);

// Field by field comparison
assertThat(actualPlugin)
    .usingRecursiveComparison()
    .isEqualTo(expectedPlugin);
```

### Soft assertions (multiple checks)
```java
@Test
void shouldHaveValidPluginDescriptor() {
    SoftAssertions softly = new SoftAssertions();
    
    softly.assertThat(descriptor.getId())
        .as("Plugin ID")
        .isNotBlank()
        .matches("[a-z0-9-]+");
    
    softly.assertThat(descriptor.getVersion())
        .as("Plugin version")
        .matches("\\d+\\.\\d+\\.\\d+");
    
    softly.assertThat(descriptor.getDependencies())
        .as("Dependencies")
        .isNotNull()
        .doesNotContainNull();
    
    softly.assertAll(); // All assertions evaluated, even if some fail
}
```

### String assertions
```java
assertThat(errorMessage)
    .startsWith("Error:")
    .contains("plugin", "failed")
    .doesNotContain("success")
    .matches("Error: .* failed")
    .hasLineCount(3);
```

## Test Organization

### Nested tests for clarity
```java
@DisplayName("PluginManager")
class PluginManagerTest {
    
    private PluginManager manager;
    
    @BeforeEach
    void setUp() {
        manager = new DefaultPluginManager();
    }
    
    @Nested
    @DisplayName("when starting plugins")
    class WhenStartingPlugins {
        
        @Test
        @DisplayName("should start all plugins in dependency order")
        void shouldStartInDependencyOrder() {
            // Test implementation
        }
        
        @Test
        @DisplayName("should skip disabled plugins")
        void shouldSkipDisabledPlugins() {
            // Test implementation
        }
        
        @Test
        @DisplayName("should fail if circular dependency detected")
        void shouldFailOnCircularDependency() {
            // Test implementation
        }
    }
    
    @Nested
    @DisplayName("when stopping plugins")  
    class WhenStoppingPlugins {
        
        @Test
        @DisplayName("should stop plugins in reverse dependency order")
        void shouldStopInReverseOrder() {
            // Test implementation
        }
    }
}
```

### Parameterized tests
```java
@ParameterizedTest
@ValueSource(strings = {"1.0.0", "2.1.3", "10.0.0-SNAPSHOT"})
@DisplayName("Should accept valid semantic versions")
void shouldAcceptValidVersions(String version) {
    assertThat(VersionParser.parse(version))
        .isNotNull()
        .hasFieldOrPropertyWithValue("valid", true);
}

@ParameterizedTest
@CsvSource({
    "plugin-a, 1.0, STARTED",
    "plugin-b, 2.0, STOPPED",
    "plugin-c, 1.5, DISABLED"
})
@DisplayName("Should load plugin with expected state")
void shouldLoadPluginWithState(String id, String version, PluginState expectedState) {
    Plugin plugin = createPlugin(id, version);
    
    assertThat(plugin.getState()).isEqualTo(expectedState);
}

@ParameterizedTest
@MethodSource("invalidPluginDescriptors")
@DisplayName("Should reject invalid plugin descriptors")
void shouldRejectInvalidDescriptors(PluginDescriptor descriptor, String expectedError) {
    assertThatThrownBy(() -> validator.validate(descriptor))
        .hasMessageContaining(expectedError);
}

static Stream<Arguments> invalidPluginDescriptors() {
    return Stream.of(
        Arguments.of(descriptorWithoutId(), "Missing plugin ID"),
        Arguments.of(descriptorWithInvalidVersion(), "Invalid version format"),
        Arguments.of(descriptorWithEmptyId(), "Plugin ID cannot be empty")
    );
}
```

## Common Patterns

### Testing with mocks (Mockito)
```java
@ExtendWith(MockitoExtension.class)
class PluginManagerTest {
    
    @Mock
    private PluginRepository repository;
    
    @Mock
    private PluginValidator validator;
    
    @InjectMocks
    private DefaultPluginManager manager;
    
    @Test
    @DisplayName("Should load plugins from repository")
    void shouldLoadPluginsFromRepository() {
        // Given
        List<PluginDescriptor> descriptors = List.of(
            createDescriptor("plugin1"),
            createDescriptor("plugin2")
        );
        when(repository.findAll()).thenReturn(descriptors);
        
        // When
        List<Plugin> plugins = manager.loadAll();
        
        // Then
        assertThat(plugins).hasSize(2);
        verify(repository).findAll();
        verify(validator, times(2)).validate(any(PluginDescriptor.class));
    }
}
```

### Test fixtures with @BeforeEach
```java
@BeforeEach
void setUp() throws IOException {
    // Create temporary directory for test plugins
    pluginDir = Files.createTempDirectory("test-plugins");
    
    // Initialize plugin manager with test config
    PluginConfig config = PluginConfig.builder()
        .pluginDirectory(pluginDir)
        .enableValidation(true)
        .build();
    
    pluginManager = new DefaultPluginManager(config);
}

@AfterEach
void tearDown() throws IOException {
    // Clean up test resources
    if (pluginManager != null) {
        pluginManager.stopAll();
    }
    if (pluginDir != null) {
        FileUtils.deleteDirectory(pluginDir.toFile());
    }
}
```

### Testing async operations
```java
@Test
@DisplayName("Should complete async plugin loading")
void shouldCompleteAsyncLoading() {
    CompletableFuture<Plugin> future = manager.loadAsync(pluginPath);
    
    assertThat(future)
        .succeedsWithin(Duration.ofSeconds(5))
        .satisfies(plugin -> {
            assertThat(plugin.getState()).isEqualTo(PluginState.STARTED);
            assertThat(plugin.getId()).isNotBlank();
        });
}
```

## Token Optimization

When writing tests:

### 1. Generate test skeleton first
```java
// Phase 1: List test cases as comments
// @Test void shouldLoadPlugin() { }
// @Test void shouldThrowExceptionForInvalidPlugin() { }
// @Test void shouldHandleMissingDependencies() { }
```

### 2. Implement incrementally
- One test at a time
- Verify compilation after each
- Run tests to validate
- Refactor if needed

### 3. Reuse patterns
```java
// Extract common setup to helper methods
private Plugin createTestPlugin(String id, String version) {
    return Plugin.builder()
        .id(id)
        .version(version)
        .build();
}
```

## Code Coverage Guidelines

- **Aim for**: 80%+ line coverage on core logic
- **Focus on**: Business logic, complex algorithms, edge cases
- **Skip**: Trivial getters/setters, POJOs, generated code
- **Test**: Happy paths + error conditions + boundary cases

### What to test
✅ **High priority**:
- Public APIs
- Complex business logic
- Error handling
- Edge cases and boundaries
- Integration points

❌ **Low priority**:
```java
// Simple getters/setters
public String getId() { return id; }
public void setId(String id) { this.id = id; }

// Simple POJOs with no logic
public class PluginInfo {
    private String id;
    private String version;
    // ... only getters/setters
}
```

## Anti-patterns

❌ **Avoid**:
```java
// 1. Generic test names
@Test void test1() { }
@Test void testPlugin() { }

// 2. Testing implementation details
assertThat(plugin.internalState.flag).isTrue(); // Couples to internals

// 3. Brittle assertions with timestamps
assertThat(message).isEqualTo("Error at 2024-01-26 10:30:15");

// 4. Multiple unrelated assertions
@Test void testEverything() {
    // 50 unrelated assertions
    assertThat(plugin.getId()).isNotNull();
    assertThat(manager.getCount()).isEqualTo(5);
    assertThat(config.isEnabled()).isTrue();
    // ... mixing multiple concerns
}

// 5. Ignoring exceptions
@Test void shouldFail() {
    try {
        loader.load(invalidPath);
        fail("Should have thrown exception");
    } catch (Exception e) {
        // Swallowing exception details
    }
}
```

✅ **Prefer**:
```java
@Test
@DisplayName("Should reject plugin with missing dependencies")
void shouldRejectPluginWithMissingDependencies() {
    PluginDescriptor descriptor = PluginDescriptor.builder()
        .id("test-plugin")
        .dependencies(List.of("missing-dep"))
        .build();
    
    assertThatThrownBy(() -> manager.load(descriptor))
        .isInstanceOf(PluginException.class)
        .hasMessageContaining("Missing dependencies: missing-dep");
}
```

## Integration with Coverage Tools

### Maven configuration
```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.11</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

### After test generation, suggest:
```bash
# Run tests with coverage
mvn clean test jacoco:report

# View coverage report
open target/site/jacoco/index.html

# Check coverage threshold
mvn verify # Fails if below configured threshold
```

## Quick Reference

```java
// ===== Basic Assertions =====
assertThat(value).isEqualTo(expected);
assertThat(value).isNotNull();
assertThat(value).isInstanceOf(String.class);
assertThat(number).isPositive().isGreaterThan(5);

// ===== Collections =====
assertThat(list).hasSize(3);
assertThat(list).contains(item);
assertThat(list).containsExactly(item1, item2, item3);
assertThat(list).containsExactlyInAnyOrder(item2, item1, item3);
assertThat(list).doesNotContain(item);
assertThat(list).allMatch(predicate);

// ===== Strings =====
assertThat(str).isNotBlank();
assertThat(str).startsWith("prefix");
assertThat(str).endsWith("suffix");
assertThat(str).contains("substring");
assertThat(str).matches("regex\\d+");

// ===== Exceptions =====
assertThatThrownBy(() -> code())
    .isInstanceOf(PluginException.class)
    .hasMessageContaining("error");

assertThatNoException().isThrownBy(() -> code());

// ===== Custom Descriptions =====
assertThat(userId)
    .as("User ID should be positive")
    .isPositive();

// ===== Object Comparison =====
assertThat(actual)
    .usingRecursiveComparison()
    .ignoringFields("timestamp", "id")
    .isEqualTo(expected);
```

## Best Practices Summary

1. **Use AssertJ** for all assertions
2. **Follow AAA pattern** (Arrange-Act-Assert)
3. **Descriptive names** with @DisplayName
4. **One concept** per test
5. **Test behavior**, not implementation
6. **Extract helpers** for common setup
7. **Use @Nested** for logical grouping
8. **Parameterize** similar tests
9. **Soft assertions** for multiple checks
10. **Coverage** on business logic, not boilerplate

## References

- [AssertJ Documentation](https://assertj.github.io/doc/)
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
