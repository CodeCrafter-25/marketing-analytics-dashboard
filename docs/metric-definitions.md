# Marketing Metric Definitions

## Purpose

This document defines the calculation rules for the Marketing Analytics Dashboard.

The definitions ensure that SQL outputs and Tableau calculations use consistent business logic.

## General Calculation Principles

1. Ratio metrics must be calculated from aggregated totals.

   Correct:

   `SUM(clicks) / SUM(impressions)`

   Incorrect:

   `AVG(clicks / impressions)`

2. Division by zero must be handled using `SAFE_DIVIDE` in BigQuery.

3. Spend, leads, conversions, revenue, and campaign budgets must be aggregated separately before they are joined.

4. A metric returns `NULL` when its denominator is zero.

5. Attributed revenue represents revenue connected to a marketing campaign through its attributed lead. It does not prove that the campaign caused the conversion.

---

## Base Metrics

| Metric | Definition | Calculation | Format |
|---|---|---|---|
| Planned Budget | Total budget assigned to selected campaigns | `SUM(budget)` once per campaign | Currency |
| Advertising Spend | Actual recorded marketing spend | `SUM(spend)` | Currency |
| Impressions | Number of advertisement displays | `SUM(impressions)` | Whole number |
| Clicks | Number of recorded advertisement clicks | `SUM(clicks)` | Whole number |
| Leads | Number of attributed marketing leads | `COUNT(lead_id)` | Whole number |
| All Conversions | Total trial and purchase conversions | `COUNT(conversion_id)` | Whole number |
| Trials | Conversions with type `trial` | `COUNTIF(conversion_type = 'trial')` | Whole number |
| Purchases | Conversions with type `purchase` | `COUNTIF(conversion_type = 'purchase')` | Whole number |
| Attributed Revenue | Revenue attributed to converted leads | `SUM(revenue)` | Currency |

---

## Efficiency Metrics

| Metric | Calculation | Format | Interpretation |
|---|---|---|---|
| Click-Through Rate (CTR) | `Clicks / Impressions × 100` | Percentage | Percentage of impressions that generated clicks |
| Cost per Click (CPC) | `Spend / Clicks` | Currency | Average advertising cost of one click |
| Cost per Thousand Impressions (CPM) | `Spend / Impressions × 1,000` | Currency | Cost of one thousand impressions |
| Click-to-Lead Rate | `Leads / Clicks × 100` | Percentage | Percentage of clicks that generated leads |
| Cost per Lead (CPL) | `Spend / Leads` | Currency | Average advertising cost of one lead |
| Lead-to-Conversion Rate | `All Conversions / Leads × 100` | Percentage | Percentage of leads that generated any conversion |
| Lead-to-Purchase Rate | `Purchases / Leads × 100` | Percentage | Percentage of leads that generated a purchase |
| Cost per Conversion | `Spend / All Conversions` | Currency | Average advertising cost of a trial or purchase conversion |
| Cost per Purchase | `Spend / Purchases` | Currency | Average advertising cost of one purchase |
| Return on Advertising Spend (ROAS) | `Attributed Revenue / Spend` | Decimal ratio | Revenue generated for every monetary unit spent |
| Budget Utilization Rate | `Spend / Planned Budget × 100` | Percentage | Percentage of the planned budget that was used |
| Revenue per Purchase | `Attributed Revenue / Purchases` | Currency | Average attributed revenue per purchase |

---

## Dashboard KPI Selection

### Primary KPI Cards

The main dashboard should contain five primary KPI cards:

1. Advertising Spend
2. Attributed Revenue
3. Purchases
4. ROAS
5. Cost per Purchase

These metrics provide a concise view of investment, business results, and acquisition efficiency.

### Secondary Metrics

The following metrics should appear in supporting charts, tooltips, or detailed views:

- Planned Budget
- Budget Utilization Rate
- Impressions
- Clicks
- CTR
- CPC
- CPM
- Leads
- Cost per Lead
- Trials
- All Conversions
- Click-to-Lead Rate
- Lead-to-Conversion Rate
- Lead-to-Purchase Rate
- Cost per Conversion
- Revenue per Purchase

---

## Campaign Objective Priorities

Campaigns with different objectives should not be evaluated using exactly the same KPI priorities.

| Campaign Objective | Primary Evaluation Metrics |
|---|---|
| Awareness | Impressions, CPM, Clicks, CTR |
| Lead Generation | Leads, Click-to-Lead Rate, Cost per Lead |
| Acquisition | Purchases, Lead-to-Purchase Rate, Cost per Purchase, Revenue, ROAS |

The campaign objective must therefore be available as a dashboard filter.

---

## Budget Calculation Rule

Budget exists once at the campaign level.

It must not be directly joined to daily spend, lead, or conversion records because this would duplicate the budget.

Budget Utilization Rate should be calculated from a campaign-level reporting table:

`Total Campaign Spend / Campaign Budget × 100`

The dataset does not contain monthly budget allocations. Therefore, monthly budget utilization should not be calculated unless a documented budget-allocation method is introduced.

---

## Time-Based Calculation Rules

Metrics use their natural event dates:

| Metric Group | Date Field |
|---|---|
| Impressions, clicks, and spend | `spend_date` |
| Leads | `created_at` |
| Trials, purchases, and revenue | `converted_at` |

Monthly ROAS compares revenue recorded during a calendar month with advertising spend recorded during the same calendar month.

Because conversions can occur after the advertising interaction, monthly ROAS should be interpreted as a calendar-period performance metric rather than a causal campaign attribution measure.

---

## Metrics Not Used

### Generic Conversion Rate

The name `Conversion Rate` is too ambiguous. The dashboard will use specific names:

- Click-to-Lead Rate
- Lead-to-Conversion Rate
- Lead-to-Purchase Rate

### Customer Acquisition Cost

Cost per Purchase should not be presented as full Customer Acquisition Cost because the dataset does not contain all customer-related acquisition costs.

### Trial-to-Purchase Rate

This metric cannot be calculated because each converted lead has only one conversion record. The same lead cannot be followed from trial to purchase.

### Net Profit and ROI

The dataset includes advertising spend but does not include product costs, operating costs, or other business expenses.

Therefore, the dashboard will prioritize ROAS and will not present attributed revenue minus advertising spend as company net profit.

### Average Row-Level Rates

Precalculated row-level rates must not be averaged because rows can have very different numbers of impressions, clicks, leads, or conversions.
