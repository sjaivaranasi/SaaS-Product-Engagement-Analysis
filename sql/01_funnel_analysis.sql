-- ============================================================
-- FUNNEL ANALYSIS: Plan Tier Conversion & Upgrade Paths
-- RavenStack SaaS Dataset
-- ============================================================

-- 1. Account conversion funnel: Trial → Active → Upgraded
SELECT
    'Total Accounts' AS stage,
    COUNT(*) AS accounts
FROM accounts

UNION ALL

SELECT 'Started Trial', COUNT(*)
FROM accounts WHERE is_trial = TRUE

UNION ALL

SELECT 'Active (Not Churned)', COUNT(*)
FROM accounts WHERE churn_flag = FALSE

UNION ALL

SELECT 'Has Upgrade', COUNT(DISTINCT a.account_id)
FROM accounts a
JOIN subscriptions s ON a.account_id = s.account_id
WHERE s.upgrade_flag = TRUE

UNION ALL

SELECT 'Enterprise Tier', COUNT(*)
FROM accounts WHERE plan_tier = 'Enterprise' AND churn_flag = FALSE;


-- 2. Plan tier migration: what do upgraders move FROM and TO?
WITH plan_changes AS (
    SELECT
        s1.account_id,
        s1.plan_tier AS from_plan,
        s2.plan_tier AS to_plan,
        s1.start_date AS from_date,
        s2.start_date AS to_date
    FROM subscriptions s1
    JOIN subscriptions s2
        ON s1.account_id = s2.account_id
        AND s2.start_date > s1.start_date
    WHERE s1.plan_tier != s2.plan_tier
)
SELECT
    from_plan,
    to_plan,
    COUNT(*) AS transitions,
    ROUND(AVG(DATEDIFF(to_date, from_date)), 0) AS avg_days_between
FROM plan_changes
GROUP BY from_plan, to_plan
ORDER BY transitions DESC;


-- 3. Conversion rate by referral source
SELECT
    a.referral_source,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN a.churn_flag = FALSE THEN 1 ELSE 0 END) AS active_accounts,
    ROUND(SUM(CASE WHEN a.churn_flag = FALSE THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS retention_pct,
    ROUND(AVG(s.mrr_amount), 2) AS avg_mrr
FROM accounts a
JOIN subscriptions s ON a.account_id = s.account_id
GROUP BY a.referral_source
ORDER BY retention_pct DESC;
