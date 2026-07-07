# Prompt: Plan — Generic Workflow

**Purpose**: Create a detailed, actionable development plan from a story analysis.
**Prerequisite**: `/analyse` must have been run — analysis file must exist.
**Output**: Development plan in `{project}/.github/development-plans/`.

---

## Context Loading

```
1. active-context.md               → current story, analysis reference
2. analysis file                   → affected modules, patterns, risks
3. p04-pattern-library.md          → matching project patterns (P-numbers)
4. p05-template-library.md         → matching templates (T-numbers)
5. ai-devagent/knowledge/          → generic principles (only if patterns are silent)
6. 1-2 reference source files      → nearest similar existing class (last resort)
```

**Max 2 skill files + 1 source file. More = token waste.**

---

## Process

### Step 1 — Read the Analysis
- Load `{project}/.github/story-analyses/analysis-{STORY-NUMBER}-*.md`
- Extract: Affected Modules list, requirements, acceptance criteria, risks

### Step 2 — Load Module Details
- For each module in the Affected Modules list, load `modules/{module-name}.md`
- Do NOT load detail files for modules not in the affected list

### Step 3 — Pattern and Template Matching
For each new component to create:
- Check `p04-pattern-library.md` for a matching pattern (P-number)
- Check `p05-template-library.md` for a matching template (T-number)
- If no pattern/template: check `ai-devagent/knowledge/architecture-patterns.md`
- **If the task involves a new REST endpoint or service conversion**: apply P12 (OpenAPI Module) — create YAML + individual server pom + individual client pom in `epl_api` as part of the plan

### Step 4 — Find Reference Implementations
For each new file type to be created:
- Check the affected module for the nearest existing similar class
- Note the reference for each: entity, repository, service interface, DTO, test class

### Step 5 — Decompose into Tasks
- Break the story into atomic, ordered implementation tasks
- Each task = one logical change (one class, one method, one test class)
- Order by dependency (base layer first, presentation last)
- Mark which tasks can be done in parallel

### Step 6 — Define Test Strategy
For each component:
- Unit test: class name, scenarios (happy path + edge cases + errors)
- Integration test: boundary, data requirements

### Step 7 — Create Plan File

**Location**: `{project}/.github/development-plans/plan-{STORY-NUMBER}-{description}-{YYYY-MM-DD}.md`

**Template**:

```markdown
# Development Plan: {STORY-NUMBER}: {Title}
**Created**: {YYYY-MM-DD}
**Based on analysis**: analysis-{STORY-NUMBER}-*.md
**Phase**: Planning

## Overview
{Short summary of changes}

## Scope Boundary
**Affected Modules** (all file creation/modification restricted to these):
- `{module-name}`: {why affected}

## Reference Implementations
- Entity: `{path/to/ExistingEntity.java}`
- Repository: `{path/to/ExistingRepository.java}`
- Service interface: `{path/to/ExistingService.java}`
- DTO: `{path/to/ExistingDto.java}`

## Implementation Tasks

### Task 1 — {Component Name}
**Module**: `{module-name}`
**File**: `{exact/path/to/File.java}` — {create | modify}
**Pattern**: {P-number} — {pattern name}
**Template**: {T-number} (if applicable)
**Changes**: {Description}
**Justification**: {Why}

## Test Coverage
- Unit: `{TestClass}` — scenarios: {list}
- Integration: `{TestClass}` — {what}

## Definition of Done
- [ ] All acceptance criteria implemented
- [ ] All unit tests green
- [ ] All integration tests green
- [ ] No new warnings / violations
- [ ] active-context.md updated

## Risks
- {Potential problems}

## Open Questions
- {Questions to resolve before implementation}
```

### Step 8 — Review Plan
- [ ] Every file path is in an affected module
- [ ] Pattern/template identified for each new file type
- [ ] Reference implementations noted for each new file type
- [ ] Step dependencies are explicit
- [ ] Test coverage is planned

## Best Practices
- **Granularity**: Tasks completable in 1-4 hours
- **Precision**: Every file has an exact path — no vague descriptions
- **Reference-first**: Always check existing code before specifying new patterns
- **Scope discipline**: If a change is not in an affected module, question whether it is really necessary

---

## Memory Update After Planning

Update `active-context.md`:
- Set Phase to "Planning complete"
- Record patterns used
- Record any architectural decisions made during planning
