======================================================
-- Hypothesis 1:
-- Customers with lower feature adoption are more likely to churn.

WITH account_adoption AS (
    SELECT
        s.account_id,
        COUNT(DISTINCT fu.feature_name) AS features_adopted
    FROM feature_usage fu
    JOIN subscriptions s
        ON fu.subscription_id = s.subscription_id
    GROUP BY 1
)

SELECT
    a.churn_flag,
    AVG(features_adopted) AS avg_features_adopted
FROM accounts a
LEFT JOIN account_adoption aa
    ON a.account_id = aa.account_id
GROUP BY 1;

======================================================

-- Hypothesis 2:
-- Customers experiencing more product errors are more likely to churn.

WITH account_errors AS (
    SELECT
        s.account_id,
        SUM(error_count) * 1.0 /
        NULLIF(SUM(usage_count), 0) AS error_rate
    FROM feature_usage fu
    JOIN subscriptions s
        ON fu.subscription_id = s.subscription_id
    GROUP BY 1
)

SELECT
    a.churn_flag,
    AVG(error_rate) AS avg_error_rate
FROM accounts a
LEFT JOIN account_errors ae
    ON a.account_id = ae.account_id
GROUP BY 1;

======================================================

-- Hypothesis 3:
-- Customers with poorer support experiences are more likely to churn.

WITH account_satisfaction AS (
    SELECT
        account_id,
        AVG(satisfaction_score) AS avg_satisfaction_score
    FROM support_tickets
    WHERE satisfaction_score IS NOT NULL
    GROUP BY 1
)

SELECT
    a.churn_flag,
    AVG(avg_satisfaction_score) AS avg_satisfaction_score
FROM accounts a
LEFT JOIN account_satisfaction s
    ON a.account_id = s.account_id
GROUP BY 1;
======================================================