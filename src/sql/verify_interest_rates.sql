SET LINESIZE 200
SET PAGESIZE 50

-- Summary statistics
SELECT 
    COUNT(*) as total_rates,
    COUNT(DISTINCT rate_type) as unique_rate_types,
    COUNT(DISTINCT currency) as unique_currencies,
    MIN(transaction_date) as earliest_date,
    MAX(transaction_date) as latest_date,
    ROUND(AVG(rate_value), 4) as avg_rate_value
FROM interest_rates;

-- Rate types distribution
SELECT 
    rate_type,
    COUNT(*) as count,
    ROUND(AVG(rate_value), 4) as avg_rate,
    MIN(rate_value) as min_rate,
    MAX(rate_value) as max_rate
FROM interest_rates
GROUP BY rate_type
ORDER BY count DESC; 