# Pro Plan — Monthly Activation Funnel (2026)

**Question:** Has the Pro activation funnel (GitHub connect → first PR → first merge) shifted month over month in 2026, and are the 90-day aggregate numbers still representative of the last 30 days?

## Definitions

Same table definitions as `plg_activation_funnel.md`:

- **Plan = `pro`** — best plan per user via `dim_user_orgs` priority mapping (`teams-v2 > max > pro > pro-trial > free`).
- **Cohort** — users created in each calendar month, excluding `is_cognition_user` and `is_synthetic_user`, with ≥1 `User:Navigate:Page` event (web-active filter).
- **has_github** — fired a git-connect event (`User:Initiate:ConnectGitProvider`, `User:Redirect:ConnectGithubOrg`, `User:Initiate:InstallGitHub`, `User:Complete:OnboardingGitConnect`, `User:Initiate:OnboardingGitConnect`) **OR** has any row in `pull_requests`.
- **first_pr** — has any `pull_requests` row (`MIN(created_at)` exists).
- **first_merge** — has any merged `pull_requests` row (`MIN(merged_at)` exists).

Rates are computed as a share of `created` (each step is a share of the full cohort, not the prior step).

## Funnel by Monthly Cohort

| Month | Created | Has GitHub | GitHub % | First PR | PR % | First Merge | Merge % |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2026-03 | 611 | 342 | 56.0% | 257 | 42.1% | 199 | 32.6% |
| 2026-04 ⚠️ | 41,343 | 8,630 | 20.9% | 2,414 | 5.8% | 1,744 | 4.2% |
| 2026-05 | 11,632 | 4,157 | 35.7% | 1,457 | 12.5% | 822 | 7.1% |
| 2026-06 ⚠️ | 4,485 | 1,495 | 33.3% | 607 | 13.5% | 388 | 8.7% |

⚠️ See guardrail notes below for April (bulk-signup contamination) and June (right-censoring).

## Interpretation

**Treat April as non-comparable, and the funnel as roughly stable across the clean months.** The headline month-over-month series looks volatile — GitHub connect runs 56% → 21% → 36% → 33% and merge runs 33% → 4% → 7% → 9% — but almost all of that swing is an artifact of the **April cohort**, which is contaminated by a bulk plan-assignment event: **77,798 "Pro" users were created on 2026-04-15 alone** (with secondary spikes on 04-18 through 04-20), versus ~10–30 organic signups per day before and after. These users were provisioned in bulk rather than signing up organically, so they overwhelmingly never connected GitHub or opened a PR, which mechanically craters every April rate. April should be excluded from any trend read. Setting April aside, the funnel is **broadly stable with a mild recent softening**: among the cleaner cohorts, GitHub-connect sits in the 33–36% range for May–June (March's 56% is a small-n, very-early cohort of only 611 users and is noisy), while first-PR (12.5% → 13.5%) and first-merge (7.1% → 8.7%) are flat-to-slightly-improving from May into June. Net: the 90-day aggregate is being dragged down by the April bulk cohort, so the aggregate **understates** the true organic funnel; the last-30-day (June) organic funnel looks healthy and in line with May, not declining.

## Guardrail Notes

- **April bulk-signup contamination (critical):** The April cohort (41,343 web-active Pro users) is dominated by a non-organic provisioning event — 77,798 Pro users created on 2026-04-15, plus elevated volume 04-18→04-20 (3.9k–10.4k/day) versus a typical organic baseline of ~10–30/day. These users depress all April rates and make April incomparable to other months. Any month-over-month conclusion should exclude April.
- **June right-censoring:** The June cohort (4,485) covers only ~21 days of signup data (through 2026-06-21) and each user has had less time to progress through the funnel. June's GitHub-connect (33.3%), PR (13.5%) and merge (8.7%) rates are therefore **lower bounds** — they will tick up as June users mature. Notably, despite censoring, June's rates already match or exceed May's, which argues against any funnel decline. June's GitHub-connect rate is **not** artificially collapsed (it tracks May closely), so recency is not masking a connect-rate problem.
- **March small-n:** Only 611 users; rates (especially the 56% connect rate) are high-variance and should not anchor the trend.
