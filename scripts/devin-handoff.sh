#!/usr/bin/env bash
#
# devin-handoff.sh — Hand off a task to a cloud Devin session.
#
# Usage:
#   devin-handoff.sh create --task TASK [--context CONTEXT] [--tag TAG] [--api-url URL]
#   devin-handoff.sh poll SESSION_ID [--interval SECS] [--api-url URL]
#   devin-handoff.sh archive SESSION_ID [--api-url URL] [--org-id ORG]
#   devin-handoff.sh --help
#   devin-handoff.sh --version
#
# Requires: curl, jq, git (optional, for auto-context)
# Environment: DEVIN_API_KEY must be set.

set -euo pipefail

readonly VERSION="1.2.0"
readonly MAX_DIFF_BYTES=102400  # 100KB
readonly DEFAULT_POLL_INTERVAL=30

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

die() { echo "error: $*" >&2; exit 1; }

usage() {
  cat <<EOF
Usage:
  devin-handoff.sh create --task TASK [OPTIONS]
  devin-handoff.sh poll SESSION_ID [OPTIONS]

Commands:
  create    Create a Devin session and print the session URL
  poll      Poll a session until it reaches a terminal state
  archive   Archive a completed session

create options:
  --task      Task description for Devin (required)
  --context   Additional context (files examined, findings, partial fixes)
  --tag       Extra tag (in addition to the default "handoff" tag)
  --api-url   Devin API base URL (default: https://api.devin.ai)
  --org-id    Organization ID (required for service keys)
  --user-id   Create session as this user (service keys only)

poll options:
  --interval  Polling interval in seconds (default: 30)
  --archive   Archive the session when it finishes
  --api-url   Devin API base URL (default: https://api.devin.ai)
  --org-id    Organization ID (required for service keys)

archive options:
  --api-url   Devin API base URL (default: https://api.devin.ai)
  --org-id    Organization ID (required for service keys)

Global:
  --help      Show this help message
  --version   Show version

Environment:
  DEVIN_API_KEY   Required. Personal (apk_*) or service (cog_*) key.
  DEVIN_ORG_ID    Optional. Organization ID for service keys.
  DEVIN_USER_ID   Optional. User ID for service keys.

Examples:
  devin-handoff.sh create --task "Fix the auth timeout bug"

  devin-handoff.sh create \\
    --task "Add rate limiting to /api/users" \\
    --context "Investigated src/api/users.py. No rate limiting exists."

  devin-handoff.sh poll devin-abc123 --interval 15

  devin-handoff.sh archive devin-abc123
EOF
  exit 0
}

check_deps() {
  for cmd in curl jq; do
    command -v "$cmd" >/dev/null 2>&1 || die "'$cmd' is required but not found."
  done
}

# Resolve the API endpoint base for the current key type.
# Sets $endpoint_base to either v1 or v3 prefix.
resolve_api_base() {
  local api_url="$1" org_id="$2"
  if [[ "$DEVIN_API_KEY" == cog_* ]]; then
    [[ -z "$org_id" ]] && die "--org-id (or DEVIN_ORG_ID) is required for service keys (cog_*)"
    echo "$api_url/v3/organizations/$org_id"
  else
    echo "$api_url/v1"
  fi
}

# Make an API request; prints body, returns non-zero on HTTP error.
api_request() {
  local method="$1" url="$2" data="${3:-}"
  local response http_code body curl_args=(-s -w $'\n%{http_code}' -X "$method"
    -H "Authorization: Bearer $DEVIN_API_KEY"
    -H "Content-Type: application/json")
  [[ -n "$data" ]] && curl_args+=(-d "$data")

  response=$(curl "${curl_args[@]}" "$url")
  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')

  if [[ "$http_code" -lt 200 || "$http_code" -ge 300 ]]; then
    local err_msg
    err_msg=$(echo "$body" | jq -r '.detail // .message // .error // "Unknown error"' 2>/dev/null || echo "$body")
    die "API returned HTTP $http_code: $err_msg"
  fi
  echo "$body"
}

# ---------------------------------------------------------------------------
# Git context gathering
# ---------------------------------------------------------------------------

get_repo_slug() {
  local remote
  remote=$(git remote get-url origin 2>/dev/null) || return 1
  echo "$remote" \
    | sed -E 's#^(ssh://)?git@[^:/]+[:/]##' \
    | sed -E 's#^https?://[^/]+/##' \
    | sed -E 's/\.git$//'
}

get_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || echo ""
}

get_diff() {
  git diff HEAD 2>/dev/null | head -c "$MAX_DIFF_BYTES" || echo ""
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

cmd_create() {
  local task="" context="" extra_tag="" api_url="${DEVIN_API_URL:-https://api.devin.ai}" org_id="${DEVIN_ORG_ID:-}" user_id="${DEVIN_USER_ID:-}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --task)    task="$2"; shift 2 ;;
      --context) context="$2"; shift 2 ;;
      --tag)     extra_tag="$2"; shift 2 ;;
      --api-url) api_url="$2"; shift 2 ;;
      --org-id)  org_id="$2"; shift 2 ;;
      --user-id) user_id="$2"; shift 2 ;;
      *)         die "Unknown option: $1 (see --help)" ;;
    esac
  done

  [[ -z "$task" ]] && die "--task is required"
  [[ -z "${DEVIN_API_KEY:-}" ]] && die "DEVIN_API_KEY is not set. Get a key at https://app.devin.ai/settings/api-keys"
  check_deps

  # Gather git context (best-effort)
  local repo="" branch="" diff=""
  if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
    repo=$(get_repo_slug || echo "")
    branch=$(get_branch)
    diff=$(get_diff)
  fi

  # Build prompt
  local prompt="$task"
  local details=""
  [[ -n "$repo" ]]    && details+="Repo: $repo"$'\n'
  [[ -n "$branch" ]]  && details+="Branch: $branch"$'\n'
  [[ -n "$context" ]] && details+=$'\n'"$context"$'\n'

  if [[ -n "$details" ]]; then
    prompt+=$'\n\n'"<details>"$'\n'"<summary>Context from local environment</summary>"$'\n\n'
    prompt+="$details"
    prompt+=$'\n'"</details>"
  fi

  if [[ -n "$diff" ]]; then
    prompt+=$'\n\n'"<details>"$'\n'"<summary>Uncommitted local changes (diff)</summary>"$'\n\n'
    prompt+='```diff'$'\n'"$diff"$'\n''```'$'\n\n'
    prompt+="</details>"
  fi

  # Build tags array: always include "handoff", plus optional extra tag
  local tags_expr='["handoff"]'
  if [[ -n "$extra_tag" && "$extra_tag" != "handoff" ]]; then
    # shellcheck disable=SC2016
    tags_expr='["handoff", $extra_tag]'
  fi

  # Build JSON payload
  local json
  local jq_args=(--arg title "${task:0:100}")
  [[ -n "$extra_tag" && "$extra_tag" != "handoff" ]] && jq_args+=(--arg extra_tag "$extra_tag")
  if [[ -n "$user_id" && "$DEVIN_API_KEY" == cog_* ]]; then
    jq_args+=(--arg uid "$user_id")
    json=$(printf '%s' "$prompt" | jq -Rs "${jq_args[@]}" \
      '{prompt: ., title: $title, tags: '"$tags_expr"', create_as_user_id: $uid}')
  else
    json=$(printf '%s' "$prompt" | jq -Rs "${jq_args[@]}" \
      '{prompt: ., title: $title, tags: '"$tags_expr"'}')
  fi

  local base
  base=$(resolve_api_base "$api_url" "$org_id")
  local body
  body=$(api_request POST "$base/sessions" "$json")

  local session_url session_id
  session_url=$(echo "$body" | jq -r '.url // empty')
  session_id=$(echo "$body" | jq -r '.session_id // empty')

  if [[ -z "$session_url" ]]; then
    if [[ -n "$session_id" ]]; then
      session_url="https://app.devin.ai/sessions/${session_id#devin-}"
    else
      die "No session URL or ID in response: $body"
    fi
  fi

  echo "$session_url"
  echo ""
  echo "To poll until completion:"
  echo "  devin-handoff.sh poll $session_id --api-url $api_url${org_id:+ --org-id $org_id}"
}

