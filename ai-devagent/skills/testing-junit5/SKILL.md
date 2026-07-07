# Skill: JUnit 5 -- Test Framework
## When to Apply This Skill
Load this skill when writing or reviewing JUnit 5 test classes.
---
## Core Annotations
| Annotation | Purpose |
|-----------|---------|
| `@Test` | Marks a test method |
| `@ParameterizedTest` | Test with multiple inputs |
| `@RepeatedTest(n)` | Runs the test n times |
| `@BeforeEach` | Runs before each test method |
| `@AfterEach` | Runs after each test method |
| `@BeforeAll` | Runs once before all tests in class (must be static) |
| `@AfterAll` | Runs once after all tests in class (must be static) |
| `@Nested` | Nested test class for grouping |
| `@DisplayName` | Human-readable test name |
| `@Disabled` | Skips a test (always add a reason as the annotation value) |
| `@Tag` | Categorise tests for filtering |
| `@Timeout` | Fails if the test exceeds a duration |
---
## Test Class Structure
- Annotate the class with the appropriate project annotation (check project memory) or with `@ExtendWith(MockitoExtension.class)` for pure unit tests
- Declare dependencies as fields -- use `@Mock` for mocks and `@InjectMocks` for the class under test
- Set up shared state in `@BeforeEach`; tear down in `@AfterEach` only if needed
- Use `@Nested` inner classes to group related test scenarios (e.g., happy path vs. error cases, one class per method under test)
- Use `@DisplayName` to describe the test class or nested class purpose in plain English
---
## Parameterized Tests
### @MethodSource (Preferred -- Uses Records)
- Define test cases as Records within the test class
- Return a `Stream<TestCaseRecord>` from the `@MethodSource` method (must be static)
- The `@ParameterizedTest` method receives the record and extracts fields
### @CsvSource (For Simple Tables)
- Use for small, inline input/expected pairs
- Keep rows short; switch to `@MethodSource` when rows become complex
### @ValueSource (For Single Values)
- Use for testing a single method with multiple primitive or String inputs
- Combine with `@NullSource` or `@EmptySource` for boundary testing
---
## Lifecycle Rules
- Never share mutable state between test methods via instance fields that are mutated in tests
- Declare `@BeforeEach` setup to reset mutable state before each test
- Use `@BeforeAll` only for expensive one-time setup (e.g., starting a test container); mark the method static
---
## Exception Tests
- Use AssertJ `assertThatThrownBy(() -> ...)` to assert exceptions -- never use try/catch
- Chain `.isInstanceOf(ExceptionType.class)` and `.hasMessageContaining(...)` on the result
- For expected exceptions with no message check, `assertThatThrownBy(...).isInstanceOf(Type.class)` is sufficient
---
## Test Tags and Filtering
- Tag unit tests with `@Tag("unit")` and integration tests with `@Tag("integration")` if the project does not use custom annotations
- Check the project-specific test annotation library before adding raw `@Tag` annotations

