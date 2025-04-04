SELECT asset_type, COUNT(*) as count FROM water_utility_assets GROUP BY asset_type ORDER BY count DESC;
