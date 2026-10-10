SELECT
    'raw_campaigns' AS table_name,
    COUNT(*) AS row_count
FROM `bright-gearbox-402817.marketing_analytics.raw_campaigns`

UNION ALL

SELECT
    'raw_daily_spend' AS table_name,
    COUNT(*) AS row_count
FROM `bright-gearbox-402817.marketing_analytics.raw_daily_spend`

UNION ALL

SELECT
    'raw_leads' AS table_name,
    COUNT(*) AS row_count
FROM `bright-gearbox-402817.marketing_analytics.raw_leads`

UNION ALL

SELECT
    'raw_conversions' AS table_name,
    COUNT(*) AS row_count
FROM `bright-gearbox-402817.marketing_analytics.raw_conversions`

ORDER BY table_name;
