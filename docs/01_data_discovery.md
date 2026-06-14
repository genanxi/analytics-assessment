# Data Discovery

## Objective

Before defining business questions, I first review the available datasets to understand their structure, identify potentially valuable attributes, validate key fields, and determine what analyses are realistically possible.

## Understand Available Data

The dataset consists of five tables:

- Accounts
- Subscriptions
- Feature Usage
- Support Tickets
- Churn Events

The first objective is to understand:

- Table grain
- Relationships between tables
- Available attributes
- Potential business outcomes
- Potential explanatory variables

### Data Model

Accounts
├── Subscriptions
│   └── Feature Usage
├── Support Tickets
└── Churn Events

### Accounts Table:
- Primary customer dimension table
- Volume: 500 accounts (500 distinct account IDs)
- Grain: One row per account
- Primary Key: account_id
- Signup date range: 2023-01-02 to 2024-12-31
- Key analytical value: Customer segmentation, retention
- Potential data considerations: Table appears to reflect the current state of each account; no account history is captured.

### Subscriptions Table
- Contains subscription lifecycle and revenue information
- Volume: 5,000 subscriptions
- Grain: One row per subscription
- Primary Key: subscription_id
- Subscription start date range: 2023-01-09 to 2024-12-31
- Foreign Key: account_id
- Key analytical value: Revenue (ARR/MRR), Retention
- Potential data considerations: 
    - One account may have multiple active subscriptions (`end_date IS NULL`) across different plan tiers, which does not always align with the account-level `plan_tier`. For example, account `A-139c3b` has active Basic, Pro, and Enterprise subscriptions and is classified as Enterprise in the Accounts table, while account `A-118f1c` also has active subscriptions across all three tiers but is classified as Pro. Additional business logic would be required to determine how the account-level plan tier is derived from subscription history.
    - Account-level churn status does not fully align with subscription status. All 110 accounts marked as churned in the Accounts table still contain subscriptions with `end_date IS NULL`, suggesting account churn and subscription activity are defined independently. Additional business logic would be required before using these fields for churn, retention, or revenue impact analysis.
  
### Feature Usage Table
- Contains product usage and adoption data
- Volume: 25,000 usage records
- Grain: One row per feature usage event
- Primary Key: `usage_id`
- Foreign Key: `subscription_id`
- Usage date range: 2023-01-01 to 2024-12-31
- Key analytical value: Feature adoption, Error Rate
- Potential data considerations:
    - Usage data is captured at the subscription level and requires aggregation for account-level analysis.
    - Usage coverage exists for 99%+ of subscriptions, suggesting adoption metrics are broadly representative.

### Support Tickets Table:

- Contains customer support interaction data
- Volume: 2,000 support tickets
- Grain: One row per support ticket
- Primary Key: `ticket_id`
- Foreign Key: `account_id`
- Ticket date range: 2023-01-01 to 2024-12-31
- Key analytical value: Customer satisfaction, Resolution time, Escalation rate
- Potential data considerations:
    - `satisfaction_score` is missing for 825 tickets (41.3% of all tickets).

### Churn Events Table

- Contains churn event details and churn reasons
- Volume: 600 churn events
- Grain: One row per churn event
- Primary Key: `churn_event_id`
- Foreign Key: `account_id`
- Churn date range: 2023-01-25 to 2024-12-31
- Key analytical value: Churn reason, refund
- Potential data considerations:
    - Multiple churn events may exist for a single account.
    - `feedback_text` is missing for 148 churn events (24.7%), limiting qualitative churn analysis.
    - `reason_code` and `feedback_text` may not always align, so churn reason analysis should rely primarily on structured `reason_code` and use `feedback_text` only as supporting context.

## Discovery Summary

Key observations from the discovery process:

- Accounts table appears to represent the current state of each customer.
- Account-level churn and subscription-level status are not fully aligned and require additional business logic before analysis.
- Account-level plan tiers do not consistently align with active subscription tiers.
- Feature usage coverage is high (99%+ of subscriptions), making adoption metrics suitable for analysis.
- Support ticket satisfaction scores have significant missingness (41.3%).
- Churn history is tracked at the event level and supports churn reason analysis.

Now, let's move to the business questions and assumptions. 