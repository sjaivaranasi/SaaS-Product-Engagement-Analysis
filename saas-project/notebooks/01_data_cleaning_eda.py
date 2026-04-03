# %% [markdown]
# # SaaS Product Engagement & Conversion Analysis
# ## Step 1: Data Cleaning & Exploratory Data Analysis
# 
# **Business Problem:** A B2B SaaS company needs to understand which user behaviors 
# predict trial-to-paid conversion, where users drop off in the activation funnel, 
# and which customer segments deliver the highest lifetime value.
# 
# **Datasets:**
# - SaaS Subscription & Churn Analytics Dataset (subscriptions, revenue, churn)
# - User Funnels Dataset (user event logs, funnel stages)

# %% [markdown]
# ---
# ## 1.1 — Import Libraries & Load Data

# %%
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings

warnings.filterwarnings('ignore')
sns.set_style('whitegrid')
plt.rcParams['figure.figsize'] = (12, 6)
plt.rcParams['font.size'] = 12

# Color palette — matches our Tableau dashboard scheme
COLORS = {
    'primary': '#2E5090',    # slate blue
    'secondary': '#1A8A6E',  # emerald
    'accent': '#E8733A',     # coral
    'warning': '#D4A843',    # gold
    'neutral': '#6B7B8D',    # warm gray
    'light': '#F0F4F8'       # background
}
PALETTE = list(COLORS.values())[:5]

# %%
# Load datasets — UPDATE THESE PATHS to where you saved the Kaggle CSVs
# -----------------------------------------------------------------------
# df_subs = pd.read_csv('data/raw/saas_subscription_churn.csv')
# df_funnel = pd.read_csv('data/raw/user_funnels.csv')

# PLACEHOLDER: uncomment the lines above and comment out the lines below
# once you have your actual data files
print("⚠️  UPDATE THE FILE PATHS ABOVE with your actual Kaggle CSV locations")
print("   Then re-run this cell.\n")
print("Expected files:")
print("   1. data/raw/saas_subscription_churn.csv")
print("   2. data/raw/user_funnels.csv")

# %% [markdown]
# ---
# ## 1.2 — Initial Inspection
# 
# Before cleaning anything, understand what you're working with.

# %%
# Uncomment once data is loaded:

# print("=" * 60)
# print("SUBSCRIPTION DATA")
# print("=" * 60)
# print(f"Shape: {df_subs.shape}")
# print(f"\nColumn types:\n{df_subs.dtypes}")
# print(f"\nNull counts:\n{df_subs.isnull().sum()}")
# print(f"\nFirst 5 rows:")
# df_subs.head()

# %%
# print("=" * 60)
# print("FUNNEL / EVENT DATA")
# print("=" * 60)
# print(f"Shape: {df_funnel.shape}")
# print(f"\nColumn types:\n{df_funnel.dtypes}")
# print(f"\nNull counts:\n{df_funnel.isnull().sum()}")
# print(f"\nFirst 5 rows:")
# df_funnel.head()

# %%
# Quick statistical summary
# df_subs.describe(include='all')

# %% [markdown]
# ---
# ## 1.3 — Data Cleaning
# 
# Checklist:
# - [ ] Drop exact duplicate rows
# - [ ] Handle nulls (drop vs. impute — document your decision)
# - [ ] Fix data types (dates as datetime, categories as category)
# - [ ] Standardize column names (snake_case)
# - [ ] Validate value ranges (no negative revenue, valid date ranges, etc.)

# %%
def clean_column_names(df):
    """Standardize column names to snake_case."""
    df.columns = (
        df.columns
        .str.strip()
        .str.lower()
        .str.replace(' ', '_')
        .str.replace('-', '_')
        .str.replace('(', '')
        .str.replace(')', '')
    )
    return df

# %%
# Apply cleaning — uncomment once data is loaded
# -----------------------------------------------

# # Clean column names
# df_subs = clean_column_names(df_subs)
# df_funnel = clean_column_names(df_funnel)

# # Drop exact duplicates
# print(f"Subscription dupes: {df_subs.duplicated().sum()}")
# df_subs = df_subs.drop_duplicates()

# print(f"Funnel dupes: {df_funnel.duplicated().sum()}")
# df_funnel = df_funnel.drop_duplicates()

# # Convert date columns — ADAPT column names to match your actual data
# # date_cols_subs = ['signup_date', 'subscription_start', 'subscription_end']
# # for col in date_cols_subs:
# #     if col in df_subs.columns:
# #         df_subs[col] = pd.to_datetime(df_subs[col], errors='coerce')

