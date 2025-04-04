-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Populate interest_rates table
INSERT INTO interest_rates (rate_id, rate_type, rate_value, transaction_date, effective_date, maturity_date, currency)
VALUES
('R001', 'LIBOR', 2.5, SYSDATE, SYSDATE, SYSDATE + 365, 'USD'),
('R002', 'LIBOR', 2.75, SYSDATE, SYSDATE, SYSDATE + 365, 'EUR'),
('R003', 'LIBOR', 2.25, SYSDATE, SYSDATE, SYSDATE + 365, 'GBP'),
('R004', 'LIBOR', 2.0, SYSDATE, SYSDATE, SYSDATE + 365, 'JPY');

-- Populate financial_statements table
INSERT INTO financial_statements (statement_date, statement_type, revenue, expenses, net_income)
VALUES
(SYSDATE - 30, 'Monthly', 1000000, 750000, 250000),
(SYSDATE - 60, 'Monthly', 950000, 700000, 250000),
(SYSDATE - 90, 'Monthly', 1050000, 800000, 250000);

-- Populate budgets table
INSERT INTO budgets (fiscal_year, department, allocated_amount, spent_amount, status)
VALUES
(2024, 'IT', 500000, 150000, 'ACTIVE'),
(2024, 'HR', 300000, 100000, 'ACTIVE'),
(2024, 'Operations', 1000000, 400000, 'ACTIVE'),
(2024, 'Marketing', 400000, 150000, 'ACTIVE');

-- Populate cash_flow table
INSERT INTO cash_flow (transaction_date, transaction_type, amount, category, description)
VALUES
(SYSDATE, 'INCOME', 50000, 'Sales', 'Monthly sales revenue'),
(SYSDATE, 'EXPENSE', 30000, 'Salaries', 'Monthly payroll'),
(SYSDATE, 'EXPENSE', 10000, 'Utilities', 'Monthly utilities'),
(SYSDATE, 'INCOME', 20000, 'Investments', 'Investment returns');

-- Populate sector_performance table
INSERT INTO sector_performance (sector_name, performance_date, performance_metric, value)
VALUES
('Technology', SYSDATE, 'Growth Rate', 5.2),
('Healthcare', SYSDATE, 'Growth Rate', 4.8),
('Finance', SYSDATE, 'Growth Rate', 3.9),
('Energy', SYSDATE, 'Growth Rate', 4.1);

-- Populate trading_activity table
INSERT INTO trading_activity (transaction_id, transaction_date, asset_type, quantity, price, transaction_type)
VALUES
('T001', SYSDATE, 'STOCK', 100, 50.25, 'BUY'),
('T002', SYSDATE, 'BOND', 50, 1000.00, 'SELL'),
('T003', SYSDATE, 'STOCK', 200, 75.50, 'BUY'),
('T004', SYSDATE, 'BOND', 30, 950.00, 'BUY');

-- Populate industrial_iot_data table
INSERT INTO industrial_iot_data (device_id, timestamp, temperature, pressure, humidity, status)
VALUES
('DEV001', SYSTIMESTAMP, 25.5, 101.3, 45.0, 'ACTIVE'),
('DEV002', SYSTIMESTAMP, 26.0, 101.5, 46.0, 'ACTIVE'),
('DEV003', SYSTIMESTAMP, 24.5, 101.2, 44.0, 'ACTIVE'),
('DEV004', SYSTIMESTAMP, 25.0, 101.4, 45.5, 'ACTIVE');

-- Populate industrial_maintenance table
INSERT INTO industrial_maintenance (maintenance_id, device_id, maintenance_date, maintenance_type, status, description)
VALUES
('M001', 'DEV001', SYSDATE, 'PREVENTIVE', 'COMPLETED', 'Regular maintenance check'),
('M002', 'DEV002', SYSDATE, 'CORRECTIVE', 'IN_PROGRESS', 'Pressure sensor replacement'),
('M003', 'DEV003', SYSDATE, 'PREVENTIVE', 'SCHEDULED', 'Annual maintenance'),
('M004', 'DEV004', SYSDATE, 'CORRECTIVE', 'COMPLETED', 'Temperature sensor calibration');

