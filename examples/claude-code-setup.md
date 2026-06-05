# Claude Code Setup

## Installation

### Option A: Plugin (recommended — 1-click install)

From inside Claude Code:

```
/plugin marketplace add club-cog/devin-handoff
/plugin install devin-handoff@cognition
```

This installs the skill for all your projects and pulls updates when you run
`/plugin marketplace update cognition`.

### Option B: Per-project skill (for teams)

```bash
# From your project root
mkdir -p .claude/skills
cp -r /path/to/devin-handoff/.agents/skills/devin-handoff/ .claude/skills/devin-handoff/
```

This makes the skill available to everyone working on the project.

### Option C: Global skill (manual copy)

```bash
cp -r /path/to/devin-handoff/.agents/skills/devin-handoff/ ~/.claude/skills/devin-handoff/
```

## API Key Setup

Set your Devin API key as an environment variable:

```bash
export DEVIN_API_KEY="apk_your_key_here"
```

Get a key at [https://app.devin.ai/settings/api-keys](https://app.devin.ai/settings/api-keys).

To persist it, add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
echo 'export DEVIN_API_KEY="apk_your_key_here"' >> ~/.zshrc
```

## Usage

Once installed, Claude Code will automatically detect when a task is a good
fit for Devin (needs a VM, browser, server, CI, etc.) and invoke the skill.

You can also ask explicitly:

- *"Hand this off to Devin"*
- *"Use Devin to deploy the staging fix"*
- *"Ask Devin to fix the flaky CI test — it needs a running server"*

### What happens

1. Claude Code gathers context from your current repo (branch, diff, etc.)
2. It runs `scripts/devin-handoff.sh create --task "..." --context "..."`
3. A Devin session is created and you get a URL
4. Claude Code moves on; you watch Devin's progress at the URL

## Example

```
You: Fix the auth timeout bug. It needs a running server to test — hand it off to Devin.

Claude Code: I'll hand this off to Devin with the context I've gathered.

Running: scripts/devin-handoff.sh create \
  --task "Fix auth timeout bug — middleware uses hardcoded 30m instead of configured value" \
  --context "Root cause in src/auth/middleware.py:87. Session.py:42 has DEFAULT_TIMEOUT=1800."

Devin session created: https://app.devin.ai/sessions/abc123

I've handed the task off to Devin. You can watch progress at the link above.
```
