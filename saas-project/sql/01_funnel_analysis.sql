-- ============================================================
-- 01_funnel_analysis.sql
-- SaaS Product Engagement & Conversion Analysis
-- Purpose: Calculate conversion rates at each funnel stage
-- ============================================================

-- STEP 1: Load your cleaned CSVs into MySQL via DBeaver
-- (File > Import Data > select CSV > map columns)
-- Tables expected: subscriptions, funnel_events


-- -------------------------------------------------------
-- Q1: Overall funnel conversion rates (stage-over-stage)
-- -------------------------------------------------------
-- ADAPT column names to match your actual data

WITH funnel_counts AS (
    SELECT
        funnel_stage,
        COUNT(DISTINCT user_id) AS unique_users
    FROM funnel_events
    GROUP BY funnel_stage
),
ordered AS (
    SELECT
        funnel_stage,
        unique_users,
        LAG(unique_users) OVER (ORDER BY 
            CASE funnel_stage
                WHEN 'visit' THEN 1
                WHEN 'signup' THEN 2
                WHEN 'activation' THEN 3
                WHEN 'trial' THEN 4
                WHEN 'conversion' THEN 5
                WHEN 'retention' THEN 6
            END
        ) AS prev_stage_users
    FROM funnel_counts
)
SELECT
    funnel_stage,
    unique_users,
    prev_stage_users,
    ROUND(unique_users / prev_stage_users * 100, 2) AS stage_conversion_pct,
    ROUND(unique_users / FIRST_VALUE(unique_users) OVER (
        ORDER BY CASE funnel_stage
            WHEN 'visit' THEN 1
            WHEN 'signup' THEN 2
            WHEN 'activation' THEN 3
            WHEN 'trial' THEN 4
            WHEN 'conversion' THEN 5
            WHEN 'retention' THEN 6
        END
    ) * 100, 2) AS overall_conversion_pct
FROM ordered
ORDER BY CASE funnel_stage
    WHEN 'visit' THEN 1
    WHEN 'signup' THEN 2
    WHEN 'activation' THEN 3
    WHEN 'trial' THEN 4
    WHEN 'conversion' THEN 5
    WHEN 'retention' THEN 6
END;


-- -------------------------------------------------------
-- Q2: Funnel conversion by plan tier
-- -------------------------------------------------------

SELECT
    s.plan_tier,
    fe.funnel_stage,
    COUNT(DISTINCT fe.user_id) AS unique_users
FROM funnel_events fe
JOIN subscriptions s ON fe.user_id = s.user_id
GROUP BY s.plan_tier, fe.funnel_stage
ORDER BY s.plan_tier,
    CASE fe.funnel_stage
        WHEN 'visit' THEN 1
        WHEN 'signup' THEN 2
        WHEN 'activation' THEN 3
        WHEN 'trial' THEN 4
        WHEN 'conversion' THEN 5
        WHEN 'retention' THEN 6
    END;


-- -------------------------------------------------------
-- Q3: Time between funnel stages (velocity)
-- -------------------------------------------------------

WITH user_stages AS (
    SELECT
        user_id,
        funnel_stage,
        MIN(event_date) AS first_reached
    FROM funnel_events
    GROUP BY user_id, funnel_stage
),
stage_pairs AS (
    SELECT
        a.user_id,
        a.funnel_stage AS from_stage,
        b.funnel_stage AS to_stage,
        DATEDIFF(b.first_reached, a.first_reached) AS days_between
    FROM user_stages a
    JOIN user_stages b 
        ON a.user_id = b.user_id
        AND a.funnel_stage = 'signup'
        AND b.funnel_stage = 'conversion'
)
SELECT
    from_stage,
    to_stage,
    COUNT(*) AS users,
    ROUND(AVG(days_between), 1) AS avg_days,
    MIN(days_between) AS min_days,
    MAX(days_between) AS max_days,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY days_between), 1) AS median_days
FROM stage_pairs
GROUP BY from_stage, to_stage;
