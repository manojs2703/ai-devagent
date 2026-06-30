# AI DevAgent — README

## What is ai-devagent?

`ai-devagent` is the **AI operating system** — the generic, reusable framework that defines
how an AI agent thinks, retrieves information, executes tasks, and maintains memory.

It is **not** a project. It contains no project-specific information.
It can be copied to any software repository and used unchanged.

---

## Directory Structure

```
ai-devagent/
├── 00-entrypoint.md          ← START HERE — first file read every session
├── workspace-registry.md     ← All projects in the workspace (EPL, Evps, ...)
├── README.md                 ← This file (human-readable overview)
│
├── agents/                   ← Agent definitions
│   ├── primary-agent.agent.md    ← PRIMARY AGENT — orchestrates all implementation
│   ├── code-optimizer.agent.md   ← Java code optimization analysis
│   └── task-propagator.agent.md  ← Task decomposition and propagation
│
├── workflows/                ← How to execute tasks
│   ├── session-startup.md    ← Session initialization protocol
│   ├── project-discovery.md  ← How to discover a new/unfamiliar project
│   ├── task-analyse.md       ← /analyse workflow
│   ├── task-plan.md          ← /plan workflow
│   ├── task-implement.md     ← /implement workflow
│   ├── task-test.md          ← /test workflow
│   ├── task-commit.md        ← /commit workflow
│   ├── task-review.md        ← /review workflow
│   └── task-translate.md     ← /translate workflow
│
├── memory/                   ← Memory governance
│   ├── memory-hierarchy.md   ← Priority rules and override model
│   ├── retrieval-strategy.md ← When and how to retrieve knowledge
│   ├── classification-rules.md ← What knowledge goes where
│   ├── maintenance-rules.md  ← When and how to update memory
│   └── token-optimization.md ← Token budget management
│
└── knowledge/                ← Generic engineering intelligence
    ├── skillset-index.md     ← Engineering capability map
    ├── architecture-patterns.md ← AP-01 to AP-10
    ├── java-engineering.md   ← Java 21, Lombok, Streams, naming
    ├── data-access-patterns.md ← ORM, transactions, JPQL
    ├── testing-strategies.md ← Test pyramid, GWT, Mockito
    ├── api-error-handling.md ← REST, error handling, logging
    └── security-performance.md ← Security, caching, observability
```

---

## Relationship with .github

| Layer | Location | Contains |
|-------|---------|----------|
| **AI DevAgent** (this) | `ai-devagent/` | Generic AI framework — portable across any repo |
| **Project Memory** | `.github/ai-memory/` | Project-specific knowledge — this repo only |

The two layers work together but are strictly separated:
- `ai-devagent` defines HOW the AI works
- `.github/ai-memory/` defines WHAT this project is

---

## Portability

This entire `ai-devagent/` directory can be:
- Copied to a new repository unchanged
- Used as a git submodule
- Referenced as a shared template

No content here should ever reference a specific project, business domain, or company name.

---

## Quick Start (New Session)

1. Read `ai-devagent/00-entrypoint.md`
2. Follow the Session Startup Sequence defined there
3. Never skip the sequence — it exists to minimize token waste

---

## Primary Agent

The `agents/primary-agent.agent.md` is the **entry point for all implementation work**.
It orchestrates the full workflow (analyse → plan → implement → test → review → commit)
across all projects registered in `workspace-registry.md`.

GitHub Copilot loads it automatically via `.github/copilot-instructions.md` at the workspace root.

---

## Multi-Project Setup

```
IdeaProjects/                          ← Workspace root
├── .github/
│   └── copilot-instructions.md        ← Wires the primary agent into GitHub Copilot
│
├── ai-devagent/                       ← AI operating system (this directory)
│   ├── 00-entrypoint.md
│   ├── workspace-registry.md          ← Project index
│   └── agents/primary-agent.agent.md  ← Primary implementation agent
│
├── EPL-Project/
│   └── .github/ai-memory/             ← EPL project memory (init with /discover)
│
└── Evps-Project/
    └── .github/ai-memory/             ← Evps project memory (init with /discover)
```
