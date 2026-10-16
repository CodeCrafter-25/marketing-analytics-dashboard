# Analytical Data Model

## Purpose

The analytical model converts four source tables with different levels of detail into two reporting tables suitable for business analysis and Tableau visualization.

The model prevents duplicated budgets, spend, leads, conversions, and revenue during joins.

## Source Tables

| Source Table | Grain |
|---|---|
| `raw_campaigns` | One row per campaign |
| `raw_daily_spend` | One row per campaign and activity date |
| `raw_leads` | One row per lead |
| `raw_conversions` | One row per converted lead |

## Reporting Tables

The project will create two analytical reporting tables:

1. `campaign_performance_summary`
2. `monthly_campaign_performance`

---

# 1. Campaign Performance Summary

## Table Name

`marketing_analytics.campaign_performance_summary`

## Grain

One row represents one marketing campaign.

The expected table size is 120 rows.

## Purpose

This table supports:

- Campaign and channel comparison
- Campaign objective analysis
- Budget utilization analysis
- Campaign ranking
- Full campaign funnel analysis
- Identification of high-spend and low-efficiency campaigns

## Dimensions

| Column | Description |
|---|---|
| campaign_id | Unique campaign identifier |
| campaign_name | Campaign name |
| channel | Marketing channel |
| objective | Campaign objective |
| start_date | Campaign start date |
| end_date | Campaign end date |
| campaign_duration_days | Inclusive number of campaign days |

## Base Metrics

| Column | Description |
|---|---|
| planned_budget | Planned campaign budget |
| active_spend_days | Number of dates with recorded campaign activity |
| impressions | Total campaign impressions |
| clicks | Total campaign clicks |
| spend | Total campaign advertising spend |
| leads | Total leads attributed to the campaign |
| lead_score_sum | Sum of lead scores used for weighted average calculation |
| conversions | Total trial and purchase conversions |
| trials | Total trial conversions |
| purchases | Total purchase conversions |
| revenue | Total attributed campaign revenue |

## Calculated Metrics

| Column | Calculation |
|---|---|
| average_lead_score | `lead_score_sum / leads` |
| budget_utilization_rate | `spend / planned_budget` |
| ctr | `clicks / impressions` |
| cpc | `spend / clicks` |
| cpm | `spend / impressions × 1,000` |
| click_to_lead_rate | `leads / clicks` |
| cost_per_lead | `spend / leads` |
| lead_to_conversion_rate | `conversions / leads` |
| lead_to_purchase_rate | `purchases / leads` |
| cost_per_conversion | `spend / conversions` |
| cost_per_purchase | `spend / purchases` |
| roas | `revenue / spend` |
| revenue_per_purchase | `revenue / purchases` |

## Join Strategy

The source tables must not be directly joined before aggregation.

Three separate summaries will be created first:

1. Daily spend aggregated by `campaign_id`
2. Leads aggregated by `campaign_id`
3. Conversions aggregated by `campaign_id` through the leads table

The aggregated results will then be joined to `raw_campaigns`.

This ensures that the planned budget appears only once per campaign.

---

# 2. Monthly Campaign Performance

## Table Name

`marketing_analytics.monthly_campaign_performance`

## Grain

One row represents one campaign in one calendar month.

The unique key is:

`report_month + campaign_id`

## Purpose

This table supports:

- Monthly performance trends
- Channel performance over time
- Campaign performance over time
- Monthly funnel analysis
- Monthly spend, purchase, revenue, and ROAS comparisons

## Dimensions

| Column | Description |
|---|---|
| report_month | First day of the reporting month |
| campaign_id | Unique campaign identifier |
| campaign_name | Campaign name |
| channel | Marketing channel |
| objective | Campaign objective |

## Base Metrics

| Column | Description |
|---|---|
| impressions | Impressions recorded during the month |
| clicks | Clicks recorded during the month |
| spend | Advertising spend recorded during the month |
| leads | Leads created during the month |
| lead_score_sum | Sum of scores for leads created during the month |
| conversions | Conversions recorded during the month |
| trials | Trial conversions recorded during the month |
| purchases | Purchase conversions recorded during the month |
| revenue | Attributed revenue recorded during the month |

## Calculated Metrics

| Column | Calculation |
|---|---|
| average_lead_score | `lead_score_sum / leads` |
| ctr | `clicks / impressions` |
| cpc | `spend / clicks` |
| cpm | `spend / impressions × 1,000` |
| click_to_lead_rate | `leads / clicks` |
| cost_per_lead | `spend / leads` |
| lead_to_conversion_rate | `conversions / leads` |
| lead_to_purchase_rate | `purchases / leads` |
| cost_per_conversion | `spend / conversions` |
| cost_per_purchase | `spend / purchases` |
| roas | `revenue / spend` |
| revenue_per_purchase | `revenue / purchases` |

## Monthly Date Rules

Each source uses its natural event date:

- Impressions, clicks, and spend use `spend_date`
- Leads use `created_at`
- Conversions and revenue use `converted_at`

The month will be calculated using:

`DATE_TRUNC(date_field, MONTH)`

A complete list of campaign-month combinations will be created from all three activity sources. This prevents the loss of months that contain leads or conversions but no advertising spend.

## Budget Exclusion

Planned budget and Budget Utilization Rate will not be included in the monthly table.

The source dataset does not contain monthly budget allocations. Repeating the full campaign budget in every month would produce incorrect totals.

---

# Rate Storage and Tableau Rules

Rates will be stored as decimals:

- `0.0163` represents `1.63%`
- `0.25` represents `25%`

Tableau will format these fields as percentages.

Precalculated row-level rates must not be averaged across campaigns or months.

For filtered totals, Tableau must calculate rates from the additive components.

Example:

`SUM([clicks]) / SUM([impressions])`

not:

`AVG([ctr])`

The same rule applies to CPC, CPL, Cost per Purchase, ROAS, and other ratio metrics.

---

# Tableau Data Sources

The final exports are expected to be:

- `tableau_campaign_performance.csv`
- `tableau_monthly_campaign_performance.csv`

The campaign table will support campaign rankings and budget analysis.

The monthly table will support time-series charts and the main date filter.

---

# Validation Requirements

## Campaign Table

- Expected rows: 120
- Unique campaign IDs: 120
- No duplicate campaign IDs
- Total planned budget must equal `$5,418,642.16`
- Spend, impressions, clicks, leads, conversions, purchases, and revenue must match the source totals

## Monthly Table

- Every `report_month + campaign_id` combination must be unique
- No missing campaign IDs
- Totals across all months must match the source totals
- Monthly budget must not be included
- Rates must be recalculated from aggregated totals during validation

## Source Control

The four raw BigQuery tables will remain unchanged.

The reporting tables will be recreated using documented SQL scripts so that the transformation process remains reproducible.
