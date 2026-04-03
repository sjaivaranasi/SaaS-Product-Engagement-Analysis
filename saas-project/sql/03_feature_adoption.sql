-- ============================================================
-- 03_feature_adoption.sql
-- SaaS Product Engagement & Conversion Analysis
-- Purpose: Which features predict conversion vs. churn?
-- ============================================================


-- -------------------------------------------------------
-- Q1: Feature usage — churned vs. retained users
-- -------------------------------------------------------

SELECT
    fe.feature_name,
    s.churn_flag,
    COUNT(DISTINCT fe.user_id) AS users_who_used,
    COUNT(*) AS total_events,
    ROUND(AVG(fe.event_count), 1) AS avg_events_per_user
FROM funnel_events fe
JOIN subscriptions s ON fe.user_id = s.user_id
WHERE fe.feature_name IS NOT NULL
GROUP BY fe.feature_name, s.churn_flag
ORDER BY fe.feature_name, s.churn_flag;


-- -------------------------------------------------------
-- Q2: Feature adoption rate by plan tier
-- -------------------------------------------------------

WITH total_per_tier AS (
    SELECT plan_tier, COUNT(DISTINCT user_id) AS total_users
    FROM subscriptions
    GROUP BY plan_tier
),
feature_usage AS (
    SELECT
        s.plan_tier,
        fe.feature_name,
        COUNT(DISTINCT fe.user_id) AS users_adopted
    FROM funnel_events fe
    JOIN subscriptions s ON fe.user_id = s.user_id
    WHERE fe.feature_name IS NOT NULL
    GROUP BY s.plan_tier, fe.feature_name
)
SELECT
    fu.plan_tier,
    fu.feature_name,
    fu.users_adopted,
    t.total_users,
    ROUND(fu.users_adopted / t.total_users * 100, 1) AS adoption_pct
FROM feature_usage fu
JOIN total_per_tier t ON fu.plan_tier = t.plan_tier
ORDER BY fu.plan_tier, adoption_pct DESC;


-- -------------------------------------------------------
-- Q3: "Aha moment" — features most correlated with conversion
-- Users who reached conversion vs. those who didn't
-- -------------------------------------------------------

WITH converted_users AS (
    SELECT DISTINCT user_id
    FROM funnel_events
    WHERE funnel_stage = 'conversion'
),
all_users AS (
    SELECT DISTINCT user_id FROM funnel_events
),
feature_by_conversion AS (
    SELECT
        fe.feature_name,
        CASE WHEN cu.user_id IS NOT NULL THEN 1 ELSE 0 END AS converted,
        COUNT(DISTINCT fe.user_id) AS user_count
    FROM funnel_events fe
    LEFT JOIN converted_users cu ON fe.user_id = cu.user_id
    WHERE fe.feature_name IS NOT NULL
    GROUP BY fe.feature_name, converted
)
SELECT
    feature_name,
    MAX(CASE WHEN converted = 1 THEN user_count END) AS converted_users,
    MAX(CASE WHEN converted = 0 THEN user_count END) AS not_converted_users,
    ROUND(
        MAX(CASE WHEN converted = 1 THEN user_count END) /
        NULLIF(MAX(CASE WHEN converted = 1 THEN user_count END) +
               MAX(CASE WHEN converted = 0 THEN user_count END), 0) * 100,
        1
    ) AS conversion_rate_pct
FROM feature_by_conversion
GROUP BY feature_name
ORDER BY conversion_rate_pct DESC;


-- -------------------------------------------------------
-- Q4: Engagement intensity — power users vs. casual
-- -------------------------------------------------------

WITH user_engagement AS (
    SELECT
        fe.user_id,
        COUNT(*) AS total_events,
        COUNT(DISTINCT fe.feature_name) AS unique_features,
        DATEDIFF(MAX(fe.event_date), MIN(fe.event_date)) AS active_span_days,
        s.churn_flag,
        s.plan_tier
    FROM funnel_events fe
    JOIN subscriptions s ON fe.user_id = s.user_id
    GROUP BY fe.user_id, s.churn_flag, s.plan_tier
)
SELECT
    CASE
        WHEN unique_features >= 4 AND total_events >= 50 THEN 'Power User'
        WHEN unique_features >= 2 AND total_events >= 20 THEN 'Active'
        ELSE 'Casual'
    END AS user_segment,
    COUNT(*) AS user_count,
    ROUND(AVG(churn_flag) * 100, 1) AS churn_rate_pct,
    ROUND(AVG(total_events), 0) AS avg_events,
    ROUND(AVG(active_span_days), 0) AS avg_active_days
FROM user_engagement
GROUP BY user_segment
ORDER BY churn_rate_pct;
