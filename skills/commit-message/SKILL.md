---
name: commit-message
description: Generate and update a git commit message and body for a given commit ID by analyzing the diff. Use when the user provides a commit hash/ID and asks to generate, update, rewrite, or fix a commit message.
---

# Commit Message Generator

Given a commit ID, analyze its changes and generate a commit message + body that matches the project's existing conventions.

## Workflow

1. **Read the project's recent history** to learn the style:

```bash
git log -10 --format='subject: %s%nbody: %b%n----'
```

2. **Optional — match a maintainer's habit**: when the commit author is known (or the user names them), sample that author's subjects and bodies:

```bash
git log -20 --author=<email> --format='subject: %s%nbody: %b%n----'
```

Prefer this pattern over generic project history when it clearly matches (same subsystem, same `Signed-off-by`).

3. **Read the commit's diff**:

```bash
git log --oneline <COMMIT_ID> -1
git diff <COMMIT_ID>^..<COMMIT_ID> --stat
git diff <COMMIT_ID>^..<COMMIT_ID>
```

4. **Find regression metadata** (when the change fixes a bug or prior commit):

```bash
git log --oneline -10 -- <touched files>
git blame -L <range> <file>   # optional, to locate introducing commit
```

Add `Fixes: <12+ char hash> ("exact subject of bad commit")` on its own line in the body. For DPDK-style stable fixes, add `Cc: stable@dpdk.org` when appropriate. Preserve existing trailers (`Signed-off-by`, `Acked-by`, etc.).

5. **Generate the commit message** following the conventions from steps 1–2 (and DPDK rules below when this repo is DPDK).

6. **Output the full `git commit --amend` command** so the user can run it directly.

## Convention Detection

Detect and follow these from the project history (do not assume Conventional Commits unless the log shows them):

- **Subject format**: many trees use `subsystem: short imperative description` (e.g. DPDK: `common/cnxk: ...`, `event/cnxk: ...`). Else: Conventional Commits (`type(scope): description`), ticket prefixes, etc.
- **Type prefixes**: only when the project uses them: `feat`, `fix`, `refactor`, `perf`, `docs`, `data`, `test`, `chore`, etc.
- **Scope**: DPDK uses the leading `subsystem:` token, not `type(scope)`.
- **Body format**: prefer **short prose paragraphs** (blank line between paragraphs). Use **`- ` bullets only** if the project's recent commits for that author/subsystem consistently use bullets. Default to **no leading `-`** for DPDK-style patches.
- **Regression lines**: `Fixes:`, `Cc: stable@dpdk.org`, `Reported-by`, `Bugzilla ID:` — copy the project's spelling and placement (usually after the explanatory body, before `Signed-off-by`).
- **Trailers**: `Signed-off-by`, `Co-authored-by`, `Acked-by`, etc. — preserve any that exist on the commit.
- **Max line length**: match the project (often wrap body at ~72 columns).

## Message Rules

- **Subject line**: imperative mood, no trailing period; for DPDK, lowercase after `subsystem:` (e.g. `common/cnxk: fix ...`).
- **Type selection** (Conventional-Commits projects only): `feat` / `fix` / `refactor` / `perf` / `docs` / `data` / `test` / `chore` as appropriate.
- **Body**: concise prose explaining **why** and **what** changed; avoid bullet lists unless the target author consistently uses them.
- **Keep it concise**: subject ≤ 72 chars; body a few sentences unless complexity requires more.

## Output Format

Always output the amend command using a HEREDOC:

~~~bash
git commit --amend -m "$(cat <<'EOF'
subsystem: subject line here

Short prose explaining the change. Second paragraph if needed.

Fixes: abcdef123456 ("subject of commit being fixed")
Cc: stable@dpdk.org

Signed-off-by: Name <email>
EOF
)"
~~~

If the commit has not been pushed, this is safe. Warn the user if `git status` shows the branch is not ahead of the remote (i.e., the commit has already been pushed).
