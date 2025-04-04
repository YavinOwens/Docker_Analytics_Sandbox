CREATE TABLE trading_activity (
    transaction_id VARCHAR2(50) PRIMARY KEY,
    transaction_date VARCHAR2(30),
    client_id VARCHAR2(50),
    product_id VARCHAR2(50),
    transaction_type VARCHAR2(20),
    share_quantity NUMBER,
    price_per_share NUMBER,
    total_value NUMBER,
    fee_amount NUMBER
);

CREATE TABLE interest_rates (
    transaction_date VARCHAR2(10) PRIMARY KEY,
    rate_type VARCHAR2(50),
    rate_value NUMBER,
    effective_date VARCHAR2(10),
    maturity_date VARCHAR2(10),
    currency VARCHAR2(3)
);

CREATE TABLE sector_performance (
    sector_id VARCHAR2(50) PRIMARY KEY,
    sector_name VARCHAR2(100),
    transaction_date VARCHAR2(10),
    performance_score NUMBER,
    market_cap NUMBER,
    volume NUMBER,
    volatility NUMBER
);

CREATE TABLE market_indices (
    index_id VARCHAR2(50) PRIMARY KEY,
    index_name VARCHAR2(100),
    transaction_date VARCHAR2(10),
    value NUMBER,
    change_percentage NUMBER,
    volume NUMBER
); 