# Engineering Skillset Index

**Layer**: AI DevAgent (generic, portable)
**Purpose**: Engineering capability map. Routes to the right knowledge area for any task.
**Project override**: Project memory maintains project-specific skill files and technology references.

---

## How to Use

1. Identify the capability needed for the current task
2. Find the relevant AI DevAgent knowledge file
3. Check project memory for the project-specific implementation of that capability

---

## Backend Development

**Scope**: Service design, domain modeling, data persistence, transaction management, background jobs

**AI DevAgent knowledge**:
- Architecture and design patterns → `architecture-patterns.md`
- Java 21, OOP, naming, Lombok → `java-engineering.md`
- Data persistence, ORM, queries → `data-access-patterns.md`
- API design, service contracts → `api-error-handling.md`

**Project memory**: Check for framework-specific patterns (custom base classes, transaction annotations, repository base interfaces)

---

## Testing

**Scope**: Unit tests, integration tests, mocking, parameterized tests, test data

**AI DevAgent knowledge**:
- Test pyramid, GWT, naming, Mockito → `testing-strategies.md`

**Project memory**: Check for project-specific test annotations, test utilities, in-memory DB setup

---

## API Design

**Scope**: REST design, request/response modeling, versioning, error codes

**AI DevAgent knowledge**:
- REST principles, DTO separation, HTTP status codes → `api-error-handling.md`

**Project memory**: Check whether this project uses REST, RPC, or messaging, and for project-specific DTO conventions

---

## Data Access

**Scope**: Entity design, repository patterns, query optimization, schema migration

**AI DevAgent knowledge**:
- ORM entity rules, transactions, JPQL, N+1 → `data-access-patterns.md`

**Project memory**: Check for the project's ORM base classes, transaction annotations, column length conventions

---

## Security

**Scope**: Authentication, authorization, input validation, secure defaults

**AI DevAgent knowledge**:
- Defense in depth, authorization pattern, input security → `security-performance.md`

**Project memory**: Check for the authorization framework used (annotation names, permission enum structure)

---

## Performance

**Scope**: Query optimization, caching, pagination, batch operations

**AI DevAgent knowledge**:
- Caching strategies, pagination, N+1, connection pools → `security-performance.md`

**Project memory**: Check for allowed caching technologies and pagination conventions

---

## Messaging / Async Integration

**Scope**: Message queues, event-driven patterns, schema contracts, dead-letter queues

**AI DevAgent knowledge**:
- AP-09 Event-Driven Integration → `architecture-patterns.md`
- AP-08 Background Processing → `architecture-patterns.md`

**Project memory**: Check for the specific messaging technology (JMS, Kafka, SQS) and message schema format

---

## Observability

**Scope**: Logging levels, structured logging, metrics, correlation IDs

**AI DevAgent knowledge**:
- Logging practices, metrics, tracing → `security-performance.md`

**Project memory**: Check for project-specific logger class or MDC conventions

---

## Build and Dependency Management

**Scope**: Multi-module builds, dependency management, BOM usage, CI/CD

**AI DevAgent knowledge**: None (project-specific topic)

**Project memory**: Check for BOM conventions, module structure, build commands

---

## Version Control / Workflow

**Scope**: Branch naming, commit message format, code review conventions

**AI DevAgent knowledge**: None (project-specific topic)

**Project memory**: Check for branch format, issue tracker conventions, commit message structure

