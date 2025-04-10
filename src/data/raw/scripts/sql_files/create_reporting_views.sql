-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format
SET LINESIZE 1000
SET PAGESIZE 1000

-- Drop existing views
DROP VIEW v_asset_maintenance_status;
DROP VIEW v_work_order_summary;
DROP VIEW v_ofwat_performance;
DROP VIEW v_capex_project_status;
DROP VIEW v_employee_performance;
DROP VIEW v_customer_satisfaction;
DROP VIEW v_employee_engagement;
DROP VIEW v_department_performance;

-- Asset Maintenance Status View
CREATE OR REPLACE VIEW v_asset_maintenance_status AS
SELECT 
    a.asset_id,
    a.asset_name,
    a.asset_type,
    a.location,
    a.status as asset_status,
    a.last_maintenance_date,
    a.next_maintenance_date,
    COUNT(wo.work_order_id) as total_work_orders,
    COUNT(CASE WHEN wo.status = 'OPEN' THEN 1 END) as open_work_orders,
    COUNT(CASE WHEN wo.status = 'IN_PROGRESS' THEN 1 END) as in_progress_work_orders,
    COUNT(CASE WHEN wo.status = 'COMPLETED' THEN 1 END) as completed_work_orders,
    ROUND(AVG(wo.actual_cost), 2) as avg_maintenance_cost
FROM water_utilities_assets a
LEFT JOIN water_utilities_work_orders wo ON a.asset_id = wo.asset_id
GROUP BY 
    a.asset_id, a.asset_name, a.asset_type, a.location, a.status,
    a.last_maintenance_date, a.next_maintenance_date;

-- Work Order Summary View
CREATE OR REPLACE VIEW v_work_order_summary AS
SELECT 
    wo.work_order_id,
    wo.description,
    wo.priority,
    wo.status,
    wo.created_date,
    wo.completed_date,
    a.asset_name,
    a.asset_type,
    e.first_name || ' ' || e.last_name as assigned_to_name,
    wo.estimated_cost,
    wo.actual_cost,
    CASE 
        WHEN wo.actual_cost > wo.estimated_cost THEN 'OVER_BUDGET'
        WHEN wo.actual_cost < wo.estimated_cost THEN 'UNDER_BUDGET'
        ELSE 'ON_BUDGET'
    END as budget_status
FROM water_utilities_work_orders wo
JOIN water_utilities_assets a ON wo.asset_id = a.asset_id
JOIN employees e ON wo.assigned_to = e.employee_id;

-- Ofwat Performance View
CREATE OR REPLACE VIEW v_ofwat_performance AS
SELECT 
    result_id,
    metric_name,
    target_value,
    actual_value,
    measurement_date,
    status,
    ROUND((actual_value - target_value) / NULLIF(target_value, 0) * 100, 2) as performance_variance,
    CASE 
        WHEN actual_value >= target_value THEN 'MET'
        ELSE 'NOT_MET'
    END as target_status
FROM ofwat_results;

-- CAPEX Project Status View
CREATE OR REPLACE VIEW v_capex_project_status AS
SELECT 
    p.project_id,
    p.project_name,
    p.status,
    p.start_date,
    p.end_date,
    p.budget_amount,
    p.spent_amount,
    e.first_name || ' ' || e.last_name as project_manager_name,
    ROUND(p.spent_amount / NULLIF(p.budget_amount, 0) * 100, 2) as budget_utilization,
    CASE 
        WHEN p.spent_amount > p.budget_amount THEN 'OVER_BUDGET'
        WHEN p.spent_amount < p.budget_amount THEN 'UNDER_BUDGET'
        ELSE 'ON_BUDGET'
    END as budget_status
FROM capex_projects p
JOIN employees e ON p.project_manager = e.employee_id;

-- Employee Performance View
CREATE OR REPLACE VIEW v_employee_performance AS
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name as employee_name,
    e.department,
    e.position,
    e.status as employee_status,
    pr.review_date,
    pr.overall_rating,
    m.first_name || ' ' || m.last_name as reviewer_name,
    pr.goals_achieved,
    pr.areas_for_improvement
FROM employees e
LEFT JOIN performance_reviews pr ON e.employee_id = pr.employee_id
LEFT JOIN employees m ON pr.reviewer_id = m.employee_id;

-- Customer Satisfaction View
CREATE OR REPLACE VIEW v_customer_satisfaction AS
SELECT 
    survey_id,
    response_date,
    score,
    comments,
    ROUND(AVG(score) OVER (ORDER BY response_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 2) as rolling_30_day_avg
FROM pulse_surveys
WHERE survey_type = 'CUSTOMER_SATISFACTION';

-- Employee Engagement View
CREATE OR REPLACE VIEW v_employee_engagement AS
SELECT 
    survey_id,
    response_date,
    score,
    comments,
    e.department,
    ROUND(AVG(score) OVER (PARTITION BY e.department ORDER BY response_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 2) as dept_rolling_30_day_avg
FROM pulse_surveys ps
JOIN employees e ON ps.respondent_id = e.employee_id
WHERE survey_type = 'EMPLOYEE_ENGAGEMENT';

-- Department Performance View
CREATE OR REPLACE VIEW v_department_performance AS
SELECT 
    e.department,
    COUNT(DISTINCT e.employee_id) as total_employees,
    COUNT(DISTINCT CASE WHEN e.status = 'ACTIVE' THEN e.employee_id END) as active_employees,
    ROUND(AVG(pr.overall_rating), 2) as avg_performance_rating,
    ROUND(AVG(ps.score), 2) as avg_engagement_score,
    COUNT(DISTINCT CASE WHEN l.leave_type = 'SICK' THEN l.employee_id END) as employees_on_sick_leave
FROM employees e
LEFT JOIN performance_reviews pr ON e.employee_id = pr.employee_id
LEFT JOIN pulse_surveys ps ON e.employee_id = ps.respondent_id AND ps.survey_type = 'EMPLOYEE_ENGAGEMENT'
LEFT JOIN leave_records l ON e.employee_id = l.employee_id
GROUP BY e.department;

-- Grant select permissions on views
GRANT SELECT ON v_asset_maintenance_status TO PUBLIC;
GRANT SELECT ON v_work_order_summary TO PUBLIC;
GRANT SELECT ON v_ofwat_performance TO PUBLIC;
GRANT SELECT ON v_capex_project_status TO PUBLIC;
GRANT SELECT ON v_employee_performance TO PUBLIC;
GRANT SELECT ON v_customer_satisfaction TO PUBLIC;
GRANT SELECT ON v_employee_engagement TO PUBLIC;
GRANT SELECT ON v_department_performance TO PUBLIC;

-- Commit changes
COMMIT;

-- Exit SQL*Plus
EXIT; 