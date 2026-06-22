# Pro Plan — First-14-Day Behaviors Predicting D30 Retention (Last 45 Days)

**Goal:** Identify which first-14-day in-product behaviors predict higher D30 retention for Pro users, using the most recent cohort to reflect current product state. Net cast as wide as possible — every available behavioral signal, not just known features.

## Cohort

- **Plan:** Pro (via `dim_user_orgs` priority mapping)
- **Signup window:** created 52–37 days ago (recent cohorts, all D30-eligible). n ≥ 300 so no expansion to 60–37 needed.
- **Filters:** web-active (≥1 `User:Navigate:Page`); activated (≥1 usage day — session OR ACU-consumption — in first 14d); excludes `is_cognition_user` / `is_synthetic_user`; excludes the 2026-04-13→04-20 bulk-provisioning cohort.
- **Exact cohort n = 5,752**
- **Baseline D30 retention = 49.1%** (2,822/5,752)
- **D30 definition:** ≥1 usage day (session OR ACU-consumption) on days 23–37 from signup.

> **Read this first — cohort structure drives interpretation.** Of the 5,752 activated Pro users, **4,707 (82%) activated via ACU-consumption only and have ZERO Devin web sessions** in their first 14 days, yet they retain at **52.2% D30 — above the 49.1% baseline.** Because every in-session feature toggle (PART 1 + most of PART 3) is, by construction, only available to the ~18% who *did* run a Devin session, those binary features are compared against this large, higher-retaining session-less mass and therefore skew toward RR D30 < 1. This is the **same structural artifact** seen in the 90-day analyses — it is NOT evidence that the features hurt retention. The signals that are measured uniformly across the whole cohort (usage **cadence / intensity** in PART 2) are the trustworthy predictors.

## PART 1 — Known feature behaviors (binary: used ≥1× in first 14d vs never)

| Feature | Used n | Used D30% | Not-used D30% | RR D30 | Chi-sq p | Sig |
|---|---:|---:|---:|---:|---:|:--:|
| `structured_output_update` | 10 | 90.0% | 49.0% | 1.837 | 2.29e-02 | **yes** ⚠️ LOW-N |
| `automation_create` | 15 | 60.0% | 49.0% | 1.224 | 5.55e-01 | no ⚠️ LOW-N |
| `playbook_triggered` | 17 | 58.8% | 49.0% | 1.200 | 5.73e-01 | no ⚠️ LOW-N |
| `pr_comment` | 97 | 55.7% | 48.9% | 1.137 | 2.26e-01 | no |
| `check_run_created` | 182 | 48.9% | 49.1% | 0.997 | 1.00e+00 | no |
| `suggest_testing_setup` | 157 | 45.2% | 49.2% | 0.920 | 3.71e-01 | no |
| `has_merge` | 336 | 44.0% | 49.4% | 0.892 | 6.60e-02 | no |
| `has_pr` | 484 | 41.5% | 49.8% | 0.835 | 6.35e-04 | **yes** |
| `checkpoint_restored` | 261 | 41.0% | 49.4% | 0.829 | 9.21e-03 | **yes** |
| `mcp_tool_call` | 208 | 40.4% | 49.4% | 0.818 | 1.32e-02 | **yes** |
| `computer_use` | 619 | 36.0% | 50.6% | 0.712 | 8.80e-12 | **yes** |
| `devin_review` | 1046 | 36.4% | 51.9% | 0.702 | 2.17e-19 | **yes** |
| `web_search` | 483 | 34.4% | 50.4% | 0.682 | 2.07e-11 | **yes** |
| `mcp_shortcut` | 0 | 0.0% | 49.1% | 0.000 | n/a | — ⚠️ LOW-N |

*`mcp_shortcut` (`Composer:Insert:MCPShortcut`): 0 users in cohort. Searched event families with no qualifying volume and excluded: Ask/Ada mode, Dana agent, Schedule:Create, Knowledge:Create, Managed Devin (0 events); `Replay:Complete:Session` present but only 5 users → LOW-N, dropped.*

## PART 3 — Newly discovered behaviors (not in the original known list)

Surfaced by scanning all first-14d `analytics_events` event names and `devin_events` types for the cohort, ranked by distinct users. All tested the same way (binary used vs never):

