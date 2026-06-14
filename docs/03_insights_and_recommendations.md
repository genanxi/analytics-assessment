# Hypothesis Testing

## Hypothesis 1: Product Adoption

Hypothesis:
Customers with lower feature adoption are more likely to churn.

Result:
- Churned accounts adopted an average of 28.34 features.
- Retained accounts adopted an average of 27.41 features.

Conclusion:
The data does not support the hypothesis. Feature adoption levels were similar across both groups, suggesting feature breadth alone is not a strong indicator of churn in this dataset.

---

## Hypothesis 2: Product Experience

Hypothesis:
Customers experiencing higher error rates are more likely to churn.

Result:
- Churned accounts had an average error rate of 5.39%.
- Retained accounts had an average error rate of 5.72%.

Conclusion:
The data does not support the hypothesis. Error rates were comparable across both groups and do not appear to be a meaningful differentiator of churn.

---

## Hypothesis 3: Support Experience

Hypothesis:
Customers with poorer support experiences are more likely to churn.

Result:
- Churned accounts reported an average satisfaction score of 4.00.
- Retained accounts reported an average satisfaction score of 3.95.

Conclusion:
The data does not support the hypothesis. Customer satisfaction scores were nearly identical across both groups.

## Additional Exploration

At this point, the results became interesting. All three initial hypotheses failed to demonstrate a meaningful relationship with churn.

Of course, in a real business environment, I would revisit the available data, collaborate with stakeholders, and formulate additional hypotheses based on business context and domain knowledge. However, the objective of this exercise was to demonstrate a structured analytical thought process rather than exhaustively search for statistically significant findings.

Before investing additional time in deeper analysis, I would typically perform a quick customer segmentation review to determine whether churn patterns differ across major customer personas.

To validate this, I analyzed churn rates across several account-level attributes:

- Industry
- Plan Tier
- Geography (Country)

The results showed that churn rates were nearly identical across plan tiers, but varied meaningfully across industries and countries. This suggests customer characteristics may be more strongly associated with churn than product adoption, product quality, or support experience within this dataset.

These findings provide a useful direction for future investigation and illustrate the importance of validating assumptions with data before committing to a specific analytical path.
