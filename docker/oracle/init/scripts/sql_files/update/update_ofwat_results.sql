-- Create required tables if they don't exist
DECLARE
    v_table_exists NUMBER;
BEGIN
    -- Check ofwat_results table
    SELECT COUNT(*) INTO v_table_exists
    FROM user_tables
    WHERE table_name = 'OFWAT_RESULTS';
    
    IF v_table_exists = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE ofwat_results (
            quarter VARCHAR2(10),
            year NUMBER,
            quarter_number NUMBER,
            water_quality_score NUMBER,
            customer_service_score NUMBER,
            leakage_reduction_score NUMBER,
            water_efficiency_score NUMBER,
            environmental_impact_score NUMBER,
            operational_efficiency_score NUMBER,
            overall_performance_score NUMBER,
            performance_rating VARCHAR2(50),
            key_achievements CLOB,
            areas_for_improvement CLOB,
            regulatory_compliance VARCHAR2(20),
            financial_incentives_earned NUMBER,
            CONSTRAINT pk_ofwat_results PRIMARY KEY (year, quarter_number),
            CONSTRAINT chk_ofwat_rating CHECK (performance_rating IN (''Good'', ''Poor'', ''Requires Improvement'', ''Outstanding''))
        )';
    END IF;
    
    -- Check industrial_performance table
    SELECT COUNT(*) INTO v_table_exists
    FROM user_tables
    WHERE table_name = 'INDUSTRIAL_PERFORMANCE';
    
    IF v_table_exists = 0 THEN
        -- Create industrial_performance table if it doesn't exist
        EXECUTE IMMEDIATE 'CREATE TABLE industrial_performance (
            performance_id VARCHAR2(50) PRIMARY KEY,
            device_id VARCHAR2(50),
            metric_name VARCHAR2(50),
            metric_value NUMBER,
            measurement_date DATE,
            measurement_time TIMESTAMP,
            unit VARCHAR2(20),
            status VARCHAR2(20),
            is_ofwat_metric CHAR(1) DEFAULT ''N'',
            FOREIGN KEY (device_id) REFERENCES industrial_iot_data(device_id)
        )';
        
        -- Insert sample performance data based on existing IoT data
        INSERT INTO industrial_performance (
            performance_id,
            device_id,
            metric_name,
            metric_value,
            measurement_date,
            measurement_time,
            unit,
            status,
            is_ofwat_metric
        )
        SELECT 
            'PERF' || LPAD(ROWNUM, 4, '0'),
            d.device_id,
            CASE MOD(ROWNUM, 4)
                WHEN 0 THEN 'Water Quality Index'
                WHEN 1 THEN 'Turbidity'
                WHEN 2 THEN 'pH'
                WHEN 3 THEN 'Water Flow Rate'
            END,
            CASE MOD(ROWNUM, 4)
                WHEN 0 THEN ROUND(DBMS_RANDOM.VALUE(70, 100), 2)
                WHEN 1 THEN ROUND(DBMS_RANDOM.VALUE(0, 5), 2)
                WHEN 2 THEN ROUND(DBMS_RANDOM.VALUE(6, 10), 2)
                WHEN 3 THEN ROUND(DBMS_RANDOM.VALUE(50, 150), 2)
            END,
            TRUNC(SYSDATE),
            SYSTIMESTAMP,
            CASE MOD(ROWNUM, 4)
                WHEN 0 THEN 'WQI'
                WHEN 1 THEN 'NTU'
                WHEN 2 THEN 'pH'
                WHEN 3 THEN 'GPM'
            END,
            'ACTIVE',
            CASE 
                WHEN MOD(ROWNUM, 4) IN (0, 1, 2) THEN 'Y'
                ELSE 'N'
            END
        FROM industrial_iot_data d
        CROSS JOIN (SELECT LEVEL FROM dual CONNECT BY LEVEL <= 4);
        
        COMMIT;
    END IF;
END;
/

-- Delete existing Ofwat results for the current quarter
DELETE FROM ofwat_results 
WHERE year = EXTRACT(YEAR FROM SYSDATE) 
AND quarter_number = CEIL(EXTRACT(MONTH FROM SYSDATE) / 3);

