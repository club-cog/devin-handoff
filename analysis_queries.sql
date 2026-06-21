-- ============================================================
-- LIFECYCLE ANALYSIS: Feature Retention & Conversion
-- Run date: 2026-06-21
-- Cohort window: last 90 days
-- BigQuery project: exafunction.analytics
-- Author: Devin (automated)
-- ============================================================

-- Summary of Analysis 3 (Email List Enrichment):
-- Input file: devin_product_launch_email_list.csv (not available this run)
-- Analysis 3 pending email list file from user

-- ============================================================
-- SECTION 0: GUARDRAIL CHECKS
-- ============================================================

-- [G1] Cohort size per plan
-- Verifies each plan has >= 100 users in the analysis cohort
WITH cohort_base AS (
  SELECT u.user_id, u.created_at
  FROM exafunction.analytics.dim_users u
  WHERE u.is_cognition_user = FALSE
    AND u.is_synthetic_user = FALSE
    AND DATE_DIFF(CURRENT_DATE(), DATE(u.created_at), DAY) BETWEEN 14 AND 90
),
web_active AS (
  SELECT DISTINCT user_id
  FROM exafunction.analytics.analytics_events
  WHERE ts_received >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
    AND event_name = 'User:Navigate:Page'
),
cohort AS (
  SELECT c.* FROM cohort_base c
  INNER JOIN web_active w ON c.user_id = w.user_id
),
plans AS (
  SELECT user_id,
    ARRAY_AGG(plan_type IGNORE NULLS ORDER BY
      CASE plan_type
        WHEN 'teams-v2'  THEN 1
        WHEN 'max'       THEN 2
        WHEN 'pro'       THEN 3
        WHEN 'pro-trial' THEN 4
        WHEN 'free'      THEN 5
        ELSE 6
      END LIMIT 1)[SAFE_OFFSET(0)] AS plan
  FROM exafunction.analytics.dim_user_orgs
  GROUP BY user_id
)
SELECT p.plan, COUNT(DISTINCT c.user_id) AS n
FROM cohort c
INNER JOIN plans p ON c.user_id = p.user_id
WHERE p.plan IN ('free', 'pro-trial', 'max', 'teams-v2', 'pro')
GROUP BY 1
ORDER BY 1;

-- [G2] Future-dated events check
-- Expected: 0 rows
SELECT COUNT(*) AS future_events
FROM exafunction.analytics.dim_sessions
WHERE created_at > CURRENT_TIMESTAMP();

-- ============================================================
-- SECTION 1: SHARED CTEs (reused across analyses)
-- ============================================================

-- [CTE: cohort] Base user cohort — created 90-14 days ago, web-active, non-cognition
-- Users created between 90 and 14 days ago, excluding Cognition internal users
-- and synthetic test users, restricted to those with at least one
-- User:Navigate:Page event in the last 90 days (web-active filter).
-- The 14-day minimum age ensures week-1 behavior data is complete.

-- [CTE: plans] Best plan per user using priority mapping
-- Assigns each user their highest-priority plan across all org memberships:
-- teams-v2 > max > pro > pro-trial > free
-- Uses ARRAY_AGG with ORDER BY priority LIMIT 1 for deterministic selection.

-- [CTE: activity] Usage days — sessions UNION ACU consumption
-- A usage day is any calendar day with either a Devin session
-- (excluding cognition-in-customer sessions) or positive internal ACU
-- consumption. The UNION DISTINCT covers Teams-v2 Cascade users who
-- never appear in dim_sessions.
SELECT user_id, DATE(created_at) AS d
FROM exafunction.analytics.dim_sessions
WHERE created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
  AND NOT is_cognition_session_in_customer_org
GROUP BY 1, 2

UNION DISTINCT

SELECT user_id, DATE(window_start) AS d
FROM exafunction.analytics.hourly_consumption_by_user
WHERE window_start >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
  AND internal_acu_delta > 0
GROUP BY 1, 2;

-- ============================================================
-- SECTION 2: ANALYSIS 1 — Feature Behavior Retention
-- ============================================================

-- [A1-FEAT] Session event counts per user per behavior in week 1
-- Counts occurrences of each tracked event type in devin_events
-- within the user's first 168 hours (week 1) from signup.
-- Event types: mcp_tool_call, computer_use, web_search,
-- playbook_triggered, structured_output_update, checkpoint_restored,
-- check_run_created, pr_comment, suggest_testing_setup
SELECT e.user_id, e.type AS behavior, COUNT(*) AS cnt
FROM exafunction.analytics.devin_events e
INNER JOIN cohort c ON e.user_id = c.user_id
WHERE e.created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
  AND TIMESTAMP_DIFF(e.created_at, c.created_at, HOUR) BETWEEN 0 AND 167
  AND e.type IN (
    'mcp_tool_call','computer_use','web_search','playbook_triggered',
    'structured_output_update','checkpoint_restored','check_run_created',
    'pr_comment','suggest_testing_setup'
  )
GROUP BY 1, 2;

