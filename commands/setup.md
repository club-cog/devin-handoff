---
description: Check that Devin Handoff is ready to use (dependencies + API key)
---

Verify the Devin Handoff plugin is ready to use. Work through these checks
in order and report the results concisely. Never print the API key value.

1. **Dependencies**: check that `curl` and `jq` are available
   (`command -v curl jq`). If `jq` is missing, offer the right install
   command for the user's platform (`brew install jq`, `sudo apt-get install jq`, etc.).

2. **API key**: check that `DEVIN_API_KEY` is set (`[ -n "$DEVIN_API_KEY" ]`).
   If it's missing:
   - Tell the user to get a key at https://app.devin.ai/settings/api-keys
   - Offer to append `export DEVIN_API_KEY="<their key>"` to their shell
     profile (`~/.zshrc`, `~/.bashrc`, ...)
   - Remind them that Claude Code inherits the environment from the shell it
     was launched from, so they need to restart Claude Code after setting it
   - Stop here and let them come back to `/devin-handoff:setup` afterward

3. **Validate the key** with a cheap API call:
   - If the key starts with `cog_` (service key), check that `DEVIN_ORG_ID`
     is also set — service keys require an org ID. Validate with:
     `curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $DEVIN_API_KEY" "https://api.devin.ai/v3/organizations/$DEVIN_ORG_ID/sessions?limit=1"`
   - Otherwise (personal `apk_` key), validate with:
     `curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $DEVIN_API_KEY" "https://api.devin.ai/v1/sessions?limit=1"`
   - `200` means the key works. `401`/`403` means it's invalid or expired —
     point the user back to https://app.devin.ai/settings/api-keys

4. **Report**: if everything passes, tell the user Devin Handoff is ready and
   they can ask things like "hand this off to Devin" or "have Devin fix the
   flaky CI test" from any repo.
