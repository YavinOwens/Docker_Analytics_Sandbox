SET LINESIZE 150
SET PAGESIZE 50

SELECT COUNT(*) as total_assets,
       COUNT(DISTINCT asset_type) as unique_asset_types,
       MIN(installation_date) as earliest_installation,
       MAX(installation_date) as latest_installation
FROM water_utility_assets;

SELECT asset_id, asset_type, status, installation_date, last_maintenance_date, next_maintenance_date
FROM water_utility_assets; 