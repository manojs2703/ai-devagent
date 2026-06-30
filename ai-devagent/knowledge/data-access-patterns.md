# Data Access Patterns

**Layer**: AI DevAgent (generic, portable)
**When to load**: Entity design, repository creation, query optimization, transaction management.
**Project override**: Project memory specifies the exact ORM framework, base classes, and transaction annotations used.

---

## ORM Entity Design

**Core Rules**:
- Annotate with `@Entity` and `@Table(name = "TABLE_NAME")`
- Every entity needs a no-arg constructor (protected or public) for ORM
- Business constructors set all required (non-nullable) fields
- Never add `@Data` (Lombok) — generates unsafe `equals/hashCode` on lazy associations
- Initialize collection fields inline: `= new ArrayList<>()`

**Column Naming**:
| Element | Convention | Example |
|---------|-----------|---------|
| Table | UPPER_SNAKE_CASE | `ORDER`, `ORDER_LINE` |
| Column | UPPER_SNAKE_CASE | `ORDER_DATE`, `TOTAL_PRICE` |
| Primary key | `ID` | `ID` |
| Foreign key | `{TABLE}_ID` | `CUSTOMER_ID` |
| Unique constraint | `UC_{TABLE}_{COLUMN}` | `UC_PRODUCT_SKU` |
| Index | `IDX_{TABLE}_{COLUMN}` | `IDX_ORDER_CUSTOMER_ID` |

**ID Strategy**: Always check whether the project uses a base entity class that provides the ID automatically before adding `@Id` manually.

---

## Associations

- `@ManyToOne` and `@OneToMany`: always `FetchType.LAZY` unless profiled as necessary
- `cascade = CascadeType.ALL` + `orphanRemoval = true` only on true ownership relationships
- Never cascade across aggregate boundaries — each aggregate manages its own lifecycle
- Bidirectional: management methods on owning side (`addChild()` / `removeChild()`)

---

## Repository Pattern

- Repositories are **interfaces** — implementation provided by framework
- One repository per aggregate root
- JPQL constructor projections for read-only operations: `SELECT NEW pkg.Dto(e.f1, e.f2)`
- `LEFT JOIN FETCH` to prevent N+1 when associations needed in result
- `@Modifying` + `@Query` for bulk updates/deletes
- Named parameters always: `:paramName` — never positional `?1`
- Never load all entities then filter or count in Java — push constraints to the query

---

## Transaction Management

**Placement**:
- Annotate **service implementations** — never interfaces
- Never bypass service layer to call repository from controller
- Read-only operations: mark `readOnly = true` for performance hints

**Boundaries**:
- One transaction per service method (default)
- Avoid long-running transactions — chunk batch operations
- `REQUIRES_NEW` only when an operation must succeed independently of its caller

---

## JPQL Best Practices

- Prefer JPQL over native SQL unless the query cannot be expressed in JPQL
- DTO projections: `SELECT NEW full.package.Dto(e.field1, e.field2)` — must match constructor exactly
- Pagination: always paginate any query that can return unbounded rows
- Count queries: `SELECT COUNT(e)` — never load entities to count
- JOIN FETCH: use when a lazy association will be accessed on every result item
- `@Modifying`: required for all UPDATE and DELETE JPQL queries

---

## Optimistic Locking

- `@Version` field on every mutable entity (Long)
- Update operations must receive the version field from the preceding read (in request DTO)
- Let the ORM throw `OptimisticLockException` — never compare versions manually
- Surface as a recoverable user error: "data was changed by another user — please reload"

---

## N+1 Query Prevention

**Signs of N+1**:
- Log shows 1 query for list + N queries for each item's association
- Loading a list, then accessing a lazy field on each element in Java

**Fixes**:
- Use `LEFT JOIN FETCH` for associations accessed on every result item
- Use DTO projections (`SELECT NEW`) to avoid loading associations entirely
- Never call `.size()` on a lazy collection — use a count query instead

---

## Pagination Pattern

- Always paginate any query that can return an unbounded number of rows
- Construct page request with page number, size, and sort order
- Map `Page<Entity>` → `Page<Dto>` in the service layer before returning
- Return total count along with the page data to enable client-side pagination UI

---

## Integration Testing for Persistence

- Use the project's custom test annotation (`@IntegrationTest` or equivalent)
- Verify persistence with a fresh load after save — don't just check no exception thrown
- Use in-memory database for tests — confirm DDL compatibility in test setup
- `@Transactional` on test class for automatic rollback