| Behavior | Used n | Used D30% | Not-used D30% | RR D30 | Chi-sq p | Sig |
|---|---:|---:|---:|---:|---:|:--:|
| `index_repo` | 11 | 54.5% | 49.1% | 1.112 | 9.50e-01 | no ⚠️ LOW-N |
| `deepwiki_view` | 113 | 53.1% | 49.0% | 1.084 | 4.40e-01 | no |
| `slash_command` | 20 | 50.0% | 49.1% | 1.019 | 1.00e+00 | no ⚠️ LOW-N |
| `devin_takeover_pr` | 43 | 46.5% | 49.1% | 0.948 | 8.55e-01 | no ⚠️ LOW-N |
| `merge_via_devin_ui` | 91 | 44.0% | 49.1% | 0.894 | 3.81e-01 | no |
| `note_used` | 339 | 44.0% | 49.4% | 0.890 | 5.96e-02 | no |
| `devin_create_pr` | 480 | 41.5% | 49.8% | 0.833 | 5.98e-04 | **yes** |
| `voice_recording` | 66 | 40.9% | 49.2% | 0.832 | 2.27e-01 | no |
| `git_push` | 495 | 41.4% | 49.8% | 0.832 | 4.43e-04 | **yes** |
| `test_recording` | 183 | 38.3% | 49.4% | 0.774 | 3.76e-03 | **yes** |
| `user_question_answered` | 701 | 37.1% | 50.7% | 0.731 | 1.75e-11 | **yes** |
| `web_get_contents` | 464 | 36.4% | 50.2% | 0.726 | 1.79e-08 | **yes** |
| `onboarding_tour` | 1046 | 35.7% | 52.0% | 0.685 | 1.28e-21 | **yes** |
| `tool_help_called` | 539 | 34.0% | 50.6% | 0.671 | 2.38e-13 | **yes** |
| `self_suspend` | 585 | 32.3% | 51.0% | 0.634 | 1.76e-17 | **yes** |
| `web_create_session` | 966 | 32.5% | 52.4% | 0.620 | 2.34e-29 | **yes** |

## PART 2 — Open behavioral signals (first 14 days)

### Volume signals

**Total Devin sessions** — overall chi-square across buckets p = 1.59e-22 (significant)  — note: 82% have 0 sessions (ACU-only activation)

| Bucket | n | D30% |
|---|---:|---:|
| 0 | 4707 | 52.2% |
| 1 | 298 | 35.2% |
| 2-3 | 298 | 30.5% |
| 4-7 | 253 | 36.0% |
| 8+ | 196 | 38.8% |

**Total PRs created** — overall chi-square across buckets p = 9.39e-05 (significant)

| Bucket | n | D30% |
|---|---:|---:|
| 0 | 5268 | 49.8% |
| 1-2 | 173 | 32.4% |
| 3-5 | 94 | 44.7% |
| 6+ | 217 | 47.5% |

**Messages sent to Devin** — ⚠️ **Not available.** `dim_sessions.num_user_messages` is 0/NULL for every user in this cohort, so the signal cannot be computed. Flagged and excluded.

**Total internal ACUs consumed** — overall chi-square across buckets p = 6.20e-24 (significant)

| Bucket | n | D30% |
|---|---:|---:|
| 0 | 4707 | 52.2% |
| 0-5 | 237 | 33.3% |
| 15+ | 624 | 37.5% |
| 5-15 | 184 | 27.2% |

**Distinct active days in first 14d** — overall chi-square across buckets p = 1.87e-156 (significant)

| Bucket | n | D30% |
|---|---:|---:|
| 1 | 680 | 29.3% |
| 2-3 | 1488 | 29.7% |
| 4-7 | 2364 | 52.5% |
| 8+ | 1220 | 77.0% |

### Timing signals

**Days from signup to first Devin session** — overall chi-square across buckets p = 3.43e-22 (significant)

| Bucket | n | D30% |
|---|---:|---:|
| 0 | 763 | 32.9% |
| 1 | 63 | 36.5% |
| 2-3 | 60 | 43.3% |
| 4-7 | 74 | 35.1% |
| 7+ | 85 | 43.5% |
| never | 4707 | 52.2% |

**Days from signup to first PR** — overall chi-square across buckets p = 8.73e-03 (significant)

| Bucket | n | D30% |
|---|---:|---:|
| 0 | 284 | 41.5% |
| 1 | 42 | 38.1% ⚠️ LOW-N |
| 2-3 | 45 | 53.3% ⚠️ LOW-N |
| 4-7 | 58 | 36.2% |
| 7+ | 55 | 40.0% |
| never | 5268 | 49.8% |

**Days from first PR to first merge** — overall chi-square across buckets p = 1.06e-03 (significant)

| Bucket | n | D30% |
|---|---:|---:|
| 1-3d | 11 | 63.6% ⚠️ LOW-N |
| 4-7d | 5 | 20.0% ⚠️ LOW-N |
| 8+d | 3 | 66.7% ⚠️ LOW-N |
| never | 140 | 33.6% |
| no_pr | 5268 | 49.8% |
| same_day | 325 | 44.3% |

### Pattern signals

**Any 2 consecutive active days in first 14d** — overall chi-square across buckets p = 4.55e-43 (significant)

| Bucket | n | D30% |
|---|---:|---:|
| no | 1164 | 31.0% |
| yes | 4588 | 53.6% |

