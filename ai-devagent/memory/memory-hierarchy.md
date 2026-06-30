# Memory Hierarchy

**Purpose**: Defines the priority rules for the two-layer memory system.

---

## The Two Layers

```
Layer 1: ai-devagent/              ← AI Operating System (generic, portable)
Layer 2: .github/ai-memory/        ← Project Memory (this repository only)
```

These layers are complementary, not duplicative.
Layer 2 always overrides Layer 1 when they conflict.

---

## Retrieval Order (Mandatory)

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

---

## Priority Rules

| Situation | Rule |
|-----------|------|
| Project convention conflicts with generic knowledge | Project convention wins |
| Project pattern conflicts with generic pattern | Project pattern wins |
| Project annotation differs from generic annotation | Use project annotation |
| No project memory on a topic | Fall back to AI DevAgent knowledge |
| AI DevAgent knowledge has no answer | Read source code (targeted) |

---

## Layer 1: AI DevAgent (Generic Knowledge)

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

---

## Layer 2: Project Memory (Project-Specific Knowledge)

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

---

## Conflict Resolution Examples

| Topic | Generic Knowledge | Project Knowledge | Use |
|-------|-----------------|------------------|-----|
| Transaction annotation | `@Transactional` | `@TransactionalMandatory` | Project |
| Repository base | `JpaRepository<E, Long>` | `ProjectRepository<E, Long>` | Project |
| Test annotation | `@ExtendWith(MockitoExtension)` | `@UnitTest` | Project |
| Null safety | `@NonNull` | `@NonNull` | Same — either |
| Error response | Generic structure | Project's `Meldungsart` | Project |

---

## Memory Scope Diagram

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
│  • How this project works • Project templates            │
│  • Current work state    • Project domain                │
└──────────────────────────────────────────────────────────┘
```

