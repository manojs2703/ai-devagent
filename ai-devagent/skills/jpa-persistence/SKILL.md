# Skill: JPA Persistence
## When to Apply This Skill
Load this skill when working with JPA entities, repositories, transactions, or JPQL queries.
**Project override**: Check project memory for the base entity class, repository base interface, and transaction annotations — they vary by project.
---
## Entity Design Rules
- Every entity must be annotated with `@Entity` and `@Table(name = "TABLE_NAME")`
- Table and column names use UPPER_SNAKE_CASE
- Every entity needs a protected or public no-arg constructor for JPA
- Business constructors set all required (non-nullable) fields
- Never add `@Data` from Lombok to entities -- it generates unsafe equals/hashCode based on all fields including lazy associations
- Use `@Version` for optimistic locking on a `Long` field named `version` (or project-specific name)
- Initialize collection fields inline (`= new ArrayList<>()` or `= new HashSet<>()`) to avoid NPEs
### ID Strategy
**Before adding `@Id` to any entity**, check whether the project uses a base entity class:
- If a base entity class exists, it already provides `id` and version. Do NOT add your own `@Id` or `@Version`.
- In standalone Spring Data JPA projects: use `@GeneratedValue(strategy = GenerationType.SEQUENCE)` with a named sequence generator per table
- Look at existing entities in the same module's model package to confirm the strategy used before creating a new entity
### Column Naming Conventions
| Element | Convention | Example |
|---------|-----------|---------|
| Table | UPPER_SNAKE_CASE | `PRODUCT`, `ORDER_LINE` |
| Column | UPPER_SNAKE_CASE | `PRODUCT_NAME`, `UNIT_PRICE` |
| Primary Key | `ID` | `ID` |
| Foreign Key | `{REFERENCED_TABLE}_ID` | `CATEGORY_ID` |
| Unique constraint | `UC_{TABLE}_{COLUMN}` | `UC_PRODUCT_SKU` |
| Index | `IDX_{TABLE}_{COLUMN}` | `IDX_PRODUCT_CATEGORY_ID` |
| Sequence | `SEQ_{TABLE}_ID` | `SEQ_PRODUCT_ID` |
---
## Associations
- Use `FetchType.LAZY` for all `@ManyToOne` and `@OneToMany` associations -- never eager unless profiled as necessary
- Define bidirectional relationship management methods on the owning side (e.g., `addChild()` / `removeChild()`)
- Use `cascade = CascadeType.ALL` with `orphanRemoval = true` only on true ownership relationships
- Avoid cascading across aggregate boundaries -- each aggregate root manages its own lifecycle
---
## Repository Pattern
- Repositories are interfaces, never classes
- Extend the appropriate base (check project memory for the project-specific base)
- Use JPQL constructor expressions (`SELECT NEW fully.qualified.DtoClass(...)`) for read-only projections
- Use `LEFT JOIN FETCH` in JPQL to prevent N+1 when associations are needed in the result
- Use `@Modifying` + `@Query` for bulk updates or deletes
- Always use named parameters (`:paramName` with `@Param`) -- never positional parameters (`?1`)
### Before Creating a New Repository
- Check the module's repository package for existing repositories
- Adopt the exact same base interface, annotation, and query style as existing repositories in that module
---
## Transactions
- Annotate service implementation classes (not interfaces) with the transaction annotation
- Mark read-only service methods as `readOnly` where the framework supports it
- **Project override**: Check project memory for the exact transaction annotation to use — do NOT default to Spring `@Transactional` without confirming
---
## JPQL Best Practices
- Always use JPQL over native SQL unless the query cannot be expressed in JPQL
- Use DTO projections with `SELECT NEW` for read-only queries
- Use `JOIN FETCH` when the caller will access a lazy association on every result item
- Use `@Modifying` for updates and deletes
- Never call `findAll()` and then filter or count in Java
- Avoid calling `size()` on a loaded collection to count -- use a count query instead
---
## Optimistic Locking
- The version field must be included in every DTO used for update operations
- On update, read the entity from the repository, apply changes, and rely on JPA to check the version on flush
- Never manually compare versions -- let JPA throw `OptimisticLockException`
---
## Pagination
- Always paginate any query that can return an unbounded number of rows
- Use `PageRequest.of(page, size, Sort.by(...))` to construct a `Pageable`
- Map the `Page<Entity>` result to `Page<Dto>` in the service layer
---
## Integration Tests
- Use the project's custom test annotation rather than plain `@DataJpaTest`
- Check the project's test module for the correct base annotation before writing any integration test
- Follow Given-When-Then structure; see `testing-guidelines.md` for test conventions

