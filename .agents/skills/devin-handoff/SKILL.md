---
name: devin-handoff
description: >
  Hand off a task to a cloud Devin session, OR inspect/resolve an existing
  Devin session. Use when the task needs
  Devin's full environment (VM, browser, shell) — e.g. multi-file changes,
  tasks needing a running server, CI work, or long-running autonomous work.
  ALSO use whenever you're given a Devin session URL or session ID (e.g.
  https://app.devin.ai/sessions/... or *.devinenterprise.com/sessions/...) and
  need to find its PR, status, branch, or latest message — the `check`/`poll`
  commands resolve a session into its PR URL and status without opening the web UI.
---

# Devin Handoff

Hand off a task to Devin. Devin gets its own VM with shell, browser,
and full repo access. You get a URL to watch progress, or can poll
until the session completes.

All `scripts/devin-handoff.sh` paths below are relative to this skill's
directory. If installed as a Claude Code or Codex plugin, use
`"${CLAUDE_PLUGIN_ROOT}/.agents/skills/devin-handoff/scripts/devin-handoff.sh"`.

## Prerequisites

- `DEVIN_API_KEY` env var (get one at https://app.devin.ai/settings/api-keys)
- `curl`, `jq` in PATH
- `git` (optional, for auto-detecting repo/branch/diff)

## When to use

- Task needs a running server, database, or Docker
- Task requires browser interaction (OAuth, screenshots, E2E tests)
- Task involves CI/CD pipelines or deployments
- Task is long-running and the user wants to continue locally
- You need parallel execution on a separate machine

## Steps

### 1. Gather context

From the current working directory:

1. **Repo**: Run `git remote get-url origin`, extract `owner/repo`
2. **Branch**: Run `git rev-parse --abbrev-ref HEAD`
3. **Diff**: Run `git diff HEAD` (truncated to 100KB automatically)
4. **Task**: The user's request, concise and specific
5. **Context** (optional): Summarize what you've learned — files examined,
   root cause hypotheses, partial fixes

### 2. Create the session

```bash
scripts/devin-handoff.sh create \
  --task "Fix the auth timeout bug — update middleware to respect configured timeout" \
  --context "Investigated src/auth/session.py and src/auth/middleware.py. Timeout is hardcoded at 30m in session.py:42."
```

The script auto-detects repo, branch, and diff. The `--context` flag is
optional but helps Devin start faster. All sessions are automatically
tagged with `handoff`.

### 3. Report the URL and poll

Tell the user the session URL. If they want to wait for completion,
poll until the session finishes:

```bash
scripts/devin-handoff.sh poll SESSION_ID --interval 15
```

The poll command prints status updates and exits when Devin finishes.
It also prints the PR URL if one was created.

### 4. Archive when done (optional)

Archive a session to clean it up from the sidebar:

```bash
scripts/devin-handoff.sh archive SESSION_ID --org-id ORG_ID
```

Or use `--archive` on `poll` to auto-archive when the session finishes:

```bash
scripts/devin-handoff.sh poll SESSION_ID --interval 15 --archive --org-id ORG_ID
```
