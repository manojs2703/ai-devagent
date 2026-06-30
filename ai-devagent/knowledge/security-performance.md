# Security and Performance

**Layer**: AI DevAgent (generic, portable)
**When to load**: Implementing security controls, optimizing queries, addressing performance bottlenecks.
**Project override**: Project memory specifies the authorization framework and technology stack.

---

## Security: Defense in Depth

**Principle**: Never rely on a single control. Layer independent defenses.

```
UI Controls (disable/hide elements)        ← UX only, never a security boundary
       ↓
API Gateway / Reverse Proxy               ← Rate limiting, TLS termination
       ↓
Authentication (who are you?)             ← Identity verification
       ↓
Authorization (what can you do?)          ← Permission enforcement  ← PRIMARY
       ↓
Input Validation + Sanitization           ← All inputs treated as untrusted
       ↓
Database Constraints                      ← Final safety net
```

---

## Authorization Rules

- **Server-side enforcement is mandatory** — client-side checks are UX only
- Permissions are named constants (enum) — never hardcode string permission names
- All write operations (create, update, delete) require an explicit permission check
- Unregistered/unknown permissions → deny by default (fail closed, never fail open)
- Authorization annotation on **service methods**, not controllers

---

## Input Security

| Risk | Defense |
|------|---------|
| SQL / JPQL injection | Parameterized queries / ORM — never concatenate |
| XSS | Encode output; validate and sanitize input |
| Path traversal | Validate and canonicalize file paths |
| Mass assignment | Use dedicated request DTOs — never bind to entity directly |
| Sensitive data in logs | Never log passwords, tokens, PII, or session IDs |

---

## Authentication Fundamentals

- Session tokens: store server-side, rotate on privilege escalation
- JWT: short expiry, strong signing key, validate signature and claims on every request
- Passwords: never store plaintext — use bcrypt / scrypt / argon2
- Never expose internal IDs in error messages or logs

---

## Performance: Query Optimization

**Load only what you need**:
- DTO projections for read-heavy paths — avoids full entity hydration
- Paginate all unbounded queries — never `findAll()` in production
- Use `COUNT` queries for counts — never `findAll().size()`
- Enable query logging in development to identify N+1 and missing indexes

**Indexing basics**:
- All foreign keys should be indexed
- Columns in frequent WHERE clauses need indexes
- Unique constraints create indexes automatically

---

## Performance: Caching

| What to Cache | TTL Guidance |
|--------------|-------------|
| Reference data (rarely changes) | Hours to days |
| User session data | Session lifetime |
| Expensive computed results | Minutes (with explicit eviction) |
| Mutable transactional data | Do NOT cache |

**Cache-aside pattern**:
1. Check cache
2. On miss: load from source
3. Populate cache
4. Serve result

**Rule**: Design cache eviction before caching. Stale data is worse than no cache.

---

## Performance: Batch Operations

- Chunk large data sets: never process millions of rows in one transaction
- Use bulk insert/update via ORM batch configuration
- Avoid loading parent entity just to update a child — use targeted update queries
- Measure before optimizing — profile first, optimize second

---

## Connection Pool Management

- Always use a connection pool (HikariCP or equivalent)
- Size pool based on measured concurrent load — not theoretical maximum
- Set acquisition timeout — never allow indefinite blocking
- Monitor pool exhaustion — surfaces as slow requests, not errors

---

## Concurrency Patterns

| Pattern | Use When |
|---------|---------|
| Optimistic locking | Low-contention writes, ORM-managed |
| Pessimistic locking | High-contention, guaranteed exclusion needed |
| DB unique constraint | Deduplication guarantee at the data layer |
| Idempotency key | Safe retry for external operations |

---

## Observability

**Structured logging** over plain string messages:
```
log.info("Order created", Map.of("orderId", id, "customerId", customerId))
```

**Metrics to instrument**:
- Request rate and error rate per endpoint
- Response time distribution (p50, p95, p99)
- Database query durations
- Cache hit/miss rates
- Queue depths (for async systems)

**Correlation IDs**:
- Thread-local request ID through all service calls in a request
- Include in log entries and in error responses
- Required for tracing requests across distributed components

