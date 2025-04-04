LOAD DATA
INFILE 'pulse_surveys.csv'
INTO TABLE pulse_surveys
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    survey_id,
    survey_date DATE "YYYY-MM-DD",
    department,
    response_rate DECIMAL EXTERNAL,
    engagement_score DECIMAL EXTERNAL,
    satisfaction_score DECIMAL EXTERNAL,
    wellbeing_score DECIMAL EXTERNAL,
    culture_score DECIMAL EXTERNAL,
    leadership_score DECIMAL EXTERNAL,
    development_score DECIMAL EXTERNAL,
    work_life_balance_score DECIMAL EXTERNAL,
    recognition_score DECIMAL EXTERNAL,
    overall_score DECIMAL EXTERNAL,
    key_findings,
    action_items,
    employee_feedback
) 