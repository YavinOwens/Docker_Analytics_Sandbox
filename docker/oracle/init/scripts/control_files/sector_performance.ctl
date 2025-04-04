OPTIONS (SKIP=1)
LOAD DATA
INFILE '/opt/oracle/sector_performance.csv'
REPLACE
INTO TABLE sector_performance
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    sector_id,
    sector_name,
    transaction_date,
    performance_score,
    market_cap,
    volume,
    volatility
) 