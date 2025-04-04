import pandas as pd
import numpy as np
from faker import Faker
from datetime import datetime, timedelta
import random
import yaml
from pathlib import Path
import json
from scipy import stats

# Set random seeds for reproducibility
RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)
random.seed(RANDOM_SEED)
fake = Faker()
Faker.seed(RANDOM_SEED)

class WorkforceDataGenerator:
    def __init__(self):
        self.start_date = datetime(2019, 1, 1)
        self.end_date = datetime.now()
        self.config = self._load_config()
        
        # Create output directory
        self.output_dir = Path('workforce_data')
        self.output_dir.mkdir(exist_ok=True)
        
        # Initialize counters
        self.employee_counter = 0
        self.training_counter = 0
        self.leave_counter = 0
        self.performance_counter = 0
        
    def _load_config(self):
        """Load configuration from YAML file"""
        with open('workforce_config.yaml', 'r') as f:
            return yaml.safe_load(f)
    
    def generate_employee_data(self):
        """Generate employee master data"""
        employees = []
        departments = self.config['departments']
        
        for department, roles in departments.items():
            for role in roles:
                # Generate multiple employees for each role
                num_employees = random.randint(3, 15)
                
                for _ in range(num_employees):
                    self.employee_counter += 1
                    employee_id = f"EMP-{department[:2].upper()}-{self.employee_counter:06d}"
                    
                    # Generate employee data
                    hire_date = fake.date_between(start_date='-10y', end_date='-1y')
                    salary = self._generate_salary(role)
                    
                    employee = {
                        'employee_id': employee_id,
                        'first_name': fake.first_name(),
                        'last_name': fake.last_name(),
                        'email': fake.email(),
                        'phone': fake.phone_number(),
                        'department': department,
                        'role': role,
                        'hire_date': hire_date,
                        'employment_status': random.choice(['Active', 'Active', 'Active', 'On Leave']),
                        'salary': salary,
                        'bonus_target': round(salary * random.uniform(0.05, 0.15), 2),
                        'certifications': self._generate_certifications(department),
                        'skills': self._generate_skills(department),
                        'location': self._generate_location(),
                        'manager_id': None,  # Will be updated later
                        'emergency_contact': {
                            'name': fake.name(),
                            'relationship': random.choice(['Spouse', 'Parent', 'Sibling', 'Friend']),
                            'phone': fake.phone_number()
                        }
                    }
                    
                    employees.append(employee)
        
        # Establish manager-employee relationships
        for employee in employees:
            if random.random() < 0.8:  # 80% chance of having a manager
                potential_managers = [
                    e for e in employees 
                    if e['employee_id'] != employee['employee_id'] and 
                    e['department'] == employee['department']
                ]
                if potential_managers:
                    employee['manager_id'] = random.choice(potential_managers)['employee_id']
        
        df = pd.DataFrame(employees)
        df.to_csv(self.output_dir / 'employees.csv', index=False)
        return df
    
    def _generate_salary(self, role):
        """Generate salary based on role"""
        base_salaries = {
            'Operator': (40000, 60000),
            'Technician': (45000, 70000),
            'Engineer': (70000, 100000),
            'Supervisor': (80000, 120000),
            'Manager': (100000, 150000),
            'Director': (150000, 200000),
            'HR Specialist': (50000, 80000),
            'HR Manager': (90000, 130000),
            'Logistics Coordinator': (45000, 70000),
            'Logistics Manager': (85000, 125000),
            'Safety Officer': (55000, 85000),
            'Training Specialist': (50000, 80000),
            'Quality Control Specialist': (50000, 80000),
            'Maintenance Supervisor': (75000, 110000)
        }
        
        salary_range = base_salaries.get(role, (40000, 80000))
        return round(random.uniform(salary_range[0], salary_range[1]), 2)
    
    def _generate_certifications(self, department):
        """Generate relevant certifications based on department"""
        certs = []
        if department == 'Operations':
            certs.extend(random.sample([
                'Water Treatment Operator License',
                'Wastewater Treatment Operator License',
                'HACCP Certification',
                'OSHA Safety Certification',
                'First Aid/CPR'
            ], k=random.randint(2, 4)))
        elif department == 'Maintenance':
            certs.extend(random.sample([
                'HVAC Certification',
                'Electrical License',
                'Plumbing License',
                'Welding Certification',
                'OSHA Safety Certification'
            ], k=random.randint(2, 4)))
        elif department == 'Safety':
            certs.extend(random.sample([
                'OSHA Safety Professional',
                'First Aid Instructor',
                'Hazardous Materials Handler',
                'Emergency Response Coordinator'
            ], k=random.randint(2, 3)))
        
        return json.dumps(certs)
    
    def _generate_skills(self, department):
        """Generate relevant skills based on department"""
        skills = []
        if department == 'Operations':
            skills.extend(random.sample([
                'Process Control',
                'Water Quality Analysis',
                'Equipment Operation',
                'Troubleshooting',
                'Safety Procedures'
            ], k=random.randint(3, 5)))
        elif department == 'Maintenance':
            skills.extend(random.sample([
                'Equipment Repair',
                'Preventive Maintenance',
                'Mechanical Systems',
                'Electrical Systems',
                'Hydraulic Systems'
            ], k=random.randint(3, 5)))
        elif department == 'Safety':
            skills.extend(random.sample([
                'Risk Assessment',
                'Safety Training',
                'Incident Investigation',
                'Compliance Management',
                'Emergency Response'
            ], k=random.randint(3, 5)))
        
        return json.dumps(skills)
    
    def _generate_location(self):
        """Generate location data for an employee"""
        facilities = self.config['locations']['facilities']['water_utilities']
        facility = random.choice(facilities)
        area = random.choice(facility['areas'])
        
        return {
            'facility_name': facility['name'],
            'area': area,
            'location_code': f"{facility['name'][:3].upper()}-{area[:3].upper()}",
            'lat': facility['lat'] + random.uniform(-0.01, 0.01),
            'lon': facility['lon'] + random.uniform(-0.01, 0.01)
        }
    
    def generate_training_data(self, employees_df):
        """Generate training and development data"""
        training_records = []
        
        for _, employee in employees_df.iterrows():
            # Generate multiple training records per employee
            num_trainings = random.randint(2, 6)
            
            for _ in range(num_trainings):
                self.training_counter += 1
                training_id = f"TRN-{self.training_counter:06d}"
                
                # Generate training data
                training_date = fake.date_between(
                    start_date=employee['hire_date'],
                    end_date=self.end_date
                )
                
                training = {
                    'training_id': training_id,
                    'employee_id': employee['employee_id'],
                    'training_type': random.choice([
                        'Safety Training',
                        'Technical Skills',
                        'Leadership Development',
                        'Compliance Training',
                        'Equipment Operation',
                        'Emergency Response'
                    ]),
                    'provider': random.choice([
                        'Internal Training',
                        'External Vendor',
                        'Industry Association',
                        'Technical Institute',
                        'Online Platform'
                    ]),
                    'start_date': training_date,
                    'end_date': training_date + timedelta(days=random.randint(1, 5)),
                    'status': random.choice(['Completed', 'In Progress', 'Scheduled']),
                    'score': random.randint(70, 100) if random.random() < 0.8 else None,
                    'certification_earned': random.choice([True, False]),
                    'cost': round(random.uniform(500, 5000), 2)
                }
                
                training_records.append(training)
        
        df = pd.DataFrame(training_records)
        df.to_csv(self.output_dir / 'training_records.csv', index=False)
        return df
    
    def generate_leave_data(self, employees_df):
        """Generate leave and attendance data"""
        leave_records = []
        
        for _, employee in employees_df.iterrows():
            # Generate multiple leave records per employee
            num_leaves = random.randint(1, 4)
            
            for _ in range(num_leaves):
                self.leave_counter += 1
                leave_id = f"LEV-{self.leave_counter:06d}"
                
                # Generate leave data
                leave_start = fake.date_between(
                    start_date=employee['hire_date'],
                    end_date=self.end_date
                )
                
                leave = {
                    'leave_id': leave_id,
                    'employee_id': employee['employee_id'],
                    'leave_type': random.choice([
                        'Vacation',
                        'Sick Leave',
                        'Personal Leave',
                        'Family Leave',
                        'Emergency Leave'
                    ]),
                    'start_date': leave_start,
                    'end_date': leave_start + timedelta(days=random.randint(1, 14)),
                    'status': random.choice(['Approved', 'Pending', 'Rejected']),
                    'reason': random.choice([
                        'Family Emergency',
                        'Medical Treatment',
                        'Vacation',
                        'Personal Matters',
                        'Mental Health'
                    ]),
                    'approved_by': random.choice(employees_df['employee_id'].tolist())
                }
                
                leave_records.append(leave)
        
        df = pd.DataFrame(leave_records)
        df.to_csv(self.output_dir / 'leave_records.csv', index=False)
        return df
    
    def generate_performance_data(self, employees_df):
        """Generate performance review data"""
        performance_records = []
        
        for _, employee in employees_df.iterrows():
            # Generate annual performance reviews
            years_employed = (self.end_date - pd.to_datetime(employee['hire_date'])).days / 365
            num_reviews = int(years_employed)
            
            for year in range(num_reviews):
                self.performance_counter += 1
                review_id = f"PERF-{self.performance_counter:06d}"
                
                # Generate review data
                review_date = pd.to_datetime(employee['hire_date']) + timedelta(days=365 * year)
                
                performance = {
                    'review_id': review_id,
                    'employee_id': employee['employee_id'],
                    'review_date': review_date,
                    'reviewer_id': random.choice(employees_df['employee_id'].tolist()),
                    'overall_rating': random.randint(1, 5),
                    'technical_skills': random.randint(1, 5),
                    'communication': random.randint(1, 5),
                    'leadership': random.randint(1, 5),
                    'safety_compliance': random.randint(1, 5),
                    'attendance': random.randint(1, 5),
                    'bonus_awarded': random.choice([True, False]),
                    'bonus_amount': round(random.uniform(1000, 10000), 2) if random.random() < 0.7 else 0,
                    'comments': random.choice([
                        'Excellent performance in all areas',
                        'Strong technical skills, needs improvement in communication',
                        'Consistently meets expectations',
                        'Shows great leadership potential',
                        'Needs improvement in attendance'
                    ]),
                    'goals_set': json.dumps(random.sample([
                        'Complete advanced certification',
                        'Improve team communication',
                        'Reduce maintenance downtime',
                        'Implement new safety procedures',
                        'Mentor junior staff'
                    ], k=random.randint(2, 4)))
                }
                
                performance_records.append(performance)
        
        df = pd.DataFrame(performance_records)
        df.to_csv(self.output_dir / 'performance_reviews.csv', index=False)
        return df
    
    def generate_all_data(self):
        """Generate all workforce data"""
        print("Generating employee data...")
        employees_df = self.generate_employee_data()
        
        print("Generating training records...")
        training_df = self.generate_training_data(employees_df)
        
        print("Generating leave records...")
        leave_df = self.generate_leave_data(employees_df)
        
        print("Generating performance reviews...")
        performance_df = self.generate_performance_data(employees_df)
        
        print("Data generation complete! Files saved in 'workforce_data' directory.")

if __name__ == "__main__":
    generator = WorkforceDataGenerator()
    generator.generate_all_data() 