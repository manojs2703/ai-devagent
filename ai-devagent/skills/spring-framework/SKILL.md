---
name: spring-framework
description: Load when creating or modifying Spring services, components, configuration, or controllers.
---

# Skill: Spring Framework
## When to Apply This Skill
Load this skill when creating or modifying Spring services, components, configuration, or controllers.
**Project override**: Check project memory for the Spring version (classic WAR vs Spring Boot) and the correct transaction/exception annotations.
---
## Dependency Injection
- Use constructor injection for all new Spring components -- it enforces immutability and simplifies testing
- Use `@RequiredArgsConstructor` with `final` fields as a Lombok shorthand for constructor injection
- Use `@Autowired` on the constructor (or omit it when only one constructor exists -- Spring injects automatically)
- Field injection (`@Autowired` on fields) is acceptable only in existing legacy code; avoid it in new code
- Use `@NonNull` on injected final fields to guard against null at construction time
---
## Service Layer
- Define service interfaces in the commons/API module -- the client and other callers depend only on interfaces
- Place service implementations in the server module (app-server or job-server)
- Annotate implementation classes (not interfaces) with the transaction annotation
- Each service method should have a single, clear responsibility
- Services must not call other services in the same layer; extract shared logic to a server-commons service
- **Project override**: Check project memory for the correct transaction annotation — it may differ from standard `@Transactional`
---
## Controllers / Remoting
- The controller delegates all logic to an injected service -- no business logic in controllers
- **Project override**: Check project memory for the communication protocol (REST vs RMI remoting)
---
## REST Controllers (Spring Boot)
- Annotate with `@RestController` and `@RequestMapping` at class level
- Use `@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping` for individual methods
- Return `ResponseEntity<Dto>` to control HTTP status codes explicitly
- Never put business logic in a REST controller -- delegate to the service layer
- Use `@Valid` on `@RequestBody` parameters to trigger Bean Validation
- Handle exceptions with a `@RestControllerAdvice` class, not inside controllers
---
## Spring Configuration
- Never hardcode environment-specific values -- always inject via `@Value("${property.key}")` or `@ConfigurationProperties`
- Use `@Profile` for environment-specific beans
- **Project override**: Check project memory for whether the project uses XML config or Java config
---
## Exception Handling
- Use specific exception classes per error case -- never throw generic `RuntimeException` from a service
- **Project override**: Check project memory for the project-specific exception base classes
- Checked exceptions: use only when the caller can realistically recover from the error
---
## Common Anti-Patterns
- Never put business logic in a controller or remoting bean -- move it to the service
- Never annotate a service interface method with a transaction annotation -- annotate the implementation
- Never allow service A to `@Autowired` service B from the same application layer -- extract shared logic
- Never bypass the service layer by calling a repository directly from a controller

