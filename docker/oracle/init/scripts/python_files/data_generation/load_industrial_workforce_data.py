import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import uuid
import os

# Create output directory if it doesn't exist
os.makedirs('transformed_data/industrial_data', exist_ok=True)
os.makedirs('transformed_data/workforce_data', exist_ok=True)

# Industrial IoT Data
def generate_iot_data(num_devices=100):
    device_types = ['Sensor', 'Camera', 'Controller', 'Monitor', 'Actuator']
    locations = ['Factory Floor', 'Warehouse', 'Office', 'Outdoor', 'Lab']
    statuses = ['Active', 'Inactive', 'Maintenance', 'Error']
    
    data = {
        'device_id': [f'DEV_{str(uuid.uuid4())[:8]}' for _ in range(num_devices)],
        'device_name': [f'Device_{i+1}' for i in range(num_devices)],
        'device_type': np.random.choice(device_types, num_devices),
        'location': np.random.choice(locations, num_devices),
        'status': np.random.choice(statuses, num_devices),
        'last_reading': np.random.uniform(0, 100, num_devices),
        'reading_timestamp': [datetime.now() - timedelta(hours=np.random.randint(0, 24)) for _ in range(num_devices)],
        'battery_level': np.random.uniform(0, 100, num_devices),
        'signal_strength': np.random.uniform(0, 100, num_devices)
    }
    return pd.DataFrame(data)

