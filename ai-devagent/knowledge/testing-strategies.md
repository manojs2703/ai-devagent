# Testing Strategies

**Layer**: AI DevAgent (generic, portable)
**When to load**: Writing, reviewing, or structuring any test.
**Project override**: Project memory specifies the exact test annotations (`@UnitTest`, `@IntegrationTest`, etc.) for this repository.

---

## Test Pyramid

```
         ╱ E2E ╲            (fewest — slow, broad scope, brittle)
        ╱────────╲
       ╱ Integration ╲      (moderate — real dependencies)
      ╱──────────────╲
     ╱   Unit Tests   ╲     (most — fast, isolated, deterministic)
    ╱──────────────────╲
```

**Cost principle**: Unit tests are cheapest. Write the minimum integration/E2E needed for confidence.

---

## Unit Tests

- Test a **single class** in isolation — all dependencies mocked or stubbed
- No Spring context, no file system, no network, no database
- Should run in under 100ms per test
- Mock all collaborators with `@Mock` + `@InjectMocks` (Mockito)
- Use `@ExtendWith(MockitoExtension.class)` or the project's equivalent annotation

---

## Integration Tests

- Test a component with its real dependencies (Spring context + in-memory DB)
- Scope: repositories, services with real persistence, message listeners
- Use the project's test annotation (do not default to `@SpringBootTest` without checking)
- Slower — run separately from unit tests in CI

---

## Given-When-Then Pattern

Every test method follows GWT with **blank-line separation**:

```java
@Test
void shouldReturnEmptyListWhenNoProductsExist() {
    // Given
    when(repository.findAll()).thenReturn(List.of());

    // When
    var result = service.findAll();

    // Then
    assertThat(result).isEmpty();
}
```

**Rules**:
- One `// When` block — calls the method under test **exactly once**
- All assertions in `// Then`
- No `if`, `while`, `for` in tests — tests must be linear and deterministic
- No control flow means no conditional assertions

---

## Test Naming

| Type | Pattern | Example |
|------|---------|---------|
| Happy path | `should{ExpectedBehaviour}` | `shouldReturnAllOrders` |
| With condition | `should{Behaviour}When{Condition}` | `shouldThrowWhenOrderNotFound` |
| Unit test class | `{ClassUnderTest}Test` | `OrderServiceTest` |
| Integration class | `{ClassUnderTest}IntegrationTest` | `OrderRepositoryIntegrationTest` |

---

## `@Nested` for Test Organization

Group related tests with `@Nested` classes:

```java
class OrderServiceTest {
    @Nested class FindById { ... }
    @Nested class CreateOrder { ... }
    @Nested class WhenOrderIsCancelled { ... }
}
```

---

## Assertions

- **AssertJ `assertThat()`** exclusively — never JUnit `assertEquals` or `assertTrue`
- Chain assertions on the same `assertThat()` for multiple properties of one object
- Exceptions: `assertThatThrownBy(() -> ...)` — never try/catch in tests
- Multiple independent assertions: `SoftAssertions.assertSoftly(softly -> { ... })`

---

## Parameterized Tests

| Source | Use When |
|--------|---------|
| `@MethodSource` with `Stream<Arguments>` | Complex multi-parameter cases |
| `@ValueSource` | Simple single-value cases (strings, ints) |
| `@CsvSource` | Small tables of input/expected pairs |

Use `@DisplayName` on parameterized tests — failure messages must identify the failing scenario.

---

## Mockito Rules

- `when(mock.method()).thenReturn(value)` for stubbing
- `verify(mock).method(argument)` for interaction verification
- `ArgumentCaptor<T>` to capture and inspect arguments passed to mocks
- `verifyNoMoreInteractions()` only when completeness of interactions matters
- Never mock value objects (Records, primitives) — use real instances

---

## Test Independence

- No shared mutable state between test methods
- Each test sets up its own data in the `// Given` section
- `@BeforeEach` for lightweight common setup only
- Never depend on test execution order

---

## What to Test vs Skip

| Test | Why |
|------|-----|
| Service business logic, edge cases, exceptions | Core value |
| Repository query correctness, projection mapping | Data integrity |
| Input validation behavior | Contract enforcement |
| Controller input binding (integration) | API contract |
| Private methods | Don't — test through the public API |
| Simple getters/setters | Don't — zero logic |

