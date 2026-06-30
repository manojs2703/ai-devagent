# Project Discovery Workflow

**Purpose**: Initialize project memory for a repository that has no `.github/ai-memory/` yet.
**When to use**: First time working in a new or unfamiliar repository.

---

## Discovery Protocol

The AI should NEVER start by scanning the repository.
Use this structured discovery sequence to build project memory efficiently.

---

## Phase 1 — Repository Structure (Minimal Scan)

Read only:
1. Root directory listing (one level deep)
2. Root `pom.xml` or `build.gradle` — module list only
3. `README.md` if present — purpose and tech stack

**Output**: Identify project type (single-module / multi-module, tech stack, deployment model).

---

## Phase 2 — Module Discovery (Targeted)

For each top-level module identified in Phase 1:
1. Read the module's `pom.xml` — name, dependencies, parent
2. Infer module role from name and dependencies (client / server / commons / database)

**Do NOT read source files yet.**

**Output**: Module responsibility map.

---

## Phase 3 — Technology Stack Identification

From the pom.xml files, identify:
- Spring Boot vs Classic Spring (WAR vs JAR, Spring Boot parent)
- JPA provider (Hibernate, EclipseLink)
- Testing framework (JUnit 5, Mockito, AssertJ)
- Internal frameworks (custom parent POMs, proprietary libraries)
- Database type (Oracle, PostgreSQL, H2)
- Messaging (JMS, Kafka, SQS, none)

**Output**: Technology decisions table.

---

## Phase 4 — Convention Discovery (Targeted Source Read)

Read ONE example of each:
- An entity class → naming, base classes, ID strategy, annotations
- A repository interface → base interface, transaction annotations
- A service implementation → framework annotations, patterns
- A controller/facade → communication protocol, DTO usage

**Read 4 files maximum — infer conventions from examples.**

**Output**: Coding conventions and patterns.

---

## Phase 5 — Build Project Memory Index

Create the following files:

```
.github/ai-memory/
├── 00-index.md               ← Index with routing decisions
└── project/
    ├── active-context.md     ← Current state (new project — empty template)
    ├── workspace-architecture.md ← Projects, tech stack, deployment
    ├── project-registry.md   ← Module list with status
    ├── domain-concepts.md    ← Domain terms discovered
    ├── pattern-library.md    ← Patterns discovered in Phase 4
    ├── template-library.md   ← Templates derived from examples
    ├── retrieval-strategy.md ← Retrieval paths for this project
    └── maintenance-rules.md  ← When/how to update this memory
```

---

## Phase 6 — Validation

Verify the memory is sufficient by answering these questions from memory alone:
1. What is this project's purpose?
2. Where does business logic live?
3. How are entities structured?
4. How are tests organized?
5. What is the module that should be modified for feature X?

If any answer requires reading source code → expand the relevant memory file.

---

## Discovery Anti-Patterns

| Anti-Pattern | Why it's wrong |
|-------------|---------------|
| Reading all source files first | Expensive — memory is always cheaper |
| Running grep across entire codebase | Broad scans waste tokens |
| Skipping pom.xml analysis | Module roles are fastest read from pom.xml |
| Creating memory with project-specific patterns only | Generic knowledge belongs in ai-devagent |

