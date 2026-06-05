# Codex Setup

## Installation

### Option A: Plugin (recommended — 1-click install)

```bash
codex plugin marketplace add club-cog/devin-handoff
codex plugin add devin-handoff@cognition
```

This installs the `devin-handoff` skill for all your projects. Update later
with `codex plugin marketplace upgrade cognition`.

### Option B: AGENTS.md (per-repo)

Codex also reads `AGENTS.md` files for agent guidance. You can:

1. Copy the handoff script into your repo
2. Add the agent guidance to your `AGENTS.md`

```bash
# From your project root
mkdir -p scripts
cp /path/to/devin-handoff/.agents/skills/devin-handoff/scripts/devin-handoff.sh scripts/devin-handoff.sh
chmod +x scripts/devin-handoff.sh

# Append the Devin handoff guidance to your AGENTS.md
echo "" >> AGENTS.md
cat /path/to/devin-handoff/AGENTS.md >> AGENTS.md
```

## API Key Setup

Set your Devin API key:

```bash
export DEVIN_API_KEY="apk_your_key_here"
```

Get a key at [https://app.devin.ai/settings/api-keys](https://app.devin.ai/settings/api-keys).

## Usage

With the `AGENTS.md` guidance in place, Codex will know when and how to
hand off tasks to Devin. You can ask:

- *"Hand this off to Devin"*
- *"This needs a running server — use Devin"*
- *"Ask Devin to handle the CI pipeline fix"*

### What happens

1. Codex reads the guidance from `AGENTS.md`
2. It gathers context from the current repo
3. It runs `scripts/devin-handoff.sh create --task "..." --context "..."`
4. A Devin session URL is printed
5. Codex shares the URL and moves on

## Example

```
You: The E2E tests are failing in CI. Hand this off to Devin — it needs a browser.

Codex: I'll hand this off to Devin.

$ scripts/devin-handoff.sh create \
    --task "Fix failing E2E tests in CI — needs browser environment" \
    --context "Tests in tests/e2e/ are timing out. Likely a selector issue after the UI redesign."

https://app.devin.ai/sessions/def456

Devin session created. You can follow progress at the link above.
```
