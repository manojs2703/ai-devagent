# Prompt: Test — Generic Workflow

**Purpose**: Consolidate and ensure test coverage for implemented code.

---

## Context Loading

```
1. active-context.md                              → current story, patterns used
2. ai-devagent/knowledge/testing-strategies.md    → GWT structure, naming
3. Project test skill file                        → project-specific test annotations
4. Class under test                               → the specific file being tested
```

**Read only the class under test. No other source files.**

---

## Skills to Load

| Skill | What it Covers |
|-------|---------------|
| `ai-devagent/skills/testing-guidelines.md` | Given-When-Then, @Nested, parameterized tests |
| `ai-devagent/skills/testing-junit5.md` | JUnit 5 annotations, lifecycle, @DisplayName |
| `ai-devagent/skills/testing-assertj.md` | Fluent assertions, soft assertions, exceptions |
| `ai-devagent/skills/testing-mockito.md` | Stubbing, verification, ArgumentCaptor |
| `ai-devagent/skills/jpa-persistence.md` | Integration test pattern for repositories |

---

## Process

### Step 1 — Inventory
- Identify all new/changed classes from the implementation
- For each class: determine what scenarios are missing test coverage

### Step 2 — Run Existing Tests
- Run `mvn clean test` for affected modules
- Fix any failing tests before adding new ones

### Step 3 — Add Missing Tests
For each class under test, write tests for:
- Happy path (primary flow) — **Mandatory**
- Input validation / invalid inputs — **Mandatory**
- Not found / empty result — **Mandatory**
- Error conditions and exception paths
- Concurrent update / optimistic lock (if applicable)
- Authorization boundary (if applicable)

### Step 4 — Quality Check
Every test must satisfy:
- [ ] Given-When-Then structure with blank-line separation
- [ ] No `if`/`while`/`for` in test body
- [ ] `@Nested` classes for logical grouping
- [ ] Descriptive method names: `should{Behaviour}When{Condition}`
- [ ] AssertJ only — no JUnit assertEquals/assertTrue
- [ ] Project-specific test annotation used (check project memory)
- [ ] Parameterized tests use Records as parameter objects
- [ ] Failure messages on parameterized tests

### Step 5 — Final Check
- [ ] All new/changed classes have tests
- [ ] `mvn clean test` passes for all affected modules
- [ ] No private methods tested directly
- [ ] Simple getters/setters not tested (zero logic)

---

## Test Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Happy path | `should{ExpectedBehaviour}` | `shouldReturnAllOrders` |
| With condition | `should{Behaviour}When{Condition}` | `shouldThrowWhenOrderNotFound` |
| Unit class | `{Class}Test` | `OrderServiceTest` |
| Integration class | `{Class}IntegrationTest` | `OrderRepositoryIntegrationTest` |

---

## Test Class Template

```java
@UnitTest  // ← project-specific annotation from project memory
class {ClassName}Test {

    @Mock
    private {Dependency} dependency;

    @InjectMocks
    private {ClassName} sut;

    @Nested
    class {MethodName} {

        @Test
        void should{ExpectedBehaviour}() {
            // Given
            {setup}

            // When
            var result = sut.{method}({args});

            // Then
            assertThat(result).{assertion};
        }

        @Test
        void should{Behaviour}When{Condition}() {
            // Given
            {setup that triggers the condition}

            // When / Then
            assertThatThrownBy(() -> sut.{method}({args}))
                .isInstanceOf({ExceptionType}.class)
                .hasMessageContaining("{expected message}");
        }
    }
}
```

---

## Memory Update After Testing

Update `active-context.md`:
- Set Phase to "Testing complete"
- Note any gaps in test coverage discovered
