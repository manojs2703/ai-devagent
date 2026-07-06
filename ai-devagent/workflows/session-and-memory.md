# Session & Memory Lifecycle

**Purpose**: Defines how the two-layer memory system is organized, what every session does with it at startup, and how to bootstrap memory for a project that doesn't have any yet.

**Contents**: [Memory Hierarchy](#memory-hierarchy) · [Session Startup](#session-startup) · [Project Discovery](#project-discovery-bootstrapping-a-new-project)

---

## Memory Hierarchy

### The Two Layers

```
Layer 1: ai-devagent/              ← AI Operating System (generic, portable)
Layer 2: .github/ai-memory/        ← Project Memory (this repository only)
```

These layers are complementary, not duplicative.
Layer 2 always overrides Layer 1 when they conflict.

### Retrieval Order (Mandatory)

```
Active Context
    ↓
Project Memory
    ↓
AI DevAgent Knowledge
    ↓
Source Code
```

Never reverse this order. Never skip layers without exhausting the previous one.

### Priority Rules

| Situation | Rule |
|-----------|------|
| Project convention conflicts with generic knowledge | Project convention wins |
| Project pattern conflicts with generic pattern | Project pattern wins |
| Project annotation differs from generic annotation | Use project annotation |
| No project memory on a topic | Fall back to AI DevAgent knowledge |
| AI DevAgent knowledge has no answer | Read source code (targeted) |

### Layer 1: AI DevAgent (Generic Knowledge)

**What it contains**:
- How to think (retrieval strategy, session startup)
- How to execute tasks (workflow files)
- How to govern memory (classification, maintenance)
- Generic engineering principles (patterns, Java, testing, security)

**What it does NOT contain**:
- Project names, business domains, company names
- Technology choices specific to a project
- Module names, class names, package structures
- Jira conventions, branch naming for a specific team

**Portability**: Can be used unchanged in any repository.

### Layer 2: Project Memory (Project-Specific Knowledge)

**What it contains**:
- This project's architecture and module structure
- This project's coding conventions and base classes
- This project's domain concepts and terminology
- This project's patterns (concrete implementations)
- This project's templates (ready-to-use code structures)
- Current active context (story, phase, decisions)

**What it does NOT contain**:
- Generic engineering principles
- Framework documentation
- Anything true for any Java project

**Scope**: This repository only.

### Conflict Resolution Examples

| Topic | Generic Knowledge | Project Knowledge | Use |
|-------|-----------------|------------------|-----|
| Transaction annotation | `@Transactional` | `@TransactionalMandatory` | Project |
| Repository base | `JpaRepository<E, Long>` | `ProjectRepository<E, Long>` | Project |
| Test annotation | `@ExtendWith(MockitoExtension)` | `@UnitTest` | Project |
| Null safety | `@NonNull` | `@NonNull` | Same — either |
| Error response | Generic structure | Project's error structure | Project |

### Memory Scope Diagram

```
┌──────────────────────────────────────────────────────────┐
│ ai-devagent/                                             │
│  Generic AI operating model — portable across any repo   │
│  • How to work     • Generic patterns                    │
│  • When to load    • Generic testing                     │
│  • Token strategy  • Generic security                    │
└──────────────────────────────────────────────────────────┘
                          ↑ overridden by
┌──────────────────────────────────────────────────────────┐
│ .github/ai-memory/                                       │
│  Project-specific memory — this repository only          │
│  • What this project is  • Project patterns              │
│  • How this project works • Project templates             │
│  • Current work state    • Project domain                │
└──────────────────────────────────────────────────────────┘
```

---

## Session Startup

**Startup sequence**: Follow the Session Startup Sequence in `ai-devagent/00-entrypoint.md` step by step. The sections below cover what that sequence doesn't: how to route a task to the right memory files, how to resume existing work, what never to do, and how to close out a session.

### Task-to-Memory Routing

| Task type | Load from project memory |
|-----------|--------------------------|
| New story analysis | `p02-project-registry.md` + project context file |
| Implementation | `p04-pattern-library.md` + `p05-template-library.md` |
| Architecture decision | `p01-workspace-architecture.md` + `p04-pattern-library.md` |
| Testing | `p04-pattern-library.md` (for test annotations) |
| Commit / release | `p07-active-context.md` only |
| Review | No project memory needed — diff is the input |

### Continuation (Existing Work)

If `active-context.md` shows an active story:
1. Read the story's analysis file from `{project}/.github/story-analyses/`
2. Resume from the documented `Next action`
3. Skip re-analysis — use stored analysis

### What Never to Do at Startup

- Do NOT scan the repository structure broadly
- Do NOT read pom.xml or build files for orientation
- Do NOT read multiple source files without a specific target
- Do NOT load all project memory files at once

### Session End Checklist

Before ending every session that made meaningful progress:

- [ ] Updated `active-context.md` with current state
- [ ] Documented architectural decisions made
- [ ] Added new patterns to `p04-pattern-library.md` (if discovered)
- [ ] Added new templates to `p05-template-library.md` (if applicable)
- [ ] Cleared completed tasks from open tasks list

---

## Project Discovery (Bootstrapping a New Project)

**When to use**: First time working in a repository that has no `.github/ai-memory/` yet.

The AI should NEVER start by scanning the repository.
Use this structured discovery sequence to build project memory efficiently.

### Phase 1 — Repository Structure (Minimal Scan)

Read only:
1. Root directory listing (one level deep)
2. Root `pom.xml` or `build.gradle` — module list only
3. `README.md` if present — purpose and tech stack

**Output**: Identify project type (single-module / multi-module, tech stack, deployment model).

### Phase 2 — Module Discovery (Targeted)

For each top-level module identified in Phase 1:
1. Read the module's `pom.xml` — name, dependencies, parent
2. Infer module role from name and dependencies (client / server / commons / database)

**Do NOT read source files yet.**

**Output**: Module responsibility map.

### Phase 3 — Technology Stack Identification

From the pom.xml files, identify:
- Spring Boot vs Classic Spring (WAR vs JAR, Spring Boot parent)
- JPA provider (Hibernate, EclipseLink)
- Testing framework (JUnit 5, Mockito, AssertJ)
- Internal frameworks (custom parent POMs, proprietary libraries)
- Database type (Oracle, PostgreSQL, H2)
- Messaging (JMS, Kafka, SQS, none)

**Output**: Technology decisions table.

### Phase 4 — Convention Discovery (Targeted Source Read)

Read ONE example of each:
- An entity class → naming, base classes, ID strategy, annotations
- A repository interface → base interface, transaction annotations
- A service implementation → framework annotations, patterns
- A controller/facade → communication protocol, DTO usage

**Read 4 files maximum — infer conventions from examples.**

**Output**: Coding conventions and patterns.

### Phase 5 — Build Project Memory Index

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

### Phase 6 — Validation

Verify the memory is sufficient by answering these questions from memory alone:
1. What is this project's purpose?
2. Where does business logic live?
3. How are entities structured?
4. How are tests organized?
5. What is the module that should be modified for feature X?

If any answer requires reading source code → expand the relevant memory file.

### Discovery Anti-Patterns

| Anti-Pattern | Why it's wrong |
|-------------|---------------|
| Reading all source files first | Expensive — memory is always cheaper |
| Running grep across entire codebase | Broad scans waste tokens |
| Skipping pom.xml analysis | Module roles are fastest read from pom.xml |
| Creating memory with project-specific patterns only | Generic knowledge belongs in ai-devagent |