-- Populate industrial_performance table
INSERT INTO industrial_performance (performance_id, device_id, timestamp, efficiency, output, quality_score)
VALUES
('P001', 'DEV001', SYSTIMESTAMP, 95.5, 1000, 98.5),
('P002', 'DEV002', SYSTIMESTAMP, 94.8, 950, 97.8),
('P003', 'DEV003', SYSTIMESTAMP, 96.2, 1050, 99.0),
('P004', 'DEV004', SYSTIMESTAMP, 95.8, 980, 98.2);

-- Populate industrial_safety table
INSERT INTO industrial_safety (safety_id, device_id, timestamp, safety_score, incident_count, risk_level)
VALUES
('S001', 'DEV001', SYSTIMESTAMP, 98.5, 0, 'LOW'),
('S002', 'DEV002', SYSTIMESTAMP, 97.8, 1, 'LOW'),
('S003', 'DEV003', SYSTIMESTAMP, 99.0, 0, 'LOW'),
('S004', 'DEV004', SYSTIMESTAMP, 98.2, 0, 'LOW');

-- Populate employees table
INSERT INTO employees (employee_id, first_name, last_name, email, phone, hire_date, department, position, status)
VALUES
('EMP001', 'John', 'Doe', 'john.doe@company.com', '555-0001', SYSDATE - 365, 'IT', 'Developer', 'ACTIVE'),
('EMP002', 'Jane', 'Smith', 'jane.smith@company.com', '555-0002', SYSDATE - 730, 'HR', 'Manager', 'ACTIVE'),
('EMP003', 'Mike', 'Johnson', 'mike.johnson@company.com', '555-0003', SYSDATE - 1095, 'Operations', 'Director', 'ACTIVE'),
('EMP004', 'Sarah', 'Williams', 'sarah.williams@company.com', '555-0004', SYSDATE - 730, 'Marketing', 'Manager', 'ACTIVE');

-- Populate employee_salary table
INSERT INTO employee_salary (salary_id, employee_id, salary_amount, effective_date, end_date, salary_type, currency)
VALUES
('SAL001', 'EMP001', 75000, SYSDATE - 365, NULL, 'FULL_TIME', 'USD'),
('SAL002', 'EMP002', 90000, SYSDATE - 730, NULL, 'FULL_TIME', 'USD'),
('SAL003', 'EMP003', 120000, SYSDATE - 1095, NULL, 'FULL_TIME', 'USD'),
('SAL004', 'EMP004', 85000, SYSDATE - 730, NULL, 'FULL_TIME', 'USD');

-- Populate employee_benefits table
INSERT INTO employee_benefits (benefit_id, employee_id, benefit_type, benefit_description, start_date, end_date, status)
VALUES
('BEN001', 'EMP001', 'HEALTH', 'Health Insurance', SYSDATE - 365, NULL, 'ACTIVE'),
('BEN002', 'EMP002', 'HEALTH', 'Health Insurance', SYSDATE - 730, NULL, 'ACTIVE'),
('BEN003', 'EMP003', 'HEALTH', 'Health Insurance', SYSDATE - 1095, NULL, 'ACTIVE'),
('BEN004', 'EMP004', 'HEALTH', 'Health Insurance', SYSDATE - 730, NULL, 'ACTIVE');

-- Populate employee_attendance table
INSERT INTO employee_attendance (attendance_id, employee_id, attendance_date, check_in, check_out, status, notes)
VALUES
('ATT001', 'EMP001', SYSDATE, SYSDATE - 8, SYSDATE, 'PRESENT', 'Regular attendance'),
('ATT002', 'EMP002', SYSDATE, SYSDATE - 8, SYSDATE, 'PRESENT', 'Regular attendance'),
('ATT003', 'EMP003', SYSDATE, SYSDATE - 8, SYSDATE, 'PRESENT', 'Regular attendance'),
('ATT004', 'EMP004', SYSDATE, SYSDATE - 8, SYSDATE, 'PRESENT', 'Regular attendance');

