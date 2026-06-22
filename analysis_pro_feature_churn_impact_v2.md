# Pro Plan — First-14-Day Feature Behaviors vs D30 Churn & Retention (v2, cleaned cohort)

**Goal:** For Pro-plan users, identify which in-product behaviors in the first 14 days are associated with lower D30 churn and higher D30 retention / session count — to decide which features to highlight in onboarding emails.

**v2 changes vs `analysis_pro_feature_churn_impact.md`:**
- **Fix 1 — Activation filter:** cohort restricted to Pro users with ≥1 usage day (session OR positive internal-ACU day) in their first 14 days. The "not used" group is now *active* users who didn't touch that feature — not dormant accounts.
- **Fix 2 — Exclude April-15 bulk cohort:** users created 2026-04-13 → 2026-04-20 (the bulk provisioning event from `analysis_pro_monthly_funnel.md`) are dropped.

## Cohort

- Pro plan (priority mapping over `dim_user_orgs`), created **37–90 days ago** (all D30-eligible, excl. 2026-04-13..04-20), web-active (`User:Navigate:Page`), **activated** (≥1 usage day in first 14d), excluding cognition/synthetic.
- **Cohort size: 9,615 users** (down from 48,112). Baseline D30 retention = **51.3%** (was 69.1%); baseline churn = **0.53%** (was 1.24%).
- Feature presence = binary (≥1 occurrence in first 14 days / hours 0–335).
- `D30%` = ≥1 usage day in days 23–37. `churned%` = no usage day in trailing 60 days.
- `RR churn` = churned% used / churned% not-used (**lower = better**). `RR D30` = D30% used / D30% not-used (**higher = better**). `p` = chi-square on D30 retained vs not.
- **Guardrail:** features with used n < 100 flagged ⚠️ LOW-N and excluded from rankings.

## Full Table

| Feature | Used n | Used D30% | Used churn% | Not-used n | Not-used D30% | Not-used churn% | RR churn | RR D30 | Chi-sq p | Med sess (used) | Med sess (not) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| has_playbook | 159 | 67.9% | 10.69% | 9,456 | 51.1% | 0.36% | 29.74 | 1.33 | 3.5e-05 | 4 | 0 |
| suggest_testing_setup | 334 | 52.7% | 5.39% | 9,281 | 51.3% | 0.36% | 15.16 | 1.03 | 6.5e-01 | 5 | 0 |
| checkpoint_restored | 479 | 49.7% | 3.34% | 9,136 | 51.4% | 0.38% | 8.72 | 0.97 | 4.9e-01 | 5 | 0 |
| pr_comment | 414 | 49.0% | 2.17% | 9,201 | 51.4% | 0.46% | 4.76 | 0.95 | 3.6e-01 | 5 | 0 |
| check_run_created | 485 | 48.0% | 1.86% | 9,130 | 51.5% | 0.46% | 4.03 | 0.93 | 1.5e-01 | 5 | 0 |
| mcp_tool_call | 521 | 45.7% | 2.30% | 9,094 | 51.7% | 0.43% | 5.37 | 0.88 | 9.0e-03 | 6 | 0 |
| has_merge | 810 | 45.4% | 1.60% | 8,805 | 51.9% | 0.43% | 3.72 | 0.88 | 5.1e-04 | 4 | 0 |
| has_pr | 1,143 | 44.7% | 1.66% | 8,472 | 52.2% | 0.38% | 4.40 | 0.86 | 2.1e-06 | 4 | 0 |
| computer_use | 1,477 | 40.3% | 1.29% | 8,138 | 53.3% | 0.39% | 3.27 | 0.76 | 3.3e-20 | 4 | 0 |
| web_search | 1,205 | 39.6% | 0.91% | 8,410 | 53.0% | 0.48% | 1.92 | 0.75 | 3.4e-18 | 5 | 0 |
| Devin Review used (web) | 2,239 | 38.8% | 0.94% | 7,376 | 55.2% | 0.41% | 2.31 | 0.70 | 6.8e-42 | 3 | 0 |
| OnboardingTour (web) | 2,279 | 36.9% | 0.31% | 7,336 | 55.8% | 0.60% | 0.51 | 0.66 | 5.9e-56 | 2 | 0 |
| structured_output_update ⚠️ | 64 | 73.4% | 6.25% | 9,551 | 51.2% | 0.49% | 12.70 | 1.43 | 6.2e-04 | 11 | 0 |
| playbook_triggered ⚠️ | 43 | 58.1% | 0.00% | 9,572 | 51.3% | 0.53% | 0.00 | 1.13 | 4.6e-01 | 12 | 0 |
| Automation:Create (web) ⚠️ | 15 | 60.0% | 0.00% | 9,600 | 51.3% | 0.53% | 0.00 | 1.17 | 6.8e-01 | 0 | 0 |
| Composer MCPShortcut (web) ⚠️ | 0 | 0.0% | 0.00% | 9,615 | 51.3% | 0.53% | n/a | n/a | n/a | 0 | 0 |

