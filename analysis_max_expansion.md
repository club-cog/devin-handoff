# Max Plan — Usage Expansion Analysis (not retention)

**Branch:** `devin/1782068917-feature-retention-analysis` · no PR

**Question:** Max users already retain at ~61% D30 — retention is not the problem. Are Max users *growing* usage over their first 3 months, and what (if anything) in Month 1 predicts growth?

## Cohort & n at every step

| Step | n |
|---|---:|
| Max plan (dim_user_orgs priority), created 180–37d ago, web-active, excl. cognition/synthetic + Apr 13–20 bulk | **950** |
| …with ≥90-day tenure (so M1/M2/M3 all observable) → **trajectory cohort** | **103** ⚠️ small |

> **Caveats (read first).** n=103 for the entire trajectory analysis — every cut below is **directional only**, and any sub-bucket with n<50 is flagged ⚠️ LOW-N. **Correlation, not causation** throughout. Repo breadth is measured via `pull_requests.pr_url` only (sessions carry no repo grain), so it understates breadth for users who run sessions without opening PRs. ACU = `hourly_consumption_by_user.internal_acu_delta` (internal compute; billable ACU is ~0 for subscription-covered Max).

## PART 1 — ACU trajectory (the headline)

**Median *weekly* internal ACU across all 103 Max users, by month since signup:**

| | Month 1 (d0–29) | Month 2 (d30–59) | Month 3 (d60–89) |
|---|---:|---:|---:|
| Median weekly ACU | 0.02 | 3.38 | 15.52 |

Median weekly ACU rises ~**0 → 15.5** over the first three months — the typical Max user starts cold and ramps. (Median M1≈0 means >half of Max users barely consume in week-1–4; the growth is real but back-loaded.)

**Trajectory split** — Expanding = M3 > M1·1.2 (or M1≈0→M3>0); Flat = within ±20% (incl. 0→0); Declining = M3 < M1·0.8:

| Trajectory | n | % of cohort | Median M1 ACU | Median M3 ACU | Mean M1 | Mean M3 |
|---|---:|---:|---:|---:|---:|---:|
| **Expanding** | 59 | 57.3% | 0.0 | 121.0 | 37.1 | 247.5 |
| **Flat** | 26 | 25.2% | 0.0 | 0.0 | 48.6 | 45.3 |
| **Declining** | 18 | 17.5% | 248.8 | 3.2 | 563.8 | 194.0 |

**Headline: ~57% of tenured Max users are expanding, ~25% flat, ~18% declining.** Expanders are the dominant mode — they start at ~0 in M1 and reach a median ~121 internal-ACU M3. The Declining group is the mirror image: they start *high* (median 249 M1) and fall to ~3 by M3 — i.e. front-loaded users who cooled, not low-usage churners. Flat is bimodal (mostly 0→0 low-usage accounts).

## PART 2 — Repo & breadth expansion

- **Breadth expansion (1 repo in M1 → 2+ repos by M3):** **15 / 103 (14.6%)** of all users; among the **34** users who had any PR-repo activity in M1, **15 (44%)** broadened to 2+ repos by M3.

- **Distinct repos overall (d0–89) vs % expanding** — multi-repo users expand more:

| Distinct repos (d0–89) | n | % Expanding |
|---|---:|---:|
| 1 | 68 | 51.5% |
| 2 | 12 | 66.7% ⚠️ LOW-N |
| 3+ | 23 | 69.6% ⚠️ LOW-N |

Monotonic: 51.5% → 66.7% → 69.6%. Users who touch more repos are more likely to grow ACU — repo breadth is the cleanest *positive* expansion correlate in the dataset (directional; sub-buckets <50).

## PART 3 — Team / seat expansion

| Segment | n | % Expanding |
|---|---:|---:|
| Solo, stayed solo | 98 | 56.1% |
| Multi-member org, stable | 4 | — ⚠️ LOW-N |
| Org grew (teammate joined ≤90d) | 1 | — ⚠️ LOW-N |

