-- =====================================================
-- Account Table
-- =====================================================
-- Check for duplicate account IDs.
SELECT
    COUNT(*) total_rows,
    COUNT(DISTINCT account_id) distinct_accounts
FROM accounts;

-- =====================================================
-- Subscription Table
-- =====================================================

-- Validate whether account-level plan_tier aligns with the highest active subscription tier.
-- Assumption: Basic < Pro < Enterprise.
-- Active subscription is defined as end_date IS NULL.

WITH active_subscription_tiers AS (
    SELECT
        account_id,
        MAX(
            CASE
                WHEN plan_tier = 'Basic' THEN 1
                WHEN plan_tier = 'Pro' THEN 2
                WHEN plan_tier = 'Enterprise' THEN 3
            END
        ) AS highest_active_tier_rank
    FROM subscriptions
    WHERE end_date IS NULL
    GROUP BY 1
),

tier_comparison AS (
    SELECT
        a.account_id,
        a.plan_tier AS account_plan_tier,
        CASE
            WHEN a.plan_tier = 'Basic' THEN 1
            WHEN a.plan_tier = 'Pro' THEN 2
            WHEN a.plan_tier = 'Enterprise' THEN 3
        END AS account_tier_rank,
        s.highest_active_tier_rank
    FROM accounts a
    LEFT JOIN active_subscription_tiers s
        ON a.account_id = s.account_id
)

SELECT
    COUNT(*) AS misaligned_accounts
FROM tier_comparison
WHERE account_tier_rank <> highest_active_tier_rank;

-- Account-level plan tier does not consistently align with the highest active subscription tier. 
-- 343 of 500 accounts (68.6%) have an account-level tier that differs from the highest active subscription tier. 

======================================================

-- Check whether churned accounts still contain subscriptions with NULL end dates.

SELECT
    COUNT(DISTINCT a.account_id) AS churned_accounts_with_active_subscriptions
FROM accounts a
JOIN subscriptions s
    ON a.account_id = s.account_id
WHERE a.churn_flag = TRUE
  AND s.end_date IS NULL;
-- 110 accounts marked as churned in the Accounts table still contain at least one subscription with a NULL end date.
 
-- =====================================================
-- Feature Usage Table
-- =====================================================

-- Determine how much of the subscription base is represented in usage data

SELECT
    COUNT(DISTINCT fu.subscription_id) AS subscriptions_with_usage,
    COUNT(DISTINCT s.subscription_id) AS total_subscriptions,
    ROUND(
        COUNT(DISTINCT fu.subscription_id) * 100.0
        / COUNT(DISTINCT s.subscription_id),
        2
    ) AS pct_subscriptions_with_usage
FROM subscriptions s
LEFT JOIN feature_usage fu
    ON s.subscription_id = fu.subscription_id;

-- =====================================================
-- Support Tickets Table
-- =====================================================
-- Check completeness of satisfaction scores.

SELECT
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN satisfaction_score IS NULL THEN 1 ELSE 0 END) AS missing_satisfaction_score,
    ROUND(
        100.0 * SUM(CASE WHEN satisfaction_score IS NULL THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS pct_missing
FROM support_tickets;

-- 825 of 2,000 tickets (41.3%) are missing satisfaction scores.

-- =====================================================
-- Churn Events Table
-- =====================================================
-- Check completeness of satisfaction scores.

SELECT
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN satisfaction_score IS NULL THEN 1 ELSE 0 END) AS missing_satisfaction_score,
    ROUND(
        100.0 * SUM(CASE WHEN satisfaction_score IS NULL THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS pct_missing
FROM support_tickets;

-- 825 of 2,000 tickets (41.3%) are missing satisfaction scores.
======================================================

-- Review potential mismatches between feedback_text and reason_code

SELECT
    churn_event_id,
    account_id,
    reason_code,
    feedback_text
FROM churn_events
WHERE feedback_text IS NOT NULL
    AND (
        (LOWER(feedback_text) LIKE '%competitor%' AND reason_code <> 'competitor')
        OR
        (LOWER(feedback_text) LIKE '%price%' AND reason_code <> 'pricing')
        OR
        (LOWER(feedback_text) LIKE '%cost%' AND reason_code <> 'pricing')
        OR
        (LOWER(feedback_text) LIKE '%support%' AND reason_code <> 'support')
        OR
        (LOWER(feedback_text) LIKE '%feature%' AND reason_code <> 'features')
    );
    --Only 42% of feedback comments aligned with the structured reason code, suggesting free-text feedback should be used as supporting context rather than a primary churn classification source.