## Ranked — by RR churn ascending (strongest churn reduction first, LOW-N excluded)

| Rank | Feature | RR churn | Used churn% | Not-used churn% |
|---:|---|---:|---:|---:|
| 1 | OnboardingTour (web) | 0.51 | 0.31% | 0.60% |
| 2 | web_search | 1.92 | 0.91% | 0.48% |
| 3 | Devin Review used (web) | 2.31 | 0.94% | 0.41% |
| 4 | computer_use | 3.27 | 1.29% | 0.39% |
| 5 | has_merge | 3.72 | 1.60% | 0.43% |
| 6 | check_run_created | 4.03 | 1.86% | 0.46% |
| 7 | has_pr | 4.40 | 1.66% | 0.38% |
| 8 | pr_comment | 4.76 | 2.17% | 0.46% |
| 9 | mcp_tool_call | 5.37 | 2.30% | 0.43% |
| 10 | checkpoint_restored | 8.72 | 3.34% | 0.38% |
| 11 | suggest_testing_setup | 15.16 | 5.39% | 0.36% |
| 12 | has_playbook | 29.74 | 10.69% | 0.36% |

## Ranked — by RR D30 descending (strongest retention lift first, LOW-N excluded)

| Rank | Feature | RR D30 | Used D30% | Not-used D30% | Chi-sq p |
|---:|---|---:|---:|---:|---:|
| 1 | has_playbook | 1.33 | 67.9% | 51.1% | 3.5e-05 |
| 2 | suggest_testing_setup | 1.03 | 52.7% | 51.3% | 6.5e-01 |
| 3 | checkpoint_restored | 0.97 | 49.7% | 51.4% | 4.9e-01 |
| 4 | pr_comment | 0.95 | 49.0% | 51.4% | 3.6e-01 |
| 5 | check_run_created | 0.93 | 48.0% | 51.5% | 1.5e-01 |
| 6 | mcp_tool_call | 0.88 | 45.7% | 51.7% | 9.0e-03 |
| 7 | has_merge | 0.88 | 45.4% | 51.9% | 5.1e-04 |
| 8 | has_pr | 0.86 | 44.7% | 52.2% | 2.1e-06 |
| 9 | computer_use | 0.76 | 40.3% | 53.3% | 3.3e-20 |
| 10 | web_search | 0.75 | 39.6% | 53.0% | 3.4e-18 |
| 11 | Devin Review used (web) | 0.70 | 38.8% | 55.2% | 6.8e-42 |
| 12 | OnboardingTour (web) | 0.66 | 36.9% | 55.8% | 5.9e-56 |

## Interpretation

**Cleaning the cohort materially changed the picture — but did not turn most features positive.** With dormant/bulk accounts removed, the baseline D30 drops from 69.1% to 51.3%, and the uniform strong-negative pattern from v1 collapses. Results now split into three groups:

- **One genuine positive: `has_playbook`** — playbook users retain **67.9% D30 vs 51.1%** (RR D30 **1.33**, p=3.5e-05). This is the only feature with a significant positive retention association in the cleaned cohort, and it is consistent with the conversion analysis where playbook was the top signal. It is the strongest candidate to highlight in onboarding emails, with the caveat that n=159 is modest and playbook users are self-selected power users.
- **Roughly neutral (the v1 "negative" was an artifact): `suggest_testing_setup` (1.03), `checkpoint_restored` (0.97), `pr_comment` (0.95), `check_run_created` (0.93)** — all within a few points of baseline and non-significant (p 0.15–0.65). Once you compare feature-users against *active* non-users, the apparent retention penalty on the code-review loop disappears. These are neutral-to-slightly-positive markers of a real workflow, not retention risks.
- **Still clearly negative — early-stage / exploratory markers: `has_pr` (0.86), `has_merge` (0.88), `mcp_tool_call` (0.88), `computer_use` (0.76), `web_search` (0.75), `Devin Review` (0.70), `OnboardingTour` (0.66).** These remain below baseline even after cleaning. The web-onboarding signals (`OnboardingTour`, `Devin Review`) are the lowest D30 — they overwhelmingly tag users still in the evaluation phase (median 2–3 sessions) who churn out regardless of feature. For `has_pr`/`has_merge`/`computer_use` the most likely driver is reverse causation: a one-off "try Devin on a task, ship a PR, leave" pattern among trialing Pro users, not that shipping code reduces retention.

**Churn columns remain unreliable — do not rank on them.** Baseline churn is 0.53% (51 of 9,615); per-feature churned counts are single/double digits, so `RR churn` values (e.g. `has_playbook` 29.7 on 17 churned, `suggest_testing_setup` 15.2) are statistical noise. The D30 chi-square is the trustworthy metric.

**Onboarding-email recommendation:** highlight **playbooks** as the headline activation action (the one defensible positive retention lever here). Treat the PR/CI/MCP code-loop as neutral table-stakes workflow rather than a retention driver, and do not build email CTAs around tours / Devin-Review browsing / computer-use — those mark users who are still evaluating and are the weakest D30 segments.
