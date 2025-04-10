OPTIONS (SKIP=1)
LOAD DATA
INFILE '/opt/oracle/transformed_data/financial_data/client_portfolios.csv'
REPLACE
INTO TABLE client_portfolios
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    portfolio_id,
    client_id,
    product_id,
    transaction_date DATE "YYYY-MM-DD",
    quantity,
    value
) 