cmd_poll() {
  local session_id="${1:-}"; shift || true
  local interval="$DEFAULT_POLL_INTERVAL" api_url="${DEVIN_API_URL:-https://api.devin.ai}" org_id="${DEVIN_ORG_ID:-}" do_archive=false

  [[ -z "$session_id" ]] && die "poll requires a SESSION_ID argument"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --interval) interval="$2"; shift 2 ;;
      --archive)  do_archive=true; shift ;;
      --api-url)  api_url="$2"; shift 2 ;;
      --org-id)   org_id="$2"; shift 2 ;;
      *)          die "Unknown option: $1 (see --help)" ;;
    esac
  done

  if [[ "$do_archive" == true && -z "$org_id" ]]; then
    die "--org-id (or DEVIN_ORG_ID) is required when using --archive"
  fi

  [[ -z "${DEVIN_API_KEY:-}" ]] && die "DEVIN_API_KEY is not set."
  check_deps

  # Normalize session_id
  [[ "$session_id" != devin-* ]] && session_id="devin-$session_id"

  local base
  base=$(resolve_api_base "$api_url" "$org_id")

  echo "Polling $session_id every ${interval}s..." >&2

  while true; do
    local body status status_detail
    body=$(api_request GET "$base/sessions/$session_id")
    status=$(echo "$body" | jq -r '.status // "unknown"')

    # v3 returns status_detail, v1 returns just status
    status_detail=$(echo "$body" | jq -r '.status_detail // empty')

    echo "[$(date +%H:%M:%S)] status=$status${status_detail:+ detail=$status_detail}" >&2

    case "$status" in
      # Terminal states
      exit|error|suspended)
        local pr_url title
        title=$(echo "$body" | jq -r '.title // empty')
        # v1 nests PR under pull_request.url; v3 under pull_requests[0].url
        pr_url=$(echo "$body" | jq -r '(.pull_request.url // .pull_requests[0].url) // empty' 2>/dev/null)

        echo ""
        echo "Session finished: status=$status${status_detail:+ ($status_detail)}"
        [[ -n "$title" ]] && echo "Title: $title"
        [[ -n "$pr_url" ]] && echo "PR: $pr_url"
        echo "$body" | jq -r '.url // empty' | grep -q . && echo "URL: $(echo "$body" | jq -r '.url')"

        # Archive if requested
        if [[ "$do_archive" == true ]]; then
          echo "Archiving session..." >&2
          api_request POST "$api_url/v3/organizations/$org_id/sessions/$session_id/archive" >/dev/null 2>&1 \
            && echo "Archived." >&2 \
            || echo "Warning: archive failed." >&2
        fi

        # Exit 0 for successful finish, 1 for error
        [[ "$status" == "exit" && "$status_detail" == "finished" ]] && exit 0
        [[ "$status" == "exit" ]] && exit 0
        exit 1
        ;;
    esac

    sleep "$interval"
  done
}

