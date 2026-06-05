# Cursor Setup

## Installation

### Per-project

```bash
# From your project root
mkdir -p .cursor/skills
cp -r /path/to/devin-handoff/.agents/skills/devin-handoff/ .cursor/skills/devin-handoff/
```

Cursor also auto-discovers `.agents/skills/`, so committing the skill there
works too.

### Global (all projects)

```bash
mkdir -p ~/.cursor/skills
cp -r /path/to/devin-handoff/.agents/skills/devin-handoff/ ~/.cursor/skills/devin-handoff/
```

## API Key Setup

Set your Devin API key:

```bash
export DEVIN_API_KEY="apk_your_key_here"
```

Get a key at [https://app.devin.ai/settings/api-keys](https://app.devin.ai/settings/api-keys).

## Usage

Once installed, the agent will detect when a task is suited for Devin
(needs VM, browser, server, CI) and invoke the skill automatically.

You can also ask directly:

- *"Hand this off to Devin"*
- *"This needs Docker — use Devin for it"*
- *"Ask Devin to deploy the staging fix"*

### What happens

1. The agent gathers context from your repo (branch, diff, findings)
2. It runs `scripts/devin-handoff.sh create --task "..." --context "..."`
3. You get a Devin session URL
4. The agent moves on; you watch at the URL

## Example

```
You: Set up the Docker development environment. This needs a VM — hand it off to Devin.

Agent: I'll hand this off to Devin with the context I've gathered.

Running: scripts/devin-handoff.sh create \
  --task "Set up Docker dev environment with docker-compose" \
  --context "docker-compose.yml exists but needs updates for the new DB service."

Session created: https://app.devin.ai/sessions/ghi789

Handed off to Devin. You can monitor progress at the link above.
```
