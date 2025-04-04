OPTIONS (SKIP=1)
LOAD DATA
INFILE '/opt/oracle/transformed_data/financial_data/trading_activity.csv'
REPLACE
INTO TABLE trading_activity
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    transaction_id,
    transaction_date,
    client_id,
    product_id,
    transaction_type,
    share_quantity,
    price_per_share,
    total_value,
    fee_amount
) 