-- Update Ofwat results based on current performance data
INSERT INTO ofwat_results (
    quarter,
    year,
    quarter_number,
    water_quality_score,
    customer_service_score,
    leakage_reduction_score,
    water_efficiency_score,
    environmental_impact_score,
    operational_efficiency_score,
    overall_performance_score,
    performance_rating,
    key_achievements,
    areas_for_improvement,
    regulatory_compliance,
    financial_incentives_earned
)
WITH performance_metrics AS (
    SELECT 
        EXTRACT(YEAR FROM SYSDATE) as year,
        CEIL(EXTRACT(MONTH FROM SYSDATE) / 3) as quarter_number,
        -- Water Quality Score (based on IoT sensor data)
        AVG(CASE 
            WHEN p.metric_name = 'Water Quality Index' THEN p.metric_value
            WHEN p.metric_name = 'Turbidity' THEN 100 - (p.metric_value * 25)
            WHEN p.metric_name = 'pH' THEN 
                CASE 
                    WHEN p.metric_value BETWEEN 6.5 AND 9.5 THEN 100
                    WHEN p.metric_value BETWEEN 6.0 AND 10.0 THEN 80
                    ELSE 60
                END
            ELSE NULL
        END) as water_quality_score,
        -- Leakage Reduction Score (based on flow meter data)
        AVG(CASE 
            WHEN p.metric_name = 'Water Flow Rate' THEN 
                CASE 
                    WHEN p.metric_value > 100 THEN 100
                    WHEN p.metric_value > 80 THEN 80
                    WHEN p.metric_value > 60 THEN 60
                    ELSE 40
                END
            ELSE NULL
        END) as leakage_reduction_score,
        -- Water Efficiency Score (based on pressure and flow data)
        AVG(CASE 
            WHEN p.metric_name = 'Water Flow Rate' THEN 
                CASE 
                    WHEN p.metric_value BETWEEN 50 AND 150 THEN 100
                    WHEN p.metric_value BETWEEN 30 AND 170 THEN 80
                    ELSE 60
                END
            ELSE NULL
        END) as water_efficiency_score,
        -- Environmental Impact Score (based on water quality and efficiency)
        AVG(CASE 
            WHEN p.metric_name IN ('Water Quality Index', 'Turbidity', 'pH') THEN 100
            WHEN p.metric_name = 'Water Flow Rate' AND p.metric_value <= 100 THEN 80
            ELSE 60
        END) as environmental_impact_score,
        -- Operational Efficiency Score (based on maintenance and safety records)
        AVG(CASE 
            WHEN m.status = 'COMPLETED' THEN 100
            WHEN m.status = 'IN_PROGRESS' THEN 80
            WHEN m.status = 'SCHEDULED' THEN 60
            ELSE 40
        END) as operational_efficiency_score
    FROM industrial_iot_data d
    JOIN industrial_performance p ON d.device_id = p.device_id
    LEFT JOIN industrial_maintenance m ON d.device_id = m.device_id
    WHERE p.measurement_time >= SYSTIMESTAMP - INTERVAL '3' MONTH
    GROUP BY 
        EXTRACT(YEAR FROM SYSDATE),
        CEIL(EXTRACT(MONTH FROM SYSDATE) / 3)
),
customer_service_metrics AS (
    SELECT 
        AVG(CASE 
            WHEN w.status = 'Completed' THEN 100
            WHEN w.status = 'In Progress' THEN 80
            WHEN w.status = 'Assigned' THEN 60
            ELSE 40
        END) as customer_service_score
    FROM water_utilities_work_orders w
    WHERE w.creation_date >= TO_CHAR(SYSDATE - INTERVAL '3' MONTH, 'YYYY-MM-DD')
)
SELECT 
    CASE 
        WHEN pm.quarter_number = 1 THEN 'Q1'
        WHEN pm.quarter_number = 2 THEN 'Q2'
        WHEN pm.quarter_number = 3 THEN 'Q3'
        ELSE 'Q4'
    END as quarter,
    pm.year,
    pm.quarter_number,
    ROUND(pm.water_quality_score, 2) as water_quality_score,
    ROUND(cs.customer_service_score, 2) as customer_service_score,
    ROUND(pm.leakage_reduction_score, 2) as leakage_reduction_score,
    ROUND(pm.water_efficiency_score, 2) as water_efficiency_score,
    ROUND(pm.environmental_impact_score, 2) as environmental_impact_score,
    ROUND(pm.operational_efficiency_score, 2) as operational_efficiency_score,
    ROUND(
        (pm.water_quality_score + cs.customer_service_score + 
         pm.leakage_reduction_score + pm.water_efficiency_score + 
         pm.environmental_impact_score + pm.operational_efficiency_score) / 6,
        2
    ) as overall_performance_score,
    CASE 
        WHEN (pm.water_quality_score + cs.customer_service_score + 
              pm.leakage_reduction_score + pm.water_efficiency_score + 
              pm.environmental_impact_score + pm.operational_efficiency_score) / 6 >= 90 THEN 'Outstanding'
        WHEN (pm.water_quality_score + cs.customer_service_score + 
              pm.leakage_reduction_score + pm.water_efficiency_score + 
              pm.environmental_impact_score + pm.operational_efficiency_score) / 6 >= 80 THEN 'Good'
        WHEN (pm.water_quality_score + cs.customer_service_score + 
              pm.leakage_reduction_score + pm.water_efficiency_score + 
              pm.environmental_impact_score + pm.operational_efficiency_score) / 6 >= 70 THEN 'Requires Improvement'
        ELSE 'Poor'
    END as performance_rating,
    'Key achievements for the quarter: ' || 
    CASE 
        WHEN pm.water_quality_score >= 90 THEN 'Excellent water quality maintained, '
        WHEN pm.water_quality_score >= 80 THEN 'Good water quality standards achieved, '
        ELSE 'Water quality needs improvement, '
    END ||
    CASE 
        WHEN pm.leakage_reduction_score >= 90 THEN 'significant leakage reduction achieved, '
        WHEN pm.leakage_reduction_score >= 80 THEN 'moderate leakage reduction achieved, '
        ELSE 'leakage reduction needs attention, '
    END ||
    CASE 
        WHEN cs.customer_service_score >= 90 THEN 'outstanding customer service delivery.'
        WHEN cs.customer_service_score >= 80 THEN 'good customer service performance.'
        ELSE 'customer service needs improvement.'
    END as key_achievements,
    'Areas for improvement: ' ||
    CASE 
        WHEN pm.water_quality_score < 80 THEN 'Water quality standards need enhancement, '
        ELSE ''
    END ||
    CASE 
        WHEN pm.leakage_reduction_score < 80 THEN 'Leakage reduction strategies need review, '
        ELSE ''
    END ||
    CASE 
        WHEN cs.customer_service_score < 80 THEN 'Customer service processes need optimization.'
        ELSE ''
    END as areas_for_improvement,
    CASE 
        WHEN (pm.water_quality_score + cs.customer_service_score + 
              pm.leakage_reduction_score + pm.water_efficiency_score + 
              pm.environmental_impact_score + pm.operational_efficiency_score) / 6 >= 80 THEN 'FULL'
        WHEN (pm.water_quality_score + cs.customer_service_score + 
              pm.leakage_reduction_score + pm.water_efficiency_score + 
              pm.environmental_impact_score + pm.operational_efficiency_score) / 6 >= 70 THEN 'PARTIAL'
        ELSE 'NON-COMPLIANT'
    END as regulatory_compliance,
    CASE 
        WHEN (pm.water_quality_score + cs.customer_service_score + 
              pm.leakage_reduction_score + pm.water_efficiency_score + 
              pm.environmental_impact_score + pm.operational_efficiency_score) / 6 >= 90 THEN 1000000
        WHEN (pm.water_quality_score + cs.customer_service_score + 
              pm.leakage_reduction_score + pm.water_efficiency_score + 
              pm.environmental_impact_score + pm.operational_efficiency_score) / 6 >= 80 THEN 500000
        WHEN (pm.water_quality_score + cs.customer_service_score + 
              pm.leakage_reduction_score + pm.water_efficiency_score + 
              pm.environmental_impact_score + pm.operational_efficiency_score) / 6 >= 70 THEN 250000
        ELSE 0
    END as financial_incentives_earned
FROM performance_metrics pm
CROSS JOIN customer_service_metrics cs;

-- Verify the update
SELECT * FROM ofwat_results 
WHERE year = EXTRACT(YEAR FROM SYSDATE) 
AND quarter_number = CEIL(EXTRACT(MONTH FROM SYSDATE) / 3)
ORDER BY year DESC, quarter_number DESC; 