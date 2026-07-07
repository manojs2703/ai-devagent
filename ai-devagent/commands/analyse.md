# Prompt: Analyse — Generic Workflow

**Purpose**: Analyze a user story before any implementation begins.
**Input**: Story number (from parameter or current branch).
**Output**: Story analysis file in `{project}/.github/story-analyses/`.

---

## Context Loading

```
1. active-context.md                          → current state, active project
2. project-registry.md                        → identify project, check context status
3. {project}/specific-project-details.md      → module overview
4. p06-atlassian-structure.md, if it exists   → known Jira/Confluence structure for this project
5. Story from issue tracker, full + all comments → via MCP tool or manual input
6. Story attachments (images, documents)      → fetched and read, not just listed
7. Confluence pages linked from the story      → fetched and read, not just noted as links
8. modules/{module}.md files                  → only for affected modules (after Step 3)
```

**No source code at this stage.**

---

## Process

### Step 1 — Determine Story Number
- Accept story number from user input parameter
- OR extract from current branch name using the project's regex pattern (check project memory)

### Step 1a — Load or Discover Atlassian Structure
- Check for `{project}/.github/ai-memory/project/p06-atlassian-structure.md`.
- **If it exists**: read it before fetching anything. It tells you this project's Jira project
  key(s), which field actually holds acceptance criteria (description vs. a custom field), the
  label/component/attachment conventions in use, and which Confluence space(s) and parent pages
  this project's stories typically link to. Use it to fetch precisely in Steps 2–2b instead of
  guessing or re-discovering structure from scratch.
- **If it does not exist**: this is the first `/analyse` run for this project. Proceed with
  Steps 2–2b as normal, but pay attention to structure while doing so — you'll create the cache
  in Step 2c from what you observe in this run.

### Step 2 — Retrieve Story Information
- Fetch the complete story from the issue tracker (via MCP tool or manual input) — the full description, not a summary
- Capture: title, description, acceptance criteria, labels, priority
- Fetch **all comments** on the story and read them in full. Comments often carry clarifications,
  scope changes, or constraints agreed after the story was written — treat them as part of the
  requirement, not optional context. Extract any comment content that is useful for implementation
  (clarified acceptance criteria, edge cases called out by reviewers, technical constraints, decisions
  made during grooming). Ignore comments that are purely process chatter (status pings, assignment
  changes) with no bearing on the implementation.

### Step 2a — Retrieve Attachments
- List every file attached to the story (directly on the issue, and on comments if the tracker
  supports comment attachments).
- Fetch and read each one — do not just record the filename:
  - **Images (mockups, screenshots, diagrams)**: view the image content and extract what it specifies
    — UI layout, expected before/after state, error messages shown, data shown in a screenshot.
  - **Documents (PDF, Word, text, spreadsheets)**: read the content and extract requirements, sample
    data, or specifications relevant to implementation.
- If an attachment can't be fetched or read (unsupported format, broken link, access denied), say so
  explicitly in the analysis file rather than silently skipping it — this is a gap the user needs to
  know about, since it may hide acceptance criteria.

### Step 2b — Follow Confluence Links
- Scan the story description and comments for Confluence page links.
- Fetch and read the full content of every linked page — treat it as part of the requirement, not
  background reading. Confluence pages linked from a story commonly contain the actual design,
  API contract, or business rules the story summarizes.
- If a linked page itself links to further Confluence pages that are clearly load-bearing (e.g. a
  parent design doc), follow one level deeper — do not recurse indefinitely.
- If a link is inaccessible (permissions, page moved/deleted), say so explicitly in the analysis file.

### Step 2c — Cache or Update Atlassian Structure
- **If `p06-atlassian-structure.md` did not exist** (Step 1a): create it now from what this run
  observed — Jira project key, issue type, which field actually held acceptance criteria, the
  label/component conventions seen, attachment types seen, and the Confluence space key(s) and
  parent page(s) of any linked pages. Use the template in `p06-atlassian-structure.md` below.
- **If it existed but this story contradicts it** (e.g. acceptance criteria showed up in a
  different field, or a new Confluence space appeared): update the file — it must reflect current
  reality, not a stale first impression.