# # date_cols_funnel = ['event_date', 'timestamp']
# # for col in date_cols_funnel:
# #     if col in df_funnel.columns:
# #         df_funnel[col] = pd.to_datetime(df_funnel[col], errors='coerce')

# # Check nulls after cleaning
# print("\nRemaining nulls (subscriptions):")
# print(df_subs.isnull().sum()[df_subs.isnull().sum() > 0])
# print("\nRemaining nulls (funnel):")
# print(df_funnel.isnull().sum()[df_funnel.isnull().sum() > 0])

# %% [markdown]
# ---
# ## 1.4 — Feature Engineering
# 
# This is where you create the columns that power your analysis.
# These derived features are what separate a junior DA project from a senior one.

# %%
# FEATURE ENGINEERING — adapt column names to your actual data
# ---------------------------------------------------------------

# # --- Cohort label (signup month) ---
# # df_subs['cohort_month'] = df_subs['signup_date'].dt.to_period('M')

# # --- Tenure (days active) ---
# # df_subs['tenure_days'] = (
# #     df_subs['subscription_end'].fillna(pd.Timestamp.now()) 
# #     - df_subs['subscription_start']
# # ).dt.days

# # --- Revenue per day (unit economics) ---
# # df_subs['revenue_per_day'] = df_subs['monthly_revenue'] / 30

# # --- Engagement score (from funnel data) ---
# # If your funnel data has event counts per user:
# # engagement = df_funnel.groupby('user_id').agg(
# #     total_events=('event_type', 'count'),
# #     unique_features=('feature_name', 'nunique'),
# #     first_event=('event_date', 'min'),
# #     last_event=('event_date', 'max'),
# # ).reset_index()
# # 
# # engagement['days_active'] = (
# #     engagement['last_event'] - engagement['first_event']
# # ).dt.days
# # 
# # engagement['events_per_day'] = (
# #     engagement['total_events'] / engagement['days_active'].clip(lower=1)
# # )

# # --- Merge engagement back to subscriptions ---
# # df_combined = df_subs.merge(engagement, on='user_id', how='left')

# %% [markdown]
# ---
# ## 1.5 — Exploratory Data Analysis (EDA)
# 
# Four key areas to explore visually before moving to SQL:
# 1. **Distribution of key metrics** (revenue, tenure, events)
# 2. **Churn vs. retained comparison**
# 3. **Funnel stage drop-off**
# 4. **Cohort patterns over time**

# %%
# --- 1. Distribution plots ---

# fig, axes = plt.subplots(1, 3, figsize=(16, 5))
# 
# # Monthly revenue distribution
# df_subs['monthly_revenue'].hist(
#     ax=axes[0], bins=30, color=COLORS['primary'], edgecolor='white'
# )
# axes[0].set_title('Monthly Revenue Distribution')
# axes[0].set_xlabel('Revenue ($)')
# 
# # Tenure distribution
# df_subs['tenure_days'].hist(
#     ax=axes[1], bins=30, color=COLORS['secondary'], edgecolor='white'
# )
# axes[1].set_title('Customer Tenure (Days)')
# axes[1].set_xlabel('Days')
# 
# # Plan tier breakdown
# df_subs['plan_tier'].value_counts().plot(
#     kind='bar', ax=axes[2], color=PALETTE
# )
# axes[2].set_title('Subscribers by Plan Tier')
# axes[2].set_xlabel('')
# 
# plt.tight_layout()
# plt.savefig('data/cleaned/01_distributions.png', dpi=150, bbox_inches='tight')
# plt.show()

# %%
# --- 2. Churn vs. Retained comparison ---

# fig, axes = plt.subplots(1, 2, figsize=(14, 5))
# 
# # Revenue by churn status
# df_subs.groupby('churn_flag')['monthly_revenue'].mean().plot(
#     kind='bar', ax=axes[0], color=[COLORS['secondary'], COLORS['accent']]
# )
# axes[0].set_title('Avg Monthly Revenue: Churned vs Retained')
# axes[0].set_ylabel('Revenue ($)')
# axes[0].set_xticklabels(['Retained', 'Churned'], rotation=0)
# 
# # Tenure by churn status
# df_subs.groupby('churn_flag')['tenure_days'].mean().plot(
#     kind='bar', ax=axes[1], color=[COLORS['secondary'], COLORS['accent']]
# )
# axes[1].set_title('Avg Tenure: Churned vs Retained')
# axes[1].set_ylabel('Days')
# axes[1].set_xticklabels(['Retained', 'Churned'], rotation=0)
# 
# plt.tight_layout()
# plt.savefig('data/cleaned/02_churn_comparison.png', dpi=150, bbox_inches='tight')
# plt.show()

