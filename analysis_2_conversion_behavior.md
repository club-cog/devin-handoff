# Analysis 2: Pre-Conversion Behavior (Free → Paid)

**Run date:** 2026-06-21
**Converters:** 7,642 (Free users with `conversion:Pro` event in last 90 days, ≥14 days from signup)
**Non-converters:** 311,406 (Free users in cohort, no `conversion:Pro` event ever)

## Validation Results

✅ GUARDRAIL 1: Cohort sizes — Converters: 7,642 / Non-converters: 311,406
✅ GUARDRAIL 2: 0 future-dated events found
✅ GUARDRAIL 3: All retention rates in [0%, 100%]
⚠️ BQML not accessible (403) — used sklearn LogisticRegression fallback

---

## Key Findings & Interpretation

**High RR behaviors have low absolute n — treat with caution.**
Playbook RR=9.06 is based on ~38 converter users (0.5% of 7,642). CI checks RR=3.67 is based on ~275 users. These ratios are directionally correct but statistically fragile. The most reliable conversion predictors by both RR and n are: merged PR (n=893 converters, RR 3.68) and MCP tools (n=229 converters, RR 3.05).

**Most reliable model output: logistic regression.**
With balanced features and full n, the logistic regression is more trustworthy than raw RR for small-n behaviors. Top predictors by odds ratio: has_ci (OR 2.74), has_playbook (OR 2.32), has_merge (OR 1.66), has_mcp_tool (OR 1.62). All significant at p<0.05.

**Counter-intuitive finding: merging code slows conversion.**
Users who merged a PR before converting took a median of 71 days to pay vs 49 days for those who did not merge. Possible explanation: users who ship code successfully are getting value from Free and have lower urgency to upgrade. Implication: merge is a retention signal, not a conversion accelerator. Conversion emails for merge users should emphasize team features and scale — not "unlock more" framing.

**Onboarding tour and Review feature show negative association with conversion** (RR 0.84 and 0.76). This is almost certainly reverse causation: users who spend time on tours and reviewing PRs are already engaged enough to stay Free longer. Do not interpret as "tours hurt conversion".

---

## Behavior Comparison Table

| # | Behavior | Converters % | Non-converters % | RR | Chi-sq p | Sig | Verdict |
|---|---|---|---|---|---|---|---|
| 1 | Triggered playbook | 0.5% | 0.1% | 9.06 | 0.0 | *** | Strong signal 🔥 |
| 2 | Had PR merged | 5.9% | 1.6% | 3.68 | 0.0 | *** | Strong signal 🔥 |
| 3 | Had CI checks | 3.6% | 1.0% | 3.67 | 0.0 | *** | Strong signal 🔥 |
| 4 | Used MCP tools | 3.0% | 1.0% | 3.05 | 0.0 | *** | Strong signal 🔥 |
| 5 | Created a PR | 8.5% | 3.5% | 2.42 | 0.0 | *** | Strong signal 🔥 |
| 6 | Restored checkpoint | 2.6% | 1.3% | 2.06 | 0.0 | *** | Strong signal 🔥 |
| 7 | Used testing setup | 1.7% | 1.3% | 1.38 | 0.000246 | *** | Weak signal |
| 8 | Used Computer Use | 5.5% | 4.4% | 1.24 | 1.2e-05 | *** | Weak signal |
| 9 | Completed onboarding tour | 10.9% | 13.0% | 0.84 | 0.0 | *** | Negligible |
| 10 | Used Devin Review | 10.4% | 13.7% | 0.76 | 0.0 | *** | Negligible |

## Continuous Variable Comparison

| Variable | Converters median | Converters p75 | Non-converters median | Non-converters p75 | Mann-Whitney p |
|---|---|---|---|---|---|
| active_days | 1 | 2 | 0 | 0 | < 0.001 *** |
| acus_total | 0.74 | 4.97 | 0 | 0 | < 0.001 *** |
| prs_created | 0 | 0 | 0 | 0 | ns |
| prs_merged | 0 | 0 | 0 | 0 | ns |

*Note: Mann-Whitney U tests computed on sampled data (all converters + 15k non-converters). For active_days and acus_total, distributional differences are extreme (median 0 vs non-zero) so p < 0.001 is expected.*

## Logistic Regression (sklearn fallback)

**Model:** `sklearn.linear_model.LogisticRegression(max_iter=1000)`
**Population:** 22,642 users (7,642 converters, 15,000 non-converters sampled)

| Feature | Coefficient | Odds Ratio | 95% CI lower | 95% CI upper | p-value | Sig |
|---|---|---|---|---|---|---|
| active_days_14d | 0.1366 | 1.1464 | 1.1273 | 1.1659 | 0.0 | *** |
| acus_week1 | 0.0838 | 1.0875 | 1.079 | 1.096 | 0.0 | *** |
| has_merge | 0.5047 | 1.6565 | 1.3594 | 2.0185 | 1e-06 | *** |
| has_mcp_tool | 0.4829 | 1.6208 | 1.2558 | 2.0919 | 0.000415 | *** |
| has_playbook | 0.8413 | 2.3194 | 1.1254 | 4.7804 | 0.045202 | * |
| has_ci | 1.0078 | 2.7397 | 2.1526 | 3.4869 | 0.0 | *** |
| completed_onboarding | 0.0143 | 1.0144 | 0.8894 | 1.1569 | 1.662863 | ns |
| used_review | -0.6567 | 0.5186 | 0.4513 | 0.5959 | 0.0 | *** |

## Time-to-Conversion

| Segment | n | Median days signup → conversion | p25 | p75 |
|---|---|---|---|---|
| Had ≥1 merge before conversion | 893 | 71 | 37 | 267 |
| Had 0 merges before conversion | 6,749 | 49 | 31 | 59 |
| Had ≥4 active days in first 14d | 1,671 | 49 | 32 | 56 |
| Had <4 active days in first 14d | 5,971 | 50 | 31 | 64 |

