# Memory Maintenance Rules

**Purpose**: When and how to update the two-layer memory system.

---

## Layer Routing for New Knowledge

| New knowledge type | Store in |
|-------------------|----------|
| Generic engineering principle (any project) | `${CLAUDE_PLUGIN_ROOT}/knowledge/` |
| Project-specific convention or pattern | `.github/ai-memory/project/` |
| Both abstract + concrete project implementation | Both locations |
| One-time story analysis | `{project}/.github/story-analyses/{name}.md` |

For classification decisions: → `${CLAUDE_PLUGIN_ROOT}/memory/classification-rules.md`

---

## Always Update (Every Session)

**`.github/ai-memory/project/active-context.md`**:
- Story started → populate "Active Project" section
- Phase changes → update status
- Architectural decision made → add to decisions table
- Story complete → move to "Recent Work", clear "Active Project"

---

## Update AI DevAgent Knowledge When

**`knowledge/architecture-patterns.md`** — add when:
- A new generic architecture pattern is proven across multiple scenarios

**`knowledge/java-engineering.md`** — add when:
- A new Java language feature becomes standard practice
- An anti-pattern is confirmed by repeated experience

**`knowledge/testing-strategies.md`** — add when:
- A testing approach proves universally effective

**Other knowledge files** — update when:
- Better generic practice is established
- Existing rule is found incorrect or incomplete

**Do NOT add to AI DevAgent**:
- Project-specific annotations, class names, business terms
- One-time decisions or story analysis

---

## Update Project Memory When

**`p04-pattern-library.md`** — add when:
- Same project-specific implementation appears 3+ times
- Framework usage decision crystallizes

**`p05-template-library.md`** — update when:
- Project standard changes (new base class, new annotation)
- Better implementation found and validated

**`p02-project-registry.md`** — update when:
- Context docs generated for a new project (❌ → ✅)
- New module added

**`p01-workspace-architecture.md`** — update when:
- New project added to workspace
- Major framework upgrade
- Architecture decision changes deployment model

**`p03-domain-concepts.md`** — update when:
- New domain term introduced
- New framework component used for first time

**`p06-atlassian-structure.md`** — update when:
- First `/analyse` run for a project (created, not just updated — see `commands/analyse.md`)
- The Jira field used for acceptance criteria changes
- A new Confluence space or parent page becomes the norm for linked docs
- Any other discovered Jira/Confluence convention turns out to be stale or wrong

---

## Self-Improvement Checklist (End of Session)

After every session with meaningful work:

1. Was any knowledge missing from memory? → Add it to the right layer
2. Was any knowledge wrong? → Fix it immediately
3. Did I read the same source file twice? → Extract key knowledge to memory
4. Did I regenerate the same pattern? → Add to template library
5. Was retrieval efficient? → Update retrieval strategy if not
6. Did I discover a generic pattern? → Add to `${CLAUDE_PLUGIN_ROOT}/knowledge/`
7. Did I discover a project-specific rule? → Add to `project/` memory
8. Is any memory stale? → Remove or update it
9. Are completed tasks cleared from the open tasks list? → Clear them

---

## Quality Rules

| Rule | Why |
|------|-----|
| AI DevAgent: no project-specific terms | Portability |
| Project memory may reference AI DevAgent | Cross-layer linking allowed |
| AI DevAgent must NOT reference project memory | Portability |
| No large code blocks in memory files | Token efficiency |
| Mark uncertain info with `⚠️ Verify` | Accuracy |
| Remove outdated entries immediately | Stale info is worse than no info |
| All content in English | Consistency |

