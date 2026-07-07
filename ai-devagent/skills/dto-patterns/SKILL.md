---
name: dto-patterns
description: Load when creating DTOs, defining service interfaces, or implementing data transfer between layers.
---

# Skill: DTO and Service Interface Patterns
## When to Apply This Skill
Load this skill when creating DTOs, defining service interfaces, or implementing data transfer between layers.
**Project override**: Check project memory for the exact DTO package structure and serialization conventions.
---
## DTO Design -- Records vs Classes
- Use Records for all NEW DTOs -- they are immutable, concise, and eliminate boilerplate
- Keep existing DTOs as classes when they implement `Serializable` or `Comparable` -- do not migrate without an explicit task
- When an existing legacy DTO needs a JPQL projection constructor, add a dedicated constructor that matches the SELECT NEW expression exactly (parameter count and types)
- Do NOT add `@Builder` or Lombok annotations to DTOs that are already Records -- Records have canonical constructors
---
## DTO Location
- DTOs live in the commons/API module -- check project memory for the exact package path
- DTOs must be serializable-compatible (Records are implicitly compatible; legacy class DTOs implement `Serializable`)
- Check the existing DTO package in the commons module before creating a new DTO to find similar patterns and naming
---
## DTO Content Rules
- Read/response DTOs carry `id` and version field for optimistic locking
- Create request DTOs do NOT carry `id` or version -- the entity is new
- Update request DTOs MUST carry `id` and version -- required for optimistic locking
- DTOs must never contain JPA entity references -- use primitive types, other DTOs, or ID/name pairs instead
- Use a lightweight reference DTO (ID + name) when referencing an associated entity by display label only
---
## JPQL DTO Projection
- Use JPQL constructor expressions (`SELECT NEW full.package.DtoClass(...)`) for all read-only queries
- The JPQL constructor must match an existing DTO constructor exactly: same parameter count and compatible types
- Never load a full entity graph and then map to a DTO in a loop -- this performs unnecessary DB work
---
## Service Interface Pattern
- Service interfaces live in the commons module
- Every public method must have Javadoc with `@param`, `@return`, and `@throws` for each declared exception
- Interfaces declare what the service does; they do not declare transaction annotations
- Implementations in the server module (app-server or job-server) are the only Spring beans
---
## Request DTO Separation
- Always create separate request DTOs for create and update operations -- never reuse the response DTO for input
- Create request: no `id`, no version
- Update request: mandatory `id` and version
- Use Bean Validation annotations on request DTO fields (`@NotNull`, `@NotBlank`, `@Size`, etc.)
---
## Layer Separation Rules
| Layer | Data Contract |
|-------|--------------|
| Controller / remoting bean | Receives and returns DTOs only |
| Service interface | Declares methods with DTO parameters and DTO return types |
| Service implementation | Uses entities internally; returns DTOs |
| Repository | Works with entities; may return DTO projections via JPQL |
| Client | DTOs only -- never depends on entity classes |
---
## Mapper Pattern
- For simple cases, use a private static `toDto(Entity e)` method in the service implementation
- For complex cases with many associations, create a dedicated `{Entity}Mapper` utility class with a private constructor
- Never use MapStruct or ModelMapper unless already present in the project -- check the project's dependencies first
- Mappers must never call the repository directly; they receive entities and return DTOs
---
## ID Reference DTOs
- When referencing an associated entity by ID and display name only, create a lightweight reference record
- This avoids deep object graphs in the response DTOs and reduces data transferred over remoting

