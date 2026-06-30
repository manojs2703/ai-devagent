# Java Engineering

**Layer**: AI DevAgent (generic, portable)
**When to load**: Writing, reviewing, or refactoring any Java code.
**Project override**: Project memory specifies project-specific annotations, base classes, and naming conventions.

---

## Java 21 Feature Usage

| Feature | Use When | Avoid When |
|---------|---------|-----------|
| **Records** | Immutable DTOs, value objects, config objects | JPA entities (need mutable + no-arg constructor) |
| **Pattern Matching `instanceof`** | Replace explicit cast after instanceof | — |
| **Sealed Interfaces** | Closed type hierarchy with exhaustive switch | Open extension points |
| **Switch Expressions** | Switch produces a value (arrow syntax) | Simple one-line dispatch |
| **Text Blocks** | Multi-line SQL, JSON, XML, JPQL | Single-line strings |
| **`var`** | Type is obvious from right-hand side | When explicit type aids readability |
| **`Stream.toList()`** | Immutable list result (Java 16+) | When mutability needed |

---

## Lombok Usage

| Annotation | Use For | Never Use On |
|-----------|---------|-------------|
| `@Builder` | Complex construction, many optional fields | Simple 1-2 field classes |
| `@Value` | Immutable value objects | JPA entities |
| `@Data` | Simple POJOs only | JPA entities (breaks Hibernate proxy) |
| `@RequiredArgsConstructor` | Constructor injection (Spring / DI) | — |
| `@NonNull` | Required parameters/fields | Fields already guarded by Bean Validation |
| `@Slf4j` | All logging | Never declare Logger field manually |
| `@EqualsAndHashCode` | Custom equals/hashCode | JPA entities (use only `id`-based) |

---

## Streams and Functional Style

**Prefer streams over loops for**:
- Filtering → `.filter(predicate)`
- Transforming → `.map(function)`
- Grouping → `Collectors.groupingBy(keyFn)`
- Aggregating → `.reduce()`, `Collectors.summingInt()`
- Collecting → `.toList()` or `Collectors.toUnmodifiableList()`

**Rules**:
- Never use streams with side effects inside `.map()` or `.filter()`
- Avoid nested streams deeper than 2 levels — extract to named method
- Never use `Collectors.toList()` when `toList()` (Java 16+) suffices

---

## Immutability

- `List.of()`, `Set.of()`, `Map.of()` for static immutable collections
- `List.copyOf()` in constructors receiving mutable collections from callers
- `final` fields wherever value is set once
- `Collections.unmodifiableList()` when wrapping an existing mutable list

---

## Constructor Injection (Spring / DI)

```java
// ✅ Correct: final fields + @RequiredArgsConstructor
@Service
@RequiredArgsConstructor
public class OrderService {
    private final OrderRepository orderRepository;
    private final @NonNull EventPublisher eventPublisher;
}

// ❌ Avoid: field injection
@Autowired
private OrderRepository orderRepository;
```

---

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Class / Record | PascalCase | `OrderService`, `ProductDto` |
| Interface | PascalCase, no `I` prefix | `OrderRepository` |
| Method | camelCase, verb-first | `findById()`, `createOrder()` |
| Variable | camelCase | `orderRepository`, `totalAmount` |
| Constant | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| Package | all lowercase | `com.example.order.service` |
| Boolean method | `is`/`has`/`can` prefix | `isActive()`, `hasPermission()` |

---

## Exception Handling Strategy

**Checked exceptions** — use when the caller can realistically recover:
- Declare in method signature / interface `throws` clause
- Represent recoverable domain conditions

**Unchecked exceptions** — for programming errors and system failures:
- Do NOT declare in `throws` clause
- Extend a project-specific base (not plain `RuntimeException`)

**Rules**:
- Never catch `Exception` except at top-level boundary handlers
- Never swallow exceptions silently — log or rethrow
- Catch the most specific type possible
- Return empty collection instead of null from collection methods

---

## Documentation Standards

- All public API methods: Javadoc with `@param`, `@return`, `@throws` where applicable
- No version annotations in code (`@version`, `@since` for new code)
- Single-line comments: blank line above, the comment, blank line below
- Inline comments for complex algorithms only — never for obvious code
- Language: use the language convention already established in the file

---

## Anti-Patterns to Avoid

| Anti-Pattern | Correct Approach |
|-------------|-----------------|
| Raw generic types (`List`, `Map`) | Always parameterize |
| Magic numbers / strings | Extract to named constant |
| `@SuppressWarnings` without justification | Add inline comment explaining why |
| Null check when `@NonNull` already guards | Trust the annotation |
| Broad `catch (Exception e)` | Catch most specific type |
| Field injection in new code | Constructor injection |
| Returning null from collection method | Return `List.of()` |
| `Optional.get()` without check | Use `orElseThrow(...)` |

