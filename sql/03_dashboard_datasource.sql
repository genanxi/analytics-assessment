-- Account Health Dashboard Data Source
-- Grain: one row per account
-- Purpose: combine customer profile, subscription value, product usage, support experience, and churn history into an account-level health score system.

WITH subscription_summary AS (
    SELECT
        account_id,
        COUNT(*) AS total_subscriptions,
        SUM(CASE WHEN end_date IS NULL THEN 1 ELSE 0 END) AS active_subscriptions,
        SUM(CASE WHEN churn_flag THEN 1 ELSE 0 END) AS churned_subscriptions,
        SUM(CASE WHEN end_date IS NULL THEN arr_amount ELSE 0 END) AS active_arr_amount,
        SUM(CASE WHEN end_date IS NULL THEN mrr_amount ELSE 0 END) AS active_mrr_amount
    FROM subscriptions
    GROUP BY 1
),

usage_summary AS (
    SELECT
        s.account_id,
        COUNT(DISTINCT fu.feature_name) AS features_adopted,
        SUM(fu.usage_count) AS total_usage_count,
        SUM(fu.usage_duration_secs) AS total_usage_duration_secs,
        SUM(fu.error_count) AS total_error_count,
        SUM(fu.error_count) * 1.0 / NULLIF(SUM(fu.usage_count), 0) AS error_rate,
        SUM(CASE WHEN fu.is_beta_feature THEN 1 ELSE 0 END) AS beta_feature_usage_events
    FROM feature_usage fu
    JOIN subscriptions s
        ON fu.subscription_id = s.subscription_id
    GROUP BY 1
),

support_summary AS (
    SELECT
        account_id,
        COUNT(*) AS ticket_count,
        SUM(CASE WHEN escalation_flag THEN 1 ELSE 0 END) AS escalated_ticket_count,
        AVG(resolution_time_hours) AS avg_resolution_time_hours,
        AVG(first_response_time_minutes) AS avg_first_response_minutes,
        AVG(satisfaction_score) AS avg_satisfaction_score,
        AVG(CASE WHEN escalation_flag THEN 1 ELSE 0 END) AS escalation_rate
    FROM support_tickets
    GROUP BY 1
),

churn_event_summary AS (
    SELECT
        account_id,
        COUNT(*) AS churn_event_count,
        MAX(churn_date) AS latest_churn_date,
        SUM(refund_amount_usd) AS total_refund_amount,
        SUM(CASE WHEN is_reactivation THEN 1 ELSE 0 END) AS reactivation_count,
        SUM(CASE WHEN preceding_upgrade_flag THEN 1 ELSE 0 END) AS preceding_upgrade_count,
        SUM(CASE WHEN preceding_downgrade_flag THEN 1 ELSE 0 END) AS preceding_downgrade_count
    FROM churn_events
    GROUP BY 1
),

base AS (
    SELECT
        a.account_id,
        a.account_name,
        a.industry,
        a.country,
        a.signup_date,
        a.referral_source,
        a.plan_tier AS account_plan_tier,
        a.seats,
        a.is_trial,
        a.churn_flag AS account_churn_flag,

        COALESCE(ss.total_subscriptions, 0) AS total_subscriptions,
        COALESCE(ss.active_subscriptions, 0) AS active_subscriptions,
        COALESCE(ss.churned_subscriptions, 0) AS churned_subscriptions,
        COALESCE(ss.active_arr_amount, 0) AS active_arr_amount,
        COALESCE(ss.active_mrr_amount, 0) AS active_mrr_amount,

        COALESCE(us.features_adopted, 0) AS features_adopted,
        COALESCE(us.total_usage_count, 0) AS total_usage_count,
        COALESCE(us.total_usage_duration_secs, 0) AS total_usage_duration_secs,
        COALESCE(us.total_error_count, 0) AS total_error_count,
        COALESCE(us.error_rate, 0) AS error_rate,
        COALESCE(us.beta_feature_usage_events, 0) AS beta_feature_usage_events,

        COALESCE(sp.ticket_count, 0) AS ticket_count,
        COALESCE(sp.escalated_ticket_count, 0) AS escalated_ticket_count,
        COALESCE(sp.avg_resolution_time_hours, 0) AS avg_resolution_time_hours,
        COALESCE(sp.avg_first_response_minutes, 0) AS avg_first_response_minutes,
        COALESCE(sp.avg_satisfaction_score, 0) AS avg_satisfaction_score,
        COALESCE(sp.escalation_rate, 0) AS escalation_rate,

        COALESCE(ce.churn_event_count, 0) AS churn_event_count,
        ce.latest_churn_date,
        COALESCE(ce.total_refund_amount, 0) AS total_refund_amount,
        COALESCE(ce.reactivation_count, 0) AS reactivation_count,
        COALESCE(ce.preceding_upgrade_count, 0) AS preceding_upgrade_count,
        COALESCE(ce.preceding_downgrade_count, 0) AS preceding_downgrade_count

    FROM accounts a
    LEFT JOIN subscription_summary ss
        ON a.account_id = ss.account_id
    LEFT JOIN usage_summary us
        ON a.account_id = us.account_id
    LEFT JOIN support_summary sp
        ON a.account_id = sp.account_id
    LEFT JOIN churn_event_summary ce
        ON a.account_id = ce.account_id
),

scored AS ( --totally made up this part :)
    SELECT
        *,

        100
        - CASE WHEN features_adopted < 20 THEN 15 ELSE 0 END
        - CASE WHEN error_rate > 0.08 THEN 15 ELSE 0 END
        - CASE WHEN escalation_rate > 0.25 THEN 15 ELSE 0 END
        - CASE WHEN avg_satisfaction_score > 0 AND avg_satisfaction_score < 3.5 THEN 15 ELSE 0 END
        - CASE WHEN account_churn_flag THEN 25 ELSE 0 END
        - CASE WHEN active_arr_amount >= 50000 AND account_churn_flag THEN 10 ELSE 0 END
        AS health_score

    FROM base
)

SELECT -- just some wild assumptions :)
    *,

    CASE
        WHEN health_score >= 80 THEN 'Healthy'
        WHEN health_score >= 60 THEN 'Watchlist'
        WHEN health_score >= 40 THEN 'At Risk'
        ELSE 'Critical'
    END AS health_segment,

    CONCAT(
        CASE WHEN features_adopted < 20 THEN 'Low adoption; ' ELSE '' END,
        CASE WHEN error_rate > 0.08 THEN 'High error rate; ' ELSE '' END,
        CASE WHEN escalation_rate > 0.25 THEN 'High escalation rate; ' ELSE '' END,
        CASE WHEN avg_satisfaction_score > 0 AND avg_satisfaction_score < 3.5 THEN 'Low satisfaction; ' ELSE '' END,
        CASE WHEN account_churn_flag THEN 'Account churn flag; ' ELSE '' END,
        CASE WHEN active_arr_amount >= 50000 AND account_churn_flag THEN 'High ARR churn risk; ' ELSE '' END
    ) AS top_risk_drivers

FROM scored;