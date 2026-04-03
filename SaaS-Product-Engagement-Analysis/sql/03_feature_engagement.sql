-- ============================================================
-- FEATURE ENGAGEMENT vs. CONVERSION
-- ============================================================
-- Which behaviors correlate with conversion vs. churn?
-- Update table/column names to match your MySQL schema.

-- Feature usage comparison: churned vs. active users
SELECT
    s.is_churned,                          -- update (0=active, 1=churned)
    COUNT(*) AS user_count,
    ROUND(AVG(s.logins_30d), 1) AS avg_logins,           -- update
    ROUND(AVG(s.features_used), 1) AS avg_features_used,  -- update
    ROUND(AVG(s.support_tickets), 1) AS avg_tickets,       -- update
    ROUND(AVG(s.tenure_days), 0) AS avg_tenure_days        -- update
FROM subscriptions s                        -- update table
GROUP BY s.is_churned;


-- Top features used by converted (active) users vs. churned
SELECT
    f.feature_name,                        -- update
    SUM(CASE WHEN s.is_churned = 0 THEN 1 ELSE 0 END) AS active_users,
    SUM(CASE WHEN s.is_churned = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(
        SUM(CASE WHEN s.is_churned = 0 THEN 1 ELSE 0 END) /
        NULLIF(SUM(CASE WHEN s.is_churned = 1 THEN 1 ELSE 0 END), 0),
    2) AS active_to_churn_ratio
FROM user_funnels f                        -- update table
JOIN subscriptions s ON f.user_id = s.customer_id  -- update join
GROUP BY f.feature_name
ORDER BY active_to_churn_ratio DESC;


-- Time-to-first-key-action by churn status
SELECT
    s.is_churned,
    ROUND(AVG(DATEDIFF(f.first_action_date, s.signup_date)), 1) AS avg_days_to_first_action,  -- update
    ROUND(MIN(DATEDIFF(f.first_action_date, s.signup_date)), 1) AS min_days,
    ROUND(MAX(DATEDIFF(f.first_action_date, s.signup_date)), 1) AS max_days
FROM subscriptions s
JOIN user_funnels f ON s.customer_id = f.user_id   -- update
WHERE f.first_action_date IS NOT NULL
GROUP BY s.is_churned;
