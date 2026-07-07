# Prompt: Review — Generic Workflow

**Purpose**: Review code changes for quality, correctness, and convention compliance.
**Input**: Git diff (full story) or specific file path(s).
**Output**: Review report in `{project}/.github/reviews/`.

---

## Context Loading

For full story review:
```
1. git diff {base-branch}..HEAD → complete diff of current branch vs base
2. Relevant skill files         → based on types of code changed
```

For file-specific review:
```
1. The specific file(s) provided
2. Relevant skill files for that file's type
```

**No active-context loading needed — diff or file is the input.**

---

## Skills to Load

- `ai-devagent/skills/git-workflow.md` — extracting diffs, avoiding Git artifacts
- `ai-devagent/skills/java-coding.md` — code quality standards
- `ai-devagent/skills/testing-guidelines.md` — test quality standards

---

## Input Modes

- **No parameter** → Full story review (compare current branch against integration branch)
- **File path(s) specified** → File-specific review (analyze only those files)

---

## Process

### For Full Story Review

**Step 1 — Verify actual changes** (avoid Git artifacts from base branch evolution):
```
git log --name-only --oneline {base-branch}..HEAD
```

**Step 2 — Overview**:
```
git --no-pager diff {base-branch}...HEAD --stat
```

**Step 3 — Detailed diff**:
```
git --no-pager diff {base-branch}...HEAD
```

Cross-check: review only files appearing in BOTH `git log` and `git diff`.

### For File-Specific Review
Analyze the specified file(s) directly — no diff needed.

---

## Review Checklist

### Architecture & Design
- [ ] Correct layer separation (controller → service → repository)
- [ ] DTOs used between layers — entities not exposed to controllers
- [ ] Service interface defines contract (implementation separate)
- [ ] No business logic in repositories or controllers

### Java Code Quality
- [ ] Java 21 features used appropriately (Records, Pattern Matching, Streams)
- [ ] Lombok annotations correct (`@Builder`, `@Value`, `@RequiredArgsConstructor`)
- [ ] Constructor injection only — no field injection
- [ ] No raw types, no magic numbers/strings (use named constants)
- [ ] `Optional` used correctly (not on fields, `.orElseThrow()` not `.get()`)
- [ ] Immutable collections where mutability not needed

### JPA / Data Access
- [ ] `FetchType.LAZY` on all associations
- [ ] No `@Data` on entities
- [ ] Version field on mutable entities (`@Version Long version`)
- [ ] Named parameters in JPQL (`:param` not `?1`)
- [ ] Transaction annotation on service implementation (not interface)

### Testing
- [ ] GWT structure with blank-line separation
- [ ] `@Nested` for grouping
- [ ] Project-specific test annotations used
- [ ] AssertJ only (no JUnit assertEquals)

### Documentation
- [ ] All public API methods have Javadoc
- [ ] No version annotations

### Security
- [ ] No sensitive data in logs
- [ ] Authorization check on all write operations
- [ ] No SQL string concatenation (parameterized queries only)

---

## Output

**Full Story Review**: `{project}/.github/reviews/review-{STORY-NUMBER}-{description}-{DATE}.md`
**File Review**: `{project}/.github/reviews/file-review-{STORY-NUMBER}-{filename}-{DATE}.md`

**Report structure**:

```markdown
# Code Review: {STORY or File} — {DATE}

## Summary
**Status**: ✅ Approve | ⚠️ Improvements recommended | ❌ Changes Required

## Acceptance Criteria (full story review only)
| Criterion | Status |
|-----------|--------|
| {Criterion} | ✅/⚠️/❌ |

## Findings

### Critical (must fix before merge)
- **{File}:{Line}** — {Finding}: {Explanation}

### Major (should fix)
- **{File}:{Line}** — {Finding}: {Explanation}

### Minor (consider fixing)
- **{File}:{Line}** — {Finding}: {Explanation}

### Positive Observations
- {What was done well}

## Recommendations
- [ ] {Required change}

## Conclusion
{Short final assessment}
```