-- Populate employee_performance table
INSERT INTO employee_performance (performance_id, employee_id, review_date, reviewer_id, rating, comments, goals_achieved, improvement_areas, next_review_date)
VALUES
('PERF001', 'EMP001', SYSDATE - 30, 'EMP003', 4.5, 'Excellent performance', 'All goals met', 'None', SYSDATE + 335),
('PERF002', 'EMP002', SYSDATE - 30, 'EMP003', 4.2, 'Good performance', 'Most goals met', 'Leadership skills', SYSDATE + 335),
('PERF003', 'EMP003', SYSDATE - 30, 'EMP002', 4.8, 'Outstanding performance', 'All goals exceeded', 'None', SYSDATE + 335),
('PERF004', 'EMP004', SYSDATE - 30, 'EMP003', 4.0, 'Good performance', 'Goals met', 'Communication skills', SYSDATE + 335);

-- Populate water_utilities_assets table
INSERT INTO water_utilities_assets (asset_id, name, type, category, manufacturer, model_number, serial_number, installation_date, expected_lifetime_hours, expected_lifetime_years, purchase_cost, replacement_cost, warranty_expiration, maintenance_interval, standards, failure_modes, condition_score, criticality_rating, operational_status, firmware_version, parent_asset_id, location)
VALUES
('ASSET001', 'Water Pump 1', 'PUMP', 'PRIMARY', 'WaterTech', 'WP-1000', 'SN001', '2023-01-01', 8760, 1, 50000, 55000, '2024-01-01', 720, 'ISO 9001', 'Mechanical failure', 95, 1, 'ACTIVE', 'v1.0', NULL, 'Main Plant'),
('ASSET002', 'Water Tank 1', 'TANK', 'STORAGE', 'WaterTech', 'WT-2000', 'SN002', '2023-02-01', 8760, 1, 100000, 110000, '2024-02-01', 720, 'ISO 9001', 'Corrosion', 98, 1, 'ACTIVE', 'v1.0', NULL, 'Main Plant');

-- Populate water_utilities_work_orders table
INSERT INTO water_utilities_work_orders (work_order_id, asset_id, type, priority, status, problem_description, assigned_technician, required_certifications, creation_date, estimated_hours, actual_hours, parts_used, downtime_hours, safety_permits, completion_status, completion_date)
VALUES
('WO001', 'ASSET001', 'MAINTENANCE', 1, 'COMPLETED', 'Regular maintenance', 'EMP001', 'Safety Certification', '2024-01-01', 4, 4, 'None', 0, 'Safety Permit 001', 'COMPLETED', '2024-01-01'),
('WO002', 'ASSET002', 'INSPECTION', 2, 'IN_PROGRESS', 'Annual inspection', 'EMP002', 'Safety Certification', '2024-01-02', 2, NULL, 'None', NULL, 'Safety Permit 002', 'IN_PROGRESS', NULL);

-- Populate ofwat_results table
INSERT INTO ofwat_results (quarter, year, quarter_number, water_quality_score, customer_service_score, leakage_reduction_score, water_efficiency_score, environmental_impact_score, operational_efficiency_score, overall_performance_score, performance_rating, key_achievements, areas_for_improvement, regulatory_compliance, financial_incentives_earned)
VALUES
('Q1', 2024, 1, 95, 90, 85, 88, 92, 87, 89, 'Good', 'Improved water quality', 'Leakage reduction', 'COMPLIANT', 100000),
('Q2', 2024, 2, 96, 91, 86, 89, 93, 88, 90, 'Good', 'Enhanced customer service', 'Water efficiency', 'COMPLIANT', 110000);

-- Populate capex_projects table
INSERT INTO capex_projects (project_id, project_name, project_type, start_date, planned_end_date, actual_end_date, base_budget, contingency_budget, total_budget, actual_cost, progress_percentage, status, priority, risk_level, benefits_realized, key_milestones, stakeholders)
VALUES
('PROJ001', 'Water Treatment Upgrade', 'INFRASTRUCTURE', '2024-01-01', '2024-12-31', NULL, 1000000, 100000, 1100000, 300000, 30, 'IN_PROGRESS', 'HIGH', 'MEDIUM', 'Improved efficiency', 'Phase 1 complete', 'Management, Operations'),
('PROJ002', 'Distribution Network Expansion', 'INFRASTRUCTURE', '2024-02-01', '2025-01-31', NULL, 2000000, 200000, 2200000, 0, 0, 'IN_PROGRESS', 'HIGH', 'HIGH', 'Increased capacity', 'Planning phase', 'Management, Operations');

