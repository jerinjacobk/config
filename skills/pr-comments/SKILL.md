---
name: pr-comments
description: Analyze and validate PR review comments. Triage by severity (must-fix, suggestion, nit), check if each has been addressed in code or replied to, and offer to fix unresolved ones. Use when the user asks to review, check, validate, or triage PR comments.
disable-model-invocation: true
---

# PR Comment Analyzer

Given a PR URL or number, fetch all review comments, triage them by severity, check whether each has been addressed, and produce an actionable checklist.

## Workflow

### 1. Fetch PR comments

```bash
# Get PR comments (review comments on diffs)
gh api repos/{owner}/{repo}/pulls/{number}/comments

# Get PR review summaries (top-level reviews)
gh api repos/{owner}/{repo}/pulls/{number}/reviews

# Get the PR diff
gh pr diff {number}
```

Extract from each comment: `id`, `path`, `line`/`original_line`, `body`, `user.login`, `created_at`, `in_reply_to_id` (for threaded replies).

### 2. Triage each comment

Classify every comment into one of:

| Severity | Criteria | Label |
|----------|----------|-------|
| **must-fix** | Bugs, logic errors, security issues, broken behavior, explicit "must fix" / "blocking" language | `[MUST-FIX]` |
| **suggestion** | Refactoring, better naming, alternative approach, performance improvement, "consider" / "maybe" / "what about" language | `[SUGGESTION]` |
| **nit** | Style, formatting, typos, minor wording, "nit" / "minor" / "optional" language | `[NIT]` |
| **question** | Asks for clarification, no code change requested | `[QUESTION]` |
| **praise** | Positive feedback, "nice", "LGTM", "+1" | `[PRAISE]` |

### 3. Check if addressed

For each non-praise comment, determine if it has been addressed:

- **Addressed in code**: The current diff (or subsequent commits) contains changes at the file+line the comment references that align with the feedback.
- **Replied to**: A reply from the PR author acknowledges or explains why it won't be changed.
- **Unresolved**: Neither code change nor author reply found.

To check, read the relevant file at the referenced lines:

```bash
# Read the current state of the file referenced by the comment
# Compare against what the comment asked for
```

### 4. Output checklist

Present results grouped by status, sorted by severity:

```markdown
## PR #{number} Comment Review

### Unresolved ({count})

- [ ] `[MUST-FIX]` **{file}:{line}** — @{reviewer}: "{comment summary}"
- [ ] `[SUGGESTION]` **{file}:{line}** — @{reviewer}: "{comment summary}"

### Addressed ({count})

- [x] `[MUST-FIX]` **{file}:{line}** — @{reviewer}: "{comment summary}"
  - Fixed in current code / Replied: "{reply summary}"

### No Action Needed ({count})

- [x] `[NIT]` **{file}:{line}** — @{reviewer}: "{comment summary}"
- [x] `[PRAISE]` @{reviewer}: "{comment summary}"
```

### 5. Offer to fix

After presenting the checklist, ask:

> Would you like me to fix the unresolved comments? I'll address must-fix items first, then suggestions.

If the user agrees, work through unresolved items one at a time, making the code changes and marking them off.

## Rules

- Truncate long comment bodies to ~80 chars in the checklist, with full text available on request.
- Group threaded replies with their parent comment — don't list replies as separate items.
- If a comment references a file/line that no longer exists (due to refactoring), note it as `[FILE MOVED]` and attempt to locate the equivalent code.
- Skip bot comments (e.g., CI bots, linters) unless they contain actionable feedback.
