# Session Startup Workflow

**Purpose**: Initialize every AI session efficiently — no wasted tokens, no repository scanning.

---

## Mandatory Startup Sequence

```
1. Read ai-devagent/00-entrypoint.md
      ↓
2. Read .github/ai-memory/00-index.md
      ↓
3. Read .github/ai-memory/project/active-context.md
      ↓
4. Identify the task (from user or active context)
      ↓
5. Load only relevant project memory (based on task type)
      ↓
6. Load ai-devagent knowledge only if project memory is silent
      ↓
7. Read source code only if all above are insufficient
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

---

## Continuation (Existing Work)

If `active-context.md` shows an active story:
1. Read the story's analysis file from `{project}/.github/story-analyses/`
2. Resume from the documented `Next action`
3. Skip re-analysis — use stored analysis

---

## What Never to Do at Startup

- Do NOT scan the repository structure broadly
- Do NOT read pom.xml or build files for orientation
- Do NOT read multiple source files without a specific target
- Do NOT load all project memory files at once

---

## Session End Checklist

Before ending every session that made meaningful progress:

- [ ] Updated `active-context.md` with current state
- [ ] Documented architectural decisions made
- [ ] Added new patterns to `p04-pattern-library.md` (if discovered)
- [ ] Added new templates to `p05-template-library.md` (if applicable)
- [ ] Cleared completed tasks from open tasks list

