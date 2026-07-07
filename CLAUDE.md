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
├── .claude-plugin/plugin.json  ← Claude Code plugin manifest
├── 00-entrypoint.md            ← START HERE every session
├── agents/                     ← Agent definitions (primary, code-optimizer, task-propagator)
├── commands/                   ← Slash command implementations (analyse, plan, implement, ...)
├── hooks/hooks.json            ← SessionStart hook — auto-reads 00-entrypoint.md
├── knowledge/                  ← Generic engineering intelligence (Java, APIs, testing, etc.)
├── memory/                     ← Memory governance rules (retrieval, classification, maintenance, project discovery)
└── skills/                     ← Reusable skills, one folder per skill with SKILL.md
```

This repo is also a Claude Code plugin marketplace (`.claude-plugin/marketplace.json`
at the repo root). To dogfood it as an installed plugin instead of reading it via
this file, run `claude --plugin-dir ./ai-devagent`.
