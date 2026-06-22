# Pro Plan — First-14-Day Feature Behaviors vs D30 Churn & Retention

**Goal:** For Pro-plan users, identify which in-product behaviors in the first 14 days are associated with lower D30 churn and higher D30 retention / session count — to decide which features to highlight in onboarding emails.

## Cohort

- Pro plan (priority mapping over `dim_user_orgs`), created **37–90 days ago** (all D30-eligible), web-active (`User:Navigate:Page`), excluding cognition/synthetic. Definitions per `analysis_queries.sql`.
- **Cohort size: 48,112 users.** Baseline D30 retention = 69.1%; baseline churn = 1.24%.
- Feature presence = binary (≥1 occurrence in first 14 days / hours 0–335).
- `D30%` = ≥1 usage day (session or positive internal-ACU day) in days 23–37. `churned%` = no usage day in trailing 60 days.
- `RR churn` = churned% used / churned% not-used (**lower = better**). `RR D30` = D30% used / D30% not-used (**higher = better**). `p` = chi-square on D30 retained vs not.
- **Guardrail:** features with used n < 100 flagged ⚠️ LOW-N and excluded from rankings.

## Full Table

| Feature | Used n | Used D30% | Used churn% | Not-used n | Not-used D30% | Not-used churn% | RR churn | RR D30 | Chi-sq p | Med sess (used) | Med sess (not) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| has_playbook | 171 | 68.4% | 11.11% | 47,941 | 69.1% | 1.20% | 9.25 | 0.99 | 9.0e-01 | 5 | 0 |
| suggest_testing_setup | 440 | 58.0% | 5.23% | 47,672 | 69.3% | 1.20% | 4.36 | 0.84 | 4.3e-07 | 5 | 0 |
| pr_comment | 600 | 56.7% | 2.33% | 47,512 | 69.3% | 1.22% | 1.91 | 0.82 | 3.7e-11 | 5 | 0 |
| check_run_created | 666 | 55.0% | 1.95% | 47,446 | 69.3% | 1.23% | 1.59 | 0.79 | 2.0e-15 | 5 | 0 |
| checkpoint_restored | 580 | 53.8% | 3.62% | 47,532 | 69.3% | 1.21% | 3.00 | 0.78 | 1.2e-15 | 6 | 0 |
| mcp_tool_call | 685 | 53.6% | 2.48% | 47,427 | 69.4% | 1.22% | 2.04 | 0.77 | 9.2e-19 | 6 | 0 |
| has_merge | 1,120 | 52.9% | 1.88% | 46,992 | 69.5% | 1.22% | 1.54 | 0.76 | 1.0e-32 | 4 | 0 |
| has_pr | 1,559 | 51.8% | 2.12% | 46,553 | 69.7% | 1.21% | 1.75 | 0.74 | 5.2e-51 | 4 | 0 |
| computer_use | 1,814 | 46.4% | 1.65% | 46,298 | 70.0% | 1.22% | 1.36 | 0.66 | 1.6e-101 | 4 | 0 |
| web_search | 1,466 | 45.0% | 1.30% | 46,646 | 69.9% | 1.23% | 1.05 | 0.64 | 5.6e-92 | 5 | 0 |
| Devin Review used (web) | 2,882 | 42.6% | 1.60% | 45,230 | 70.8% | 1.21% | 1.31 | 0.60 | 3.2e-221 | 2 | 0 |
| OnboardingTour (web) | 2,738 | 39.0% | 1.10% | 45,374 | 71.0% | 1.25% | 0.88 | 0.55 | 1.7e-270 | 2 | 0 |
| structured_output_update ⚠️ | 89 | 74.2% | 6.74% | 48,023 | 69.1% | 1.23% | 5.50 | 1.07 | 3.6e-01 | 11 | 0 |
| playbook_triggered ⚠️ | 49 | 59.2% | 4.08% | 48,063 | 69.2% | 1.23% | 3.31 | 0.86 | 1.8e-01 | 12 | 0 |
| Automation:Create (web) ⚠️ | 17 | 52.9% | 0.00% | 48,095 | 69.2% | 1.24% | 0.00 | 0.77 | 2.4e-01 | 0 | 0 |
| Composer MCPShortcut (web) ⚠️ | 1 | 100.0% | 0.00% | 48,111 | 69.1% | 1.24% | 0.00 | 1.45 | 1.0e+00 | 4 | 0 |

## Ranked — by RR churn ascending (strongest churn reduction first, LOW-N excluded)

