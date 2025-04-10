LOAD DATA
INFILE '/opt/oracle/cleaned_data/financial_data/advisor_data.csv'
INTO TABLE advisor_data
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    advisor_id,
    name,
    client_count,
    total_aum,
    start_date,
    client_retention_rate,
    client_satisfaction_score,
    new_client_acquisition
) 