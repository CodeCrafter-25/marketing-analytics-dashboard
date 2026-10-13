# Source Data Profile

## Overview

Source data profiling was performed after the completion of the initial data quality assessment.

The purpose of this stage was to understand the dataset coverage, available marketing dimensions, performance volumes, conversion structure, and preliminary channel-level efficiency.

## Dataset Coverage

| Metric | Result |
|---|---:|
| Campaigns | 120 |
| Marketing channels | 5 |
| Campaign objectives | 3 |
| Earliest campaign start | 2023-01-04 |
| Latest campaign end | 2025-12-02 |
| Total planned budget | $5,418,642.16 |
| Average campaign budget | $45,155.35 |

The dataset contains three campaign objectives:

- Awareness
- Lead generation
- Acquisition

The five marketing channels are:

- Affiliate
- Display
- Paid Search
- Paid Social
- Video

## Advertising Performance

| Metric | Result |
|---|---:|
| Earliest spend date | 2023-01-04 |
| Latest spend date | 2025-12-02 |
| Active calendar days | 1,064 |
| Total impressions | 436,844,819 |
| Total clicks | 7,102,319 |
| Total spend | $4,523,050.02 |
| Overall CTR | 1.63% |
| Overall CPC | $0.64 |
| Overall CPM | $10.35 |

Approximately 83.5% of the total planned campaign budget was spent.

## Lead Profile

| Lead Source | Total Leads | Average Lead Score |
|---|---:|---:|
| Affiliate | 67,849 | 50.56 |
| Paid Search | 65,268 | 50.66 |
| Paid Social | 57,619 | 50.47 |
| Display | 45,149 | 50.54 |
| Video | 25,799 | 50.64 |
| **Total** | **261,684** | — |

Average lead scores are very similar across all channels. Therefore, average lead score may have limited value as a primary dashboard KPI.

## Conversion Profile

| Conversion Type | Conversions | Revenue | Average Revenue |
|---|---:|---:|---:|
| Trial | 23,005 | $0.00 | $0.00 |
| Purchase | 16,691 | $21,561,839.01 | $1,291.82 |
| **Total** | **39,696** | **$21,561,839.01** | — |

Trials and purchases are recorded as separate conversion types.

Because each lead has no more than one conversion record, the dataset does not support tracking the same lead from trial to purchase. Therefore, a trial-to-purchase conversion rate should not be calculated.

## Preliminary Channel Performance

| Channel | Spend | Leads | Conversions | Purchases | Revenue | CTR | Cost per Purchase | ROAS |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Affiliate | $857,835.07 | 67,849 | 10,352 | 4,332 | $5,610,700.73 | 2.50% | $198.02 | 6.54 |
| Paid Search | $897,091.53 | 65,268 | 10,019 | 4,204 | $5,439,329.35 | 3.49% | $213.39 | 6.06 |
| Paid Social | $984,731.88 | 57,619 | 8,648 | 3,646 | $4,690,137.28 | 1.79% | $270.09 | 4.76 |
| Display | $955,297.00 | 45,149 | 6,744 | 2,871 | $3,734,117.43 | 0.60% | $332.74 | 3.91 |
| Video | $828,094.54 | 25,799 | 3,933 | 1,638 | $2,087,554.22 | 0.89% | $505.55 | 2.52 |

## Preliminary Observations

1. Affiliate generated the highest ROAS and the lowest cost per purchase.
2. Paid Search produced the highest CTR and the second-highest ROAS.
3. Paid Social delivered mid-range efficiency across the principal metrics.
4. Display generated the highest number of impressions but had the lowest CTR.
5. Video had the highest CPC and cost per purchase and the lowest ROAS.
6. Lead-to-conversion rates were relatively similar across channels.
7. Average lead scores showed very little variation between channels.

## Metric Interpretation

The following metrics must be kept separate in the analysis:

- Click-to-Lead Rate = Leads / Clicks
- Lead-to-Conversion Rate = All Conversions / Leads
- Lead-to-Purchase Rate = Purchases / Leads
- Cost per Conversion = Spend / All Conversions
- Cost per Purchase = Spend / Purchases
- ROAS = Revenue / Spend

These definitions will be documented before the analytical reporting tables are created.

## Profiling Conclusion

The dataset provides sufficient coverage for campaign, channel, objective, time-series, funnel, budget, and return analysis.

The next stage is to define the business questions and final metric calculation rules before building the analytical data model.
