-- Workforce Attendance Table
CREATE TABLE workforce_attendance (
    attendance_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    attendance_date DATE,
    check_in_time TIMESTAMP,
    check_out_time TIMESTAMP,
    status VARCHAR2(20),
    notes VARCHAR2(500)
);

-- Workforce Performance Table
CREATE TABLE workforce_performance (
    performance_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    review_date DATE,
    review_type VARCHAR2(50),
    rating NUMBER,
    feedback VARCHAR2(1000),
    goals_set VARCHAR2(1000),
    reviewed_by VARCHAR2(50)
);

-- Workforce Skills Table
CREATE TABLE workforce_skills (
    skill_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    skill_name VARCHAR2(100),
    proficiency_level VARCHAR2(20),
    certification_date DATE,
    expiry_date DATE,
    certified_by VARCHAR2(50)
);

-- Workforce Training Table
CREATE TABLE workforce_training (
    training_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    training_name VARCHAR2(100),
    training_type VARCHAR2(50),
    start_date DATE,
    end_date DATE,
    status VARCHAR2(20),
    completion_date DATE,
    trainer VARCHAR2(50)
);

-- Workforce Scheduling Table
CREATE TABLE workforce_scheduling (
    schedule_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    shift_date DATE,
    shift_type VARCHAR2(20),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    department VARCHAR2(50),
    status VARCHAR2(20)
);

-- Workforce Leave Table
CREATE TABLE workforce_leave (
    leave_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    leave_type VARCHAR2(50),
    start_date DATE,
    end_date DATE,
    status VARCHAR2(20),
    approved_by VARCHAR2(50),
    reason VARCHAR2(500)
); 