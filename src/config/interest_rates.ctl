OPTIONS (SKIP=1)
LOAD DATA
INFILE '/opt/oracle/transformed_data/financial_data/interest_rates.csv'
REPLACE
INTO TABLE interest_rates
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    dummy FILLER,
    transaction_date,
    rate_value,
    rate_type,
    effective_date,
    maturity_date,
    currency
) 