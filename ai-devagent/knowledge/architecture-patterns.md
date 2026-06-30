# Architecture Patterns

**Layer**: AI DevAgent (generic, portable)
**When to load**: Any design or implementation task — service, repository, controller, integration.
**Project override**: Project memory specifies concrete implementations of these patterns.

---

## AP-01: Layered Architecture

**Intent**: Separate concerns across horizontal layers. Each layer depends only on the layer below.

```
Presentation / Controller
       ↓ (DTOs only)
   Service Layer
       ↓ (entities or DTOs)
  Repository / DAO
       ↓
   Data Store
```

**Rules**:
- Controllers receive/return DTOs only — never entities
- Services contain all business logic
- Repositories are persistence-only — no business logic
- No layer may skip a level (controller calling repository directly is forbidden)
- Cross-layer contracts use interfaces, not concrete classes

---

## AP-02: Service Interface Pattern (Facade)

**Intent**: Define the contract for a capability separately from its implementation.

**Structure**:
- Interface in shared/API module → contract, Javadoc, no framework annotations
- Implementation in server module → framework annotations, transaction management
- Caller always depends on interface, never on implementation

**Rules**:
- Transaction annotations belong on the **implementation**, never the interface
- One interface per cohesive business capability
- Interface methods use DTOs as parameters and return types
- Never annotate the interface with framework annotations (`@Service`, `@Transactional`, etc.)

---

## AP-03: Repository Pattern

**Intent**: Encapsulate all data access behind a well-defined interface.

**Rules**:
- Repositories are interfaces — the framework provides the implementation
- One repository per aggregate root
- Repositories return domain entities or DTO projections — never raw rows
- Business logic does NOT belong in repositories
- Use named queries — avoid inline SQL string concatenation
- Naming: `findBy{Criteria}`, `deleteBy{Criteria}`, `countBy{Criteria}`

---

## AP-04: DTO Pattern (Data Transfer Object)

**Intent**: Transfer data between layers without exposing internal domain model.

**Request/Response separation** (mandatory):
| DTO Type | Contains |
|----------|---------|
| Create Request | All creation fields, validation annotations, no `id` |
| Update Request | `id` + version (optimistic lock), update fields, validation |
| Response / Read | `id`, display fields, version |
| Reference / Lookup | `id` + display name only |

**Rules**:
- DTOs are pure data containers — no business logic, no framework dependencies
- DTOs never reference ORM entities or framework beans
- Use immutable types (Records, `@Value`) for new DTOs wherever possible

---

## AP-05: CQRS — Command Query Separation

**Intent**: Separate operations that change state from operations that read state.

**Lightweight CQRS** (applicable without full event sourcing):
- **Queries** → return DTOs, use projections (no full entity hydration when unnecessary)
- **Commands** → return void or minimal confirmation, work with domain entities
- Read models optimize for display (JOIN to projection directly)
- Write models work with fully loaded entities

**When to apply**: Any service with both read-heavy and write-heavy operations.

---

## AP-06: Authorization Pattern

**Intent**: Enforce access control at the correct boundary.

**Principle — Defense in Depth**:
```
UI Controls (disable buttons)          ← UX only, never security
       ↓
Service Layer Permission Check         ← PRIMARY enforcement boundary
       ↓
Database (constraints)                 ← Safety net
```

**Rules**:
- Server-side enforcement is mandatory — client-side is UX only
- Authorization checks belong on **service methods**, not controllers
- Define permissions as named constants (enum) — never hardcode strings
- Enforce via AOP annotation (aspect runs at call time)
- Unregistered permissions → deny by default (fail closed)
- All write operations (create, update, delete) require explicit permission check

---

## AP-07: Optimistic Locking

**Intent**: Prevent lost updates in concurrent write scenarios without pessimistic locks.

**Rules**:
- Every mutable entity needs a version field (`@Version` on a Long)
- Update request DTOs must carry the version value from the read operation
- On update: load entity → apply changes → let ORM verify version on flush
- Surface `OptimisticLockException` to the caller as a recoverable user error
- Never manually compare versions — the ORM enforces this automatically

---

## AP-08: Background Processing Pattern

**Intent**: Perform long-running operations outside the request/response cycle.

**Rules**:
- Pass minimal context to background task (IDs, not full objects)
- Tasks should be idempotent wherever possible (safe to retry)
- Chunk large batch operations — each chunk in its own transaction
- Log start, end, and failure with enough context to diagnose issues
- Dead-letter mechanism required for failed message processing

---

## AP-09: Event-Driven Integration

**Intent**: Decouple components via asynchronous messaging.

**Rules**:
- Producer does not know consumers — publishes to a topic/queue
- Messages carry all state needed for processing (no callbacks to producer)
- Messages are idempotent-safe — reprocessing yields the same result
- Dead-letter queue required for failed processing
- Use schema (XML, JSON schema, Avro) for message contracts — never raw string concatenation

---

## AP-10: Null Safety Pattern

**Intent**: Eliminate NullPointerExceptions through design rather than defensive checks.

**Rules**:
- Annotate non-null parameters with `@NonNull` — generates null check at construction
- Return empty collections (`List.of()`) from collection-returning methods — never null
- Return `Optional<T>` only from single-item lookups — never from collection methods
- Prefer `.orElseThrow(...)` over `Optional.get()` — give a meaningful error message
- Never annotate `Optional` fields — use it only as a method return type

