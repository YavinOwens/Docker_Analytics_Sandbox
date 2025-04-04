CREATE TABLE interest_rates (
    rate_id VARCHAR2(50) PRIMARY KEY,
    rate_type VARCHAR2(50),
    rate_value NUMBER,
    transaction_date DATE,
    effective_date DATE,
    maturity_date DATE,
    currency VARCHAR2(3)
); 