**Returned within 3 days of first activity** — overall chi-square across buckets p = 4.34e-18 (significant)

| Bucket | n | D30% |
|---|---:|---:|
| no | 1174 | 37.7% |
| yes | 4578 | 52.0% |

**Distinct repos with a PR (first 14d)** — overall chi-square across buckets p = 1.82e-05 (significant)

| Bucket | n | D30% |
|---|---:|---:|
| 0 | 5282 | 49.7% |
| 1 | 318 | 36.2% |
| 2 | 95 | 50.5% |
| 3+ | 57 | 59.6% |

*Repo signal is PR-derived (parsed from `pull_requests.pr_url`); `dim_sessions` has no repo identifier, so users active without a PR show as 0 repos.*

### Session-quality signals

**Average internal ACU per session** — overall chi-square across buckets p = 3.01e-26 (significant)

| Bucket | n | D30% |
|---|---:|---:|
| high_10+ | 308 | 44.5% |
| low_<2 | 266 | 32.3% |
| medium_2-10 | 471 | 29.7% |
| no_session | 4707 | 52.2% |

**Share of sessions that produced a PR** — overall chi-square across buckets p = 4.86e-26 (significant)

| Bucket | n | D30% |
|---|---:|---:|
| 0% | 554 | 28.5% |
| 1-25% | 53 | 34.0% |
| 25-50% | 126 | 40.5% |
| 50%+ | 312 | 43.6% |
| no_session | 4707 | 52.2% |

## Ranked summary — top behaviors by RR D30 (n ≥ 50, p < 0.05, RR > 1)

| Rank | Behavior | n | D30% | RR D30 | p |
|---:|---|---:|---:|---:|---:|
| 1 | 8+ active days (first 14d) | 1220 | 77.0% | 1.855 | 3.00e-107 |
| 2 | consecutive active days | 4588 | 53.6% | 1.730 | 4.55e-43 |
| 3 | returned within 3d of first activity | 4578 | 52.0% | 1.377 | 4.34e-18 |
| 4 | 4-7 active days (first 14d) | 2364 | 52.5% | 1.125 | 1.52e-05 |

**No individual PART 1 / PART 3 feature toggle qualifies** — none has a statistically significant RR D30 > 1 at n ≥ 50. Every qualifying positive predictor is a **cadence / intensity** signal measured across the whole cohort.

## New events discovered in PART 3 (not previously analyzed)

Top first-14d cohort behaviors surfaced that were not in the original known-feature list (distinct users in cohort):

- `User:Create:Session` (966) — creating a session from the web UI
- `Devin:Create:PR` (480) / `User:MergeViaDevinUI:PR` (91) / `Devin:TakeOver:PR` (43) — Devin-UI PR actions
- `git_push` (495), `web_get_contents` (464), `tool_help_called` (539), `self_suspend` (585) — session-event types
- `user_question_answered` (701) — user answered a Devin clarifying question
- `note_used` (339) — knowledge/note used in a session
- `TestRecording:Open:Viewer` (183) / `Play:Video` (180) — test-recording / replay viewer
- `Voice:Complete:Recording` (66) — voice input
- `SlashCommand:Used` (20 ⚠️), `User:Index:Repo` (11 ⚠️), `Automation:Create:Automation` (15 ⚠️) — low volume

All were tested in the PART 3 table above. None is a significant positive D30 predictor; the higher-volume ones (`web_create_session`, `git_push`, `user_question_answered`, `self_suspend`) skew **negative** for the same structural reason as PART 1 — they only exist for the session-running 18%.

## What changed vs the 90-day analysis, and the single strongest new signal

In the cleaned 90-day analysis (`analysis_pro_feature_churn_impact_v2.md`), the one defensible positive lever was **`has_playbook` (RR D30 ≈ 1.33)**. In this recent 45-day, wide-net cohort that signal **does not reproduce at strength**: `playbook_triggered` is now **LOW-N (17 users, RR 1.20, p=0.57)** — directional at best — and no single feature toggle is a significant positive D30 predictor. What the wider net reveals instead is that **usage cadence dominates every feature flag**: the **single strongest signal is doing ≥8 distinct active days in the first 14 days → 77.0% D30 vs 41.5% for everyone else (RR 1.86, p≈3e-107)**, followed by having any 2 consecutive active days (53.6% vs 31.0%, RR 1.73) and returning within 3 days of first activity (52.0% vs 37.7%, RR 1.38). The product takeaway shifts accordingly: for onboarding/lifecycle emails, the target behavior to drive is **repeat, consecutive-day engagement in week 1**, not adoption of any one feature. Feature toggles (PR/CI/MCP/review/computer-use) should be treated as **table-stakes correlates of being an active session-runner**, not as independent retention levers — and the large ACU-only activated segment (82%, retaining at 52%) deserves its own analysis since standard feature instrumentation is blind to it.

