-- ============================================================
-- 02_cohort_retention.sql
-- SaaS Product Engagement & Conversion Analysis
-- Purpose: Monthly cohort retention analysis
-- ============================================================


-- -------------------------------------------------------
-- Q1: Monthly cohort retention grid
-- Shows what % of each signup cohort is still active N months later
-- -------------------------------------------------------

WITH cohorts AS (
    SELECT
        user_id,
        DATE_FORMAT(signup_date, '%Y-%m') AS cohort_month,
        signup_date
    FROM subscriptions
),
activity AS (
    SELECT
        fe.user_id,
        c.cohort_month,
        TIMESTAMPDIFF(MONTH, c.signup_date, fe.event_date) AS months_since_signup
    FROM funnel_events fe
    JOIN cohorts c ON fe.user_id = c.user_id
    WHERE fe.event_date >= c.signup_date
),
retention AS (
    SELECT
        cohort_month,
        months_since_signup,
        COUNT(DISTINCT user_id) AS active_users
    FROM activity
    WHERE months_since_signup >= 0
    GROUP BY cohort_month, months_since_signup
),
cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM cohorts
    GROUP BY cohort_month
)
SELECT
    r.cohort_month,
    cs.cohort_size,
    r.months_since_signup,
    r.active_users,
    ROUND(r.active_users / cs.cohort_size * 100, 1) AS retention_pct
FROM retention r
JOIN cohort_sizes cs ON r.cohort_month = cs.cohort_month
ORDER BY r.cohort_month, r.months_since_signup;


-- -------------------------------------------------------
-- Q2: Cohort retention by plan tier
-- -------------------------------------------------------

WITH cohorts AS (
    SELECT
        user_id,
        plan_tier,
        DATE_FORMAT(signup_date, '%Y-%m') AS cohort_month,
        signup_date
    FROM subscriptions
),
activity AS (
    SELECT
        fe.user_id,
        c.plan_tier,
        c.cohort_month,
        TIMESTAMPDIFF(MONTH, c.signup_date, fe.event_date) AS months_since_signup
    FROM funnel_events fe
    JOIN cohorts c ON fe.user_id = c.user_id
),
retention AS (
    SELECT
        plan_tier,
        cohort_month,
        months_since_signup,
        COUNT(DISTINCT user_id) AS active_users
    FROM activity
    WHERE months_since_signup >= 0
    GROUP BY plan_tier, cohort_month, months_since_signup
),
cohort_sizes AS (
    SELECT
        plan_tier,
        cohort_month,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM cohorts
    GROUP BY plan_tier, cohort_month
)
SELECT
    r.plan_tier,
    r.cohort_month,
    cs.cohort_size,
    r.months_since_signup,
    r.active_users,
    ROUND(r.active_users / cs.cohort_size * 100, 1) AS retention_pct
FROM retention r
JOIN cohort_sizes cs
    ON r.plan_tier = cs.plan_tier
    AND r.cohort_month = cs.cohort_month
ORDER BY r.plan_tier, r.cohort_month, r.months_since_signup;


-- -------------------------------------------------------
-- Q3: Churn timing — when do most users churn?
-- -------------------------------------------------------

SELECT
    TIMESTAMPDIFF(MONTH, signup_date, churn_date) AS months_to_churn,
    COUNT(*) AS churned_users,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 1) AS pct_of_total_churn
FROM subscriptions
WHERE churn_flag = 1
    AND churn_date IS NOT NULL
GROUP BY months_to_churn
ORDER BY months_to_churn;
