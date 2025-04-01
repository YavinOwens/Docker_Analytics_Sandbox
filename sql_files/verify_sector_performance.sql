SET LINESIZE 200
SET PAGESIZE 50

-- Summary statistics
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT sector_name) as unique_sectors,
    MIN(transaction_date) as earliest_date,
    MAX(transaction_date) as latest_date,
    ROUND(AVG(market_cap), 2) as avg_market_cap,
    ROUND(AVG(performance_score), 4) as avg_performance_score,
    ROUND(AVG(volume), 2) as avg_volume,
    ROUND(AVG(volatility), 4) as avg_volatility
FROM sector_performance;

-- Sector distribution and performance
SELECT 
    sector_name,
    COUNT(*) as record_count,
    ROUND(AVG(market_cap), 2) as avg_market_cap,
    ROUND(AVG(performance_score), 4) as avg_performance_score,
    ROUND(AVG(volume), 2) as avg_volume,
    ROUND(AVG(volatility), 4) as avg_volatility
FROM sector_performance
GROUP BY sector_name
ORDER BY avg_market_cap DESC; 