-- ============================================================
-- FEATURE ENGAGEMENT vs. CHURN
-- RavenStack SaaS Dataset
-- ============================================================

-- 1. Feature usage comparison: churned vs active accounts
SELECT
    a.churn_flag,
    COUNT(DISTINCT a.account_id) AS account_count,
    ROUND(AVG(u.usage_count), 1) AS avg_usage_count,
    ROUND(AVG(u.usage_duration_secs / 60.0), 1) AS avg_duration_min,
    ROUND(AVG(u.error_count), 2) AS avg_errors,
    COUNT(DISTINCT u.feature_name) AS features_touched
FROM accounts a
JOIN subscriptions s ON a.account_id = s.account_id
JOIN feature_usage u ON s.subscription_id = u.subscription_id
GROUP BY a.churn_flag;


-- 2. Top features used by active vs churned (find "sticky" features)
SELECT
    u.feature_name,
    u.is_beta_feature,
    SUM(CASE WHEN a.churn_flag = FALSE THEN u.usage_count ELSE 0 END) AS active_usage,
    SUM(CASE WHEN a.churn_flag = TRUE THEN u.usage_count ELSE 0 END) AS churned_usage,
    ROUND(
        SUM(CASE WHEN a.churn_flag = FALSE THEN u.usage_count ELSE 0 END) /
        NULLIF(SUM(CASE WHEN a.churn_flag = TRUE THEN u.usage_count ELSE 0 END), 0),
    2) AS active_to_churn_ratio
FROM feature_usage u
JOIN subscriptions s ON u.subscription_id = s.subscription_id
JOIN accounts a ON s.account_id = a.account_id
GROUP BY u.feature_name, u.is_beta_feature
ORDER BY active_to_churn_ratio DESC
LIMIT 20;


-- 3. Error-prone features and their impact on churn
SELECT
    u.feature_name,
    COUNT(*) AS total_events,
    SUM(CASE WHEN u.error_count > 0 THEN 1 ELSE 0 END) AS error_events,
    ROUND(SUM(CASE WHEN u.error_count > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS error_rate_pct,
    ROUND(AVG(CASE WHEN u.error_count > 0 THEN 1.0 ELSE 0 END), 3) AS error_pct,
    COUNT(DISTINCT CASE WHEN a.churn_flag = TRUE THEN a.account_id END) AS churned_users_ct
FROM feature_usage u
JOIN subscriptions s ON u.subscription_id = s.subscription_id
JOIN accounts a ON s.account_id = a.account_id
GROUP BY u.feature_name
HAVING error_rate_pct > 30
ORDER BY error_rate_pct DESC;


-- 4. Beta feature adoption and its relationship to retention
SELECT
    u.is_beta_feature,
    COUNT(DISTINCT a.account_id) AS accounts,
    ROUND(AVG(u.usage_count), 1) AS avg_usage,
    ROUND(AVG(u.usage_duration_secs / 60.0), 1) AS avg_duration_min,
    ROUND(SUM(CASE WHEN a.churn_flag = TRUE THEN 1 ELSE 0 END) /
          COUNT(DISTINCT a.account_id) * 100, 1) AS churn_rate_pct
FROM feature_usage u
JOIN subscriptions s ON u.subscription_id = s.subscription_id
JOIN accounts a ON s.account_id = a.account_id
GROUP BY u.is_beta_feature;