-- Populate pulse_surveys table
INSERT INTO pulse_surveys (survey_id, survey_date, department, response_rate, engagement_score, satisfaction_score, wellbeing_score, culture_score, leadership_score, development_score, work_life_balance_score, recognition_score, overall_score, key_findings, action_items, employee_feedback)
VALUES
('SURV001', '2024-01-01', 'IT', 85, 0.85, 0.82, 0.88, 0.86, 0.84, 0.83, 0.87, 0.85, 0.85, 'High engagement', 'Improve communication', 'Positive feedback'),
('SURV002', '2024-01-01', 'HR', 90, 0.88, 0.85, 0.90, 0.87, 0.86, 0.85, 0.89, 0.87, 0.87, 'Strong culture', 'Enhance development', 'Very positive');

-- Populate utility_employees table
INSERT INTO utility_employees (employee_id, first_name, last_name, email, phone, department, role, hire_date, employment_status, salary, bonus_target, certifications, skills, location, manager_id, emergency_contact)
VALUES
('UEMP001', 'Tom', 'Wilson', 'tom.wilson@utility.com', '555-1001', 'Operations', 'Operator', '2023-01-01', 'Active', 65000, 5000, 'Safety Certification', 'Water Treatment', 'Main Plant', 'UEMP003', 'Emergency Contact 1'),
('UEMP002', 'Lisa', 'Brown', 'lisa.brown@utility.com', '555-1002', 'Maintenance', 'Technician', '2023-02-01', 'Active', 70000, 6000, 'Maintenance Certification', 'Equipment Repair', 'Main Plant', 'UEMP003', 'Emergency Contact 2'),
('UEMP003', 'David', 'Miller', 'david.miller@utility.com', '555-1003', 'Management', 'Manager', '2022-01-01', 'Active', 90000, 10000, 'Management Certification', 'Leadership', 'Main Plant', NULL, 'Emergency Contact 3');

-- Populate performance_reviews table
INSERT INTO performance_reviews (review_id, employee_id, review_date, reviewer_id, overall_rating, technical_skills, communication, leadership, safety_compliance, attendance, bonus_awarded, bonus_amount, comments, goals_set)
VALUES
('PREV001', 'UEMP001', '2024-01-01', 'UEMP003', 4.5, 4.5, 4.0, 3.5, 5.0, 5.0, 1, 5000, 'Excellent performance', 'Technical training'),
('PREV002', 'UEMP002', '2024-01-01', 'UEMP003', 4.2, 4.0, 4.5, 4.0, 4.5, 4.5, 1, 6000, 'Good performance', 'Leadership development');

-- Populate leave_records table
INSERT INTO leave_records (leave_id, employee_id, leave_type, start_date, end_date, status, reason, approved_by)
VALUES
('LEAVE001', 'UEMP001', 'Vacation', '2024-02-01', '2024-02-05', 'Approved', 'Family vacation', 'UEMP003'),
('LEAVE002', 'UEMP002', 'Sick Leave', '2024-01-15', '2024-01-16', 'Approved', 'Medical appointment', 'UEMP003');

-- Populate training_records table
INSERT INTO training_records (training_id, employee_id, training_type, provider, start_date, end_date, status, score, certification_earned, cost)
VALUES
('TRAIN001', 'UEMP001', 'Safety', 'Safety Institute', '2024-01-01', '2024-01-02', 'Completed', 95, 1, 1000),
('TRAIN002', 'UEMP002', 'Technical', 'Technical Institute', '2024-01-15', '2024-01-16', 'Completed', 90, 1, 1500);

-- Populate advisor_data table
INSERT INTO advisor_data (advisor_id, name, client_count, total_aum, start_date, client_retention_rate, client_satisfaction_score, new_client_acquisition)
VALUES
('ADV001', 'John Smith', 100, 10000000, '2023-01-01', 95, 4.5, 10),
('ADV002', 'Jane Doe', 150, 15000000, '2023-01-01', 98, 4.8, 15);

-- Populate investment_products table
INSERT INTO investment_products (product_id, product_name, product_type, risk_level, min_investment, management_fee, performance_fee, inception_date, status)
VALUES
('PROD001', 'Growth Fund', 'MUTUAL_FUND', 'HIGH', 10000, 0.02, 0.20, '2023-01-01', 'Active'),
('PROD002', 'Income Fund', 'MUTUAL_FUND', 'LOW', 5000, 0.01, 0.10, '2023-01-01', 'Active');

