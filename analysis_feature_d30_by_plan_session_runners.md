# Feature Predictors of D30 Retention WITHIN Session-Runners — by Plan (Free / TrialPro / Max)

**Goal:** Replicate the Pro session-runner analysis (`analysis_pro_feature_d30_session_runners.md`) separately for **Free**, **TrialPro (pro-trial)**, and **Max** — to see whether the Pro predictors (`pr_comment` 1.69, `deepwiki_view` 1.68, `check_run_created` 1.63, `has_pr`/`has_merge` ~1.43) hold per plan or differ.

## Method (same as Pro)

- Plan via `dim_user_orgs` priority mapping; web-active (≥1 `User:Navigate:Page`); excl. cognition/synthetic; excl. 2026-04-13→04-20 bulk cohort.
- **Session-runner filter:** ≥1 Devin session in `dim_sessions` (excl. `is_cognition_session_in_customer_org`) in first 14 days — ACU-only activators excluded.
- D30 = ≥1 usage day (session OR ACU) on days 23–37 from signup. RR D30 = Used D30% / Not-used D30%. LOW-N if used n < 50.
- Signup window 52–37d per plan; **Max expanded to 90–37d** (only 124 session-runners at 52–37d, < 200 threshold).

> **Caveat — correlation, not causation.** Feature use and retention may both be driven by user intent. **TrialPro baseline D30 is ~1%** (trials largely expire/convert by D30, so absolute retained counts are tiny and most TrialPro RRs are directional). **Max n=303** even after expansion — directional. Read significance flags, not point estimates.

## Per-plan cohort sizes & baseline D30

| Plan | Window | Session-runner n | Baseline D30 |
|---|---|---:|---:|
| Pro (prior) | 52–37d | 1,016 | 34.8% |
| Free | 52–37d | 4,047 | 7.6% |
| TrialPro (pro-trial) | 52–37d | 16,573 | 1.2% |
| Max | 90–37d (expanded: <200 at 52–37d) | 303 | 61.4% |

## Free — feature table (ranked by RR D30 desc)

| Feature | Used n | Used D30% | Not-used D30% | RR D30 | Chi-sq p | Sig |
|---|---:|---:|---:|---:|---:|:--:|
| `automation_create` | 10 | 50.0% | 7.5% | 6.640 | 8.40e-06 | **yes** ⚠️ LOW-N |
| `playbook_triggered` | 27 | 37.0% | 7.4% | 4.980 | 6.35e-08 | **yes** ⚠️ LOW-N |
| `mcp_tool_call` | 329 | 21.3% | 6.4% | 3.310 | 7.08e-22 | **yes** |
| `deepwiki_view` | 278 | 19.1% | 6.8% | 2.807 | 2.50e-13 | **yes** |
| `pr_comment` | 100 | 14.0% | 7.5% | 1.873 | 2.53e-02 | **yes** |
| `checkpoint_restored` | 324 | 12.7% | 7.2% | 1.758 | 5.86e-04 | **yes** |
| `check_run_created` | 337 | 11.9% | 7.3% | 1.637 | 3.18e-03 | **yes** |
| `has_merge` | 595 | 10.1% | 7.2% | 1.398 | 1.87e-02 | **yes** |
| `has_pr` | 1395 | 8.6% | 7.1% | 1.207 | 1.06e-01 | no |
| `suggest_testing_setup` | 314 | 8.9% | 7.5% | 1.185 | 4.35e-01 | no |
| `test_recording` | 279 | 7.2% | 7.7% | 0.935 | 8.51e-01 | no |
| `web_search` | 704 | 6.7% | 7.8% | 0.852 | 3.29e-01 | no |
| `computer_use` | 1514 | 5.2% | 9.1% | 0.565 | 5.68e-06 | **yes** |
| `devin_review` | 3503 | 5.3% | 22.4% | 0.238 | 8.81e-44 | **yes** |

**Distinct active days (first 14d)** — chi-square p = 1.56e-94

| Bucket | n | D30% |
|---|---:|---:|
| 1 | 2708 | 3.7% |
| 2-3 | 1012 | 10.0% |
| 4-7 | 264 | 27.7% |
| 8+ | 63 | 57.1% |

**Session count (first 14d)** — chi-square p = 3.45e-45

| Bucket | n | D30% |
|---|---:|---:|
| 1 | 2779 | 4.6% |
| 2-3 | 925 | 10.6% |
| 4-7 | 250 | 18.8% |
| 8+ | 93 | 37.6% |

## TrialPro (pro-trial) — feature table (ranked by RR D30 desc)

