-- ============================================================
-- 04_revenue_segmentation.sql
-- SaaS Product Engagement & Conversion Analysis
-- Purpose: Revenue analysis by segment, MRR trends, LTV
-- ============================================================


-- -------------------------------------------------------
-- Q1: Revenue breakdown by plan tier
-- -------------------------------------------------------

SELECT
    plan_tier,
    COUNT(DISTINCT user_id) AS subscribers,
    ROUND(SUM(monthly_revenue), 2) AS total_mrr,
    ROUND(AVG(monthly_revenue), 2) AS arpu,
    ROUND(MIN(monthly_revenue), 2) AS min_revenue,
    ROUND(MAX(monthly_revenue), 2) AS max_revenue,
    ROUND(AVG(CASE WHEN churn_flag = 1 THEN 1.0 ELSE 0 END) * 100, 1) AS churn_rate_pct
FROM subscriptions
GROUP BY plan_tier
ORDER BY total_mrr DESC;


-- -------------------------------------------------------
-- Q2: Monthly MRR trend
-- -------------------------------------------------------

SELECT
    DATE_FORMAT(signup_date, '%Y-%m') AS month,
    COUNT(DISTINCT user_id) AS active_subscribers,
    ROUND(SUM(monthly_revenue), 2) AS mrr,
    ROUND(SUM(monthly_revenue) - LAG(SUM(monthly_revenue)) OVER (
        ORDER BY DATE_FORMAT(signup_date, '%Y-%m')
    ), 2) AS mrr_change,
    COUNT(DISTINCT CASE WHEN churn_flag = 1 THEN user_id END) AS churned_users
FROM subscriptions
GROUP BY DATE_FORMAT(signup_date, '%Y-%m')
ORDER BY month;


-- -------------------------------------------------------
-- Q3: Estimated Customer Lifetime Value (CLV) by tier
-- -------------------------------------------------------

SELECT
    plan_tier,
    ROUND(AVG(monthly_revenue), 2) AS avg_monthly_revenue,
    ROUND(AVG(
        TIMESTAMPDIFF(MONTH, signup_date,
            COALESCE(churn_date, CURDATE()))
    ), 1) AS avg_lifetime_months,
    ROUND(
        AVG(monthly_revenue) * AVG(
            TIMESTAMPDIFF(MONTH, signup_date,
                COALESCE(churn_date, CURDATE()))
        ), 2
    ) AS estimated_clv
FROM subscriptions
GROUP BY plan_tier
ORDER BY estimated_clv DESC;


-- -------------------------------------------------------
-- Q4: Revenue at risk — high-value users showing churn signals
-- -------------------------------------------------------

WITH user_engagement AS (
    SELECT
        user_id,
        COUNT(*) AS total_events,
        MAX(event_date) AS last_event,
        DATEDIFF(CURDATE(), MAX(event_date)) AS days_since_last_event
    FROM funnel_events
    GROUP BY user_id
)
SELECT
    s.user_id,
    s.plan_tier,
    s.monthly_revenue,
    ue.total_events,
    ue.days_since_last_event,
    DENSE_RANK() OVER (ORDER BY s.monthly_revenue DESC) AS revenue_rank,
    CASE
        WHEN ue.days_since_last_event > 30 THEN 'High Risk'
        WHEN ue.days_since_last_event > 14 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS churn_risk
FROM subscriptions s
JOIN user_engagement ue ON s.user_id = ue.user_id
WHERE s.churn_flag = 0
ORDER BY s.monthly_revenue DESC
LIMIT 50;
