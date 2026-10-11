# Data Quality Report

## Overview

An initial data quality assessment was performed in BigQuery across all four source tables.

The assessment covered 312,740 records:

| Table | Records |
|---|---:|
| raw_campaigns | 120 |
| raw_daily_spend | 11,240 |
| raw_leads | 261,684 |
| raw_conversions | 39,696 |
| **Total** | **312,740** |

## Validation Areas

The assessment included:

- Missing primary keys
- Duplicate primary keys
- Missing required values
- Foreign-key integrity
- Invalid numeric values
- Invalid date sequences
- Cross-table date consistency
- Duplicate campaign-date combinations
- Multiple conversions assigned to the same lead

## Validation Results

### Missing Values and Primary Keys

| Table | Missing Primary Keys | Duplicate Primary Keys | Rows With Missing Required Values |
|---|---:|---:|---:|
| raw_campaigns | 0 | 0 | 0 |
| raw_daily_spend | 0 | 0 | 0 |
| raw_leads | 0 | 0 | 0 |
| raw_conversions | 0 | 0 | 0 |

All primary keys are present and unique. No missing values were identified in the required fields.

### Foreign-Key Integrity

| Validation Check | Issues |
|---|---:|
| Daily spend records without a matching campaign | 0 |
| Leads without a matching campaign | 0 |
| Conversions without a matching lead | 0 |

All foreign-key relationships are valid.

### Numeric and Date Validation

| Validation Check | Issues |
|---|---:|
| Campaign end date before start date | 0 |
| Clicks greater than impressions | 0 |
| Lead score outside the 1–100 range | 0 |
| Negative campaign budget | 0 |
| Negative conversion revenue | 0 |
| Negative impressions, clicks, or spend | 0 |

No invalid numeric values or date sequences were identified.

### Cross-Table Validation

| Validation Check | Issues |
|---|---:|
| Conversion before lead creation | 0 |
| Daily spend outside the campaign period | 0 |
| Duplicate campaign-date combinations | 0 |
| Multiple conversions per lead | 0 |

No cross-table consistency issues were identified.

## Conclusion

No data quality issues were identified by the performed validation checks.

The source tables can be used without removing or correcting records. However, analytical transformations are still required to aggregate tables at compatible levels of detail and prevent duplicated spend, budget, lead, conversion, or revenue values during joins.

The original source tables will remain unchanged. All calculated metrics and analytical transformations will be created in separate BigQuery tables or views.

