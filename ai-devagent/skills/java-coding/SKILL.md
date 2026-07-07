---
name: java-coding
description: Load for any Java code — writing, refactoring, or reviewing. Java 21 coding guidelines.
---

# Skill: Java 21 Coding Guidelines
## When to Apply This Skill
Load this skill for **any Java code** -- writing, refactoring, or reviewing.
**Project override**: Project memory specifies import namespace (javax vs jakarta) and German domain term conventions.
---
## Java Version and Imports
- Target: **Java 21**
- Confirm the correct namespace by checking an existing class in the same module before adding imports
- Check project memory for the import convention (`javax.*` vs `jakarta.*`) — it varies by project type
---
## Java 21 Features -- When to Use
### Records
- Use Records for DTOs, configuration objects, and value types -- they are immutable and eliminate boilerplate
- Use the compact constructor only for validation logic inside the record
- Do NOT use Records for JPA entities -- JPA requires mutable classes with a no-arg constructor
- Do NOT migrate existing Serializable/Comparable classes to Records without an explicit task
### Pattern Matching for instanceof
- Always use pattern matching (`instanceof Type var`) instead of performing a cast immediately after an instanceof check
- Never perform an explicit cast when a pattern match can be used instead
### Sealed Interfaces
- Use sealed interfaces for closed type hierarchies where all subtypes are known at compile time
- Pair sealed interfaces with exhaustive switch expressions so the compiler enforces all cases
### Switch Expressions
- Prefer switch expressions (arrow syntax) over switch statements whenever the switch produces a value
- Include a `default` case or ensure exhaustiveness through sealed types
### Text Blocks
- Use text blocks for multi-line SQL, JPQL, JSON, or XML strings
- Align content to a consistent indentation level; the closing `"""` determines the left margin
---
## Lombok -- Reducing Boilerplate
- Use `@Builder` for classes with multiple optional fields or complex construction sequences
- Use `@Value` for immutable value objects (generates a final class with final fields and no setters)
- Use `@NonNull` on constructor/method parameters that must never be null -- eliminates manual null checks
- Use `@Slf4j` for logging -- never declare a Logger field manually
- Use `@RequiredArgsConstructor` with `final` fields to generate constructor injection code
- Never add `@Data` to JPA entities -- it breaks Hibernate proxies and generates unsafe equals/hashCode
---
## Streams -- Prefer Over Imperative Loops
- Use `stream()` with `filter()`, `map()`, and `collect()` for filtering and transforming collections
- Use `Collectors.toUnmodifiableList()` when the result must not be modified by callers
- Use `toList()` (Java 16+) as a concise shorthand for an unmodifiable list
- Use `Collectors.groupingBy()` for grouping operations
- Use `Stream.reduce()` for aggregating values (e.g., summing BigDecimal)
- Never use a `for` loop where a Stream pipeline is clearly more readable
---
## Immutability
- Use `List.of()`, `Set.of()`, `Map.of()` for static immutable collections
- Use `List.copyOf()` in constructors when accepting mutable collections from callers
- Return `Collections.unmodifiableList()` from getters that expose internal mutable collections
- Mark fields `final` wherever the value is set once (in constructor or field initializer)
---
## Naming Conventions
| Element | Convention | Example |
|---------|-----------|---------|
| Class / Record | PascalCase | `OrderService`, `ProductDto` |
| Interface | PascalCase, no I prefix | `OrderRepository`, `PaymentProcessor` |
| Method | camelCase, verb-first | `findById()`, `createOrder()`, `isActive()` |
| Variable | camelCase | `orderRepository`, `totalAmount` |
| Constant | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE` |
| Package | lowercase | `com.example.order.service` |
---
## Documentation Rules
- All public API methods must have Javadoc with `@param`, `@return`, and `@throws` where applicable
- Do not document version information in code (no `@version`, no `@since` for new code)
- Single-line comments always use three lines: blank line above, the comment text, blank line below
- New code: English comments and Javadoc
- Existing code: keep the existing language (German comments stay German)
---
## Anti-Patterns to Avoid
- **Raw types**: always parameterize generic types; never use `List` without a type argument
- **Magic numbers**: extract any numeric literal with domain meaning into a named constant
- **Redundant null checks with @NonNull**: if a field or parameter is guarded by `@NonNull`, do not add `if (x != null)` checks
- **Suppressed warnings without justification**: `@SuppressWarnings` must always be accompanied by an inline comment explaining why the suppression is safe
- **Broad exception catch**: catch the most specific exception type; never catch `Exception` unless at a top-level boundary handler
- **Returning null from collection methods**: return an empty collection instead of null
- **Field injection in new code**: use constructor injection for all new Spring components

