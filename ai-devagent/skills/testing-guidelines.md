# Skill: Testing Guidelines Overview
## When to Apply This Skill
Load this skill for any testing task. For deeper details, load the specific skills:
| Need | Skill File |
|------|-----------|
| JUnit 5 test structure, lifecycle, extensions | `ai-devagent/skills/testing-junit5.md` |
| AssertJ fluent assertions | `ai-devagent/skills/testing-assertj.md` |
| Mockito mocking and verification | `ai-devagent/skills/testing-mockito.md` |
**Project override**: Check project memory for project-specific test annotations (`@UnitTest`, `@IntegrationTest`, etc.).
---
## Core Principle: Given-When-Then
- Every test method must follow the Given-When-Then pattern with blank-line separation between sections
- "Given" sets up the preconditions and test data
- "When" calls the method under test exactly once
- "Then" contains all assertions about the result
---
## Test Quality Rules
- Never use control flow (`if`, `while`, `for`) in tests -- tests must be deterministic and linear
- Test exactly one behaviour per test method -- splitting reduces debugging time when tests fail
- Name test methods descriptively: `shouldThrowWhenProductNotFound`, `shouldReturnEmptyListWhenNoProducts`
- Tests must be independent -- no shared mutable state between test methods
- Use `@Nested` classes to group tests by feature, scenario, or input condition
- Use parameterized tests for multiple similar inputs -- avoid copy-paste test methods
---
## Test Categories
### Unit Tests
- Test a single class in isolation -- all dependencies are mocked or stubbed
- No Spring context, no database, no file system
- **Project override**: Use the project's custom unit test annotation (check project memory) or `@ExtendWith(MockitoExtension.class)`
- Should run in milliseconds
### Integration Tests
- Test a component in conjunction with its real dependencies (e.g., Spring context + in-memory database)
- **Project override**: Use the project's custom integration test annotation (check project memory)
- Scope: repository tests, service tests with real DB, JMS tests
- Slow; run separately from unit tests
---
## Parameterized Tests
- Use `@MethodSource` with a `Stream` of Records as the preferred approach for complex test cases
- Use `@ValueSource` for simple single-value parameterization (strings, ints)
- Use `@CsvSource` for small tables of input/expected pairs
- Name test cases clearly so that failure messages identify the failing scenario
---
## Test Naming
- Test class: `{ClassUnderTest}Test` (unit) or `{ClassUnderTest}IntegrationTest` (integration)
- Test method: `should{ExpectedBehaviour}When{Condition}` or `should{ExpectedBehaviour}` for simple cases
---
## Assertions
- Use AssertJ (`assertThat`) exclusively -- never JUnit `assertEquals` or `assertTrue`
- Chain assertions on a single `assertThat` call when checking multiple properties of the same object
- For exceptions: use `assertThatThrownBy` -- never try/catch in tests
- For soft assertions (checking multiple independent things): use `SoftAssertions.assertSoftly`

