-- ============================================================
-- FUNNEL ANALYSIS: Signup → Activation → Engagement → Conversion
-- ============================================================
-- Update table/column names to match your MySQL schema after import.

-- Overall funnel stage counts and drop-off rates
WITH funnel_stages AS (
    SELECT
        funnel_stage,
        COUNT(DISTINCT user_id) AS users_at_stage
    FROM user_funnels  -- update table name
    GROUP BY funnel_stage
),
ordered_stages AS (
    SELECT
        funnel_stage,
        users_at_stage,
        FIRST_VALUE(users_at_stage) OVER (ORDER BY users_at_stage DESC) AS top_of_funnel,
        LAG(users_at_stage) OVER (ORDER BY users_at_stage DESC) AS prev_stage_users
    FROM funnel_stages
)
SELECT
    funnel_stage,
    users_at_stage,
    ROUND(users_at_stage / top_of_funnel * 100, 1) AS pct_of_top_funnel,
    ROUND((users_at_stage - COALESCE(prev_stage_users, users_at_stage)) 
          / COALESCE(prev_stage_users, users_at_stage) * 100, 1) AS stage_dropoff_pct
FROM ordered_stages
ORDER BY users_at_stage DESC;


-- Funnel conversion by plan tier
SELECT
    s.subscription_type,       -- update column name
    f.funnel_stage,            -- update column name
    COUNT(DISTINCT f.user_id) AS user_count
FROM user_funnels f            -- update table name
JOIN subscriptions s           -- update table name
    ON f.user_id = s.customer_id  -- update join key
GROUP BY s.subscription_type, f.funnel_stage
ORDER BY s.subscription_type, user_count DESC;
