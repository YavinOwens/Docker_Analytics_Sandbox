import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random
from pathlib import Path
import json
from scipy import stats

# Set random seeds for reproducibility
RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)
random.seed(RANDOM_SEED)

class WaterUtilitiesMetricsGenerator:
    def __init__(self):
        self.start_date = datetime(2019, 1, 1)
        self.end_date = datetime.now()
        
        # Create output directory
        self.output_dir = Path('water_utilities_metrics')
        self.output_dir.mkdir(exist_ok=True)
        
        # Initialize counters
        self.capex_counter = 0
        self.pulse_survey_counter = 0
        
    def generate_ofwat_results(self):
        """Generate Ofwat performance results"""
        ofwat_data = []
        
        # Generate quarterly results from 2019 to present
        current_date = self.start_date
        while current_date <= self.end_date:
            # Base performance scores with some randomness
            base_scores = {
                'water_quality': random.uniform(0.85, 0.98),
                'customer_service': random.uniform(0.80, 0.95),
                'leakage_reduction': random.uniform(0.75, 0.90),
                'water_efficiency': random.uniform(0.80, 0.95),
                'environmental_impact': random.uniform(0.85, 0.98),
                'operational_efficiency': random.uniform(0.80, 0.95)
            }
            
            # Add seasonal variations
            season_factor = 1.0
            if current_date.month in [6, 7, 8]:  # Summer
                season_factor = 0.95
            elif current_date.month in [12, 1, 2]:  # Winter
                season_factor = 1.05
            
            # Calculate final scores
            scores = {k: round(v * season_factor * random.uniform(0.95, 1.05), 3) 
                     for k, v in base_scores.items()}
            
            # Generate Ofwat record
            ofwat_record = {
                'quarter': current_date.strftime('%Y-Q%q'),
                'year': current_date.year,
                'quarter_number': (current_date.month - 1) // 3 + 1,
                'water_quality_score': scores['water_quality'],
                'customer_service_score': scores['customer_service'],
                'leakage_reduction_score': scores['leakage_reduction'],
                'water_efficiency_score': scores['water_efficiency'],
                'environmental_impact_score': scores['environmental_impact'],
                'operational_efficiency_score': scores['operational_efficiency'],
                'overall_performance_score': round(np.mean(list(scores.values())), 3),
                'performance_rating': self._calculate_performance_rating(scores),
                'key_achievements': json.dumps(self._generate_key_achievements()),
                'areas_for_improvement': json.dumps(self._generate_improvement_areas()),
                'regulatory_compliance': random.choice(['Compliant', 'Compliant', 'Compliant', 'Minor Issues']),
                'financial_incentives_earned': round(random.uniform(100000, 500000), 2)
            }
            
            ofwat_data.append(ofwat_record)
            current_date += timedelta(days=90)  # Move to next quarter
        
        df = pd.DataFrame(ofwat_data)
        df.to_csv(self.output_dir / 'ofwat_results.csv', index=False)
        return df
    
    def generate_capex_data(self):
        """Generate CAPEX (Capital Expenditure) data"""
        capex_data = []
        
        # Generate monthly CAPEX records
        current_date = self.start_date
        while current_date <= self.end_date:
            # Generate multiple CAPEX projects per month
            num_projects = random.randint(1, 5)
            
            for _ in range(num_projects):
                self.capex_counter += 1
                project_id = f"CAPEX-{self.capex_counter:06d}"
                
                # Generate project data
                project_type = random.choice([
                    'Infrastructure Upgrade',
                    'Treatment Plant Modernization',
                    'Distribution Network Improvement',
                    'Technology Implementation',
                    'Facility Expansion',
                    'Environmental Compliance',
                    'Safety Enhancement',
                    'Automation Project'
                ])
                
                # Generate project timeline
                start_date = current_date + timedelta(days=random.randint(0, 30))
                duration_months = random.randint(3, 24)
                end_date = start_date + timedelta(days=duration_months * 30)
                
                # Generate budget data
                base_budget = random.uniform(100000, 5000000)
                contingency = base_budget * random.uniform(0.05, 0.15)
                total_budget = base_budget + contingency
                
                # Generate progress data
                if end_date < self.end_date:
                    progress = random.uniform(0.8, 1.0)
                    actual_cost = total_budget * random.uniform(0.9, 1.1)
                    status = random.choice(['Completed', 'Completed', 'Completed', 'On Track'])
                else:
                    progress = random.uniform(0.0, 0.8)
                    actual_cost = total_budget * progress * random.uniform(0.9, 1.1)
                    status = random.choice(['In Progress', 'On Track', 'Delayed'])
                
                capex_record = {
                    'project_id': project_id,
                    'project_name': f"{project_type} Project {self.capex_counter}",
                    'project_type': project_type,
                    'start_date': start_date,
                    'planned_end_date': end_date,
                    'actual_end_date': end_date if status == 'Completed' else None,
                    'base_budget': round(base_budget, 2),
                    'contingency_budget': round(contingency, 2),
                    'total_budget': round(total_budget, 2),
                    'actual_cost': round(actual_cost, 2),
                    'progress_percentage': round(progress * 100, 2),
                    'status': status,
                    'priority': random.choice(['High', 'Medium', 'Low']),
                    'risk_level': random.choice(['Low', 'Medium', 'High']),
                    'benefits_realized': json.dumps(self._generate_project_benefits()),
                    'key_milestones': json.dumps(self._generate_project_milestones()),
                    'stakeholders': json.dumps(self._generate_stakeholders())
                }
                
                capex_data.append(capex_record)
            
            current_date += timedelta(days=30)  # Move to next month
        
        df = pd.DataFrame(capex_data)
        df.to_csv(self.output_dir / 'capex_projects.csv', index=False)
        return df
    
    def generate_pulse_survey_data(self):
        """Generate employee pulse survey data"""
        pulse_data = []
        
        # Generate monthly pulse survey results
        current_date = self.start_date
        while current_date <= self.end_date:
            # Generate survey data for each department
            departments = [
                'Operations', 'Maintenance', 'Safety', 'HR', 
                'Logistics', 'Training', 'Quality Control'
            ]
            
            for department in departments:
                self.pulse_survey_counter += 1
                survey_id = f"PULSE-{self.pulse_survey_counter:06d}"
                
                # Generate base scores with some randomness
                base_scores = {
                    'engagement': random.uniform(0.70, 0.90),
                    'satisfaction': random.uniform(0.70, 0.90),
                    'wellbeing': random.uniform(0.70, 0.90),
                    'culture': random.uniform(0.70, 0.90),
                    'leadership': random.uniform(0.70, 0.90),
                    'development': random.uniform(0.70, 0.90),
                    'work_life_balance': random.uniform(0.70, 0.90),
                    'recognition': random.uniform(0.70, 0.90)
                }
                
                # Add seasonal variations
                season_factor = 1.0
                if current_date.month in [6, 7, 8]:  # Summer
                    season_factor = 1.05
                elif current_date.month in [12, 1, 2]:  # Winter
                    season_factor = 0.95
                
                # Calculate final scores
                scores = {k: round(v * season_factor * random.uniform(0.95, 1.05), 3) 
                         for k, v in base_scores.items()}
                
                # Generate pulse survey record
                pulse_record = {
                    'survey_id': survey_id,
                    'survey_date': current_date,
                    'department': department,
                    'response_rate': round(random.uniform(0.75, 0.95), 3),
                    'engagement_score': scores['engagement'],
                    'satisfaction_score': scores['satisfaction'],
                    'wellbeing_score': scores['wellbeing'],
                    'culture_score': scores['culture'],
                    'leadership_score': scores['leadership'],
                    'development_score': scores['development'],
                    'work_life_balance_score': scores['work_life_balance'],
                    'recognition_score': scores['recognition'],
                    'overall_score': round(np.mean(list(scores.values())), 3),
                    'key_findings': json.dumps(self._generate_key_findings()),
                    'action_items': json.dumps(self._generate_action_items()),
                    'employee_feedback': json.dumps(self._generate_employee_feedback())
                }
                
                pulse_data.append(pulse_record)
            
            current_date += timedelta(days=30)  # Move to next month
        
        df = pd.DataFrame(pulse_data)
        df.to_csv(self.output_dir / 'pulse_surveys.csv', index=False)
        return df
    
    def _calculate_performance_rating(self, scores):
        """Calculate Ofwat performance rating based on scores"""
        overall_score = np.mean(list(scores.values()))
        if overall_score >= 0.95:
            return 'Outstanding'
        elif overall_score >= 0.90:
            return 'Good'
        elif overall_score >= 0.85:
            return 'Requires Improvement'
        else:
            return 'Poor'
    
    def _generate_key_achievements(self):
        """Generate key achievements for Ofwat results"""
        return random.sample([
            'Reduced water leakage by 15%',
            'Improved customer satisfaction scores',
            'Implemented new water treatment technology',
            'Enhanced environmental protection measures',
            'Optimized operational efficiency',
            'Upgraded distribution network',
            'Reduced energy consumption',
            'Improved water quality metrics'
        ], k=random.randint(3, 5))
    
    def _generate_improvement_areas(self):
        """Generate areas for improvement"""
        return random.sample([
            'Customer response times',
            'Water pressure management',
            'Infrastructure maintenance',
            'Energy efficiency',
            'Waste reduction',
            'Employee training',
            'Digital transformation',
            'Environmental impact'
        ], k=random.randint(2, 4))
    
    def _generate_project_benefits(self):
        """Generate project benefits for CAPEX projects"""
        return random.sample([
            'Improved operational efficiency',
            'Enhanced safety measures',
            'Reduced maintenance costs',
            'Better environmental compliance',
            'Increased capacity',
            'Improved customer service',
            'Cost savings',
            'Technology advancement'
        ], k=random.randint(3, 5))
    
    def _generate_project_milestones(self):
        """Generate project milestones"""
        return random.sample([
            'Project planning completed',
            'Design phase completed',
            'Equipment procurement',
            'Installation completed',
            'Testing phase',
            'Staff training',
            'Commissioning',
            'Project handover'
        ], k=random.randint(4, 6))
    
    def _generate_stakeholders(self):
        """Generate project stakeholders"""
        return random.sample([
            'Operations Team',
            'Maintenance Team',
            'Safety Department',
            'Environmental Team',
            'Customer Service',
            'Regulatory Bodies',
            'Local Community',
            'Contractors'
        ], k=random.randint(3, 5))
    
    def _generate_key_findings(self):
        """Generate key findings for pulse surveys"""
        return random.sample([
            'High employee engagement in safety initiatives',
            'Strong team collaboration',
            'Good work-life balance',
            'Effective leadership communication',
            'Opportunities for skill development',
            'Positive workplace culture',
            'Well-maintained facilities',
            'Clear career progression paths'
        ], k=random.randint(3, 5))
    
    def _generate_action_items(self):
        """Generate action items for pulse surveys"""
        return random.sample([
            'Enhance training programs',
            'Improve communication channels',
            'Implement flexible working arrangements',
            'Strengthen recognition programs',
            'Develop leadership skills',
            'Address workload concerns',
            'Enhance workplace safety',
            'Improve career development opportunities'
        ], k=random.randint(2, 4))
    
    def _generate_employee_feedback(self):
        """Generate employee feedback for pulse surveys"""
        return random.sample([
            'Great team environment',
            'Good work-life balance',
            'Clear communication from management',
            'Opportunities for growth',
            'Strong safety culture',
            'Well-organized workplace',
            'Supportive colleagues',
            'Challenging and rewarding work'
        ], k=random.randint(4, 6))
    
    def generate_all_data(self):
        """Generate all metrics data"""
        print("\n=== Starting Water Utilities Metrics Generation ===")
        print(f"Start Date: {self.start_date.strftime('%Y-%m-%d')}")
        print(f"End Date: {self.end_date.strftime('%Y-%m-%d')}")
        print(f"Output Directory: {self.output_dir.absolute()}\n")
        
        print("1. Generating Ofwat results...")
        ofwat_df = self.generate_ofwat_results()
        print(f"   ✓ Generated {len(ofwat_df)} quarterly records")
        print(f"   ✓ Saved to: {self.output_dir / 'ofwat_results.csv'}")
        
        print("\n2. Generating CAPEX data...")
        capex_df = self.generate_capex_data()
        print(f"   ✓ Generated {len(capex_df)} project records")
        print(f"   ✓ Saved to: {self.output_dir / 'capex_projects.csv'}")
        
        print("\n3. Generating pulse survey data...")
        pulse_df = self.generate_pulse_survey_data()
        print(f"   ✓ Generated {len(pulse_df)} survey records")
        print(f"   ✓ Saved to: {self.output_dir / 'pulse_surveys.csv'}")
        
        print("\n=== Data Generation Summary ===")
        print(f"Total Ofwat Records: {len(ofwat_df)}")
        print(f"Total CAPEX Projects: {len(capex_df)}")
        print(f"Total Pulse Surveys: {len(pulse_df)}")
        print(f"\nAll files have been saved to: {self.output_dir.absolute()}")
        print("=== Generation Complete ===\n")

if __name__ == "__main__":
    generator = WaterUtilitiesMetricsGenerator()
    generator.generate_all_data() 