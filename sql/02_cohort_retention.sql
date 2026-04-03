-- ============================================================
-- COHORT RETENTION: Monthly signup cohorts tracked over time
-- RavenStack SaaS Dataset
-- ============================================================

-- 1. Monthly signup cohort sizes
SELECT
    DATE_FORMAT(signup_date, '%Y-%m') AS cohort,
    COUNT(*) AS cohort_size,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS churn_pct
FROM accounts
GROUP BY DATE_FORMAT(signup_date, '%Y-%m')
ORDER BY cohort;


-- 2. Cohort retention by quarter (subscription activity)
WITH account_cohorts AS (
    SELECT
        account_id,
        DATE_FORMAT(signup_date, '%Y-%m') AS signup_cohort,
        signup_date
    FROM accounts
),
sub_activity AS (
    SELECT
        ac.account_id,
        ac.signup_cohort,
        TIMESTAMPDIFF(MONTH, ac.signup_date, s.start_date) AS months_since_signup
    FROM account_cohorts ac
    JOIN subscriptions s ON ac.account_id = s.account_id
    WHERE s.start_date >= ac.signup_date
),
cohort_sizes AS (
    SELECT signup_cohort, COUNT(DISTINCT account_id) AS cohort_size
    FROM account_cohorts
    GROUP BY signup_cohort
)
SELECT
    sa.signup_cohort,
    cs.cohort_size,
    sa.months_since_signup,
    COUNT(DISTINCT sa.account_id) AS active_accounts,
    ROUND(COUNT(DISTINCT sa.account_id) / cs.cohort_size * 100, 1) AS retention_pct
FROM sub_activity sa
JOIN cohort_sizes cs ON sa.signup_cohort = cs.signup_cohort
WHERE sa.months_since_signup BETWEEN 0 AND 12
GROUP BY sa.signup_cohort, cs.cohort_size, sa.months_since_signup
ORDER BY sa.signup_cohort, sa.months_since_signup;


-- 3. Churn timing: how many months after signup do accounts churn?
SELECT
    TIMESTAMPDIFF(MONTH, a.signup_date, c.churn_date) AS months_to_churn,
    COUNT(*) AS churn_count,
    ROUND(AVG(c.refund_amount_usd), 2) AS avg_refund
FROM accounts a
JOIN churn_events c ON a.account_id = c.account_id
GROUP BY TIMESTAMPDIFF(MONTH, a.signup_date, c.churn_date)
ORDER BY months_to_churn;
