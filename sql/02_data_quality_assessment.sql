-- ============================================================
-- Marketing Analytics Dashboard
-- Initial Data Quality Assessment
-- ============================================================


-- 1. Missing values and duplicate primary keys

SELECT
    'raw_campaigns' AS table_name,
    COUNT(*) AS total_rows,
    COUNTIF(NULLIF(TRIM(campaign_id), '') IS NULL)
        AS missing_primary_keys,
    COUNTIF(NULLIF(TRIM(campaign_id), '') IS NOT NULL)
        - COUNT(DISTINCT NULLIF(TRIM(campaign_id), ''))
        AS duplicate_primary_key_rows,
    COUNTIF(
        NULLIF(TRIM(campaign_id), '') IS NULL
        OR NULLIF(TRIM(campaign_name), '') IS NULL
        OR NULLIF(TRIM(channel), '') IS NULL
        OR NULLIF(TRIM(objective), '') IS NULL
        OR start_date IS NULL
        OR end_date IS NULL
        OR budget IS NULL
    ) AS rows_with_missing_required_values
FROM `bright-gearbox-402817.marketing_analytics.raw_campaigns`

UNION ALL

SELECT
    'raw_daily_spend',
    COUNT(*),
    COUNTIF(NULLIF(TRIM(spend_id), '') IS NULL),
    COUNTIF(NULLIF(TRIM(spend_id), '') IS NOT NULL)
        - COUNT(DISTINCT NULLIF(TRIM(spend_id), '')),
    COUNTIF(
        NULLIF(TRIM(spend_id), '') IS NULL
        OR NULLIF(TRIM(campaign_id), '') IS NULL
        OR spend_date IS NULL
        OR impressions IS NULL
        OR clicks IS NULL
        OR spend IS NULL
    )
FROM `bright-gearbox-402817.marketing_analytics.raw_daily_spend`

UNION ALL

SELECT
    'raw_leads',
    COUNT(*),
    COUNTIF(NULLIF(TRIM(lead_id), '') IS NULL),
    COUNTIF(NULLIF(TRIM(lead_id), '') IS NOT NULL)
        - COUNT(DISTINCT NULLIF(TRIM(lead_id), '')),
    COUNTIF(
        NULLIF(TRIM(lead_id), '') IS NULL
        OR NULLIF(TRIM(campaign_id), '') IS NULL
        OR created_at IS NULL
        OR NULLIF(TRIM(lead_source), '') IS NULL
        OR lead_score IS NULL
    )
FROM `bright-gearbox-402817.marketing_analytics.raw_leads`

UNION ALL

SELECT
    'raw_conversions',
    COUNT(*),
    COUNTIF(NULLIF(TRIM(conversion_id), '') IS NULL),
    COUNTIF(NULLIF(TRIM(conversion_id), '') IS NOT NULL)
        - COUNT(DISTINCT NULLIF(TRIM(conversion_id), '')),
    COUNTIF(
        NULLIF(TRIM(conversion_id), '') IS NULL
        OR NULLIF(TRIM(lead_id), '') IS NULL
        OR converted_at IS NULL
        OR NULLIF(TRIM(conversion_type), '') IS NULL
        OR revenue IS NULL
    )
FROM `bright-gearbox-402817.marketing_analytics.raw_conversions`

ORDER BY table_name;


-- 2. Foreign-key integrity

SELECT
    'daily_spend_without_campaign' AS check_name,
    COUNT(*) AS issue_count
FROM `bright-gearbox-402817.marketing_analytics.raw_daily_spend` AS d
LEFT JOIN `bright-gearbox-402817.marketing_analytics.raw_campaigns` AS c
    ON d.campaign_id = c.campaign_id
WHERE c.campaign_id IS NULL

UNION ALL

SELECT
    'leads_without_campaign',
    COUNT(*)
FROM `bright-gearbox-402817.marketing_analytics.raw_leads` AS l
LEFT JOIN `bright-gearbox-402817.marketing_analytics.raw_campaigns` AS c
    ON l.campaign_id = c.campaign_id
WHERE c.campaign_id IS NULL

UNION ALL

SELECT
    'conversions_without_lead',
    COUNT(*)
FROM `bright-gearbox-402817.marketing_analytics.raw_conversions` AS cv
LEFT JOIN `bright-gearbox-402817.marketing_analytics.raw_leads` AS l
    ON cv.lead_id = l.lead_id
WHERE l.lead_id IS NULL

ORDER BY check_name;


-- 3. Invalid numeric values and dates

SELECT
    'negative_campaign_budget' AS check_name,
    COUNTIF(budget < 0) AS issue_count
FROM `bright-gearbox-402817.marketing_analytics.raw_campaigns`

UNION ALL

SELECT
    'campaign_end_before_start',
    COUNTIF(end_date < start_date)
FROM `bright-gearbox-402817.marketing_analytics.raw_campaigns`

UNION ALL

SELECT
    'negative_daily_metrics',
    COUNTIF(impressions < 0 OR clicks < 0 OR spend < 0)
FROM `bright-gearbox-402817.marketing_analytics.raw_daily_spend`

UNION ALL

SELECT
    'clicks_greater_than_impressions',
    COUNTIF(clicks > impressions)
FROM `bright-gearbox-402817.marketing_analytics.raw_daily_spend`

UNION ALL

SELECT
    'lead_score_outside_1_to_100',
    COUNTIF(lead_score NOT BETWEEN 1 AND 100)
FROM `bright-gearbox-402817.marketing_analytics.raw_leads`

UNION ALL

SELECT
    'negative_conversion_revenue',
    COUNTIF(revenue < 0)
FROM `bright-gearbox-402817.marketing_analytics.raw_conversions`

ORDER BY check_name;


-- 4. Cross-table date and relationship checks

SELECT
    'daily_spend_outside_campaign_period' AS check_name,
    COUNT(*) AS issue_count
FROM `bright-gearbox-402817.marketing_analytics.raw_daily_spend` AS d
JOIN `bright-gearbox-402817.marketing_analytics.raw_campaigns` AS c
    ON d.campaign_id = c.campaign_id
WHERE d.spend_date < c.start_date
   OR d.spend_date > c.end_date

UNION ALL

SELECT
    'conversion_before_lead_creation',
    COUNT(*)
FROM `bright-gearbox-402817.marketing_analytics.raw_conversions` AS cv
JOIN `bright-gearbox-402817.marketing_analytics.raw_leads` AS l
    ON cv.lead_id = l.lead_id
WHERE cv.converted_at < l.created_at

UNION ALL

SELECT
    'multiple_conversions_per_lead',
    COUNT(*)
FROM (
    SELECT lead_id
    FROM `bright-gearbox-402817.marketing_analytics.raw_conversions`
    GROUP BY lead_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT
    'duplicate_campaign_date_combinations',
    COUNT(*)
FROM (
    SELECT campaign_id, spend_date
    FROM `bright-gearbox-402817.marketing_analytics.raw_daily_spend`
    GROUP BY campaign_id, spend_date
    HAVING COUNT(*) > 1
)

ORDER BY check_name;