| Feature | Used n | Used D30% | Not-used D30% | RR D30 | Chi-sq p | Sig |
|---|---:|---:|---:|---:|---:|:--:|
| `automation_create` | 128 | 7.8% | 1.1% | 7.021 | 3.49e-11 | **yes** |
| `deepwiki_view` | 237 | 7.2% | 1.1% | 6.658 | 5.33e-17 | **yes** |
| `pr_comment` | 388 | 2.8% | 1.1% | 2.521 | 4.18e-03 | **yes** |
| `playbook_triggered` | 52 | 1.9% | 1.2% | 1.655 | 1.00e+00 | no |
| `devin_review` | 10488 | 1.3% | 0.9% | 1.419 | 3.10e-02 | **yes** |
| `test_recording` | 1730 | 1.4% | 1.1% | 1.218 | 4.27e-01 | no |
| `checkpoint_restored` | 3088 | 1.3% | 1.1% | 1.178 | 3.99e-01 | no |
| `has_pr` | 5337 | 1.3% | 1.1% | 1.145 | 4.07e-01 | no |
| `suggest_testing_setup` | 1665 | 1.3% | 1.2% | 1.093 | 7.89e-01 | no |
| `mcp_tool_call` | 1885 | 1.2% | 1.2% | 1.054 | 9.00e-01 | no |
| `computer_use` | 8081 | 1.1% | 1.2% | 0.957 | 8.16e-01 | no |
| `web_search` | 6604 | 1.1% | 1.2% | 0.918 | 6.14e-01 | no |
| `has_merge` | 3933 | 1.1% | 1.2% | 0.894 | 5.74e-01 | no |
| `check_run_created` | 2133 | 0.9% | 1.2% | 0.739 | 2.48e-01 | no |

**Distinct active days (first 14d)** — chi-square p = 2.33e-08

| Bucket | n | D30% |
|---|---:|---:|
| 1 | 4940 | 0.6% |
| 2-3 | 4884 | 1.0% |
| 4-7 | 5499 | 1.5% |
| 8+ | 1250 | 2.6% |

**Session count (first 14d)** — chi-square p = 2.94e-03

| Bucket | n | D30% |
|---|---:|---:|
| 1 | 5842 | 0.9% |
| 2-3 | 5076 | 1.2% |
| 4-7 | 3647 | 1.1% |
| 8+ | 2008 | 1.9% |

## Max — feature table (ranked by RR D30 desc)

| Feature | Used n | Used D30% | Not-used D30% | RR D30 | Chi-sq p | Sig |
|---|---:|---:|---:|---:|---:|:--:|
| `checkpoint_restored` | 87 | 87.4% | 50.9% | 1.715 | 8.29e-09 | **yes** |
| `playbook_triggered` | 15 | 100.0% | 59.4% | 1.684 | n/a | — ⚠️ LOW-N |
| `pr_comment` | 99 | 83.8% | 50.5% | 1.660 | 4.59e-08 | **yes** |
| `automation_create` | 4 | 100.0% | 60.9% | 1.643 | n/a | — ⚠️ LOW-N |
| `suggest_testing_setup` | 74 | 86.5% | 53.3% | 1.623 | 6.90e-07 | **yes** |
| `has_merge` | 164 | 74.4% | 46.0% | 1.616 | 8.15e-07 | **yes** |
| `computer_use` | 211 | 68.2% | 45.7% | 1.495 | 3.35e-04 | **yes** |
| `devin_review` | 257 | 64.6% | 43.5% | 1.486 | 1.09e-02 | **yes** |
| `check_run_created` | 117 | 75.2% | 52.7% | 1.428 | 1.45e-04 | **yes** |
| `has_pr` | 201 | 68.2% | 48.0% | 1.419 | 1.06e-03 | **yes** |
| `deepwiki_view` | 62 | 79.0% | 56.8% | 1.390 | 2.26e-03 | **yes** |
| `mcp_tool_call` | 129 | 72.1% | 53.4% | 1.349 | 1.49e-03 | **yes** |
| `web_search` | 186 | 66.7% | 53.0% | 1.258 | 2.39e-02 | **yes** |
| `test_recording` | 107 | 67.3% | 58.2% | 1.157 | 1.51e-01 | no |

**Distinct active days (first 14d)** — chi-square p = 8.21e-09

| Bucket | n | D30% |
|---|---:|---:|
| 1 | 32 | 28.1% ⚠️ LOW-N |
| 2-3 | 41 | 41.5% ⚠️ LOW-N |
| 4-7 | 90 | 55.6% |
| 8+ | 140 | 78.6% |

