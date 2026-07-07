# Prompt: Implement — Generic Workflow

**Purpose**: Implement code changes based on the development plan.
**Prerequisite**: `/plan` must have been run — plan file must exist.

---

## Context Loading

```
1. active-context.md           → current task, patterns used
2. plan file                   → specific tasks and templates
3. p05-template-library.md     → template for the class being created
4. ${CLAUDE_PLUGIN_ROOT}/skills/java-coding/SKILL.md  → always load for any Java code
5. tech-specific skill         → 1-2 additional (JPA, Spring, JavaFX, JMS)
6. 1-2 reference source files  → existing similar class in the same module
```

**Load only the template and skills for the current task. Not all templates.**

---

## Skills to Load First

Before writing any code, load the relevant skill files:

| Task | Load |
|------|------|
| Any Java code | `${CLAUDE_PLUGIN_ROOT}/skills/java-coding/SKILL.md` |
| JPA entities, repositories | `${CLAUDE_PLUGIN_ROOT}/skills/jpa-persistence/SKILL.md` |
| Spring services, DI | `${CLAUDE_PLUGIN_ROOT}/skills/spring-framework/SKILL.md` |
| DTOs, service interfaces | `${CLAUDE_PLUGIN_ROOT}/skills/dto-patterns/SKILL.md` |
| Tests | `${CLAUDE_PLUGIN_ROOT}/skills/testing-guidelines/SKILL.md` + junit5 + assertj + mockito |
| JavaFX client | `${CLAUDE_PLUGIN_ROOT}/skills/javafx-client/SKILL.md` |
| JMS messaging | `${CLAUDE_PLUGIN_ROOT}/skills/jms-messaging/SKILL.md` |
| Maven / dependencies | `${CLAUDE_PLUGIN_ROOT}/skills/maven-build/SKILL.md` |
| Git / commits | `${CLAUDE_PLUGIN_ROOT}/skills/git-workflow/SKILL.md` |
| SQL scripts | `${CLAUDE_PLUGIN_ROOT}/skills/sql-scripts/SKILL.md` |

**Always load `java-coding.md` for any Java code.**
**Also load project-specific VW skills from `.github/skills/vw/` for EPL Bestand projects.**

---

## Scope Discipline

Before creating or modifying any file:
1. Read the **Affected Modules** from the plan — treat it as a hard boundary
2. Verify the file belongs to one of those modules
3. If not in the affected list — STOP, do not proceed without justification

**OpenAPI tasks (P12)**: For any new REST endpoint / service conversion, the following `epl_api` artefacts are **always in scope** even if not explicitly listed in the plan:
- YAML spec in `epl-api-apis/src/main/resources/{public|private}/`
- Server pom: `epl-api-server/{public|private}/{name}/pom.xml`
- Client pom: `epl-api-client/{public|private}/{name}/pom.xml`
- Module registration in `epl-api-server/pom.xml` + `epl-api-client/pom.xml`

**private vs public**: YAML consumed by `epl_basis` for DB access → `private/`; all others → `public/`

**New service implementations**: Write FRESH — do NOT delegate to an existing `@RemotingService` or `@Service` bean. Implement logic directly against repository/domain layer.

**Never**:
- Scan the entire project for files — search only within affected modules
- Read files in non-affected modules
- Create files outside the affected modules
- Add dependencies without checking whether the BOM already manages the version

---

## Process

### Step 1 — Read the Plan
- Load `{project}/.github/development-plans/plan-{STORY-NUMBER}-*.md`
- Extract: Affected Modules, Reference Implementations, ordered Implementation Tasks

### Step 2 — Load Reference Files
- For each file type you will create, read the reference implementation from the plan
- Adopt the same structure, annotations, imports, and code style as the reference

### Step 3 — Implement Task by Task
- Follow the plan order — one logical task at a time
- Load the template (T-number) for the class being created
- Apply the project's specific annotations and naming (from project memory)
- After each task: check for compile errors
- Fix errors before proceeding to the next task

### Step 4 — Write Tests in Parallel
- Tests belong in the same module as the code under test (`src/test/java/`)
- Use the project-specific test annotation (check project memory)
- Write unit tests for each new class; integration tests for persistence/JMS boundaries

### Step 5 — Final Validation
- All changed files compile without errors
- Build affected modules: `mvn clean install -pl {affected-modules} -am`
- All relevant tests pass
- No files created/modified outside the affected modules

---

## Quality Checklist (Per Class)

- [ ] Correct package declaration
- [ ] All required imports (no wildcard imports)
- [ ] Correct framework annotations (from project memory)
- [ ] No `@Data` on JPA entities
- [ ] Constructor injection (not field injection)
- [ ] No raw types, no magic numbers/strings (use named constants)
- [ ] Public API has Javadoc
- [ ] Exception handling follows conventions

---

## Memory Update After Implementation

Update `active-context.md`:
- Set Phase to "Implementing"
- Mark completed tasks
- Record any deviations from the plan and why
- Record new patterns discovered (if novel — add to pattern library)
