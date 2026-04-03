-- ============================================================
-- REVENUE SEGMENTATION & MRR ANALYSIS
-- ============================================================
-- Update table/column names to match your MySQL schema.

-- MRR by plan tier
SELECT
    subscription_type,                      -- update
    COUNT(*) AS subscribers,
    ROUND(SUM(monthly_revenue), 2) AS total_mrr,           -- update
    ROUND(AVG(monthly_revenue), 2) AS arpu,                -- update
    ROUND(SUM(CASE WHEN is_churned = 1 THEN monthly_revenue ELSE 0 END), 2) AS churned_mrr,
    ROUND(
        SUM(CASE WHEN is_churned = 1 THEN monthly_revenue ELSE 0 END) /
        NULLIF(SUM(monthly_revenue), 0) * 100,
    1) AS mrr_churn_pct
FROM subscriptions                          -- update table
GROUP BY subscription_type
ORDER BY total_mrr DESC;


-- Customer value segmentation (RFM-style)
SELECT
    customer_id,
    subscription_type,
    monthly_revenue,
    tenure_days,
    NTILE(4) OVER (ORDER BY monthly_revenue DESC) AS revenue_quartile,
    NTILE(4) OVER (ORDER BY tenure_days DESC) AS tenure_quartile,
    CASE
        WHEN NTILE(4) OVER (ORDER BY monthly_revenue DESC) = 1
         AND NTILE(4) OVER (ORDER BY tenure_days DESC) = 1 THEN 'Champion'
        WHEN NTILE(4) OVER (ORDER BY monthly_revenue DESC) <= 2 THEN 'High Value'
        WHEN NTILE(4) OVER (ORDER BY tenure_days DESC) >= 3 THEN 'At Risk'
        ELSE 'Growth Potential'
    END AS customer_segment
FROM subscriptions
WHERE is_churned = 0
ORDER BY monthly_revenue DESC;


-- Monthly MRR trend
SELECT
    DATE_FORMAT(signup_date, '%Y-%m') AS month,   -- update
    COUNT(*) AS new_subscribers,
    ROUND(SUM(monthly_revenue), 2) AS new_mrr,
    SUM(SUM(monthly_revenue)) OVER (ORDER BY DATE_FORMAT(signup_date, '%Y-%m')) AS cumulative_mrr
FROM subscriptions
GROUP BY DATE_FORMAT(signup_date, '%Y-%m')
ORDER BY month;
