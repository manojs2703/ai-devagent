# AI DevAgent — README

## What is ai-devagent?

`ai-devagent` is the **AI operating system** — the generic, reusable framework that defines
how an AI agent thinks, retrieves information, executes tasks, and maintains memory.

It is **not** a project. It contains no project-specific information.
It ships as an installable **Claude Code plugin** (and, for GitHub Copilot,
via the `apm`-compatible workspace installer) — see Installation below.

---

## Directory Structure

```
ai-devagent/
├── .claude-plugin/
│   └── plugin.json            ← Claude Code plugin manifest
├── 00-entrypoint.md            ← START HERE — auto-surfaced every session via hooks/hooks.json
├── README.md                   ← This file (human-readable overview)
├── plugin-role.md              ← Source for the Plugin Role zone (Copilot/legacy installer, Claude full)
├── plugin-role.flat.md         ← Source for the Plugin Role zone (Copilot/legacy installer, flattened)
│
├── agents/                     ← Agent definitions (native Claude Code subagents)
│   ├── primary-agent.agent.md    ← PRIMARY AGENT — orchestrates all implementation
│   ├── code-optimizer.agent.md   ← Java code optimization analysis
│   └── task-propagator.agent.md  ← Task decomposition and propagation
│
├── commands/                   ← Native slash commands (/ai-devagent:analyse, /ai-devagent:plan, ...)
│
├── hooks/
│   └── hooks.json              ← SessionStart hook — auto-reads 00-entrypoint.md every session
│
├── memory/                     ← Memory governance (shipped as reference docs, read on demand)
│   ├── retrieval-strategy.md ← When and how to retrieve knowledge
│   ├── classification-rules.md ← What knowledge goes where
│   ├── maintenance-rules.md  ← When and how to update memory
│   ├── project-discovery.md  ← Bootstrapping memory for a new project
│   ├── token-optimization.md ← Token budget management
│   └── sync-protocol.md      ← How CLAUDE.md and copilot-instructions.md stay in sync
│
├── knowledge/                  ← Generic engineering intelligence (reference docs, read on demand)
│   ├── skillset-index.md     ← Engineering capability map
│   ├── architecture-patterns.md ← AP-01 to AP-10
│   ├── java-engineering.md   ← Java 21, Lombok, Streams, naming
│   ├── data-access-patterns.md ← ORM, transactions, JPQL
│   ├── testing-strategies.md ← Test pyramid, GWT, Mockito
│   ├── api-error-handling.md ← REST, error handling, logging
│   └── security-performance.md ← Security, caching, observability
│
└── skills/                     ← Model-invoked skills, one folder per skill with SKILL.md
    ├── java-coding/SKILL.md, jpa-persistence/SKILL.md, spring-framework/SKILL.md, ...
```

---

## Installation

See [`setup/README.md`](../setup/README.md) for the full installation guide — Claude Code
plugin marketplace, GitHub Copilot/IntelliJ workspace installer, and APM (Agent Package
Manager) are all covered there.

---

## Relationship with .github

| Layer | Location | Contains |
|-------|---------|----------|
| **AI DevAgent** (this) | `ai-devagent/` | Generic AI framework — portable across any repo |
| **Workspace Registry** | `.github/workspace-registry.md` | Project index — generated per-workspace by the installer |
| **Project Memory** | `.github/ai-memory/` | Project-specific knowledge — this repo only |

The two layers work together but are strictly separated:
- `ai-devagent` defines HOW the AI works
- `.github/ai-memory/` defines WHAT this project is

---

## Portability

This entire `ai-devagent/` directory can be:
- Installed as a Claude Code plugin (see Installation above)
- Copied to a new repository unchanged
- Used as a git submodule
- Referenced as a shared template

No content here should ever reference a specific project, business domain, or company name.

---

## Quick Start (New Session)

Once installed as a Claude Code plugin, this happens automatically via the
`SessionStart` hook (`hooks/hooks.json`) — it reads `00-entrypoint.md` at the
start of every session for you. For local dev without installing:

1. Read `${CLAUDE_PLUGIN_ROOT}/00-entrypoint.md` (or `ai-devagent/00-entrypoint.md` if working directly in this repo)
2. Follow the Session Startup Sequence defined there
3. Never skip the sequence — it exists to minimize token waste

---

## Primary Agent

The `agents/primary-agent.agent.md` is the **entry point for all implementation work**.
It orchestrates the full workflow (analyse → plan → implement → test → review → commit)
across all projects registered in `.github/workspace-registry.md`.

For Claude Code, installing the plugin makes this agent and the SessionStart hook
available automatically — no manual `CLAUDE.md` wiring needed. For GitHub Copilot,
the legacy workspace installer (`setup/install.ps1`) still wires the same content
into `.github/copilot-instructions.md`. Both surfaces carry the same Plugin Role
content (see `plugin-role.md` / `plugin-role.flat.md`) and stay in sync per
`memory/sync-protocol.md`.

---

## Multi-Project Setup

This layout describes the GitHub Copilot / legacy installer path. Claude Code
users can skip `CLAUDE.md` entirely and just `/plugin install ai-devagent` at
the workspace root instead — everything else (workspace registry, per-project
`.github/ai-memory/`) stays the same.

```
IdeaProjects/                          ← Workspace root
├── CLAUDE.md                          ← Wires the primary agent into Claude Code (legacy path)
├── .github/
│   ├── copilot-instructions.md        ← Wires the primary agent into GitHub Copilot
│   └── workspace-registry.md          ← Project index (generated by the installer)
│
├── ai-devagent/                       ← AI operating system (this directory)
│   ├── 00-entrypoint.md
│   └── agents/primary-agent.agent.md  ← Primary implementation agent
│
├── ProjectA/
│   └── .github/ai-memory/             ← ProjectA memory (init with /discover)
│
└── ProjectB/
    └── .github/ai-memory/             ← ProjectB memory (init with /discover)
```
