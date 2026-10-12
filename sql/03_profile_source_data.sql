-- ============================================================
-- Marketing Analytics Dashboard
-- Source Data Profiling
-- ============================================================


-- 1. Campaign overview

SELECT
    COUNT(*) AS total_campaigns,
    COUNT(DISTINCT channel) AS unique_channels,
    COUNT(DISTINCT objective) AS unique_objectives,
    MIN(start_date) AS earliest_campaign_start,
    MAX(end_date) AS latest_campaign_end,
    ROUND(SUM(budget), 2) AS total_planned_budget,
    ROUND(AVG(budget), 2) AS average_campaign_budget
FROM `bright-gearbox-402817.marketing_analytics.raw_campaigns`;


-- 2. Campaign distribution by channel and objective

SELECT
    channel,
    objective,
    COUNT(*) AS campaign_count,
    ROUND(SUM(budget), 2) AS planned_budget,
    ROUND(AVG(budget), 2) AS average_campaign_budget
FROM `bright-gearbox-402817.marketing_analytics.raw_campaigns`
GROUP BY
    channel,
    objective
ORDER BY
    channel,
    campaign_count DESC;


-- 3. Overall advertising performance

SELECT
    MIN(spend_date) AS earliest_spend_date,
    MAX(spend_date) AS latest_spend_date,
    COUNT(DISTINCT spend_date) AS active_calendar_days,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    ROUND(SUM(spend), 2) AS total_spend,

    ROUND(
        SAFE_DIVIDE(SUM(clicks), SUM(impressions)) * 100,
        2
    ) AS overall_ctr_percent,

    ROUND(
        SAFE_DIVIDE(SUM(spend), SUM(clicks)),
        2
    ) AS overall_cpc,

    ROUND(
        SAFE_DIVIDE(SUM(spend), SUM(impressions)) * 1000,
        2
    ) AS overall_cpm

FROM `bright-gearbox-402817.marketing_analytics.raw_daily_spend`;


-- 4. Lead profile by source

SELECT
    lead_source,
    COUNT(*) AS total_leads,
    ROUND(AVG(lead_score), 2) AS average_lead_score,
    MIN(created_at) AS earliest_lead_date,
    MAX(created_at) AS latest_lead_date
FROM `bright-gearbox-402817.marketing_analytics.raw_leads`
GROUP BY lead_source
ORDER BY total_leads DESC;


-- 5. Conversion profile by type

SELECT
    conversion_type,
    COUNT(*) AS total_conversions,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS average_revenue,
    MIN(converted_at) AS earliest_conversion_date,
    MAX(converted_at) AS latest_conversion_date
FROM `bright-gearbox-402817.marketing_analytics.raw_conversions`
GROUP BY conversion_type
ORDER BY total_conversions DESC;


-- 6. Preliminary marketing funnel by channel
-- Each source is aggregated separately before the final joins.
-- This prevents duplicated budget, spend, leads, and revenue.

WITH campaign_summary AS (
    SELECT
        channel,
        COUNT(*) AS campaign_count,
        SUM(budget) AS planned_budget
    FROM `bright-gearbox-402817.marketing_analytics.raw_campaigns`
    GROUP BY channel
),

performance_summary AS (
    SELECT
        c.channel,
        SUM(d.impressions) AS impressions,
        SUM(d.clicks) AS clicks,
        SUM(d.spend) AS spend
    FROM `bright-gearbox-402817.marketing_analytics.raw_daily_spend` AS d
    JOIN `bright-gearbox-402817.marketing_analytics.raw_campaigns` AS c
        ON d.campaign_id = c.campaign_id
    GROUP BY c.channel
),

lead_summary AS (
    SELECT
        c.channel,
        COUNT(*) AS leads,
        AVG(l.lead_score) AS average_lead_score
    FROM `bright-gearbox-402817.marketing_analytics.raw_leads` AS l
    JOIN `bright-gearbox-402817.marketing_analytics.raw_campaigns` AS c
        ON l.campaign_id = c.campaign_id
    GROUP BY c.channel
),

conversion_summary AS (
    SELECT
        c.channel,
        COUNT(*) AS conversions,
        COUNTIF(LOWER(cv.conversion_type) = 'purchase')
            AS purchase_conversions,
        SUM(cv.revenue) AS revenue
    FROM `bright-gearbox-402817.marketing_analytics.raw_conversions` AS cv
    JOIN `bright-gearbox-402817.marketing_analytics.raw_leads` AS l
        ON cv.lead_id = l.lead_id
    JOIN `bright-gearbox-402817.marketing_analytics.raw_campaigns` AS c
        ON l.campaign_id = c.campaign_id
    GROUP BY c.channel
)

SELECT
    cs.channel,
    cs.campaign_count,
    ROUND(cs.planned_budget, 2) AS planned_budget,
    ps.impressions,
    ps.clicks,
    ROUND(ps.spend, 2) AS spend,
    ls.leads,
    ROUND(ls.average_lead_score, 2) AS average_lead_score,
    cvs.conversions,
    cvs.purchase_conversions,
    ROUND(cvs.revenue, 2) AS revenue,

    ROUND(
        SAFE_DIVIDE(ps.clicks, ps.impressions) * 100,
        2
    ) AS ctr_percent,

    ROUND(
        SAFE_DIVIDE(ps.spend, ps.clicks),
        2
    ) AS cpc,

    ROUND(
        SAFE_DIVIDE(ls.leads, ps.clicks) * 100,
        2
    ) AS click_to_lead_rate_percent,

    ROUND(
        SAFE_DIVIDE(cvs.conversions, ls.leads) * 100,
        2
    ) AS lead_to_conversion_rate_percent,

    ROUND(
        SAFE_DIVIDE(ps.spend, cvs.conversions),
        2
    ) AS cost_per_conversion,

    ROUND(
        SAFE_DIVIDE(ps.spend, cvs.purchase_conversions),
        2
    ) AS cost_per_purchase,

    ROUND(
        SAFE_DIVIDE(cvs.revenue, ps.spend),
        2
    ) AS roas

FROM campaign_summary AS cs
LEFT JOIN performance_summary AS ps
    USING (channel)
LEFT JOIN lead_summary AS ls
    USING (channel)
LEFT JOIN conversion_summary AS cvs
    USING (channel)
ORDER BY roas DESC;