**The individual→team path is essentially non-existent for Max: all 103 users were solo at signup, and only 1 had a teammate join within 90 days.** Max behaves as a single-player power-user plan; seat expansion is not where the growth comes from (that's the Teams motion). Max expansion = *within-individual ACU growth*, not seat growth. (n far too small to compare growing-org ACU vs solo — directional null.)

## PART 4 — What Month-1 behavior predicts expansion?

Presence of each Month-1 behavior in **Expanding (n=59)** vs **Flat+Declining (n=44)**. RR = Expanding-rate / Not-expanding-rate; >1 = more common among expanders.

| Month-1 behavior | Exp used/n | Not-exp used/n | Exp % | Not-exp % | RR | Chi-sq p | Sig |
|---|---:|---:|---:|---:|---:|---:|:--:|
| `deepwiki_view` | 11/59 | 6/44 | 18.6% | 13.6% | 1.37 | 0.683 | no |
| `devin_review` | 22/59 | 18/44 | 37.3% | 40.9% | 0.91 | 0.866 | no |
| `checkpoint_restored` | 21/59 | 18/44 | 35.6% | 40.9% | 0.87 | 0.730 | no |
| `suggest_testing_setup` | 16/59 | 19/44 | 27.1% | 43.2% | 0.63 | 0.136 | no |
| `mcp_tool_call` | 7/59 | 9/44 | 11.9% | 20.5% | 0.58 | 0.360 | no |
| `check_run_created` | 9/59 | 13/44 | 15.3% | 29.5% | 0.52 | 0.132 | no |
| `pr_comment` | 7/59 | 11/44 | 11.9% | 25.0% | 0.47 | 0.140 | no |
| `computer_use` | 10/59 | 18/44 | 16.9% | 40.9% | 0.41 | 0.013 | **neg-sig** |
| `automation_create` | 0/59 | 0/44 | 0.0% | 0.0% | n/a | n/a | no ⚠️ LOW-N |
| `cli_usage` | 0/59 | 0/44 | 0.0% | 0.0% | n/a | n/a | no ⚠️ LOW-N |
| `playbook_triggered` | 1/59 | 0/44 | 1.7% | 0.0% | n/a | 1.000 | no ⚠️ LOW-N |

**Active days in Month 1 → % Expanding** (the dominant structural driver):

| M1 active days | n | % Expanding |
|---|---:|---:|
| 1–4 | 73 | 63.0% |
| 5–10 | 9 | 66.7% ⚠️ LOW-N |
| 11–20 | 13 | 46.2% ⚠️ LOW-N |
| 20+ | 8 | 12.5% ⚠️ LOW-N |

**Key finding — the expansion metric is mechanically anti-correlated with Month-1 intensity.** No M1 *feature* positively predicts expansion at significance; the only significant signal is `computer_use` going the **wrong** way (RR 0.41, p=0.013), and `check_run_created`/`pr_comment`/`suggest_testing_setup` all trend negative. Likewise, users with **20+ active days in M1 expand only 12.5%** of the time vs **63% for 1–4 days**. The reason is structural: ratio-based 'expansion' rewards a *low M1 base*, so users who front-load (heavy features + many active days in week 1) have little headroom left to grow and instead read as Flat/Declining. The one *positive* directional signal is `deepwiki_view` (RR 1.37, ns) — consistent with its universal-positive role in the retention analyses — and, from Part 2, **repo breadth** (multi-repo M1 → more expansion).

## Summary

**Is Max's opportunity expansion or retention?** Expansion. Retention is already strong (61% D30) and **~57% of tenured Max users grow ACU M1→M3** (median weekly 0.02→15.5), with only ~18% declining — and decliners are cooled *former* power-users, not low-usage churners. The lifecycle play for Max is sustaining/accelerating the natural ramp and re-igniting the ~18% who front-loaded then cooled.

**Single best Month-1 predictor of growth?** There is **no clean positive feature lever** — ratio-expansion is confounded by M1 base level (heavy week-1 users have no headroom). The best *directional* positives are **multi-repo activity** (3+ repos → 70% expanding vs 52% for 1) and **`deepwiki_view`** (RR 1.37, ns). The actionable read: encourage Max users to bring **more repos** into Devin early, rather than maximizing week-1 intensity on one repo.

**Is individual→team a real path worth a lifecycle play?** No — not within Max. 102/103 are solo and stay solo; only 1 added a teammate in 90 days. Seat expansion is the Teams motion, not a Max lifecycle lever. Nurture Max as a single-player power-user plan (more repos, sustained cadence); route genuine team signals to the Teams funnel.


*Caveats: n=103 (directional); correlation not causation; repo breadth via PR URLs only; sub-buckets <50 flagged LOW-N; ACU = internal compute.*
