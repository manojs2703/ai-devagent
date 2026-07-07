# AI DevAgent — Entrypoint

**This is the first document read at the start of every AI session.**

**Role**: AI operating system. Defines how the AI thinks, retrieves, and acts.
**Scope**: Generic — reusable across any software repository.
**Project knowledge**: Always in the repository's `.github/ai-memory/` directory.

---

## Session Startup Sequence

Every session MUST follow this sequence — no exceptions:

```
Step 1 → Read this file (you are here)
Step 2 → Read .github/workspace-registry.md          (project index — identify target project)
Step 3 → Read {project}/.github/ai-memory/00-index.md          (project memory index)
Step 4 → Read {project}/.github/ai-memory/project/p07-active-context.md  (current state)
Step 5 → Load relevant project memory files           (based on the task)
Step 6 → Load ai-devagent knowledge files             (only if project memory is silent)
Step 7 → Read source code                             (last resort — targeted reads only)
```

**If no ai-memory exists for the target project**: Run `${CLAUDE_PLUGIN_ROOT}/memory/project-discovery.md` before step 3.

**Never skip to source code. Never scan the repository broadly. Follow the sequence.**

---

## Memory Hierarchy

```
┌─────────────────────────────────────────────────┐
│  Tier 0 — Workspace Registry                    │  ← Load FIRST — identifies target project
│  .github/workspace-registry.md                  │
├─────────────────────────────────────────────────┤
│  Tier 1 — Active Context                        │  ← Load EVERY session
│  {project}/.github/ai-memory/project/           │
│                    active-context.md            │
├─────────────────────────────────────────────────┤
│  Tier 2 — Project Memory                        │  ← Load for project tasks
│  {project}/.github/ai-memory/project/*.md       │
│  {project}/.github/workflow/                    │
├─────────────────────────────────────────────────┤
│  Tier 3 — AI DevAgent Knowledge                 │  ← Load when project memory silent
│  ${CLAUDE_PLUGIN_ROOT}/knowledge/*.md                     │
├─────────────────────────────────────────────────┤
│  Tier 4 — Source Code                           │  ← Last resort — targeted only
│  One or two specific files — never broad scans  │
└─────────────────────────────────────────────────┘
```

**Priority rule**: Lower tiers override higher tiers when they conflict.
Project conventions always override generic recommendations.

For the full priority-rule and conflict-resolution model, see
`memory/classification-rules.md` (Priority Rule section).

---

## Context Loading Strategy

| What to load | When | Why |
|-------------|------|-----|
| `active-context.md` | Every session | Restores current state — no re-analysis |
| Project memory files | Task-specific | Avoid loading all — load only relevant files |
| `${CLAUDE_PLUGIN_ROOT}/knowledge/` | Project memory is silent | Generic fallback only |
| Source code | Specific class needed | Never for orientation |

**Token discipline**: Source code is the most expensive context. Exhaust all memory layers first.

---

## Workflow Commands

Each command is a two-layer system:
- **EPL wrapper** (`.github/prompts/`): YAML frontmatter + EPL context → references the generic workflow
- **Generic workflow** (`${CLAUDE_PLUGIN_ROOT}/commands/`): authoritative step-by-step implementation

| Command | Generic Workflow (authoritative) |
|---------|----------------------------------|
| `/analyse` | `commands/analyse.md` |
| `/plan` | `commands/plan.md` |
| `/implement` | `commands/implement.md` |
| `/test` | `commands/test.md` |
| `/commit` | `commands/commit.md` |
| `/review` | `commands/review.md` |
| `/translate` | `commands/translate.md` |
| `/doall` | `commands/doall.md` |
| `/propagate` | `commands/propagate.md` |

---

## Agents

| Agent | File | Role |
|-------|------|------|
| **Primary Agent** ⭐ | `agents/primary-agent.agent.md` | **Entry point for ALL implementation work** — orchestrates across all projects |
| **Code Optimizer** | `agents/code-optimizer.agent.md` | Called by primary agent for Java optimization analysis |
| **Task Propagator** | `agents/task-propagator.agent.md` | Called by primary agent for task decomposition |

**The Primary Agent is always the first agent activated. All other agents are sub-agents called by it.**
**All agents must read this entrypoint before processing any request.**

---

## Repository Discovery (New Repository)

When working in an unfamiliar repository, run the project discovery workflow:
→ `${CLAUDE_PLUGIN_ROOT}/memory/project-discovery.md`

This workflow initializes the `{project}/.github/ai-memory/` structure without broad repository scans.

---

## Multi-Project Workspace

This AI DevAgent manages multiple projects. The workspace registry is the source of truth:
→ `.github/workspace-registry.md` (generated per-workspace by the installer — see `setup/install.ps1`)

All task routing, project identification, and memory loading starts from the workspace registry.
The **Primary Agent** (`agents/primary-agent.agent.md`) is responsible for this routing.

---

## Knowledge Quick Routing

```
Task type?
│
├─ Architecture / design?        → knowledge/architecture-patterns.md
├─ Java code quality?            → knowledge/java-engineering.md
├─ Database / ORM / queries?     → knowledge/data-access-patterns.md
├─ Writing tests?                → knowledge/testing-strategies.md
├─ API design / error handling?  → knowledge/api-error-handling.md
├─ Security / performance?       → knowledge/security-performance.md
├─ Which knowledge applies?      → knowledge/skillset-index.md
├─ What goes in memory vs code?  → memory/classification-rules.md
└─ Token usage running high?     → memory/token-optimization.md
```

---

## Memory Governance

| Rule | Action |
|------|--------|
| Knowledge is generic | → `${CLAUDE_PLUGIN_ROOT}/knowledge/` |
| Knowledge is project-specific | → `.github/ai-memory/project/` |
| Knowledge is both | → Both (abstract principle + concrete implementation) |
| One-time story analysis | → `{project}/.github/story-analyses/` |
| Session completed | → Update `active-context.md` |

Full rules: `memory/classification-rules.md` and `memory/maintenance-rules.md`

