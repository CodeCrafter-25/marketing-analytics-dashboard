CREATE OR REPLACE TABLE
  `bright-gearbox-402817.marketing_analytics.monthly_campaign_performance` AS

WITH spend_summary AS (
  SELECT
    DATE_TRUNC(spend_date, MONTH) AS report_month,
    campaign_id,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(spend) AS spend
  FROM `bright-gearbox-402817.marketing_analytics.raw_daily_spend`
  GROUP BY report_month, campaign_id
),

lead_summary AS (
  SELECT
    DATE_TRUNC(created_at, MONTH) AS report_month,
    campaign_id,
    COUNT(*) AS leads,
    SUM(lead_score) AS lead_score_sum
  FROM `bright-gearbox-402817.marketing_analytics.raw_leads`
  GROUP BY report_month, campaign_id
),

conversion_summary AS (
  SELECT
    DATE_TRUNC(c.converted_at, MONTH) AS report_month,
    l.campaign_id,
    COUNT(*) AS conversions,
    COUNTIF(LOWER(c.conversion_type) = 'trial') AS trials,
    COUNTIF(LOWER(c.conversion_type) = 'purchase') AS purchases,
    SUM(c.revenue) AS revenue
  FROM `bright-gearbox-402817.marketing_analytics.raw_conversions` AS c
  JOIN `bright-gearbox-402817.marketing_analytics.raw_leads` AS l
    USING (lead_id)
  GROUP BY report_month, l.campaign_id
),

campaign_months AS (
  SELECT report_month, campaign_id FROM spend_summary

  UNION DISTINCT

  SELECT report_month, campaign_id FROM lead_summary

  UNION DISTINCT

  SELECT report_month, campaign_id FROM conversion_summary
),

monthly_base AS (
  SELECT
    cm.report_month,
    cm.campaign_id,
    c.campaign_name,
    c.channel,
    c.objective,

    COALESCE(s.impressions, 0) AS impressions,
    COALESCE(s.clicks, 0) AS clicks,
    COALESCE(s.spend, 0) AS spend,

    COALESCE(l.leads, 0) AS leads,
    COALESCE(l.lead_score_sum, 0) AS lead_score_sum,

    COALESCE(cv.conversions, 0) AS conversions,
    COALESCE(cv.trials, 0) AS trials,
    COALESCE(cv.purchases, 0) AS purchases,
    COALESCE(cv.revenue, 0) AS revenue

  FROM campaign_months AS cm
  JOIN `bright-gearbox-402817.marketing_analytics.raw_campaigns` AS c
    USING (campaign_id)
  LEFT JOIN spend_summary AS s
    USING (report_month, campaign_id)
  LEFT JOIN lead_summary AS l
    USING (report_month, campaign_id)
  LEFT JOIN conversion_summary AS cv
    USING (report_month, campaign_id)
)

SELECT
  *,
  SAFE_DIVIDE(lead_score_sum, leads) AS average_lead_score,
  SAFE_DIVIDE(clicks, impressions) AS ctr,
  SAFE_DIVIDE(spend, clicks) AS cpc,
  SAFE_DIVIDE(spend, impressions) * 1000 AS cpm,
  SAFE_DIVIDE(leads, clicks) AS click_to_lead_rate,
  SAFE_DIVIDE(spend, leads) AS cost_per_lead,
  SAFE_DIVIDE(conversions, leads) AS lead_to_conversion_rate,
  SAFE_DIVIDE(purchases, leads) AS lead_to_purchase_rate,
  SAFE_DIVIDE(spend, conversions) AS cost_per_conversion,
  SAFE_DIVIDE(spend, purchases) AS cost_per_purchase,
  SAFE_DIVIDE(revenue, spend) AS roas,
  SAFE_DIVIDE(revenue, purchases) AS revenue_per_purchase
FROM monthly_base;


-- Validation query
SELECT
  COUNT(*) AS total_rows,

  COUNT(
    DISTINCT CONCAT(
      CAST(report_month AS STRING),
      '|',
      campaign_id
    )
  ) AS unique_campaign_months,

  COUNT(*) -
  COUNT(
    DISTINCT CONCAT(
      CAST(report_month AS STRING),
      '|',
      campaign_id
    )
  ) AS duplicate_rows,

  COUNTIF(campaign_id IS NULL) AS missing_campaign_ids,

  MIN(report_month) AS earliest_month,
  MAX(report_month) AS latest_month,

  SUM(impressions) AS total_impressions,
  SUM(clicks) AS total_clicks,
  ROUND(SUM(spend), 2) AS total_spend,
  SUM(leads) AS total_leads,
  SUM(conversions) AS total_conversions,
  SUM(trials) AS total_trials,
  SUM(purchases) AS total_purchases,
  ROUND(SUM(revenue), 2) AS total_revenue

FROM `bright-gearbox-402817.marketing_analytics.monthly_campaign_performance`;
