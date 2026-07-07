---
name: maven-build
description: Load when running builds, adding dependencies, or working with Maven configuration.
---

# Skill: Maven Multi-Module Build
## When to Apply This Skill
Load this skill when running builds, adding dependencies, or working with Maven configuration.
**Project override**: Check project memory for the BOM hierarchy and EPL/VW-specific BOM imports.
---
## Build Commands
- Always run Maven from the project root directory (where the parent pom.xml is located)
- Use `mvn clean install -DskipTests` for a fast build check without running tests
- Use `mvn clean install` for a full build including tests
- Use `mvn clean install -pl {module-name} -am` to build a specific module and all its upstream dependencies
- Use `mvn clean test -pl {module-name} -Dtest={TestClassName}` to run a single test class
- Use `mvn dependency:tree` to inspect the dependency tree
- Always use `--no-pager` equivalent where relevant; Maven output goes to stdout without paging
---
## Standard Module Structure
- Parent POM: declares all modules, manages dependency versions via `<dependencyManagement>`
- `{prefix}-commons`: shared interfaces, DTOs, enums, constants -- no Spring dependencies
- `{prefix}-server-commons`: JPA entities, repositories, shared server services
- `{prefix}-app-server`: service implementations, remoting controllers, WAR packaging
- `{prefix}-job-server`: batch jobs, JMS listeners, scheduled tasks
- `{prefix}-client`: JavaFX client, FXML controllers -- no server dependencies
- `{prefix}-database`: DDL scripts, migration artifacts (no Java code)
- `{prefix}-doc`: documentation, templates (no Java code)
---
## Dependency Management Rules
- Never specify versions directly for BOM-managed artifacts -- always rely on BOM imports in the parent POM
- Never add a BOM import to a module POM; BOMs belong in the parent `<dependencyManagement>` only
- Declare direct dependencies (without version) in each module POM
- Use `<scope>provided</scope>` for container-provided libraries (Servlet API, JPA provider)
- Use `<scope>test</scope>` for test-only dependencies (JUnit, Mockito, AssertJ)
- **Project override**: Check project memory (`specific-libraries.md`) before adding a new dependency
---
## Module Dependency Rules
- Client modules must NOT depend on server modules -- they depend only on commons
- Server modules may depend on server-commons and commons
- App-server and job-server must NOT depend on each other -- share logic through server-commons
- Commons modules must NOT contain Spring annotations -- they are framework-independent contracts
---
## Adding a New Module
- Add the module to the parent POM `<modules>` section
- Create the module POM with the correct `<parent>` reference and `<artifactId>`
- Declare only the dependencies the module directly uses
- Follow the naming convention `{prefix}-{purpose}` (e.g., `ps-server-commons`, `an-client`)

