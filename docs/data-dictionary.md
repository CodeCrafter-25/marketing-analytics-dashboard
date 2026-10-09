# Data Dictionary

## Dataset Structure

The dataset consists of four related source tables:

1. `campaigns`
2. `daily_spend`
3. `leads`
4. `conversions`

---

## Table: campaigns

One row represents one marketing campaign.

| Column | Data Type | Description |
|---|---|---|
| campaign_id | STRING | Unique campaign identifier |
| campaign_name | STRING | Name of the marketing campaign |
| channel | STRING | Marketing channel used by the campaign |
| objective | STRING | Primary campaign objective |
| start_date | DATE | Campaign start date |
| end_date | DATE | Campaign end date |
| budget | NUMERIC | Planned campaign budget |

**Primary key:** `campaign_id`

---

## Table: daily_spend

One row represents the daily performance of one campaign.

| Column | Data Type | Description |
|---|---|---|
| spend_id | STRING | Unique daily spend record identifier |
| campaign_id | STRING | Campaign identifier |
| spend_date | DATE | Date of campaign activity |
| impressions | INTEGER | Number of times advertisements were displayed |
| clicks | INTEGER | Number of recorded advertisement clicks |
| spend | NUMERIC | Actual advertising spend |

**Primary key:** `spend_id`  
**Foreign key:** `campaign_id` → `campaigns.campaign_id`

---

## Table: leads

One row represents one marketing lead.

| Column | Data Type | Description |
|---|---|---|
| lead_id | STRING | Unique lead identifier |
| campaign_id | STRING | Campaign attributed to the lead |
| created_at | DATE | Date when the lead was created |
| lead_source | STRING | Source attributed to the lead |
| lead_score | INTEGER | Lead quality score from 1 to 100 |

**Primary key:** `lead_id`  
**Foreign key:** `campaign_id` → `campaigns.campaign_id`

---

## Table: conversions

One row represents one converted lead.

| Column | Data Type | Description |
|---|---|---|
| conversion_id | STRING | Unique conversion identifier |
| lead_id | STRING | Identifier of the converted lead |
| converted_at | DATE | Conversion date |
| conversion_type | STRING | Type of conversion, such as trial or purchase |
| revenue | NUMERIC | Revenue attributed to the conversion |

**Primary key:** `conversion_id`  
**Foreign key:** `lead_id` → `leads.lead_id`

---

## Table Relationships

- One campaign can have many daily spend records.
- One campaign can generate many leads.
- One lead can have zero or one conversion.
- A conversion is connected to a campaign through the leads table.

## Important Modelling Consideration

The tables have different levels of detail.

Campaign budgets, daily spend records, leads, and conversions must be aggregated separately before they are joined. Otherwise, spend, budget, or revenue values may be duplicated.

## Source File Summary

| Source File | Data Rows | Columns |
|---|---:|---:|
| campaigns.csv | 120 | 7 |
| daily_spend.csv | 11,240 | 6 |
| leads.csv | 261,684 | 5 |
| conversions.csv | 39,696 | 5 |
| **Total** | **312,740** | — |

The row counts exclude the CSV header rows.

## Initial File Inspection

The initial manual inspection confirmed that:

- All four expected source files are present
- Column names match the published dataset structure
- Dates use the `YYYY-MM-DD` format
- Numeric values use a decimal point
- Primary and foreign key columns are present
- No obvious file corruption or column-separation issues were identified

Detailed data quality checks will be performed in BigQuery.
