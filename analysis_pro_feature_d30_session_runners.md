# Pro Plan — Feature Predictors of D30 Retention WITHIN Session-Runners (Last 45 Days)

**Goal:** Identify which first-14-day features predict D30 retention for Pro users **restricted to users who actually run Devin sessions** — removing the ACU-only-activation confound that dragged every session-based feature toward a negative RR in prior analyses.

## Cohort

- **Plan:** Pro (`dim_user_orgs` priority mapping)
- **Signup window:** created 52–37 days ago (D30-eligible, current product state). n ≥ 300 → no expansion to 60–37 needed.
- **Filters:** web-active (≥1 `User:Navigate:Page`); excludes `is_cognition_user`/`is_synthetic_user`; excludes 2026-04-13→04-20 bulk cohort.
- **CRITICAL new filter:** ≥1 Devin session in `dim_sessions` (excl. `is_cognition_session_in_customer_org`) in the first 14 days. ACU-only activators are excluded entirely, so the "not used" group for any feature is a **session-runner who didn't use that specific feature** — a fair comparison.
- **Exact cohort n = 1,016** (vs 5,752 in the full activated cohort — the ~82% ACU-only mass is gone)
- **Baseline D30 (session-runner cohort) = 34.8%** (354/1016) — far below the 49.1% full-cohort baseline, confirming the ACU-only segment was inflating it.

> **Caveat — correlation, not causation.** This removes the ACU-only confound, but feature use and retention may both be driven by underlying user intent/seriousness. A motivated user both adopts features AND returns; the feature is not proven to *cause* retention. Treat these as fair associational signals for targeting, not causal levers.

## Feature table — within session-runners, ranked by RR D30 descending

| Feature | Used n | Used D30% | Not-used D30% | RR D30 | Chi-sq p | Sig |
|---|---:|---:|---:|---:|---:|:--:|
| `automation_create` | 8 | 87.5% | 34.4% | 2.542 | 5.68e-03 | **yes** ⚠️ LOW-N |
| `playbook_triggered` | 17 | 58.8% | 34.4% | 1.708 | 6.63e-02 | no ⚠️ LOW-N |
| `pr_comment` | 88 | 55.7% | 32.9% | 1.694 | 2.97e-05 | **yes** |
| `deepwiki_view` | 104 | 54.8% | 32.6% | 1.683 | 1.07e-05 | **yes** |
| `check_run_created` | 180 | 51.1% | 31.3% | 1.631 | 6.91e-07 | **yes** |
| `has_pr` | 469 | 41.6% | 29.1% | 1.430 | 4.02e-05 | **yes** |
| `has_merge` | 319 | 43.9% | 30.7% | 1.429 | 5.76e-05 | **yes** |
| `suggest_testing_setup` | 166 | 44.0% | 33.1% | 1.330 | 9.03e-03 | **yes** |
| `checkpoint_restored` | 273 | 41.0% | 32.6% | 1.260 | 1.50e-02 | **yes** |
| `mcp_tool_call` | 198 | 41.4% | 33.3% | 1.245 | 3.75e-02 | **yes** |
| `devin_review` | 828 | 35.7% | 30.9% | 1.159 | 2.35e-01 | no |
| `test_recording` | 171 | 36.8% | 34.4% | 1.070 | 6.07e-01 | no |
| `computer_use` | 594 | 35.7% | 33.6% | 1.061 | 5.45e-01 | no |
| `web_search` | 456 | 34.2% | 35.4% | 0.968 | 7.53e-01 | no |

*Web events verified: `Review:Job:Launch`/`Review:PRPage:View` (Devin Review), `Automation:Create:Automation`, `DeepWiki:*` (deepwiki_view), `TestRecording:*` (test_recording) — all present. Searched and not found: none additional required.*

## Cadence buckets within session-runners

**Session count (first 14d)** — chi-square p = 1.93e-01

| Sessions | n | D30% |
|---|---:|---:|
| 1 | 294 | 35.7% |
| 2-3 | 291 | 30.2% |
| 4-7 | 244 | 35.7% |
| 8+ | 187 | 39.6% |

**Distinct active days (first 14d)** — chi-square p = 4.25e-17

| Active days | n | D30% |
|---|---:|---:|
| 1 | 131 | 20.6% |
| 2-3 | 252 | 22.6% |
| 4-7 | 439 | 35.3% |
| 8+ | 194 | 59.3% |

## Comparison — which features unmasked, and does cadence still win?

**Features that flipped from negative/flat to clearly positive once the ACU-only mass was removed.** In the full-cohort 45-day analysis nearly every session-based feature had RR D30 < 1 (the artifact). Within session-runners they reverse:

- `pr_comment` — RR D30 **1.69** (p=3.0e-05)
- `deepwiki_view` — RR D30 **1.68** (p=1.1e-05)
- `check_run_created` — RR D30 **1.63** (p=6.9e-07)
- `has_pr` — RR D30 **1.43** (p=4.0e-05)
- `has_merge` — RR D30 **1.43** (p=5.8e-05)
- `suggest_testing_setup` — RR D30 **1.33** (p=9.0e-03)
- `checkpoint_restored` — RR D30 **1.26** (p=1.5e-02)
- `mcp_tool_call` — RR D30 **1.25** (p=3.8e-02)

The strongest now-significant feature signals are **`pr_comment`, `deepwiki_view`, `check_run_created`** (RR ≈ 1.6–1.7) plus the code-loop markers **`has_pr` / `has_merge`** (RR ≈ 1.4) — all of which looked *negative* in the confounded full-cohort view.

**Does cadence still beat features? Yes — but it's active *days*, not session count.** Distinct active days remains the single strongest signal even here: **8+ active days → 59.3% D30** (RR ≈ 1.70 vs cohort baseline), a steep monotonic climb (1 day 20.6% → 2–3 22.6% → 4–7 35.3% → 8+ 59.3%). Notably **raw session count is nearly flat** (35.7% → 39.6% across buckets, weakly significant) — so it is repeat-day *cadence/return behavior*, not sheer session volume, that dominates. Feature adoption (RR ~1.4–1.7) is a real, now-unmasked positive correlate, but consistent multi-day engagement in week 1 still produces the largest retention separation.

