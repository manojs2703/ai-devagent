# AI DevAgent

This repository contains the **AI DevAgent** framework — a structured agent system for AI-assisted software development.

## Session Startup

At the start of every session, read `ai-devagent/00-entrypoint.md` and follow the Session Startup Sequence defined there exactly. Do not skip the sequence.

## Quick Reference

| File | Purpose |
|------|---------|
| `ai-devagent/00-entrypoint.md` | Entry point — read first every session |
| `.github/workspace-registry.md` | Project registry — generated per-workspace by the installer |
| `ai-devagent/agents/primary-agent.agent.md` | Primary agent — entry point for all implementation |

## Package Contents

```
ai-devagent/
├── 00-entrypoint.md       ← START HERE every session
├── agents/                ← Agent definitions (primary, code-optimizer, task-propagator)
├── workflows/             ← Task workflows (analyse, plan, implement, test, review, commit)
├── knowledge/             ← Generic engineering intelligence (Java, APIs, testing, etc.)
├── memory/                ← Memory governance rules
├── prompts/               ← Slash command implementations
└── skills/                ← Reusable skill libraries
```
