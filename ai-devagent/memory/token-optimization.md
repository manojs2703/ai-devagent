# Token Optimization

**Purpose**: Rules for minimizing token usage while maximizing knowledge reuse.

---

## Core Principle

> Source code is the most expensive context.
> Memory is the cheapest context.
> Prefer memory over source code at all times.

---

## Token Cost Reference

| Operation | Approximate Tokens |
|-----------|-------------------|
| Read `00-entrypoint.md` | ~400 |
| Read `active-context.md` | ~300 |
| Read one knowledge file | ~600-800 |
| Read one project memory file | ~500-1,000 |
| Read all knowledge files | ~5,000-6,000 |
| Read a small source file | ~500-1,500 |
| Read a large source file | ~1,500-4,000 |
| Read all project memory | ~5,000-8,000 |
| Broad repository scan | ~10,000+ |

---

## Optimization Strategies

### Strategy 1 — Load Only What the Task Needs

```
/analyse → active-context + registry + project details + 2-3 module files
/plan    → active-context + patterns + templates + 1 skill + 1 source
/implement → template + skill + 1-2 source reference files
/test    → testing knowledge + test skill + class under test only
/commit  → active-context only
/review  → git diff + relevant skill files
```

Never load all memory files for a task that only needs two.

### Strategy 2 — Exhaust Memory Before Reading Source

Before reading any source file, verify:
1. Is the answer in `active-context.md`? → Use that
2. Is the answer in project memory? → Use that
3. Is the answer in AI DevAgent knowledge? → Use that
4. Only then → read source code (targeted file, not broad scan)

### Strategy 3 — Cache Discovered Knowledge

When source code is read:
- Extract the reusable pattern into project memory
- Next session: read memory, not source code again

When an analysis is done:
- Save to `{project}/.github/story-analyses/`
- Next session: read the analysis file, not the Jira story again

### Strategy 4 — Targeted Source Reads

When source code is unavoidable:
- Read ONE specific file, not a directory
- Read for a specific purpose (find the base class, find the annotation)
- Read the smallest file that contains the needed information
- Stop after finding the answer — do not continue reading

### Strategy 5 — Never Scan

Never use:
- Recursive grep across all files
- List all files in a module directory
- Read all tests to understand test patterns

Instead:
- Use stored patterns and templates
- Use project memory for structure
- Use targeted search with specific file path pattern

---

## Warning Signs (Too Many Tokens)

| Sign | Action |
|------|--------|
| Reading 5+ source files for a single task | Stop — check memory first |
| Loading all skill files at start | Load selectively — 1-2 per task |
| Grep across entire project | Use project memory patterns instead |
| Re-analyzing a class already analyzed | Check story-analyses directory |
| Repeated reads of the same file | Extract to memory, stop re-reading |

