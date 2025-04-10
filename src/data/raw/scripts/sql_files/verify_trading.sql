SET LINESIZE 200
SET PAGESIZE 50

-- Summary statistics
SELECT 
    COUNT(*) as total_transactions,
    COUNT(DISTINCT client_id) as unique_clients,
    COUNT(DISTINCT product_id) as unique_products,
    MIN(transaction_date) as earliest_date,
    MAX(transaction_date) as latest_date,
    ROUND(SUM(total_value), 2) as total_value,
    ROUND(SUM(fee_amount), 2) as total_fees
FROM trading_activity;

-- Transaction types distribution
SELECT 
    transaction_type,
    COUNT(*) as count,
    ROUND(AVG(share_quantity), 2) as avg_shares,
    ROUND(AVG(price_per_share), 2) as avg_price,
    ROUND(AVG(total_value), 2) as avg_value
FROM trading_activity
GROUP BY transaction_type
ORDER BY count DESC; 