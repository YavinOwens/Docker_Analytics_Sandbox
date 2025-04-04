OPTIONS (SKIP=1)
LOAD DATA
INFILE '/opt/oracle/transformed_data/industrial_data/water_utilities_work_orders.csv'
REPLACE
INTO TABLE water_utilities_work_orders
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    work_order_id,
    asset_id,
    type,
    priority,
    status,
    problem_description,
    assigned_technician,
    required_certifications,
    creation_date DATE "YYYY-MM-DD",
    estimated_hours,
    actual_hours,
    parts_used,
    downtime_hours,
    safety_permits,
    completion_status,
    completion_date DATE "YYYY-MM-DD"
) 