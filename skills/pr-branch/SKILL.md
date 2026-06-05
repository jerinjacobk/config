---
name: pr-branch
description: Create a new feature branch using the project's naming convention from commits on HEAD. Use when the user wants a new branch from current work or asks for branch naming that matches existing branches.
---

# PR Branch Creator

Create a new feature branch using the project's naming convention, derived from the current commit(s) on HEAD.

## Workflow

1. **Get the git username prefix** from the configured email:

```bash
git config user.email
```

Extract the local part before `@` (e.g. `jerinj@marvell.com` → `jerinj`).

2. **Sample existing branches** to confirm the convention:

```bash
git branch -a --sort=-committerdate | head -20
```

Convention: `<user>-<area>-<description>` where description words are joined with `_`.

3. **Analyze current changes** to determine `<area>` and `<description>`:

```bash
git log main..HEAD --oneline
git diff main..HEAD --stat
```

- `<area>`: the primary subsystem being changed (e.g. `tracker`, `infra`, `docs`). Infer from the most-touched top-level directory or the scope in commit subjects like `fix(validate):` → `validate`.
- `<description>`: 1–4 word slug summarizing **all** commits from main to HEAD, underscore-separated, lowercase (e.g. `mcp_integration`, `sprint_updates`, `epic_link_fix`). Read all subjects via `git log main..HEAD --oneline` and distill a single description covering the combined scope.

4. **Create the branch**:

```bash
git checkout -b <user>-<area>-<description>
```

Example: `git checkout -b pbhagavatula-validate-exclude_closed`

5. **Print the result** and ask whether to push with `git push -u origin HEAD`.