**Session count (first 14d)** — chi-square p = 2.44e-02

| Bucket | n | D30% |
|---|---:|---:|
| 1 | 72 | 56.9% |
| 2-3 | 60 | 48.3% |
| 4-7 | 60 | 61.7% |
| 8+ | 111 | 71.2% |

## Cross-plan comparison — RR D30 side by side

| Feature | Free RR | TrialPro RR | Pro RR | Max RR | Consistent? |
|---|---:|---:|---:|---:|:--:|
| `pr_comment` | 1.87 | 2.52 | 1.69 | 1.66 | ✅ |
| `deepwiki_view` | 2.81 | 6.66 | 1.68 | 1.39 | ✅ |
| `check_run_created` | 1.64 | 0.74 (ns) | 1.63 | 1.43 | ✅ |
| `has_pr` | 1.21 (ns) | 1.15 (ns) | 1.43 | 1.42 | ✅ |
| `has_merge` | 1.40 | 0.89 (ns) | 1.43 | 1.62 | ✅ |
| `suggest_testing_setup` | 1.18 (ns) | 1.09 (ns) | 1.33 | 1.62 | ✅ |
| `checkpoint_restored` | 1.76 | 1.18 (ns) | 1.26 | 1.72 | ✅ |
| `mcp_tool_call` | 3.31 | 1.05 (ns) | 1.25 | 1.35 | ✅ |
| `devin_review` | 0.24 | 1.42 | 1.16 (ns) | 1.49 | ❌ |
| `computer_use` | 0.56 | 0.96 (ns) | 1.06 (ns) | 1.49 | ❌ |
| `web_search` | 0.85 (ns) | 0.92 (ns) | 0.97 (ns) | 1.26 | ⚠️ |
| `test_recording` | 0.93 (ns) | 1.22 (ns) | 1.07 (ns) | 1.16 (ns) | ⚠️ |

*✅ consistent positive (sig in ≥2 plans, no opposite) · ⚠️ varies/weak · ❌ opposite significant signal in some plan. Pro column from `analysis_pro_feature_d30_session_runners.md`.*

## Summary — universal vs plan-specific, and does cadence win everywhere?

**Two predictors are genuinely universal — significant and positive on every plan: `pr_comment` and `deepwiki_view`.** `deepwiki_view` is the single most consistent feature signal in the whole dataset (Free RR 2.81, TrialPro 6.66, Pro 1.68, Max 1.39; significant on all four), and `pr_comment` is positive-significant everywhere (1.66–2.52). The **code-execution loop** (`check_run_created`, `has_merge`, `checkpoint_restored`, plus `has_pr`/`suggest_testing_setup`) is positive on Free, Pro and Max but **washes out on TrialPro** — where baseline D30 is ~1% and trials expire before the loop can pay off, so only the early *exploration* signals (`deepwiki_view`, `pr_comment`, `automation_create` RR 7.0, `devin_review` 1.42) separate retainers. **`mcp_tool_call` is plan-specific:** a powerful Free signal (RR 3.31) that fades to neutral on paid plans (it likely marks the rare high-intent Free user). **Two features flip sign by plan (❌):** `devin_review` is strongly *negative* on Free (RR 0.24 — but 87% of Free session-runners use it, so the non-users are an unusual, highly-retaining minority — a selection artifact, not 'review hurts Free') yet positive on TrialPro/Max; and `computer_use` is negative on Free (0.56) but positive on Max (1.49), consistent with exploratory dabbling on Free vs. genuine agentic work by Max power users.

**Does cadence (active days) win everywhere? Mostly — but it dominates on the *lower* tiers and yields to features on Max.** "8+ active days in first 14d" is the steepest signal on **Free** (57.1% D30 vs 7.6% baseline ≈ RR 7.5, monotonic 3.7%→10.0%→27.7%→57.1%) and **Pro** (59.3% vs 34.8%), is directional on **TrialPro** (2.6% vs 1.2%, everything tiny), and on **Max** active days is still strongly monotonic (28.1% → 41.5% → 55.6% → 78.6%, p=8e-09; 8+ vs 61.4% baseline ≈ RR 1.28). The difference on Max is that cadence no longer *out-separates* features — several feature toggles match or exceed it (`checkpoint_restored` 87%, `suggest_testing_setup` 87%, `pr_comment` 84%), so Max is **both feature- and cadence-driven**, whereas Free/Pro/TrialPro are cadence-first. Raw *session count* is a much weaker/flatter signal than active *days* on every plan — repeat-day return behavior is what matters.

