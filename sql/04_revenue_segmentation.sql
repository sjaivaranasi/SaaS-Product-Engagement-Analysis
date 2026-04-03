-- ============================================================
-- REVENUE SEGMENTATION & MRR ANALYSIS
-- RavenStack SaaS Dataset
-- ============================================================

-- 1. MRR breakdown by plan tier
SELECT
    plan_tier,
    COUNT(*) AS subscriptions,
    SUM(CASE WHEN churn_flag = FALSE THEN 1 ELSE 0 END) AS active_subs,
    ROUND(SUM(mrr_amount), 0) AS total_mrr,
    ROUND(AVG(mrr_amount), 0) AS arpu,
    ROUND(SUM(CASE WHEN churn_flag = TRUE THEN mrr_amount ELSE 0 END), 0) AS lost_mrr,
    ROUND(SUM(CASE WHEN churn_flag = TRUE THEN mrr_amount ELSE 0 END) /
          NULLIF(SUM(mrr_amount), 0) * 100, 1) AS mrr_churn_pct
FROM subscriptions
GROUP BY plan_tier
ORDER BY total_mrr DESC;


-- 2. Revenue by referral source (CAC efficiency signal)
SELECT
    a.referral_source,
    COUNT(DISTINCT a.account_id) AS accounts,
    ROUND(SUM(s.mrr_amount), 0) AS total_mrr,
    ROUND(AVG(s.mrr_amount), 0) AS avg_mrr,
    ROUND(SUM(CASE WHEN a.churn_flag = TRUE THEN s.mrr_amount ELSE 0 END) /
          NULLIF(SUM(s.mrr_amount), 0) * 100, 1) AS revenue_churn_pct
FROM accounts a
JOIN subscriptions s ON a.account_id = s.account_id
GROUP BY a.referral_source
ORDER BY total_mrr DESC;


-- 3. Customer value segmentation (RFM-style)
SELECT
    a.account_id,
    a.account_name,
    a.industry,
    a.plan_tier,
    SUM(s.mrr_amount) AS total_mrr,
    COUNT(s.subscription_id) AS sub_count,
    ROUND(AVG(CASE WHEN s.end_date IS NOT NULL
        THEN DATEDIFF(s.end_date, s.start_date)
        ELSE DATEDIFF('2025-01-01', s.start_date) END), 0) AS avg_tenure_days,
    NTILE(4) OVER (ORDER BY SUM(s.mrr_amount) DESC) AS revenue_quartile,
    CASE
        WHEN NTILE(4) OVER (ORDER BY SUM(s.mrr_amount) DESC) = 1 AND a.churn_flag = FALSE THEN 'Champion'
        WHEN NTILE(4) OVER (ORDER BY SUM(s.mrr_amount) DESC) <= 2 AND a.churn_flag = FALSE THEN 'High Value'
        WHEN a.churn_flag = TRUE THEN 'Lost'
        ELSE 'Growth Potential'
    END AS customer_segment
FROM accounts a
JOIN subscriptions s ON a.account_id = s.account_id
GROUP BY a.account_id, a.account_name, a.industry, a.plan_tier, a.churn_flag
ORDER BY total_mrr DESC
LIMIT 50;


-- 4. Monthly MRR trend with cumulative
SELECT
    DATE_FORMAT(s.start_date, '%Y-%m') AS month,
    COUNT(*) AS new_subscriptions,
    ROUND(SUM(s.mrr_amount), 0) AS new_mrr,
    SUM(ROUND(SUM(s.mrr_amount), 0)) OVER (ORDER BY DATE_FORMAT(s.start_date, '%Y-%m')) AS cumulative_mrr
FROM subscriptions s
GROUP BY DATE_FORMAT(s.start_date, '%Y-%m')
ORDER BY month;


-- 5. Churn revenue impact by reason
SELECT
    c.reason_code,
    COUNT(*) AS churn_events,
    ROUND(AVG(c.refund_amount_usd), 2) AS avg_refund,
    ROUND(SUM(c.refund_amount_usd), 2) AS total_refunds,
    SUM(c.preceding_upgrade_flag) AS had_recent_upgrade,
    SUM(c.preceding_downgrade_flag) AS had_recent_downgrade
FROM churn_events c
GROUP BY c.reason_code
ORDER BY churn_events DESC;
