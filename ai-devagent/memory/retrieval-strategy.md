# Retrieval Strategy

**Purpose**: When and how to retrieve knowledge during an AI session.
**Goal**: Maximum reuse of stored knowledge, minimum source code reads.

---

## Retrieval Hierarchy (Always Follow This Order)

```
Tier 1 — Active Context              (fastest, load first every session)
  └─ .github/ai-memory/project/active-context.md

Tier 2 — Project Memory              (project-specific, load for all project tasks)
  └─ .github/ai-memory/project/*.md
  └─ {project}/.github/workflow/specific-project-details.md
  └─ {project}/.github/workflow/modules/{module}.md

Tier 3 — AI DevAgent Knowledge       (generic principles, when project memory is silent)
  └─ ai-devagent/knowledge/*.md
  └─ ai-devagent/memory/*.md

Tier 4 — Source Code                 (last resort — targeted reads only)
  └─ One or two specific files — never broad scans
```

**Rule**: Project Memory ALWAYS overrides AI DevAgent. Load project memory before AI DevAgent.
Never read source code when project memory or AI DevAgent already answers the question.

---

## Decision Flowchart

```
Question or task arrived?
│
├─ Is there an active story?
│    Yes → active-context.md (resume from last state)
│
├─ Architecture / pattern question?
│    Check project memory (p04) first → then ai-devagent/knowledge/architecture-patterns.md
│
├─ Java code question?
│    Check project skill file first → then ai-devagent/knowledge/java-engineering.md
│
├─ Test structure question?
│    Check project test skill → then ai-devagent/knowledge/testing-strategies.md
│
├─ Module/package question?
│    Check project memory (p01, p02, project context file)
│    Source code only if project memory doesn't answer
│
└─ None of the above?
     Source code → one specific targeted file
```

---

## Task-to-Memory Routing

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

---

## What NOT to Load

| Avoid | Reason |
|-------|--------|
| All project memory files at once | Load only what the current task needs |
| All AI DevAgent knowledge files | Selective retrieval only |
| Multiple source files at once | One targeted read at a time |
| Repository-wide file scans | Always targeted by specific path |
| ai-devagent knowledge when project memory answers | Redundant — project memory is sufficient |
| Source code when memory answers | Source code is expensive |

---

## Finding Reference Implementations

Priority order for finding an existing example:
1. Check `p05-template-library.md` — pre-built template?
2. Check `p04-pattern-library.md` — documented pattern with reference class?
3. If still needed:
   - Entity → search `**/model/*.java` in the project module
   - Repository → search `**/repository/*.java`
   - Service impl → search `**/service/*Impl.java`
   - Controller → search `**/controller/*.java`

**Read at most 2 reference files before proceeding.**

---

## Token Budget Per Task Type

| Task | Target Budget | Key Sources |
|------|--------------|-------------|
| /analyse | 3,000-5,000 | Active context + registry + project details + modules |
| /plan | 3,000-5,000 | Active context + patterns + 1 AI knowledge file + 2 skills + 1 source |
| /implement | 4,000-8,000 | Template + skill + 1-2 source files |
| /test | 2,000-4,000 | AI testing knowledge + test skill + class under test |
| /commit | 1,000-2,000 | Active context + git skill |
| /review | 3,000-6,000 | Diff + relevant skill files |

---

## Retrieval Anti-Patterns

| Anti-Pattern | Correct Approach |
|-------------|-----------------|
| Reading pom.xml for orientation | Check project registry (p02) |
| Scanning entire src/ tree | Use pattern library to find exact path |
| Loading all skill files | Load 1-2 relevant to current task |
| Re-reading a class already in memory | Use the stored knowledge |
| Reading an entity to find its fields | Check template library |

