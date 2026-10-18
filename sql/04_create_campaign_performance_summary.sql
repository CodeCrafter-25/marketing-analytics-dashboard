CREATE OR REPLACE TABLE
  `bright-gearbox-402817.marketing_analytics.campaign_performance_summary` AS

WITH spend_summary AS (
  SELECT
    campaign_id,
    COUNT(DISTINCT spend_date) AS active_spend_days,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(spend) AS spend
  FROM `bright-gearbox-402817.marketing_analytics.raw_daily_spend`
  GROUP BY campaign_id
),

lead_summary AS (
  SELECT
    campaign_id,
    COUNT(*) AS leads,
    SUM(lead_score) AS lead_score_sum
  FROM `bright-gearbox-402817.marketing_analytics.raw_leads`
  GROUP BY campaign_id
),

conversion_summary AS (
  SELECT
    l.campaign_id,
    COUNT(*) AS conversions,
    COUNTIF(LOWER(c.conversion_type) = 'trial') AS trials,
    COUNTIF(LOWER(c.conversion_type) = 'purchase') AS purchases,
    SUM(c.revenue) AS revenue
  FROM `bright-gearbox-402817.marketing_analytics.raw_conversions` AS c
  JOIN `bright-gearbox-402817.marketing_analytics.raw_leads` AS l
    USING (lead_id)
  GROUP BY l.campaign_id
),

campaign_base AS (
  SELECT
    c.campaign_id,
    c.campaign_name,
    c.channel,
    c.objective,
    c.start_date,
    c.end_date,
    DATE_DIFF(c.end_date, c.start_date, DAY) + 1
      AS campaign_duration_days,
    c.budget AS planned_budget,

    COALESCE(s.active_spend_days, 0) AS active_spend_days,
    COALESCE(s.impressions, 0) AS impressions,
    COALESCE(s.clicks, 0) AS clicks,
    COALESCE(s.spend, 0) AS spend,

    COALESCE(l.leads, 0) AS leads,
    COALESCE(l.lead_score_sum, 0) AS lead_score_sum,

    COALESCE(cv.conversions, 0) AS conversions,
    COALESCE(cv.trials, 0) AS trials,
    COALESCE(cv.purchases, 0) AS purchases,
    COALESCE(cv.revenue, 0) AS revenue

  FROM `bright-gearbox-402817.marketing_analytics.raw_campaigns` AS c
  LEFT JOIN spend_summary AS s USING (campaign_id)
  LEFT JOIN lead_summary AS l USING (campaign_id)
  LEFT JOIN conversion_summary AS cv USING (campaign_id)
)

SELECT
  *,
  SAFE_DIVIDE(lead_score_sum, leads) AS average_lead_score,
  SAFE_DIVIDE(spend, planned_budget) AS budget_utilization_rate,
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
FROM campaign_base;

___________________________

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT campaign_id) AS unique_campaigns,
  COUNT(*) - COUNT(DISTINCT campaign_id) AS duplicate_rows,
  ROUND(SUM(planned_budget), 2) AS total_planned_budget,
  SUM(impressions) AS total_impressions,
  SUM(clicks) AS total_clicks,
  ROUND(SUM(spend), 2) AS total_spend,
  SUM(leads) AS total_leads,
  SUM(conversions) AS total_conversions,
  SUM(trials) AS total_trials,
  SUM(purchases) AS total_purchases,
  ROUND(SUM(revenue), 2) AS total_revenue
FROM `bright-gearbox-402817.marketing_analytics.campaign_performance_summary`;
