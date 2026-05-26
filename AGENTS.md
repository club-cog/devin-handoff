# Devin Handoff — Agent Guide

## What this is

A script to hand off tasks to [Devin](https://devin.ai), a cloud AI software
engineer. Use it when a task needs a VM, browser, CI, or long-running execution.

## When to hand off

- **VM / server**: Running a dev server, testing endpoints, Docker builds
- **Browser**: Screenshots, OAuth flows, E2E testing, scraping
- **CI/CD**: Pipeline debugging, deployment, infrastructure changes
- **Long-running work**: Migrations, batch processing, large refactors
- **Parallel execution**: Offload work while you continue locally

## How to use

1. Gather context from the current repo (the script does this automatically)
2. Summarize what you've learned so far as `--context`
3. Run:

```bash
scripts/devin-handoff.sh create \
  --task "<concise task description>" \
  --context "<what you've found so far>"
```

4. Share the session URL with the user
5. To wait for completion, poll until Devin finishes:

```bash
scripts/devin-handoff.sh poll SESSION_ID --interval 15
```

The poll command prints status updates every N seconds and exits when
the session reaches a terminal state. It prints the PR URL if one was created.

6. To archive the session when done:

```bash
scripts/devin-handoff.sh archive SESSION_ID --org-id ORG_ID
```

Or auto-archive after polling: add `--archive --org-id ORG_ID` to the poll command.

## Requirements

- `DEVIN_API_KEY` environment variable must be set
- `curl` and `jq` must be available
- `git` is optional (for automatic repo/branch/diff detection)
