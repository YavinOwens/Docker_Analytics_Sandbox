CREATE TABLE trading_activity (
    transaction_id VARCHAR2(50) PRIMARY KEY,
    transaction_date DATE,
    client_id VARCHAR2(50),
    product_id VARCHAR2(50),
    transaction_type VARCHAR2(20),
    share_quantity NUMBER,
    price_per_share NUMBER,
    total_value NUMBER,
    fee_amount NUMBER
); 