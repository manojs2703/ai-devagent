# Prompt: Propagate — Generic Workflow

**Purpose**: Decompose a task or story into work items, assign responsibility, define execution sequence, and identify blockers.

---

## Process

Follow `ai-devagent/agents/task-propagator.agent.md` for the complete propagation workflow.

### Quick Reference — Propagation Steps

1. **Classify** the input (story / bug / refactoring / performance / review)
2. **Decompose** into work items (What + Who + How + Input + Output + Depends)
3. **Identify blockers** (human decisions, missing info, external dependencies)
4. **Generate propagation plan** with phased execution sequence
5. **Save** the plan to `{project}/.github/story-analyses/propagation-{ID}-{DATE}.md`
6. **Update** `active-context.md` with the propagation result

### Output Format

```markdown
# Task Propagation Plan: {Title}
**Date**: {YYYY-MM-DD}
**Input**: {task/story}

## Execution Sequence
### Phase 1 — Discovery (AI)
### Phase 2 — Planning (AI + Human)
### Phase 3 — Implementation (AI + Developer)
### Phase 4 — Quality (AI)
### Phase 5 — Release (AI + CI/CD)

## Blockers
## Decisions Required
```

