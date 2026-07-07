# Knowledge Classification Rules

**Purpose**: Rules for classifying new knowledge so it ends up in the right place.

---

## The Core Question

> "Is this knowledge true for any software project, or is it specific to this repository?"

- True for any project → `${CLAUDE_PLUGIN_ROOT}/knowledge/`
- Specific to this repository → `.github/ai-memory/project/`
- Both aspects → Both locations (abstract principle + concrete implementation)
- One-time story analysis → `{project}/.github/story-analyses/`

---

## Classification Decision Tree

```
New knowledge to store?
│
├─ True for any software project regardless of technology?
│    Yes → ${CLAUDE_PLUGIN_ROOT}/knowledge/
│
├─ Specific to this repository (framework, domain, conventions)?
│    Yes → .github/ai-memory/project/
│
├─ Has both generic and project-specific aspects?
│    Yes → Both:
│         ${CLAUDE_PLUGIN_ROOT}/knowledge/: abstract principle (what and why)
│         .github/ai-memory/project/: concrete implementation (how in this project)
│
└─ One-time analysis for a specific story or task?
     Yes → {project}/.github/story-analyses/{name}.md
            (NOT memory — analysis files are ephemeral)
```

---

## Classification Examples

| Knowledge | Location | Reason |
|-----------|----------|--------|
| "Service interfaces separate contract from implementation" | AI DevAgent | True for any architecture |
| "Service interfaces live in `{prefix}-commons/fassade`" | Project Memory | Project-specific naming |
| "Prefer `@NonNull` to guard parameters" | AI DevAgent | Language/library rule |
| "Repository pattern: one per aggregate root" | AI DevAgent | Design principle |
| "Repositories extend `ProjectRepository<E, Long>`" | Project Memory | Project base class |
| "Prevent N+1 with JOIN FETCH" | AI DevAgent | Any ORM project |
| "`@TransactionalMandatory` on repository interfaces" | Project Memory | Project-specific annotation |
| "GWT structure for tests" | AI DevAgent | Any test framework |
| "`@UnitTest` annotation from project library" | Project Memory | Project-specific annotation |
| "Server-side authorization enforcement" | AI DevAgent | Universal security principle |
| "`@BeppoCheck` AOP annotation" | Project Memory | Project framework |
| "Acceptance criteria live in a custom Jira field, not the description" | Project Memory | Project's Jira/Confluence structure — `p06-atlassian-structure.md` |

---

## Split Rule (Partially Reusable Knowledge)

When a concept has both generic and project-specific aspects, split it:

**AI DevAgent**: Abstract principle — what it achieves and why
**Project Memory**: Concrete implementation — exact class names, annotations, conventions

### Example: Error Code Pattern

**AI DevAgent** (`api-error-handling.md`):
> Use named error code constants — never hardcode error strings.
> Group by domain area. Machine-readable codes enable client-side error handling.

**Project Memory** (`p04-pattern-library.md`):
> EPL error codes: format `{PREFIX}_{THREE_DIGIT_NUMBER}` (e.g., `PS_001`).
> Implement `Meldungsart` interface. Location: `{prefix}-commons/meldung/{Project}Meldungsart.java`.

---

## Priority Rule (Conflict Resolution)

```
Project Memory WINS over AI DevAgent.
Project Memory WINS over industry defaults.
Project conventions WIN over generic standards.
```

This library provides defaults. Project memory provides overrides.
Never replace project conventions with library defaults unless explicitly requested.

### Conflict Resolution Examples

| Topic | Generic Knowledge | Project Knowledge | Use |
|-------|-----------------|------------------|-----|
| Transaction annotation | `@Transactional` | `@TransactionalMandatory` | Project |
| Repository base | `JpaRepository<E, Long>` | `ProjectRepository<E, Long>` | Project |
| Test annotation | `@ExtendWith(MockitoExtension)` | `@UnitTest` | Project |
| Null safety | `@NonNull` | `@NonNull` | Same — either |
| Error response | Generic structure | Project's error structure | Project |

---

## AI DevAgent Maintenance Rules

### Add when
- A principle applies to any software project (not project-specific)
- A pattern has been proven effective across multiple projects
- An engineering insight is stable and consensus-level knowledge

### Do NOT add
- Project names, business domains, or framework-specific class names
- One-time decisions or story-specific analysis
- Speculative or unproven practices

### File Size Limits

| File | Soft Limit | Hard Limit |
|------|-----------|-----------|
| `00-entrypoint.md` | 500 tokens | 700 tokens |
| `knowledge/*.md` files | 700 tokens | 1,000 tokens |
| `memory/*.md` files | 500 tokens | 700 tokens |

If a file exceeds its soft limit, review for outdated content before adding more.

---

## Library Quality Rules

| Rule | Reason |
|------|--------|
| No project-specific terms | Portability |
| Principles over implementations | Reusability |
| Concise — quick reference not textbook | Token efficiency |
| No large code blocks | Token efficiency |
| Mark uncertain info with ⚠️ | Correctness |
| Remove outdated entries immediately | Stale info is worse than no info |
| English only | Consistency |

