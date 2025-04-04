CREATE TABLE sector_performance (
    sector_id VARCHAR2(50) PRIMARY KEY,
    sector_name VARCHAR2(100),
    market_cap NUMBER,
    daily_return NUMBER,
    weekly_return NUMBER,
    monthly_return NUMBER,
    year_to_date_return NUMBER,
    transaction_date DATE
); 