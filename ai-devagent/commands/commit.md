# Prompt: Commit — Generic Workflow

**Purpose**: Prepare a well-structured commit message for the current changes.

---

## Context Loading

```
1. active-context.md            → story number, story title, phase
2. git diff (changed files)     → understand scope of changes
3. git-workflow skill           → commit message format
```

**Minimum context — this is a low-cost task.**

---

## Skills to Load

- `${CLAUDE_PLUGIN_ROOT}/skills/git-workflow/SKILL.md` — commit format, branch naming, pre-commit checklist

---

## Process

### Step 1 — Analyze Changes
- Read current diff: `git --no-pager diff --name-only`
- Identify affected classes and modules
- Summarize what changed and why

### Step 2 — Prepare Commit Message

**Format**:
```
{TYPE}({scope}): {summary}

{STORY-NUMBER} — {Story Title}

{Body: what changed and why — omit if obvious}
```

**Commit types**:
| Type | When |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring without behavior change |
| `test` | Adding or fixing tests |
| `docs` | Documentation only |
| `chore` | Build, config, dependency updates |
| `perf` | Performance improvement |

**Rules**:
- Summary: imperative mood, max 72 characters, no period at end
- Include story number if working on a tracked story (check project memory for format)
- Body: wrap at 72 characters, blank line after summary
- Never include: stack traces, internal IDs, passwords, PII
- **Do not execute the commit** — only prepare the message

### Step 3 — Pre-Commit Checklist
- [ ] Only files in affected modules are staged
- [ ] No debugging artifacts (console output, System.out.println, TODO without ticket)
- [ ] No sensitive data (passwords, tokens, personal info)
- [ ] Tests pass locally (or CI will run them)
- [ ] Commit message includes ticket/story reference
- [ ] Branch name follows project convention

### Step 4 — Check Documentation
- Analyze whether the project's `specific-project-details.md` needs updating
- Propose an update if a new module or significant pattern was added
- Minor features do not require an update

---

## Memory Update After Commit

If story is complete:
- Update `active-context.md` → move to "Recent Work", clear "Active Project"
- Update `project-registry.md` if new context docs were created