-- Populate client_portfolios table
INSERT INTO client_portfolios (portfolio_id, client_id, product_id, transaction_date, quantity, value)
VALUES
('PORT001', 'CLT001', 'PROD001', '2024-01-01', 100, 10000),
('PORT002', 'CLT002', 'PROD002', '2024-01-01', 200, 10000);

-- Populate cash_flow table
INSERT INTO cash_flow (transaction_id, transaction_date, category, amount, description, status)
VALUES
('CF001', '2024-01-01', 'INCOME', 50000, 'Client fees', 'Completed'),
('CF002', '2024-01-01', 'EXPENSE', 30000, 'Operating costs', 'Completed');

-- Populate budgets table
INSERT INTO budgets (budget_id, department, fiscal_year, allocated_amount, spent_amount, remaining_amount, status)
VALUES
('BUD001', 'Operations', 2024, 1000000, 300000, 700000, 'Active'),
('BUD002', 'Marketing', 2024, 500000, 150000, 350000, 'Active');

-- Populate financial_statements table
INSERT INTO financial_statements (statement_id, statement_type, transaction_date, period, revenue, expenses, net_income, assets, liabilities, equity)
VALUES
('FS001', 'Income Statement', '2024-01-01', 'Q1', 1000000, 800000, 200000, 5000000, 3000000, 2000000),
('FS002', 'Balance Sheet', '2024-01-01', 'Q1', NULL, NULL, NULL, 5000000, 3000000, 2000000);

-- Commit the transaction
COMMIT;

-- Verify the data
SELECT 'interest_rates' as table_name, COUNT(*) as row_count FROM interest_rates UNION ALL
SELECT 'financial_statements', COUNT(*) FROM financial_statements UNION ALL
SELECT 'budgets', COUNT(*) FROM budgets UNION ALL
SELECT 'cash_flow', COUNT(*) FROM cash_flow UNION ALL
SELECT 'sector_performance', COUNT(*) FROM sector_performance UNION ALL
SELECT 'trading_activity', COUNT(*) FROM trading_activity UNION ALL
SELECT 'industrial_iot_data', COUNT(*) FROM industrial_iot_data UNION ALL
SELECT 'industrial_maintenance', COUNT(*) FROM industrial_maintenance UNION ALL
SELECT 'industrial_performance', COUNT(*) FROM industrial_performance UNION ALL
SELECT 'industrial_safety', COUNT(*) FROM industrial_safety UNION ALL
SELECT 'employees', COUNT(*) FROM employees UNION ALL
SELECT 'employee_salary', COUNT(*) FROM employee_salary UNION ALL
SELECT 'employee_benefits', COUNT(*) FROM employee_benefits UNION ALL
SELECT 'employee_attendance', COUNT(*) FROM employee_attendance UNION ALL
SELECT 'employee_performance', COUNT(*) FROM employee_performance UNION ALL
SELECT 'water_utilities_assets', COUNT(*) FROM water_utilities_assets UNION ALL
SELECT 'water_utilities_work_orders', COUNT(*) FROM water_utilities_work_orders UNION ALL
SELECT 'ofwat_results', COUNT(*) FROM ofwat_results UNION ALL
SELECT 'capex_projects', COUNT(*) FROM capex_projects UNION ALL
SELECT 'pulse_surveys', COUNT(*) FROM pulse_surveys UNION ALL
SELECT 'utility_employees', COUNT(*) FROM utility_employees UNION ALL
SELECT 'performance_reviews', COUNT(*) FROM performance_reviews UNION ALL
SELECT 'leave_records', COUNT(*) FROM leave_records UNION ALL
SELECT 'training_records', COUNT(*) FROM training_records UNION ALL
SELECT 'advisor_data', COUNT(*) FROM advisor_data UNION ALL
SELECT 'investment_products', COUNT(*) FROM investment_products UNION ALL
SELECT 'client_portfolios', COUNT(*) FROM client_portfolios UNION ALL
SELECT 'cash_flow', COUNT(*) FROM cash_flow UNION ALL
SELECT 'budgets', COUNT(*) FROM budgets UNION ALL
SELECT 'financial_statements', COUNT(*) FROM financial_statements
ORDER BY table_name;