| Rank | Feature | RR churn | Used churn% | Not-used churn% |
|---:|---|---:|---:|---:|
| 1 | OnboardingTour (web) | 0.88 | 1.10% | 1.25% |
| 2 | web_search | 1.05 | 1.30% | 1.23% |
| 3 | Devin Review used (web) | 1.31 | 1.60% | 1.21% |
| 4 | computer_use | 1.36 | 1.65% | 1.22% |
| 5 | has_merge | 1.54 | 1.88% | 1.22% |
| 6 | check_run_created | 1.59 | 1.95% | 1.23% |
| 7 | has_pr | 1.75 | 2.12% | 1.21% |
| 8 | pr_comment | 1.91 | 2.33% | 1.22% |
| 9 | mcp_tool_call | 2.04 | 2.48% | 1.22% |
| 10 | checkpoint_restored | 3.00 | 3.62% | 1.21% |
| 11 | suggest_testing_setup | 4.36 | 5.23% | 1.20% |
| 12 | has_playbook | 9.25 | 11.11% | 1.20% |

## Ranked — by RR D30 descending (strongest retention lift first, LOW-N excluded)

| Rank | Feature | RR D30 | Used D30% | Not-used D30% | Chi-sq p |
|---:|---|---:|---:|---:|---:|
| 1 | has_playbook | 0.99 | 68.4% | 69.1% | 9.0e-01 |
| 2 | suggest_testing_setup | 0.84 | 58.0% | 69.3% | 4.3e-07 |
| 3 | pr_comment | 0.82 | 56.7% | 69.3% | 3.7e-11 |
| 4 | check_run_created | 0.79 | 55.0% | 69.3% | 2.0e-15 |
| 5 | checkpoint_restored | 0.78 | 53.8% | 69.3% | 1.2e-15 |
| 6 | mcp_tool_call | 0.77 | 53.6% | 69.4% | 9.2e-19 |
| 7 | has_merge | 0.76 | 52.9% | 69.5% | 1.0e-32 |
| 8 | has_pr | 0.74 | 51.8% | 69.7% | 5.2e-51 |
| 9 | computer_use | 0.66 | 46.4% | 70.0% | 1.6e-101 |
| 10 | web_search | 0.64 | 45.0% | 69.9% | 5.6e-92 |
| 11 | Devin Review used (web) | 0.60 | 42.6% | 70.8% | 3.2e-221 |
| 12 | OnboardingTour (web) | 0.55 | 39.0% | 71.0% | 1.7e-270 |

## Interpretation

**The result is the inverse of the hypothesis: under this cohort definition, *every* tested feature is associated with LOWER D30 retention (all RR D30 < 1.0) and, for the churn-significant features, HIGHER churn (RR churn > 1.0). No feature reduces churn or lifts retention here.** Feature users *do* run more sessions in the first 14 days (median 2–12 vs 0 for non-users), so the "more sessions" half of the hypothesis holds — but more sessions correlates with *lower* D30 in this cohort, which is the tell that the comparison is confounded, not that features hurt retention.

**Why this happens — the "not-used" baseline is inflated, exactly like the Analysis 1 cohort artifact.** This cohort has **no activation filter**: of 48,112 users, ~46K never triggered any given feature and have a median of **0 sessions** in their first 14 days, yet carry a 69% D30 baseline and 1.2% churn. That baseline is dominated by web-active-but-barely-active Pro accounts — including the **2026-04-15 bulk Pro provisioning event** (~67 days ago, squarely inside the 37–90d window) — whose retention is measured generously (any single ACU/session day in days 23–37 counts as "retained"). Genuinely engaged users who trigger features are a small, self-selected slice (666–2,882 users) being compared against this inflated mass, so they look *worse* on a rate basis. This is the same selection effect we corrected in Analysis 1, amplified by the missing activation filter.

**What is actually trustworthy here:** the *ordering* among feature-users is informative even if the absolute RRs are biased. Onboarding-flow web events (`OnboardingTour` 39.0% D30, `Devin Review` 42.6%) and exploratory signals (`web_search` 45.0%, `computer_use` 46.4%) sit at the bottom of D30 — these mark early-stage / evaluating users. Code-shipping signals cluster highest among feature-users (`pr_comment` 56.7%, `check_run_created` 55.0%, `has_merge` 52.9%, `has_pr` 51.8%), consistent with the merged-PR session analysis. Churn RRs are noisy (churn is only ~1–5% everywhere; counts are single/double digits) and should not be ranked on — `has_playbook` RR churn 9.25 rests on 19 churned of 171.

**Recommendation before acting on onboarding emails:** re-run this on the **activated cohort** (≥1 usage day in first 14d, the Analysis 1 fix) and exclude the 2026-04-15 bulk Pro cohort, so feature-users are compared against *active* non-users rather than dormant provisioned accounts. As-is, this table should not be read as "these features reduce retention" — it is a baseline-contamination artifact. The directional, defensible takeaway: emphasize **shipping code (open a PR, connect CI, get to a merge)** over tours/review-browsing/computer-use as the onboarding goal.