- **Never write this file into the plugin** (`${CLAUDE_PLUGIN_ROOT}`). It is project memory and always
  belongs under `{project}/.github/ai-memory/project/` — the plugin stays generic and portable.

**`p06-atlassian-structure.md` template**:

```markdown
# Atlassian Structure — {Project Name}

**Last updated**: {YYYY-MM-DD}
**Purpose**: Cached Jira/Confluence structure so /analyse doesn't rediscover it every run.

## Jira
- **Project key(s)**: {e.g. ABC, XYZ}
- **Issue types seen**: {Story, Bug, Task, ...}
- **Acceptance criteria location**: {Description | Custom field name}
- **Labels/components convention**: {...}
- **Attachment conventions**: {typical file types, naming patterns}

## Confluence
- **Space key(s) linked from stories**: {...}
- **Typical parent/root pages**: {title/URL}
- **Page structure notes**: {...}

## Quirks / Gotchas
- {Anything unusual discovered — e.g. "acceptance criteria sometimes only in a comment, not the field"}
```

### Step 3 — Module Identification (Critical)
1. Load the project's `specific-project-details.md` for the module list
2. Map story keywords to modules using module responsibilities
3. For each identified module, load `modules/{module-name}.md` if it exists
4. Produce the definitive affected-module list — be precise, not broad

**This module list is the scope boundary for all subsequent planning and implementation.**

### Step 4 — Pattern Recognition
Classify the story type:
- New feature / New field / New screen
- Bug fix / Regression fix
- Performance optimization
- Refactoring / Cleanup
- API change / Breaking change

### Step 5 — Risk Analysis
- Breaking change risk (API contracts, database schema, serialization)
- Performance impact (query changes, cache invalidation)
- Testing effort (new test pyramid layer needed?)
- Cross-module dependencies
- External system dependencies

### Step 6 — Question Generation
Generate questions for:
- Unclear acceptance criteria
- Missing edge case handling
- Unspecified error behavior
- Cross-cutting concerns (logging, security, transaction boundaries)

### Step 7 — Create Analysis File

**Location**: `{project}/.github/story-analyses/analysis-{STORY-NUMBER}-{short-description}-{DATE}.md`

**Template**:

```markdown
# Analysis: {STORY-NUMBER}: {Title}
**Date**: {YYYY-MM-DD}
**Project**: {project-name}
**Phase**: Analysed

## Story Description
{Original story text}

## Acceptance Criteria
{List from issue tracker}

## Comments Relevant to Implementation
{Clarifications, scope changes, constraints, or decisions pulled from the story's comment thread —
only include comments that affect implementation; omit pure process chatter. Cite the commenter and
date if useful for traceability. State "None" if no comments carry implementation-relevant content.}

## Attachments
{For each attachment: filename, type, and what it specifies (extracted from the actual content, not
the filename). Flag any attachment that could not be fetched or read. State "None" if the story has
no attachments.}

## Linked Confluence Pages
{For each linked page: title/URL and the requirements, design, or constraints extracted from its
content. Flag any link that could not be accessed. State "None" if the story links no Confluence
pages.}

## Analysis

### Affected Modules
- [ ] `{module-name}` — {reason}
**Scope boundary**: Implementation stays within these modules only.

### Technical Components
{Which specific classes/packages are relevant}

### Pattern Match
- Story type: {type}
- Matching patterns: {P-numbers from project pattern library}
- Matching templates: {T-numbers from template library}

### Risk Assessment
- Scope: [Small | Medium | Large]
- Risk: [Low | Medium | High]
- Breaking changes: [Yes / No / Unknown]

## Open Questions

### For Product Owner
1. {Question} — *Why relevant*: {reason}

### Technical Clarifications
1. {Question} — *Options*: {possible answers}

## Notes
{Free area}

---
*Next step: Run /plan to create the development plan.*
```

---

## Memory Update After Analysis

Update `active-context.md`:
- Set Active Project section with the story
- Set Phase to "Analysed"
- Record affected modules
- Record open questions

Also confirm `p06-atlassian-structure.md` was created (first run) or updated (structure changed)
per Step 2c — this is separate from `active-context.md` and easy to forget since it's not part
of the per-story checklist above.
