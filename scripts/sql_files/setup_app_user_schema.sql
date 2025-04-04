-- Connect as app_user
CONNECT app_user/app_password@//localhost:1521/FREEPDB1

-- Create tables
@create/create_interest_rates.sql
@create/create_financial_tables.sql
@create/create_industrial_tables.sql
@create/create_employees.sql
@create/create_other_tables.sql
@create/create_remaining_tables.sql
@create/create_reporting_views.sql
@create/create_sector_performance.sql
@create/create_trading_activity.sql
@create/create_workforce_tables.sql
@create/docker_create_water_utilities_tables.sql
@create/docker_create_water_utilities_calculations.sql
@create/docker_create_compliance_reports.sql

-- Verify tables were created
SELECT table_name, owner
FROM all_tables
WHERE owner = 'APP_USER'
ORDER BY table_name;
