# Skill: Git Workflow
## When to Apply This Skill
Load this skill when working with branches, commits, or the `/commit` and `/review` commands.
**Project override**: Check project memory for the ticket ID format and issue tracker conventions.
---
## Branch Naming
- Feature branches: `feature/{TICKET-ID}-short-description`
- Bug fix branches: `bugfix/{TICKET-ID}-short-description`
- Hotfix branches: `hotfix/{TICKET-ID}-short-description`
- Release branches: `release/{VERSION}`
- Use lowercase, hyphens for spaces, max ~50 characters after the ticket ID
---
## Reading Current Branch
- Read `.git/HEAD` directly (no git command needed): format is `ref: refs/heads/{branch-name}`
- Extract the branch name by stripping the `ref: refs/heads/` prefix
- Extract the story/ticket number using the project's regex pattern (check project memory)
---
## Commit Message Format
- First line: `{TICKET-ID} {Short description}` (max 72 characters)
- Blank line after the first line
- Optional body: explain WHY the change was made, not what (the diff shows what)
- Optional footer: affected modules, breaking changes, migration notes
---
## Commit Scope Rules
- Stage only files that are in the affected modules identified in the story analysis
- Do not stage unrelated changes or reformatting of files outside the scope
- Use `git status` to verify what is staged before committing
---
## Code Review (for `/review` command)
- Compare the current branch against the integration branch (check project memory for branch name)
- Use `git diff {base-branch}..HEAD` to see all changes in the current branch
- Focus the review on the affected modules listed in the story analysis
- Review output goes to `.github/reviews/review-{STORY-NUMBER}-{YYYY-MM-DD}.md`
---
## Git Commands
- Always use `git --no-pager` for commands that may page output
- Use `git diff --name-only {base}..HEAD` to get a list of changed files
- Use `git log --no-pager --oneline -20` for a compact recent history