# Industrial Maintenance
def generate_maintenance_data(device_ids, num_records=200):
    maintenance_types = ['Preventive', 'Corrective', 'Predictive', 'Emergency']
    statuses = ['Scheduled', 'In Progress', 'Completed', 'Cancelled']
    
    data = {
        'maintenance_id': [f'MAINT_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'device_id': np.random.choice(device_ids, num_records),
        'maintenance_type': np.random.choice(maintenance_types, num_records),
        'scheduled_date': [datetime.now().date() + timedelta(days=np.random.randint(-30, 30)) for _ in range(num_records)],
        'completed_date': [datetime.now().date() + timedelta(days=np.random.randint(-30, 30)) for _ in range(num_records)],
        'status': np.random.choice(statuses, num_records),
        'technician_id': [f'TECH_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'description': [f'Maintenance description {i+1}' for i in range(num_records)],
        'parts_replaced': [f'Parts {i+1}' for i in range(num_records)]
    }
    return pd.DataFrame(data)

# Industrial Performance
def generate_performance_data(device_ids, num_records=500):
    metric_names = ['Temperature', 'Pressure', 'Humidity', 'Flow Rate', 'Vibration']
    units = ['°C', 'PSI', '%', 'L/min', 'mm/s']
    statuses = ['Normal', 'Warning', 'Critical']
    
    data = {
        'performance_id': [f'PERF_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'device_id': np.random.choice(device_ids, num_records),
        'metric_name': np.random.choice(metric_names, num_records),
        'metric_value': np.random.uniform(0, 100, num_records),
        'measurement_date': [datetime.now().date() - timedelta(days=np.random.randint(0, 30)) for _ in range(num_records)],
        'measurement_time': [datetime.now() - timedelta(hours=np.random.randint(0, 24)) for _ in range(num_records)],
        'unit': np.random.choice(units, num_records),
        'status': np.random.choice(statuses, num_records)
    }
    return pd.DataFrame(data)

# Industrial Safety
def generate_safety_data(device_ids, num_records=100):
    incident_types = ['Malfunction', 'Alert', 'Warning', 'Emergency']
    severity_levels = ['Low', 'Medium', 'High', 'Critical']
    statuses = ['Open', 'In Progress', 'Resolved', 'Closed']
    
    data = {
        'safety_id': [f'SAFE_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'device_id': np.random.choice(device_ids, num_records),
        'incident_type': np.random.choice(incident_types, num_records),
        'incident_date': [datetime.now().date() - timedelta(days=np.random.randint(0, 30)) for _ in range(num_records)],
        'severity_level': np.random.choice(severity_levels, num_records),
        'description': [f'Safety incident description {i+1}' for i in range(num_records)],
        'action_taken': [f'Action taken {i+1}' for i in range(num_records)],
        'reported_by': [f'EMP_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'status': np.random.choice(statuses, num_records)
    }
    return pd.DataFrame(data)

# Workforce Attendance
def generate_attendance_data(num_records=1000):
    statuses = ['Present', 'Absent', 'Late', 'Early Departure']
    
    data = {
        'attendance_id': [f'ATT_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'employee_id': [f'EMP_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'attendance_date': [datetime.now().date() - timedelta(days=np.random.randint(0, 30)) for _ in range(num_records)],
        'check_in_time': [datetime.now() - timedelta(hours=np.random.randint(0, 24)) for _ in range(num_records)],
        'check_out_time': [datetime.now() - timedelta(hours=np.random.randint(0, 24)) for _ in range(num_records)],
        'status': np.random.choice(statuses, num_records),
        'notes': [f'Attendance note {i+1}' for i in range(num_records)]
    }
    return pd.DataFrame(data)

# Workforce Performance
def generate_workforce_performance_data(num_records=500):
    review_types = ['Annual', 'Quarterly', 'Monthly', 'Project']
    
    data = {
        'performance_id': [f'PERF_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'employee_id': [f'EMP_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'review_date': [datetime.now().date() - timedelta(days=np.random.randint(0, 365)) for _ in range(num_records)],
        'review_type': np.random.choice(review_types, num_records),
        'rating': np.random.uniform(1, 5, num_records),
        'feedback': [f'Performance feedback {i+1}' for i in range(num_records)],
        'goals_set': [f'Goals set {i+1}' for i in range(num_records)],
        'reviewed_by': [f'MGR_{str(uuid.uuid4())[:8]}' for _ in range(num_records)]
    }
    return pd.DataFrame(data)

# Workforce Skills
def generate_skills_data(num_records=800):
    skill_names = ['Programming', 'Data Analysis', 'Project Management', 'Communication', 'Technical Writing']
    proficiency_levels = ['Beginner', 'Intermediate', 'Advanced', 'Expert']
    
    data = {
        'skill_id': [f'SKILL_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'employee_id': [f'EMP_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'skill_name': np.random.choice(skill_names, num_records),
        'proficiency_level': np.random.choice(proficiency_levels, num_records),
        'certification_date': [datetime.now().date() - timedelta(days=np.random.randint(0, 365)) for _ in range(num_records)],
        'expiry_date': [datetime.now().date() + timedelta(days=np.random.randint(0, 365)) for _ in range(num_records)],
        'certified_by': [f'CERT_{str(uuid.uuid4())[:8]}' for _ in range(num_records)]
    }
    return pd.DataFrame(data)

# Workforce Training
def generate_training_data(num_records=300):
    training_types = ['Technical', 'Soft Skills', 'Safety', 'Compliance']
    statuses = ['Scheduled', 'In Progress', 'Completed', 'Cancelled']
    
    data = {
        'training_id': [f'TRAIN_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'employee_id': [f'EMP_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'training_name': [f'Training {i+1}' for i in range(num_records)],
        'training_type': np.random.choice(training_types, num_records),
        'start_date': [datetime.now().date() - timedelta(days=np.random.randint(0, 30)) for _ in range(num_records)],
        'end_date': [datetime.now().date() + timedelta(days=np.random.randint(0, 30)) for _ in range(num_records)],
        'status': np.random.choice(statuses, num_records),
        'completion_date': [datetime.now().date() + timedelta(days=np.random.randint(0, 30)) for _ in range(num_records)],
        'trainer': [f'TRAINER_{str(uuid.uuid4())[:8]}' for _ in range(num_records)]
    }
    return pd.DataFrame(data)

# Workforce Scheduling
def generate_scheduling_data(num_records=1000):
    shift_types = ['Morning', 'Afternoon', 'Night', 'Flexible']
    departments = ['IT', 'HR', 'Finance', 'Operations', 'Sales']
    statuses = ['Scheduled', 'In Progress', 'Completed', 'Cancelled']
    
    data = {
        'schedule_id': [f'SCHED_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'employee_id': [f'EMP_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'shift_date': [datetime.now().date() + timedelta(days=np.random.randint(0, 30)) for _ in range(num_records)],
        'shift_type': np.random.choice(shift_types, num_records),
        'start_time': [datetime.now() + timedelta(hours=np.random.randint(0, 24)) for _ in range(num_records)],
        'end_time': [datetime.now() + timedelta(hours=np.random.randint(0, 24)) for _ in range(num_records)],
        'department': np.random.choice(departments, num_records),
        'status': np.random.choice(statuses, num_records)
    }
    return pd.DataFrame(data)

# Workforce Leave
def generate_leave_data(num_records=400):
    leave_types = ['Annual', 'Sick', 'Personal', 'Maternity', 'Paternity']
    statuses = ['Pending', 'Approved', 'Rejected', 'Cancelled']
    
    data = {
        'leave_id': [f'LEAVE_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'employee_id': [f'EMP_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'leave_type': np.random.choice(leave_types, num_records),
        'start_date': [datetime.now().date() + timedelta(days=np.random.randint(0, 30)) for _ in range(num_records)],
        'end_date': [datetime.now().date() + timedelta(days=np.random.randint(0, 30)) for _ in range(num_records)],
        'status': np.random.choice(statuses, num_records),
        'approved_by': [f'MGR_{str(uuid.uuid4())[:8]}' for _ in range(num_records)],
        'reason': [f'Leave reason {i+1}' for i in range(num_records)]
    }
    return pd.DataFrame(data)

# Generate and save all data
if __name__ == "__main__":
    # Generate Industrial data
    iot_df = generate_iot_data()
    maintenance_df = generate_maintenance_data(iot_df['device_id'].tolist())
    performance_df = generate_performance_data(iot_df['device_id'].tolist())
    safety_df = generate_safety_data(iot_df['device_id'].tolist())
    
    # Save Industrial data
    iot_df.to_csv('transformed_data/industrial_data/industrial_iot_data.csv', index=False)
    maintenance_df.to_csv('transformed_data/industrial_data/industrial_maintenance.csv', index=False)
    performance_df.to_csv('transformed_data/industrial_data/industrial_performance.csv', index=False)
    safety_df.to_csv('transformed_data/industrial_data/industrial_safety.csv', index=False)
    
    # Generate and save Workforce data
    attendance_df = generate_attendance_data()
    workforce_performance_df = generate_workforce_performance_data()
    skills_df = generate_skills_data()
    training_df = generate_training_data()
    scheduling_df = generate_scheduling_data()
    leave_df = generate_leave_data()
    
    # Save Workforce data
    attendance_df.to_csv('transformed_data/workforce_data/workforce_attendance.csv', index=False)
    workforce_performance_df.to_csv('transformed_data/workforce_data/workforce_performance.csv', index=False)
    skills_df.to_csv('transformed_data/workforce_data/workforce_skills.csv', index=False)
    training_df.to_csv('transformed_data/workforce_data/workforce_training.csv', index=False)
    scheduling_df.to_csv('transformed_data/workforce_data/workforce_scheduling.csv', index=False)
    leave_df.to_csv('transformed_data/workforce_data/workforce_leave.csv', index=False) 