cmd_archive() {
  local session_id="${1:-}"; shift || true
  local api_url="${DEVIN_API_URL:-https://api.devin.ai}" org_id="${DEVIN_ORG_ID:-}"

  [[ -z "$session_id" ]] && die "archive requires a SESSION_ID argument"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --api-url) api_url="$2"; shift 2 ;;
      --org-id)  org_id="$2"; shift 2 ;;
      *)         die "Unknown option: $1 (see --help)" ;;
    esac
  done

  [[ -z "${DEVIN_API_KEY:-}" ]] && die "DEVIN_API_KEY is not set."
  check_deps

  # Normalize session_id
  [[ "$session_id" != devin-* ]] && session_id="devin-$session_id"

  # Archive is v3-only; require org_id for all key types
  [[ -z "$org_id" ]] && die "--org-id (or DEVIN_ORG_ID) is required for archive"

  local base="$api_url/v3/organizations/$org_id"
  local body
  body=$(api_request POST "$base/sessions/$session_id/archive")

  local title status
  title=$(echo "$body" | jq -r '.title // empty')
  status=$(echo "$body" | jq -r '.status // empty')

  echo "Archived: $session_id"
  [[ -n "$title" ]] && echo "Title: $title"
  [[ -n "$status" ]] && echo "Status: $status"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

case "${1:-}" in
  --help|-h)    usage ;;
  --version|-v) echo "devin-handoff $VERSION"; exit 0 ;;
  create)       shift; cmd_create "$@" ;;
  poll)         shift; cmd_poll "$@" ;;
  archive)      shift; cmd_archive "$@" ;;
  "")           usage ;;
  *)            die "Unknown command: $1 (see --help)" ;;
esac