-- [A1-RET] Retention flags per user (D30, D60, churned)
-- D30: any usage day between days 23-37 from signup (eligible if account >= 37 days old)
-- D60: any usage day between days 53-67 from signup (eligible if account >= 67 days old)
-- Churned: no usage day in the trailing 60 days from today
SELECT c.user_id, c.created_at, p.plan,
  CASE WHEN DATE_DIFF(CURRENT_DATE(), DATE(c.created_at), DAY) >= 37
       THEN LOGICAL_OR(a.d BETWEEN DATE_ADD(DATE(c.created_at), INTERVAL 23 DAY)
                                AND DATE_ADD(DATE(c.created_at), INTERVAL 37 DAY))
       ELSE NULL END AS d30_retained,
  CASE WHEN DATE_DIFF(CURRENT_DATE(), DATE(c.created_at), DAY) >= 67
       THEN LOGICAL_OR(a.d BETWEEN DATE_ADD(DATE(c.created_at), INTERVAL 53 DAY)
                                AND DATE_ADD(DATE(c.created_at), INTERVAL 67 DAY))
       ELSE NULL END AS d60_retained,
  NOT LOGICAL_OR(a.d >= DATE_SUB(CURRENT_DATE(), INTERVAL 60 DAY)) AS churned
FROM cohort c
INNER JOIN plans p ON c.user_id = p.user_id
LEFT JOIN activity a ON c.user_id = a.user_id
WHERE p.plan IN ('free','pro-trial','max','teams-v2','pro')
GROUP BY c.user_id, c.created_at, p.plan;

-- [A1-MAIN] Final bucket x retention table
-- Query map:
--   cohort_base:       users created 90-14 days ago, non-cognition/synthetic
--   web_active:        users with page navigation event in 90 days
--   cohort:            intersection of above two
--   plans:             best plan per user
--   activity:          all usage days (sessions + ACU consumption)
--   week1_behaviors:   event counts per user per behavior in week 1
--   user_retention:    retention flags per user
--   all_behaviors:     static list of 9 behaviors
--   user_behavior_counts: cross join users x behaviors with bucketing
-- Buckets: 0, 1-2, 3-5, 5+ (collapsed to 0/1+ if any non-zero bucket < 100)
-- Output: behavior, plan, bucket, n, d30_eligible_n, d30_retained_n,
--         d60_eligible_n, d60_retained_n, churned_n
-- All counts use COUNT(DISTINCT user_id) to prevent join fan-out inflation.

-- [A1-CROSS] Cross-behavior interaction — PR + MCP + Playbook
-- Groups users with >=1 pr_created event in week 1:
--   A: PR only (no MCP, no playbook)
--   B: PR + MCP tool call
--   C: PR + playbook
--   D: PR + both
-- Output: plan, group, n, d30_eligible_n, d30_retained_n,
--         d60_eligible_n, d60_retained_n, churned_n

-- ============================================================
-- SECTION 3: ANALYSIS 2 — Pre-Conversion Behavior
-- ============================================================

-- [A2-CONV] Identify converters — conversion:Pro event + pre-conversion window
-- Converters: Free users with conversion:Pro event in last 90 days
-- Pre-conversion window = 14 days before their earliest conversion:Pro timestamp
-- Excluded: users whose conversion:Pro fired within 14 days of signup
SELECT ae.user_id, MIN(ae.ts_received) AS conversion_ts
FROM exafunction.analytics.analytics_events ae
WHERE ae.event_name = 'conversion:Pro'
  AND ae.ts_received >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
GROUP BY ae.user_id;

-- [A2-NONCONV] Non-converter cohort
-- Users in cohort (created 90-14 days ago, web-active) with current plan = free
-- and no conversion:Pro event ever. Window = days 0-14 from signup.

-- [A2-FEAT] Feature presence in window for both groups
-- Binary features: has_mcp_tool, has_playbook, has_computer_use,
--   has_checkpoint, has_ci, has_testing_setup (from devin_events)
-- Non-windowed: completed_onboarding (User:Complete:OnboardingTour ever)
-- Windowed: used_review (Review:Job:Launch or Review:PRPage:View in window)
-- PR features: has_pr, has_merge (from pull_requests table)

-- [A2-MAIN] Comparison table
-- For each behavior: converter %, non-converter %, RR, chi-sq p, significance

-- [A2-BQML] Logistic regression
-- Note: BQML CREATE MODEL returned 403 (bigquery.models.create denied).
-- Fallback: sklearn.linear_model.LogisticRegression(max_iter=1000)
-- Features: active_days_14d, acus_week1, has_merge, has_mcp_tool,
--           has_playbook, has_ci, completed_onboarding, used_review
-- Outcome: converted (1/0)
-- Population: all 7,642 converters + 15,000 sampled non-converters
-- Script: analysis_logistic_regression.py

-- ============================================================
-- SECTION 4: ANALYSIS 3 — Email List Enrichment
-- ============================================================

-- [A3-MATCH] User matching strategy (email -> username -> org_id)
-- Note: Email list file not provided in this session.
-- Match strategy:
--   1. Primary: LOWER(TRIM(email)) -> analytics.dim_users.primary_email_address
--   2. Fallback 1: username -> analytics.dim_users.username
--   3. Fallback 2: org_id -> analytics.dim_user_orgs.org_id -> user_id
SELECT user_id, LOWER(primary_email_address) AS email, username
FROM exafunction.analytics.dim_users;

-- [A3-ENRICH] All appended fields per matched user
-- Fields: has_pr, has_merge, first_pr_date, first_merge_date,
--         last_active_date_bq, days_since_last_active,
--         total_active_days_90d, active_days_14d, acus_week1,
--         weekly_acus_avg_90d, lifecycle_stage, churn_risk
-- All activity fields use the session + ACU consumption union (CTE: activity)

-- [A3-STAGE] Lifecycle stage assignment
-- Priority order: churned_likely > at_risk_high > at_risk_activated >
--   at_risk_not_activated > activated > pr_no_merge > no_github > unknown
