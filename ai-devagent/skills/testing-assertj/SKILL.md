---
name: testing-assertj
description: Load when writing assertions in tests. AssertJ fluent assertions.
---

# Skill: AssertJ -- Fluent Assertions
## When to Apply This Skill
Load this skill when writing assertions in tests.
---
## Core Principle
- Use a single `assertThat(subject)` call and chain all assertions about that subject
- Never use multiple separate `assertThat` calls for the same object -- chain them instead
- Never use JUnit 5 `assertEquals`, `assertTrue`, or `assertNotNull` -- always use AssertJ
- Import: `import static org.assertj.core.api.Assertions.*`
---
## Object Assertions
- Use `.isNotNull()` / `.isNull()` for null checks
- Use `.isEqualTo(expected)` for value equality
- Use `.isSameAs(ref)` for reference identity checks
- Use `.isInstanceOf(Type.class)` for type checking
- Use `.usingRecursiveComparison()` for field-by-field comparison when `equals()` is not overridden
- Use `.usingRecursiveComparison().ignoringFields("id", "createdAt")` to exclude generated or time-dependent fields
---
## Collection Assertions
- Use `.hasSize(n)` for size checks
- Use `.isEmpty()` / `.isNotEmpty()` for emptiness
- Use `.contains(element)` to check presence of one or more elements (order-independent)
- Use `.containsExactly(...)` to verify exact elements in exact order
- Use `.containsExactlyInAnyOrder(...)` for exact elements regardless of order
- Use `.doesNotContain(element)` for negative membership
- Use `.extracting(FieldOrMethod)` to extract a property from each element before asserting
- Use `.extracting(A, B)` with `.containsExactly(tuple(a1, b1), tuple(a2, b2))` for multi-field extraction
---
## Exception Assertions
- Use `assertThatThrownBy(() -> codeUnderTest())` -- never try/catch in test methods
- Chain `.isInstanceOf(ExceptionType.class)` to check the exception type
- Chain `.hasMessageContaining("text")` to check the message
- Chain `.hasMessage("exact message")` for exact message matching
- Use `assertThatCode(() -> codeUnderTest()).doesNotThrowAnyException()` to assert no exception is thrown
---
## Optional Assertions
- Use `.isPresent()` / `.isEmpty()` on `Optional` -- do not call `.get()` before asserting
- Use `.hasValue(expected)` to assert the Optional contains a specific value
---
## String Assertions
- Use `.startsWith(prefix)`, `.endsWith(suffix)`, `.contains(substring)` for partial string checks
- Use `.isBlank()` / `.isNotBlank()` for whitespace checks
- Use `.hasLineCount(n)` for multiline strings
---
## Soft Assertions
- Use `SoftAssertions.assertSoftly(softly -> { ... })` when checking multiple independent properties
- All failures are collected and reported together at the end of the soft assertion block
- Use soft assertions in integration tests or when asserting many fields of a complex object

