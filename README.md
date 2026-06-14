# From Data to Decisions: Turning Data into Insights, Recommendations, and Business Action

## Introduction

For this exercise, I selected the RavenStack synthetic SaaS dataset because it contains customer account, subscription, product usage, support, and churn information, which closely resembles the types of datasets I work with regularly in product and business analytics.

In a typical analytics engagement, my process starts with business questions rather than data. I partner closely with stakeholders to understand business objectives, identify challenges or opportunities, generate hypotheses, prioritize questions based on impact, and then use data to validate assumptions, provide insights, and recommend actions. Depending on the outcome, I may also help operationalize the solution through reporting, dashboards, or monitoring frameworks.

This project is slightly different because I am working from a predefined dataset and do not have stakeholders available to provide business context. To simulate a real-world analytics workflow, I will generate my own hypotheses and business questions based on the available data and my experience working in SaaS product and customer analytics.

Before conducting any analysis, I typically spend time understanding the data itself. This includes reviewing available datasets, understanding table relationships and business definitions, evaluating data quality, and identifying any limitations or gaps that may impact confidence in the analysis. In a production environment, this stage often involves collaboration with engineering, product, and business teams to clarify definitions, validate assumptions, and request additional data when necessary. For the purposes of this exercise, I will document those considerations and proceed using the information available in the dataset.

## Project Approach

The project is organized into three primary phases:

### 1. Data Discovery

Review available datasets, understand table relationships, assess data quality, and identify limitations that may influence the analysis.

### 2. Business Questions & Analysis

Generate and prioritize business questions, develop hypotheses, and use SQL and Python to validate assumptions and uncover insights.

### 3. Findings & Recommendations

Summarize key findings, recommendations, limitations, and potential next steps based on the analysis.

## Repository Structure

```text
analytics-assessment/

README.md

data/
├── raw/
└── README.md

docs/
├── 01_data_discovery.md
├── 02_business_questions.md
└── 03_insights_and_recommendations.md

sql/
├── 01_data_quality.sql
├── 02_business_questions.sql
└── 03_dashbord_datasource.sql

python/
└── churn_analysis.ipynb

visualizations/
├── analysis/
└── dashboard_mockup/

```

## Supporting Materials

* SQL queries used for data validation, exploration, transformation, and analysis
* Python notebooks used for statistical analysis, correlation analysis, and modeling
* Documentation describing assumptions, analytical reasoning, findings, and recommendations


Let's get started.
