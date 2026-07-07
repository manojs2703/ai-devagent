# Prompt: DoAll — Generic Workflow

**Purpose**: Run the complete workflow for a story end-to-end.

---

## Steps (Execute in Order)

1. **/analyse** — Analyze story, document in `{project}/.github/story-analyses/`
2. **/plan** — Create development plan, document in `{project}/.github/development-plans/`
3. **/implement** — Implement planned changes
4. **/test** — Consolidate and ensure test coverage
5. **/commit** — Prepare commit message

---

## Stop Conditions

**After /analyse** — Stop and ask the user for explicit approval before continuing if:
- Open questions or unclear requirements exist
- Acceptance criteria are ambiguous or incomplete
- Critical risks or unresolvable dependencies identified

**During /implement** — Stop if:
- A file change would affect a module outside the affected list
- A dependency conflict is identified
- An architectural decision requires clarification

---

## Output Summary

After completing all steps, provide:
- Analysis file path
- Plan file path
- List of files created/modified
- Test coverage summary
- Prepared commit message

