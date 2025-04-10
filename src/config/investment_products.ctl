LOAD DATA
INFILE '/opt/oracle/transformed_data/financial_data/investment_products.csv'
INTO TABLE investment_products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    product_id,
    product_name,
    product_type,
    risk_level,
    min_investment,
    management_fee,
    performance_fee,
    inception_date,
    status
) 