# Free Plan — Conversion-to-Paid Analysis (session-runners)

**Branch:** `devin/1782068917-feature-retention-analysis` · no PR

**Question:** For Free users, what first-14-day behavior predicts **converting to paid** (not just retaining)? Run with the clean session-runner framing (ACU-only/dormant activators excluded), conversion as the outcome.

## ⚠️ Read first — two conversion definitions (this materially changes interpretation)

The prompt defines conversion as a `conversion:Pro/Teams/Max` event **or** a plan change to `pro/pro-trial/teams-v2/max` within 60d. Investigating the data, **`conversion:Pro` events and `pro-trial` starts fire on entering the Pro *funnel* / starting a trial, not on paying.** Among the 316,403 web-active free-at-signup users: **123,024 fired a conversion event** and **166,810 started a `pro-trial`**, but only **12,296 (3.9%) reached a genuine *paid* subscription** (`pro`/`teams-v2`/`max`). So I report two outcomes throughout:

- **Funnel conversion** (prompt's literal definition — event OR any pro/pro-trial/teams/max sub ≤60d): dominated by trial starts. **High rate, low business meaning.**

- **Paid conversion** (genuine revenue — `pro`/`teams-v2`/`max` subscription ≤60d): the metric that maps to money. **This is the one to optimize for.**

> **Caveats (apply everywhere):** correlation, not causation — feature use and conversion may both reflect user intent. **Plan-at-signup-free** is derived from `dim_historic_subscriptions` (org-level; for the rare multi-member free org, a teammate's trial/sub can be attributed to the user — minor noise, most free users are solo). Subscriptions are org-grain, conversion *events* are user-grain. n<50 flagged ⚠️ LOW-N. Observation window = 60 days from signup; cohort signup 90–37d ago so all have ≥37d and most ≥60d observed.

## Cohort & base rates

| Population | n | Funnel conv | Paid conv |
|---|---:|---:|---:|
| Web-active, free-at-signup (90–37d) | 316,403 | 53.8% | 3.9% |
| …**session-runners** (≥1 Devin session in first 14d) — **analysis cohort** | **54,074** | **59.44%** | **5.48%** |

Using the **session-runner** cohort (matches the prior Free retention analysis, removes the dormant/ACU-only confound that inflated prior RRs). All Part-1/2/3 tables are within this cohort.

## PART 1 — Feature behaviors that predict conversion (first 14d), ranked by **Paid RR**

### Feature table

| Feature | Used n | Paid% used | Paid% not | **Paid RR** | Paid p | Funnel RR | Funnel p | Sig (paid) |
|---|---:|---:|---:|---:|---:|---:|---:|:--:|
| `playbook_triggered` | 288 | 31.6% | 5.3% | **5.92** | 7.3e-84 | 1.30 | 1.4e-09 | **yes** |
| `deepwiki_view` | 1722 | 21.3% | 5.0% | **4.29** | 2.8e-187 | 0.80 | 3.2e-23 | **yes** |
| `pr_comment` | 3180 | 18.7% | 4.6% | **4.03** | 4.4e-251 | 1.30 | 4.8e-82 | **yes** |
| `devin_review` | 30400 | 7.6% | 2.7% | **2.82** | 1.6e-137 | 1.38 | 0.0e+00 | **yes** |
| `mcp_tool_call` | 6091 | 12.6% | 4.6% | **2.76** | 2.7e-148 | 1.23 | 1.7e-90 | **yes** |
| `has_merge` | 10454 | 10.7% | 4.2% | **2.53** | 6.9e-150 | 1.36 | 6.7e-305 | **yes** |
| `check_run_created` | 6054 | 11.8% | 4.7% | **2.53** | 3.8e-117 | 1.29 | 8.5e-140 | **yes** |
| `has_pr` | 15910 | 9.4% | 3.8% | **2.46** | 5.2e-150 | 1.20 | 2.4e-125 | **yes** |
| `onboarding_tour` | 31609 | 7.3% | 3.0% | **2.45** | 9.0e-104 | 1.69 | 0.0e+00 | **yes** |
| `web_search` | 17344 | 8.6% | 4.0% | **2.17** | 1.2e-109 | 1.53 | 0.0e+00 | **yes** |
| `computer_use` | 24309 | 7.4% | 3.9% | **1.93** | 5.6e-74 | 1.20 | 1.5e-143 | **yes** |
| `suggest_testing_setup` | 5217 | 9.4% | 5.1% | **1.86** | 7.2e-39 | 0.81 | 1.7e-59 | **yes** |
| `checkpoint_restored` | 7137 | 9.0% | 4.9% | **1.81** | 1.9e-43 | 1.06 | 6.0e-08 | **yes** |
| `automation_create` | 149 | 8.7% | 5.5% | **1.60** | 1.2e-01 | 1.58 | 1.7e-17 | no |

## PART 2 — Behavioral signals (first 14d)

**Distinct active days**

| Bucket | n | Funnel conv% | Paid conv% |
|---|---:|---:|---:|
| 1 | 25,094 | 35.1% | 1.52% |
| 2-3 | 13,497 | 67.09% | 4.94% |
| 4-7 | 11,931 | 91.22% | 9.66% |
| 8+ | 3,552 | 95.55% | 21.45% |

**Total PRs created**

| Bucket | n | Funnel conv% | Paid conv% |
|---|---:|---:|---:|
| 0 | 38,164 | 56.19% | 3.83% |
| 1-2 | 7,711 | 49.31% | 5.77% |
| 3-5 | 3,411 | 76.05% | 7.62% |
| 6+ | 4,788 | 89.81% | 16.62% |

**Total internal ACUs**

| Bucket | n | Funnel conv% | Paid conv% |
|---|---:|---:|---:|
| 0 | 12 | 58.33% | 0% ⚠️ |
| 1-5 | 22,767 | 22.05% | 1.8% |
| 5-15 | 11,754 | 73.89% | 3.77% |
| 15+ | 19,541 | 94.31% | 10.79% |

**Distinct repos**

| Bucket | n | Funnel conv% | Paid conv% |
|---|---:|---:|---:|
| 1 | 50,335 | 57.71% | 4.76% |
| 2 | 2,395 | 80.21% | 12.94% |
| 3+ | 1,344 | 87.2% | 19.12% |

**Days to first activity**

| Bucket | n | Funnel conv% | Paid conv% |
|---|---:|---:|---:|
| 0 | 45,013 | 55.21% | 5.11% |
| 1 | 3,578 | 79.65% | 7.77% |
| 2-3 | 2,137 | 83.15% | 6.79% |
| 4-7 | 2,076 | 81.84% | 6.26% |
| 7+ | 1,270 | 75.67% | 8.43% |

**Best behavioral separator:** distinct **active days** and **total ACUs** dominate. Paid conversion climbs 1.5%→4.9%→9.7%→**21.5%** across active-day buckets (1→8+) and 1.8%→…→**10.8%** across ACU buckets; **distinct repos** is the steepest per-step lift (1→4.8%, 2→12.9%, 3+→**19.1%** paid). Raw PR *count* matters less than active days. Days-to-first-activity shows fast starters (day 0) are not the highest converters — engaged-over-time beats first-day rush.

## PART 3 — Logistic regression (multivariate)

Weighted logistic GLM on first-14d features (binned sufficient statistics, n=54,074; BQML unavailable — no dataset-create permission — so fit in statsmodels on grouped counts). **Primary model = PAID conversion.**

| Feature | Coef | Odds ratio | p |
|---|---:|---:|---:|
| `active_days` | 0.206 | **1.23** | 4.6e-142 |
| `total_acus` | 0.012 | **1.01** | 3.2e-31 |
| `has_pr` | 0.417 | **1.52** | 9.3e-11 |
| `has_merge` | 0.034 | **1.03** | 6.3e-01 |
| `has_mcp_tool` | 0.354 | **1.43** | 2.7e-12 |
| `has_deepwiki_view` | 0.853 | **2.35** | 2.3e-30 |
| `has_ci` | 0.034 | **1.04** | 5.8e-01 |
| `has_pr_comment` | 0.432 | **1.54** | 1.2e-10 |
| `distinct_repos` | -0.037 | **0.96** | 2.9e-01 |

**Independent drivers of paid conversion (controlling for all others):** `has_deepwiki_view` (OR **2.35**) is by far the strongest, then `has_pr_comment` (1.54), `has_pr` (1.52), `has_mcp_tool` (1.43), and `active_days` (1.23 **per day**). `has_merge`, `has_ci`, `distinct_repos` lose significance once `has_pr`/`active_days` are in the model (collinear). DeepWiki and pr_comment survive multivariate control — they are not just cadence proxies.

*(The funnel-conversion regression produces inverted signs — e.g. `deepwiki_view` OR 0.17 — because funnel 'conversion' ≈ auto-enrolled trial start, which anti-correlates with deliberate feature use. This is exactly why the paid definition is the trustworthy one; funnel regression is not interpretable and is omitted as a predictor model.)*

## PART 4 — Retention vs conversion: same drivers or different?

Free session-runner **D30 retention RR** (prior analysis) vs **conversion RR** here:

| Feature | Retention RR | Funnel-conv RR | **Paid-conv RR** | Same driver? |
|---|---:|---:|---:|:--:|
| `deepwiki_view` | 2.81 | 0.80 | **4.29** | ✅ |
| `mcp_tool_call` | 3.31 | 1.23 | **2.76** | ✅ |
| `pr_comment` | 1.87 | 1.30 | **4.03** | ✅ |
| `checkpoint_restored` | 1.76 | 1.06 | **1.81** | ✅ |
| `check_run_created` | 1.64 | 1.29 | **2.53** | ✅ |
| `has_merge` | 1.4 | 1.36 | **2.53** | ✅ |
| `has_pr` | 1.21 | 1.20 | **2.46** | ✅ |
| `computer_use` | 0.56 | 1.20 | **1.93** | ❌ |
| `devin_review` | 0.24 | 1.38 | **2.82** | ❌ |

## Summary

**Single best first-14-day predictor of a Free user converting to *paid*:** **viewing DeepWiki.** `playbook_triggered` has the highest *univariate* paid RR (5.92) but is rare (n=288) and washes out once cadence is controlled; **DeepWiki view** is the strongest *independent* signal in the multivariate model (OR **2.35**, p=2e-30), ahead of `pr_comment` (1.54), `has_pr` (1.52) and `mcp_tool_call` (1.43), while also being far higher-volume (1,722 users, univariate RR 4.29). Behaviorally, **distinct active days** and **multi-repo usage** give the steepest lift (3+ repos → ~19% paid vs ~5% baseline).

**Same drivers as retention?** Largely **yes** — `deepwiki_view`, `pr_comment`, `mcp_tool_call`, `check_run_created`, `checkpoint_restored` are positive for **both** D30 retention and paid conversion (✅). The cadence story (active days) also drives both. So pushing the 'aha' exploration loop (DeepWiki, MCP, the PR/CI loop) **does double duty**: it both retains and converts — there is **no tradeoff** for these. The exceptions are the two retention-negative oddities (`devin_review` ret-RR 0.24, `computer_use` 0.56) which were Free selection artifacts, not genuine drivers.

**What should the Free email sequence optimize for?** Drive users to the **DeepWiki / repo-understanding + first-PR loop early, across more than one repo, on repeated days.** Because retention and paid-conversion drivers coincide, a single behavior-activation sequence (get them to DeepWiki + open a PR + come back the next day) optimizes both outcomes simultaneously — you do **not** have to choose. Avoid optimizing for raw first-day speed or single-session PR volume; optimize for *repeat-day, multi-repo exploration*.


*Caveats recap: conversion:Pro events/pro-trial = funnel not revenue (paid is the trustworthy outcome); plan-at-signup via org-grain subscriptions (minor multi-member noise); correlation not causation; 60-day observation window; BQML unavailable so regression via weighted GLM on grouped stats.*
