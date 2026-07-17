#!/usr/bin/env bash

set -euo pipefail

readonly TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$TEST_DIR/.." && pwd)"
readonly HANDOFF_SCRIPT="$REPO_ROOT/.agents/skills/devin-handoff/scripts/devin-handoff.sh"
readonly TEST_TMP="$(mktemp -d "${TMPDIR:-/tmp}/devin-handoff-test.XXXXXX")"
readonly CURL_COUNT_FILE="$TEST_TMP/curl-count"
readonly SLEEP_COUNT_FILE="$TEST_TMP/sleep-count"

cleanup() {
  rm -rf "$TEST_TMP"
}
trap cleanup EXIT

# Exported functions replace network and timing commands in the child Bash
# process that runs devin-handoff.sh.
curl() {
  local count=0
  [[ -s "$MOCK_CURL_COUNT_FILE" ]] && count=$(<"$MOCK_CURL_COUNT_FILE")
  printf '%s\n' "$((count + 1))" >"$MOCK_CURL_COUNT_FILE"
  printf '%s\n200\n' "$MOCK_BODY"
}

sleep() {
  local count=0
  [[ -s "$MOCK_SLEEP_COUNT_FILE" ]] && count=$(<"$MOCK_SLEEP_COUNT_FILE")
  printf '%s\n' "$((count + 1))" >"$MOCK_SLEEP_COUNT_FILE"
  return "${MOCK_SLEEP_EXIT:-99}"
}

export -f curl sleep

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

assert_eq() {
  local expected="$1" actual="$2" message="$3"
  [[ "$actual" == "$expected" ]] || fail "$message (expected=$expected actual=$actual)"
}

assert_contains() {
  local value="$1" expected="$2" message="$3"
  [[ "$value" == *"$expected"* ]] || fail "$message"
}

assert_not_contains() {
  local value="$1" unexpected="$2" message="$3"
  [[ "$value" != *"$unexpected"* ]] || fail "$message"
}

read_count() {
  local file="$1"
  if [[ -s "$file" ]]; then
    printf '%s' "$(<"$file")"
  else
    printf '0'
  fi
}

run_poll() {
  local body="$1"
  rm -f "$CURL_COUNT_FILE" "$SLEEP_COUNT_FILE"

  set +e
  RUN_OUTPUT=$(
    MOCK_BODY="$body" \
    MOCK_CURL_COUNT_FILE="$CURL_COUNT_FILE" \
    MOCK_SLEEP_COUNT_FILE="$SLEEP_COUNT_FILE" \
    MOCK_SLEEP_EXIT=99 \
    DEVIN_API_KEY=cog_test \
    DEVIN_ORG_ID=org-test \
      "$HANDOFF_SCRIPT" poll devin-example --interval 1 2>&1
  )
  RUN_RC=$?
  set -e
}

test_finished_is_terminal() {
  run_poll '{"status":"running","status_detail":"finished","title":"Finished session","pull_requests":[],"url":"https://app.devin.ai/sessions/example"}'

  assert_eq 0 "$RUN_RC" "running/finished should exit successfully"
  assert_eq 1 "$(read_count "$CURL_COUNT_FILE")" "running/finished should make one request"
  assert_eq 0 "$(read_count "$SLEEP_COUNT_FILE")" "running/finished should not sleep"
  assert_contains "$RUN_OUTPUT" "Session finished: status=running (finished)" "running/finished should print the terminal summary"
  printf 'ok - running/finished is terminal\n'
}

test_waiting_for_user_remains_terminal() {
  run_poll '{"status":"running","status_detail":"waiting_for_user","title":"Waiting session","pull_requests":[]}'

  assert_eq 0 "$RUN_RC" "running/waiting_for_user should exit successfully"
  assert_eq 1 "$(read_count "$CURL_COUNT_FILE")" "running/waiting_for_user should make one request"
  assert_eq 0 "$(read_count "$SLEEP_COUNT_FILE")" "running/waiting_for_user should not sleep"
  printf 'ok - running/waiting_for_user remains terminal\n'
}

test_failure_status_takes_precedence() {
  run_poll '{"status":"error","status_detail":"finished","title":"Failed session","pull_requests":[]}'

  assert_eq 1 "$RUN_RC" "error/finished should remain a failure"
  assert_eq 1 "$(read_count "$CURL_COUNT_FILE")" "error/finished should make one request"
  assert_eq 0 "$(read_count "$SLEEP_COUNT_FILE")" "error/finished should not sleep"
  printf 'ok - top-level failure takes precedence\n'
}

test_working_remains_non_terminal() {
  run_poll '{"status":"running","status_detail":"working","title":"Working session","pull_requests":[]}'

  assert_eq 99 "$RUN_RC" "running/working should continue to sleep"
  assert_eq 1 "$(read_count "$CURL_COUNT_FILE")" "running/working should make one request before sleeping"
  assert_eq 1 "$(read_count "$SLEEP_COUNT_FILE")" "running/working should invoke sleep"
  assert_not_contains "$RUN_OUTPUT" "Session finished:" "running/working should not print the terminal summary"
  printf 'ok - running/working remains non-terminal\n'
}

test_finished_is_terminal
test_waiting_for_user_remains_terminal
test_failure_status_takes_precedence
test_working_remains_non_terminal

printf 'all poll terminal-state tests passed\n'
