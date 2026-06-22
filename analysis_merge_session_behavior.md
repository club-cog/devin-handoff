# Pro Plan — Session Behaviors Predicting a Successful Merge

**Question:** For Pro-plan sessions in the last 90 days that produced a PR, which in-session behaviors differ between sessions that ended in a **merged** PR vs an **unmerged** PR (PR opened but not merged within 14 days)?

## Cohort Definition

- Source: `exafunction.analytics.dim_sessions` (session-level), events from `exafunction.analytics.devin_events` joined on `devin_id`.
- `plan_type = 'pro'`, session `created_at` within last 90 days.
- Excludes `is_cognition_user`, `is_synthetic_user`, and cognition-in-customer-org sessions.
- Session must have produced a PR (`gh_pr IS NOT NULL`, `pr_created_at IS NOT NULL`).
- **14-day observability filter:** `pr_created_at` must be ≥ 14 days ago, so every PR has a fully-observed 14-day merge window (avoids right-censoring of recent PRs).
- **merged** = `pr_merged_at` set AND merged within 14 days of PR creation (`days_from_pr_created_to_merged <= 14`).
- **unmerged** = PR opened but not merged within 14 days (never merged, or merged later).

| Group | Sessions |
|---|---:|
| merged | 15,549 |
| unmerged | 7,955 |

## Event Presence Rate — merged vs unmerged

Presence = ≥1 event of that type in the session. RR = merged rate / unmerged rate. p = Pearson chi-square (2×2, Yates-corrected).

| Session event | Merged % | Unmerged % | RR (merged/unmerged) | Chi-square p |
|---|---:|---:|---:|---:|
| `pr_comment` | 36.84% | 20.55% | **1.79** | 4.8e-143 |
| `check_run_created` | 48.92% | 33.00% | **1.48** | 6.1e-120 |
| `checkpoint_restored` | 8.19% | 7.14% | 1.15 | 4.8e-03 |
| `mcp_tool_call` | 12.90% | 11.59% | 1.11 | 4.3e-03 |
| `suggest_testing_setup` | 16.27% | 14.72% | 1.11 | 2.1e-03 |
| `web_search` | 13.67% | 15.08% | 0.91 | 3.5e-03 |
| `computer_use` | 22.00% | 25.09% | 0.88 | 1.1e-07 |

## Median Session ACU Consumption

`consumed_acus` (billable) is 0 for most Pro sessions (subscription-covered — only ~16% of merged and ~11% of unmerged sessions show any billable ACU), so it is uninformative as a central tendency. `consumed_internal_acus` (actual compute consumed) is the meaningful session-cost metric.

| Group | Median billable ACU | Median internal ACU | p75 internal | p90 internal | Mean internal |
|---|---:|---:|---:|---:|---:|
| merged | 0.00 | **3.71** | 8.65 | 20.55 | 10.73 |
| unmerged | 0.00 | **2.88** | 8.12 | 20.10 | 9.82 |

Merged sessions consume ~29% more internal ACU at the median (3.71 vs 2.88), consistent with merged work being more substantial. The upper tail (p75/p90) is nearly identical, so the difference is concentrated in the typical session, not in heavy outliers.

## Interpretation

**The two behaviors that strongly predict a successful merge are integration/review signals, not raw compute:**

- **`pr_comment` (RR 1.79)** and **`check_run_created` (RR 1.48)** are by far the strongest separators (p ≈ 1e-143 / 1e-120). These reflect a session that engaged with code review and CI — i.e., the PR entered a real review loop. Sessions that merge are the ones that produce a PR people actually comment on and that triggers CI checks.
- **`computer_use` (RR 0.88)** and **`web_search` (RR 0.91)** are mildly *negative* signals — sessions leaning on browser/computer-use and web research are slightly less likely to merge, likely a proxy for more exploratory/ambiguous tasks rather than well-scoped code changes.
- `mcp_tool_call`, `suggest_testing_setup`, and `checkpoint_restored` are weakly positive (RR 1.1–1.15); statistically significant only because of large n, and not large enough to act on alone.

**Onboarding-email recommendation:** steer new Pro users toward task types that land in a review loop — connecting CI (so `check_run_created` fires) and PRs against repos with active reviewers (so `pr_comment` happens). De-emphasize computer-use / open-ended research framing as the path to a successful merge.

**Caveats:** This is associational, not causal — `check_run_created` and `pr_comment` are partly *consequences* of opening a mergeable PR against a mature repo (reverse causation / repo-quality confound). Treat them as markers of high-merge-likelihood task setups, not levers that independently cause merges.
