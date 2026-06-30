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
4. Story from issue tracker                   → via MCP tool or manual input
5. modules/{module}.md files                  → only for affected modules (after Step 3)
```

**No source code at this stage.**

---

## Process

### Step 1 — Determine Story Number
- Accept story number from user input parameter
- OR extract from current branch name using the project's regex pattern (check project memory)

### Step 2 — Retrieve Story Information
- Fetch story from the issue tracker (via MCP tool or manual input)
- Capture: title, description, acceptance criteria, labels, priority

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
