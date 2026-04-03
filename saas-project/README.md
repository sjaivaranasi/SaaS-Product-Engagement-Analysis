# SaaS Product Engagement & Conversion Analysis

## Business Problem

A B2B SaaS company is experiencing below-benchmark trial-to-paid conversion rates and rising churn among mid-tier subscribers. Leadership needs to understand which user behaviors during the trial period predict conversion, where users drop off in the activation funnel, and which customer segments deliver the highest lifetime value — to inform targeted retention strategies and product roadmap priorities.

## Approach

End-to-end analytics engagement following a consulting-style workflow:

1. **Data Cleaning & Feature Engineering** (Python) — Merged subscription and user event datasets, handled nulls/duplicates, engineered cohort labels, engagement scores, and funnel stage flags
2. **Analytical Queries** (SQL / MySQL) — Funnel conversion rates, monthly cohort retention grids, feature adoption vs. churn correlation, revenue segmentation by plan tier
3. **Executive Dashboard** (Tableau) — Interactive views covering conversion funnel, cohort retention heatmap, plan-tier revenue breakdown, and KPI summary
4. **Stakeholder Presentation** (PowerPoint) — McKinsey-style deck structured with the Pyramid Principle and MECE framework

## Key Findings

> _To be completed after analysis_

- Finding 1: ...
- Finding 2: ...
- Finding 3: ...

## Recommendations

> _To be completed after analysis_

1. ...
2. ...
3. ...

## Tools & Technologies

| Layer | Tools |
|-------|-------|
| Data Cleaning & EDA | Python (Pandas, NumPy, Matplotlib, Seaborn) |
| Database & Queries | MySQL, DBeaver |
| Visualization | Tableau Public |
| Presentation | PowerPoint (Pyramid Principle / MECE) |
| Version Control | Git / GitHub |

## Dashboard

> [View on Tableau Public](#) _(link to be added)_

![Dashboard Screenshot](dashboards/dashboard_screenshot.png)

## Project Structure

```
SaaS-Product-Engagement-Analysis/
├── README.md
├── data/
│   ├── raw/                  # Original Kaggle CSVs
│   └── cleaned/              # Processed outputs
├── notebooks/
│   └── 01_data_cleaning_eda.ipynb
├── sql/
│   ├── 01_funnel_analysis.sql
│   ├── 02_cohort_retention.sql
│   ├── 03_feature_adoption.sql
│   └── 04_revenue_segmentation.sql
├── dashboards/
│   └── tableau_public_link.md
└── presentation/
    └── SaaS_Engagement_Analysis.pptx
```

## Data Sources

- [SaaS Subscription & Churn Analytics Dataset](https://www.kaggle.com/datasets/rivalytics/saas-subscription-and-churn-analytics-dataset) — Subscription tiers, churn flags, revenue, customer attributes
- [User Funnels Dataset](https://www.kaggle.com/datasets/amirmotefaker/user-funnels-dataset) — User event logs with funnel stage progression

## Author

**S. Jai Varanasi**
- [LinkedIn](https://www.linkedin.com/in/sjaivaranasi)
- [GitHub](https://github.com/sjaivaranasi)
- [Tableau Public](https://public.tableau.com/app/profile/s.jai.varanasi/vizzes)
