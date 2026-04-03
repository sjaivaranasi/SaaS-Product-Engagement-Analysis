-- ============================================================
-- COHORT RETENTION: Monthly signup cohorts tracked over time
-- ============================================================
-- Update table/column names to match your MySQL schema.

-- Step 1: Assign each user to their signup cohort month
WITH user_cohorts AS (
    SELECT
        customer_id,                                    -- update
        DATE_FORMAT(signup_date, '%Y-%m') AS cohort,    -- update date column
        signup_date                                     -- update
    FROM subscriptions                                  -- update table
),

-- Step 2: Calculate months since signup for each activity
user_activity AS (
    SELECT
        uc.customer_id,
        uc.cohort,
        TIMESTAMPDIFF(MONTH, uc.signup_date, f.event_date) AS months_since_signup  -- update
    FROM user_cohorts uc
    JOIN user_funnels f ON uc.customer_id = f.user_id    -- update join
    WHERE f.event_date >= uc.signup_date                  -- update
),

-- Step 3: Count distinct users per cohort per month
cohort_sizes AS (
    SELECT cohort, COUNT(DISTINCT customer_id) AS cohort_size
    FROM user_cohorts
    GROUP BY cohort
)

SELECT
    ua.cohort,
    cs.cohort_size,
    ua.months_since_signup,
    COUNT(DISTINCT ua.customer_id) AS active_users,
    ROUND(COUNT(DISTINCT ua.customer_id) / cs.cohort_size * 100, 1) AS retention_pct
FROM user_activity ua
JOIN cohort_sizes cs ON ua.cohort = cs.cohort
WHERE ua.months_since_signup BETWEEN 0 AND 12
GROUP BY ua.cohort, cs.cohort_size, ua.months_since_signup
ORDER BY ua.cohort, ua.months_since_signup;
