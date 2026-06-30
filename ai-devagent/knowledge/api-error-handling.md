# API Design and Error Handling

**Layer**: AI DevAgent (generic, portable)
**When to load**: Designing or modifying APIs, service methods, error handling, or logging.
**Project override**: Project memory specifies whether this project uses REST, RMI, or another communication protocol.

---

## REST API Design

### Resource Naming
- Resources are **nouns**, not verbs: `/orders`, not `/getOrders`
- Hierarchical resources: `/orders/{id}/items`
- Plural nouns for collections: `/products`, `/users`
- Kebab-case for multi-word resources: `/order-items`

### HTTP Methods
| Method | Purpose | Idempotent |
|--------|---------|-----------|
| GET | Read resource or collection | Yes |
| POST | Create new resource | No |
| PUT | Replace resource entirely | Yes |
| PATCH | Partial update | No |
| DELETE | Remove resource | Yes |

### HTTP Status Codes
| Situation | Code |
|-----------|------|
| Success, returns body | 200 OK |
| Created successfully | 201 Created |
| Success, no body | 204 No Content |
| Invalid request data | 400 Bad Request |
| Not authenticated | 401 Unauthorized |
| Not authorized | 403 Forbidden |
| Resource not found | 404 Not Found |
| Optimistic lock conflict | 409 Conflict |
| Server error | 500 Internal Server Error |

---

## Request / Response DTO Separation

**Never reuse the same DTO for request and response.**

| DTO Type | Contains |
|----------|---------|
| Create Request | Creation fields, validation annotations, no `id`, no version |
| Update Request | `id` (required), version (required), updatable fields |
| Response / Read | `id`, all display fields, version |
| Reference / Lookup | `id` + display name only |

---

## Input Validation

- Bean Validation annotations on request DTOs (`@NotNull`, `@NotBlank`, `@Size`, `@Min`)
- Trigger validation at the controller boundary (`@Valid` on request body)
- Return 400 with field-level error details on validation failure
- Do not duplicate validation logic in service layer unless business rules differ from format rules

---

## Error Response Structure

```json
{
  "errorCode": "ORDER_NOT_FOUND",
  "message": "Order with ID 123 was not found",
  "timestamp": "2026-06-18T10:15:30Z"
}
```

- Never expose stack traces in API error responses
- `errorCode`: machine-readable constant (enables client error handling)
- `message`: human-readable description

---

## Exception Hierarchy (Generic)

```
RuntimeException
  └─ AppException (project base, unchecked)
       ├─ NotFoundException         (404)
       ├─ ValidationException       (400)
       ├─ ConflictException         (409)
       └─ AuthorizationException    (403)

Exception
  └─ RecoverableException (project base, checked)
```

**Project override**: Use the project-specific exception base classes — do not extend plain `RuntimeException`.

---

## Exception Handling Rules

- Business logic methods throw specific exceptions — never generic `Exception`
- Controllers never contain try/catch — use a global exception handler (`@ControllerAdvice` or equivalent)
- Expected failures (not found, validation): log at `WARN`
- Unexpected failures: log at `ERROR` with full stack trace
- Checked exceptions: use only when the caller can realistically recover

---

## Service Layer Error Patterns

```java
// Not Found Pattern
var entity = repository.findById(id)
    .orElseThrow(() -> new NotFoundException("Entity", id));

// Validation Before Persist
validate(entity);           // throw ValidationException if invalid
repository.save(entity);    // only saves if valid
```

---

## Logging Practices

| Level | When |
|-------|------|
| ERROR | Unexpected failures, system errors |
| WARN | Expected failures, degraded operation |
| INFO | Significant state changes, business events |
| DEBUG | Method entry/exit at service boundary |
| TRACE | Per-item processing in bulk operations |

**Rules**:
- Use structured logging: `log.debug("Creating order", Map.of("customerId", id))`
- Never log sensitive data (passwords, tokens, personal information)
- Check `log.isDebugEnabled()` before constructing expensive debug strings
- Use `@Slf4j` (or equivalent) — never declare a Logger field manually

---

## API Versioning

| Strategy | When |
|----------|------|
| URL versioning `/v1/orders` | Breaking changes — simplest and most visible |
| Header versioning `API-Version: 2` | Non-breaking preferred changes |

**Rule**: Never break existing API consumers without versioning or prior coordination.

