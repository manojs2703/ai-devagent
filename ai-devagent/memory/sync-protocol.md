# Memory Sync Protocol

Governs how `CLAUDE.md` and `copilot-instructions.md` stay mutually aware
without becoming duplicate copies of each other. Both files' "How to use
this file" sections point here. This doc ships as part of the plugin base
and is installed once per project, unmodified.

## Why not just one shared file?
A single shared memory file forces both tools to pay the token cost of the
other tool's preferred verbosity/structure on every read. Splitting them
lets each tool load only the shape it parses efficiently, while the sync
step keeps the *substance* — not the phrasing — identical.

## The three zones per file

| Zone | Owner | Written by | Read by |
|---|---|---|---|
| Plugin Role | installer | install-time only | both, rarely re-read in full |
| Project Memory / Project Rules | the tool itself | Claude→CLAUDE.md, Copilot→copilot-instructions.md | the owning tool, every session |
| Synced From X | the *other* tool | cross-write after any memory update | the owning tool, folded in opportunistically |

## Update flow (either direction)

1. Tool A implements/decides something worth remembering.
2. Tool A writes a full entry into its own native memory zone, in its own
   format (Claude: structured decision entries; Copilot: flat rule lines).
3. Tool A **compresses** that same entry — see translation rules below —
   and appends it to the `Synced From A` zone in Tool B's file.
4. Tool A does NOT rewrite Tool B's native zone directly. Only Tool B
   promotes synced entries into its own native zone, in its own next
   session, in its own format. This prevents format contamination and
   keeps each file internally consistent.
5. Superseded entries are marked `status: superseded-by:<id>` (Claude) or
   simply deleted (Copilot, since its format has no status field) rather
   than left to accumulate. Prune the `Synced From` zones the same way once
   the owning tool has promoted or discarded them.

## Translation rules: Claude → Copilot

Take a Claude memory entry:
```
- [2026-07-03] API error handling
  decision: all repository-layer calls wrap errors in AppError before rethrow
  why: lets the controller layer pattern-match on error type
  where: src/data/*.repository.ts
  status: active
```
Compress to:
```
- [src/data/*.repository.ts] Rule: wrap thrown errors in AppError before rethrow. (est. 2026-07-03)
```
Drop `why` entirely unless it changes *what* the rule requires (rationale
that doesn't alter the actionable instruction is pure overhead for Copilot's
budget). Drop `status` — Copilot's file only ever holds active rules.

## Translation rules: Copilot → Claude

Take a Copilot rule:
```
- [src/api/routes/*.ts] Rule: every route handler must validate input with zod before use. (est. 2026-07-02)
```
Expand to:
```
- [2026-07-02] Input validation (from Copilot session)
  decision: route handlers validate input with zod before use
  where: src/api/routes/*.ts
  status: active
```
Leave `why` blank/omitted rather than inventing a rationale Copilot's
format never captured — don't fabricate context that wasn't there.

## What never gets synced
- Anything scoped to a single throwaway session (typos, one-off debugging).
- Entries already marked superseded on the source side.
- Full rationale paragraphs, code snippets, or examples — only the
  compressed actionable line crosses over. If deeper context is genuinely
  needed by both tools, it belongs in project docs, referenced by path from
  both memory zones, not duplicated into either.

## Install-time behavior (plugin generic instructions)
The plugin's base templates for `CLAUDE.md` and `copilot-instructions.md`
contain `{{GENERIC_PLUGIN_INSTRUCTIONS}}` / `{{GENERIC_PLUGIN_INSTRUCTIONS_FLAT}}`
placeholders. On install:
1. Installer fills these from the plugin's own instruction source (single
   source of truth in the plugin repo), rendering the Claude version with
   full structure and the Copilot version pre-flattened.
2. Installer creates empty Memory/Rules and Synced-From zones with the
   markers shown in the templates — never pre-populates them with
   speculative content.
3. On subsequent plugin upgrades, the installer re-renders only the
   Plugin Role zone (by marker) and leaves Project Memory / Synced-From
   zones untouched, so project-specific learning isn't lost on upgrade.
