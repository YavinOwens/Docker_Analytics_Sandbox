import pandas as pd
import cx_Oracle
import os
from datetime import datetime
import logging
from pathlib import Path
import json

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('elt_process.log'),
        logging.StreamHandler()
    ]
)

class ELTProcessor:
    def __init__(self):
        self.connection_string = "system/Welcome123@localhost:1521/XEPDB1"
        self.data_dir = Path('water_utilities_finance')
        self.metrics_dir = Path('water_utilities_metrics')
        self.workforce_dir = Path('workforce_data')
        self.industrial_dir = Path('industrial_data')
        self.setup_database()

    def setup_database(self):
        """Create necessary tables in the database"""
        try:
            connection = cx_Oracle.connect(self.connection_string)
            cursor = connection.cursor()

            # Create Financial Statements table
            cursor.execute("""
                CREATE TABLE financial_statements (
                    period VARCHAR2(7),
                    year NUMBER,
                    month NUMBER,
                    water_sales NUMBER(15,2),
                    wastewater_charges NUMBER(15,2),
                    connection_fees NUMBER(15,2),
                    total_revenue NUMBER(15,2),
                    labor_costs NUMBER(15,2),
                    materials_costs NUMBER(15,2),
                    energy_costs NUMBER(15,2),
                    maintenance_costs NUMBER(15,2),
                    other_costs NUMBER(15,2),
                    total_costs NUMBER(15,2),
                    operating_income NUMBER(15,2),
                    net_income NUMBER(15,2),
                    operating_margin NUMBER(5,2),
                    net_margin NUMBER(5,2),
                    revenue_growth NUMBER(5,2),
                    cost_efficiency NUMBER(5,2),
                    water_loss_percentage NUMBER(5,2),
                    energy_efficiency NUMBER(5,2)
                )
            """)

            # Create Budgets table
            cursor.execute("""
                CREATE TABLE budgets (
                    year NUMBER,
                    budget_id VARCHAR2(20),
                    total_budget NUMBER(15,2),
                    operational_budget NUMBER(15,2),
                    capital_budget NUMBER(15,2),
                    maintenance_budget NUMBER(15,2),
                    labor_budget NUMBER(15,2),
                    materials_budget NUMBER(15,2),
                    energy_budget NUMBER(15,2),
                    technology_budget NUMBER(15,2),
                    safety_budget NUMBER(15,2),
                    training_budget NUMBER(15,2),
                    contingency_budget NUMBER(15,2),
                    status VARCHAR2(20),
                    approved_by VARCHAR2(20),
                    approval_date DATE,
                    budget_notes CLOB
                )
            """)

            # Create Cash Flow table
            cursor.execute("""
                CREATE TABLE cash_flow (
                    transaction_id VARCHAR2(20),
                    date DATE,
                    transaction_type VARCHAR2(50),
                    amount NUMBER(15,2),
                    is_inflow NUMBER(1),
                    payment_method VARCHAR2(20),
                    status VARCHAR2(20),
                    reference_number VARCHAR2(20),
                    description VARCHAR2(200),
                    category VARCHAR2(50)
                )
            """)

            # Create Metrics tables
            cursor.execute("""
                CREATE TABLE water_quality_metrics (
                    timestamp TIMESTAMP,
                    location_id VARCHAR2(20),
                    ph NUMBER(4,2),
                    turbidity NUMBER(5,2),
                    chlorine NUMBER(5,2),
                    hardness NUMBER(5,2),
                    alkalinity NUMBER(5,2),
                    status VARCHAR2(20),
                    alert_level VARCHAR2(20)
                )
            """)

            cursor.execute("""
                CREATE TABLE system_performance_metrics (
                    timestamp TIMESTAMP,
                    location_id VARCHAR2(20),
                    pressure NUMBER(5,2),
                    flow_rate NUMBER(8,2),
                    water_loss NUMBER(5,2),
                    pump_efficiency NUMBER(5,2),
                    status VARCHAR2(20),
                    alert_level VARCHAR2(20)
                )
            """)

            cursor.execute("""
                CREATE TABLE energy_metrics (
                    timestamp TIMESTAMP,
                    location_id VARCHAR2(20),
                    power_consumption NUMBER(10,2),
                    energy_efficiency NUMBER(5,2),
                    peak_demand NUMBER(10,2),
                    status VARCHAR2(20),
                    alert_level VARCHAR2(20)
                )
            """)

            # Create Workforce tables
            cursor.execute("""
                CREATE TABLE employees (
                    employee_id VARCHAR2(20),
                    first_name VARCHAR2(50),
                    last_name VARCHAR2(50),
                    department VARCHAR2(50),
                    role VARCHAR2(50),
                    hire_date DATE,
                    salary NUMBER(10,2),
                    education_level VARCHAR2(50),
                    experience_years NUMBER(3),
                    status VARCHAR2(20)
                )
            """)

            cursor.execute("""
                CREATE TABLE performance_reviews (
                    review_id VARCHAR2(20),
                    employee_id VARCHAR2(20),
                    review_date DATE,
                    rating VARCHAR2(20),
                    productivity_score NUMBER(3,2),
                    quality_score NUMBER(3,2),
                    teamwork_score NUMBER(3,2),
                    initiative_score NUMBER(3,2),
                    attendance_score NUMBER(3,2),
                    overall_score NUMBER(3,2),
                    comments CLOB
                )
            """)

            cursor.execute("""
                CREATE TABLE training_records (
                    record_id VARCHAR2(20),
                    employee_id VARCHAR2(20),
                    training_type VARCHAR2(50),
                    completion_date DATE,
                    status VARCHAR2(20),
                    score NUMBER(3,2),
                    instructor VARCHAR2(100),
                    notes CLOB
                )
            """)

            # Create Industrial tables
            cursor.execute("""
                CREATE TABLE equipment (
                    equipment_id VARCHAR2(20),
                    type VARCHAR2(50),
                    category VARCHAR2(50),
                    location VARCHAR2(100),
                    installation_date DATE,
                    status VARCHAR2(20),
                    last_maintenance_date DATE,
                    next_maintenance_date DATE,
                    specifications CLOB
                )
            """)

            cursor.execute("""
                CREATE TABLE maintenance_records (
                    record_id VARCHAR2(20),
                    equipment_id VARCHAR2(20),
                    maintenance_type VARCHAR2(50),
                    scheduled_date DATE,
                    completion_date DATE,
                    status VARCHAR2(20),
                    priority VARCHAR2(20),
                    description CLOB,
                    technician VARCHAR2(100),
                    parts_used CLOB
                )
            """)

            cursor.execute("""
                CREATE TABLE work_orders (
                    order_id VARCHAR2(20),
                    equipment_id VARCHAR2(20),
                    type VARCHAR2(50),
                    status VARCHAR2(20),
                    priority VARCHAR2(20),
                    created_date DATE,
                    assigned_date DATE,
                    completion_date DATE,
                    description CLOB,
                    assigned_to VARCHAR2(100)
                )
            """)

            connection.commit()
            logging.info("Database tables created successfully")

        except cx_Oracle.Error as error:
            logging.error(f"Error creating database tables: {error}")
            raise
        finally:
            if 'connection' in locals():
                connection.close()

    def load_financial_statements(self):
        """Load financial statements data"""
        try:
            df = pd.read_csv(self.data_dir / 'financial_statements.csv')
            connection = cx_Oracle.connect(self.connection_string)
            cursor = connection.cursor()

            for _, row in df.iterrows():
                cursor.execute("""
                    INSERT INTO financial_statements (
                        period, year, month, water_sales, wastewater_charges,
                        connection_fees, total_revenue, labor_costs, materials_costs,
                        energy_costs, maintenance_costs, other_costs, total_costs,
                        operating_income, net_income, operating_margin, net_margin,
                        revenue_growth, cost_efficiency, water_loss_percentage,
                        energy_efficiency
                    ) VALUES (
                        :1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13,
                        :14, :15, :16, :17, :18, :19, :20, :21
                    )
                """, (
                    row['period'], row['year'], row['month'],
                    row['water_sales'], row['wastewater_charges'],
                    row['connection_fees'], row['total_revenue'],
                    row['labor_costs'], row['materials_costs'],
                    row['energy_costs'], row['maintenance_costs'],
                    row['other_costs'], row['total_costs'],
                    row['operating_income'], row['net_income'],
                    row['operating_margin'], row['net_margin'],
                    row['revenue_growth'], row['cost_efficiency'],
                    row['water_loss_percentage'], row['energy_efficiency']
                ))

            connection.commit()
            logging.info(f"Loaded {len(df)} financial statements records")

        except Exception as e:
            logging.error(f"Error loading financial statements: {e}")
            raise
        finally:
            if 'connection' in locals():
                connection.close()

    def load_budgets(self):
        """Load budgets data"""
        try:
            df = pd.read_csv(self.data_dir / 'budgets.csv')
            connection = cx_Oracle.connect(self.connection_string)
            cursor = connection.cursor()

            for _, row in df.iterrows():
                cursor.execute("""
                    INSERT INTO budgets (
                        year, budget_id, total_budget, operational_budget,
                        capital_budget, maintenance_budget, labor_budget,
                        materials_budget, energy_budget, technology_budget,
                        safety_budget, training_budget, contingency_budget,
                        status, approved_by, approval_date, budget_notes
                    ) VALUES (
                        :1, :2, :3, :4, :5, :6, :7, :8, :9, :10,
                        :11, :12, :13, :14, :15, :16, :17
                    )
                """, (
                    row['year'], row['budget_id'], row['total_budget'],
                    row['operational_budget'], row['capital_budget'],
                    row['maintenance_budget'], row['labor_budget'],
                    row['materials_budget'], row['energy_budget'],
                    row['technology_budget'], row['safety_budget'],
                    row['training_budget'], row['contingency_budget'],
                    row['status'], row['approved_by'],
                    pd.to_datetime(row['approval_date']), row['budget_notes']
                ))

            connection.commit()
            logging.info(f"Loaded {len(df)} budget records")

        except Exception as e:
            logging.error(f"Error loading budgets: {e}")
            raise
        finally:
            if 'connection' in locals():
                connection.close()

    def load_cash_flow(self):
        """Load cash flow data"""
        try:
            df = pd.read_csv(self.data_dir / 'cash_flow.csv')
            connection = cx_Oracle.connect(self.connection_string)
            cursor = connection.cursor()

            for _, row in df.iterrows():
                cursor.execute("""
                    INSERT INTO cash_flow (
                        transaction_id, date, transaction_type, amount,
                        is_inflow, payment_method, status, reference_number,
                        description, category
                    ) VALUES (
                        :1, :2, :3, :4, :5, :6, :7, :8, :9, :10
                    )
                """, (
                    row['transaction_id'], pd.to_datetime(row['date']),
                    row['transaction_type'], row['amount'],
                    row['is_inflow'], row['payment_method'],
                    row['status'], row['reference_number'],
                    row['description'], row['category']
                ))

            connection.commit()
            logging.info(f"Loaded {len(df)} cash flow records")

        except Exception as e:
            logging.error(f"Error loading cash flow: {e}")
            raise
        finally:
            if 'connection' in locals():
                connection.close()

    def load_metrics(self):
        """Load metrics data"""
        try:
            # Load water quality metrics
            df_water = pd.read_csv(self.metrics_dir / 'water_quality_metrics.csv')
            connection = cx_Oracle.connect(self.connection_string)
            cursor = connection.cursor()

            for _, row in df_water.iterrows():
                cursor.execute("""
                    INSERT INTO water_quality_metrics (
                        timestamp, location_id, ph, turbidity, chlorine,
                        hardness, alkalinity, status, alert_level
                    ) VALUES (
                        :1, :2, :3, :4, :5, :6, :7, :8, :9
                    )
                """, (
                    pd.to_datetime(row['timestamp']), row['location_id'],
                    row['ph'], row['turbidity'], row['chlorine'],
                    row['hardness'], row['alkalinity'], row['status'],
                    row['alert_level']
                ))

            # Load system performance metrics
            df_system = pd.read_csv(self.metrics_dir / 'system_performance_metrics.csv')
            for _, row in df_system.iterrows():
                cursor.execute("""
                    INSERT INTO system_performance_metrics (
                        timestamp, location_id, pressure, flow_rate,
                        water_loss, pump_efficiency, status, alert_level
                    ) VALUES (
                        :1, :2, :3, :4, :5, :6, :7, :8
                    )
                """, (
                    pd.to_datetime(row['timestamp']), row['location_id'],
                    row['pressure'], row['flow_rate'], row['water_loss'],
                    row['pump_efficiency'], row['status'], row['alert_level']
                ))

            # Load energy metrics
            df_energy = pd.read_csv(self.metrics_dir / 'energy_metrics.csv')
            for _, row in df_energy.iterrows():
                cursor.execute("""
                    INSERT INTO energy_metrics (
                        timestamp, location_id, power_consumption,
                        energy_efficiency, peak_demand, status, alert_level
                    ) VALUES (
                        :1, :2, :3, :4, :5, :6, :7
                    )
                """, (
                    pd.to_datetime(row['timestamp']), row['location_id'],
                    row['power_consumption'], row['energy_efficiency'],
                    row['peak_demand'], row['status'], row['alert_level']
                ))

            connection.commit()
            logging.info(f"Loaded {len(df_water)} water quality records")
            logging.info(f"Loaded {len(df_system)} system performance records")
            logging.info(f"Loaded {len(df_energy)} energy records")

        except Exception as e:
            logging.error(f"Error loading metrics: {e}")
            raise
        finally:
            if 'connection' in locals():
                connection.close()

    def load_workforce(self):
        """Load workforce data"""
        try:
            # Load employees
            df_employees = pd.read_csv(self.workforce_dir / 'employees.csv')
            connection = cx_Oracle.connect(self.connection_string)
            cursor = connection.cursor()

            for _, row in df_employees.iterrows():
                cursor.execute("""
                    INSERT INTO employees (
                        employee_id, first_name, last_name, department,
                        role, hire_date, salary, education_level,
                        experience_years, status
                    ) VALUES (
                        :1, :2, :3, :4, :5, :6, :7, :8, :9, :10
                    )
                """, (
                    row['employee_id'], row['first_name'], row['last_name'],
                    row['department'], row['role'], pd.to_datetime(row['hire_date']),
                    row['salary'], row['education_level'], row['experience_years'],
                    row['status']
                ))

            # Load performance reviews
            df_reviews = pd.read_csv(self.workforce_dir / 'performance_reviews.csv')
            for _, row in df_reviews.iterrows():
                cursor.execute("""
                    INSERT INTO performance_reviews (
                        review_id, employee_id, review_date, rating,
                        productivity_score, quality_score, teamwork_score,
                        initiative_score, attendance_score, overall_score,
                        comments
                    ) VALUES (
                        :1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11
                    )
                """, (
                    row['review_id'], row['employee_id'],
                    pd.to_datetime(row['review_date']), row['rating'],
                    row['productivity_score'], row['quality_score'],
                    row['teamwork_score'], row['initiative_score'],
                    row['attendance_score'], row['overall_score'],
                    row['comments']
                ))

            # Load training records
            df_training = pd.read_csv(self.workforce_dir / 'training_records.csv')
            for _, row in df_training.iterrows():
                cursor.execute("""
                    INSERT INTO training_records (
                        record_id, employee_id, training_type,
                        completion_date, status, score, instructor, notes
                    ) VALUES (
                        :1, :2, :3, :4, :5, :6, :7, :8
                    )
                """, (
                    row['record_id'], row['employee_id'], row['training_type'],
                    pd.to_datetime(row['completion_date']), row['status'],
                    row['score'], row['instructor'], row['notes']
                ))

            connection.commit()
            logging.info(f"Loaded {len(df_employees)} employee records")
            logging.info(f"Loaded {len(df_reviews)} performance review records")
            logging.info(f"Loaded {len(df_training)} training records")

        except Exception as e:
            logging.error(f"Error loading workforce data: {e}")
            raise
        finally:
            if 'connection' in locals():
                connection.close()

    def load_industrial(self):
        """Load industrial data"""
        try:
            # Load equipment
            df_equipment = pd.read_csv(self.industrial_dir / 'equipment.csv')
            connection = cx_Oracle.connect(self.connection_string)
            cursor = connection.cursor()

            for _, row in df_equipment.iterrows():
                cursor.execute("""
                    INSERT INTO equipment (
                        equipment_id, type, category, location,
                        installation_date, status, last_maintenance_date,
                        next_maintenance_date, specifications
                    ) VALUES (
                        :1, :2, :3, :4, :5, :6, :7, :8, :9
                    )
                """, (
                    row['equipment_id'], row['type'], row['category'],
                    row['location'], pd.to_datetime(row['installation_date']),
                    row['status'], pd.to_datetime(row['last_maintenance_date']),
                    pd.to_datetime(row['next_maintenance_date']),
                    row['specifications']
                ))

            # Load maintenance records
            df_maintenance = pd.read_csv(self.industrial_dir / 'maintenance_records.csv')
            for _, row in df_maintenance.iterrows():
                cursor.execute("""
                    INSERT INTO maintenance_records (
                        record_id, equipment_id, maintenance_type,
                        scheduled_date, completion_date, status,
                        priority, description, technician, parts_used
                    ) VALUES (
                        :1, :2, :3, :4, :5, :6, :7, :8, :9, :10
                    )
                """, (
                    row['record_id'], row['equipment_id'], row['maintenance_type'],
                    pd.to_datetime(row['scheduled_date']),
                    pd.to_datetime(row['completion_date']), row['status'],
                    row['priority'], row['description'], row['technician'],
                    row['parts_used']
                ))

            # Load work orders
            df_work_orders = pd.read_csv(self.industrial_dir / 'work_orders.csv')
            for _, row in df_work_orders.iterrows():
                cursor.execute("""
                    INSERT INTO work_orders (
                        order_id, equipment_id, type, status,
                        priority, created_date, assigned_date,
                        completion_date, description, assigned_to
                    ) VALUES (
                        :1, :2, :3, :4, :5, :6, :7, :8, :9, :10
                    )
                """, (
                    row['order_id'], row['equipment_id'], row['type'],
                    row['status'], row['priority'],
                    pd.to_datetime(row['created_date']),
                    pd.to_datetime(row['assigned_date']),
                    pd.to_datetime(row['completion_date']),
                    row['description'], row['assigned_to']
                ))

            connection.commit()
            logging.info(f"Loaded {len(df_equipment)} equipment records")
            logging.info(f"Loaded {len(df_maintenance)} maintenance records")
            logging.info(f"Loaded {len(df_work_orders)} work order records")

        except Exception as e:
            logging.error(f"Error loading industrial data: {e}")
            raise
        finally:
            if 'connection' in locals():
                connection.close()

    def process_all(self):
        """Process all data files"""
        try:
            logging.info("Starting ELT process")
            
            # Load financial data
            self.load_financial_statements()
            self.load_budgets()
            self.load_cash_flow()
            
            # Load metrics data
            self.load_metrics()
            
            # Load workforce data
            self.load_workforce()
            
            # Load industrial data
            self.load_industrial()
            
            logging.info("ELT process completed successfully")
        except Exception as e:
            logging.error(f"ELT process failed: {e}")
            raise

if __name__ == "__main__":
    processor = ELTProcessor()
    processor.process_all() 