# %%
# --- 3. Funnel stage drop-off ---

# # Adapt to your actual funnel stage column name
# funnel_order = ['visit', 'signup', 'activation', 'trial', 'conversion', 'retention']
# 
# funnel_counts = (
#     df_funnel.groupby('funnel_stage')['user_id']
#     .nunique()
#     .reindex(funnel_order)
# )
# 
# fig, ax = plt.subplots(figsize=(10, 6))
# bars = ax.barh(
#     funnel_counts.index, funnel_counts.values,
#     color=[COLORS['primary'] if i < len(funnel_counts)-1 else COLORS['secondary'] 
#            for i in range(len(funnel_counts))]
# )
# 
# # Add conversion rate labels
# for i in range(1, len(funnel_counts)):
#     rate = funnel_counts.iloc[i] / funnel_counts.iloc[i-1] * 100
#     ax.text(
#         funnel_counts.iloc[i] + 10, i, f'{rate:.1f}%',
#         va='center', fontweight='bold', color=COLORS['accent']
#     )
# 
# ax.set_title('User Conversion Funnel')
# ax.set_xlabel('Unique Users')
# ax.invert_yaxis()
# plt.tight_layout()
# plt.savefig('data/cleaned/03_funnel_dropoff.png', dpi=150, bbox_inches='tight')
# plt.show()

# %%
# --- 4. Cohort retention heatmap ---

# # Build cohort matrix
# df_subs['cohort_month'] = df_subs['signup_date'].dt.to_period('M')
# df_subs['activity_month'] = df_subs['last_active_date'].dt.to_period('M')  # adapt col name
# 
# cohort_data = df_subs.groupby(['cohort_month', 'activity_month']).agg(
#     users=('user_id', 'nunique')
# ).reset_index()
# 
# cohort_data['period_number'] = (
#     cohort_data['activity_month'] - cohort_data['cohort_month']
# ).apply(lambda x: x.n)
# 
# cohort_pivot = cohort_data.pivot(
#     index='cohort_month', columns='period_number', values='users'
# )
# 
# # Convert to retention percentages
# cohort_sizes = cohort_pivot[0]
# retention = cohort_pivot.divide(cohort_sizes, axis=0) * 100
# 
# fig, ax = plt.subplots(figsize=(14, 8))
# sns.heatmap(
#     retention, annot=True, fmt='.0f', cmap='YlGnBu',
#     ax=ax, vmin=0, vmax=100,
#     cbar_kws={'label': 'Retention %'}
# )
# ax.set_title('Monthly Cohort Retention (%)')
# ax.set_xlabel('Months Since Signup')
# ax.set_ylabel('Cohort (Signup Month)')
# plt.tight_layout()
# plt.savefig('data/cleaned/04_cohort_retention.png', dpi=150, bbox_inches='tight')
# plt.show()

# %% [markdown]
# ---
# ## 1.6 — Export Cleaned Data
# 
# Export for SQL (MySQL/DBeaver) and Tableau.

# %%
# # Export cleaned & merged dataset
# df_combined.to_csv('data/cleaned/saas_combined_cleaned.csv', index=False)
# 
# # Also export individual tables for SQL loading
# df_subs.to_csv('data/cleaned/subscriptions_cleaned.csv', index=False)
# df_funnel.to_csv('data/cleaned/funnel_events_cleaned.csv', index=False)
# 
# print("✅ Cleaned data exported to data/cleaned/")
# print(f"   - saas_combined_cleaned.csv ({df_combined.shape})")
# print(f"   - subscriptions_cleaned.csv ({df_subs.shape})")
# print(f"   - funnel_events_cleaned.csv ({df_funnel.shape})")

# %% [markdown]
# ---
# ## Next Steps
# 
# 1. **Load cleaned CSVs into MySQL** via DBeaver (Import CSV wizard)
# 2. **Run analytical SQL queries** (see `sql/` folder)
# 3. **Connect Tableau** to MySQL or cleaned CSVs
# 4. **Build executive dashboard** in Tableau
# 5. **Create McKinsey-style deck** from findings
