import pandas as pd
import numpy as np
from faker import Faker
from datetime import datetime, timedelta
import random
from scipy import stats
import yfinance as yf
from dateutil.relativedelta import relativedelta
import json
import os

# Set random seeds for reproducibility
np.random.seed(42)
random.seed(42)
fake = Faker()
Faker.seed(42)

class FinancialDataGenerator:
    def __init__(self):
        self.start_date = datetime(2021, 1, 1)
        self.end_date = datetime.now()
        self.num_clients = 5000
        self.num_products = 50
        self.num_advisors = 100
        
        # Create output directory if it doesn't exist
        if not os.path.exists('financial_data'):
            os.makedirs('financial_data')
    
    def generate_client_portfolio_data(self):
        """Generate client portfolio data"""
        client_data = {
            'client_id': [f'CLT{i:05d}' for i in range(self.num_clients)],
            'account_type': np.random.choice(
                ['Individual', 'Joint', 'IRA', '401K', 'Institutional'],
                size=self.num_clients,
                p=[0.3, 0.2, 0.2, 0.2, 0.1]
            ),
            'account_balance': np.random.lognormal(
                mean=12,  # Log-normal distribution for realistic balance distribution
                sigma=1.5,
                size=self.num_clients
            ),
            'risk_profile': np.random.randint(1, 11, size=self.num_clients),
            'account_open_date': [
                fake.date_between(start_date='-10y', end_date='today')
                for _ in range(self.num_clients)
            ]
        }
        
        # Adjust account balances to realistic ranges
        client_data['account_balance'] = np.clip(
            client_data['account_balance'],
            10000,  # Minimum $10,000
            50000000  # Maximum $50,000,000
        )
        
        # Generate asset allocation based on risk profile
        def generate_asset_allocation(risk_profile):
            if risk_profile <= 3:
                return {
                    'stocks': random.uniform(0.2, 0.4),
                    'bonds': random.uniform(0.4, 0.6),
                    'cash': random.uniform(0.1, 0.2),
                    'alternatives': random.uniform(0.05, 0.15)
                }
            elif risk_profile <= 7:
                return {
                    'stocks': random.uniform(0.5, 0.7),
                    'bonds': random.uniform(0.2, 0.4),
                    'cash': random.uniform(0.05, 0.15),
                    'alternatives': random.uniform(0.05, 0.15)
                }
            else:
                return {
                    'stocks': random.uniform(0.7, 0.9),
                    'bonds': random.uniform(0.1, 0.2),
                    'cash': random.uniform(0.02, 0.08),
                    'alternatives': random.uniform(0.05, 0.15)
                }
        
        # Generate returns based on risk profile and market conditions
        def generate_returns(risk_profile):
            base_return = np.random.normal(0.08, 0.02)  # Base market return
            risk_adjustment = (risk_profile - 5) * 0.01  # Higher risk = higher potential return
            noise = np.random.normal(0, 0.02)  # Random noise
            
            ytd_return = base_return + risk_adjustment + noise
            one_year = ytd_return * 1.1
            three_year = one_year * 1.15
            five_year = three_year * 1.2
            ten_year = five_year * 1.25
            
            return {
                'ytd_return': ytd_return,
                'one_year_return': one_year,
                'three_year_return': three_year,
                'five_year_return': five_year,
                'ten_year_return': ten_year
            }
        
        # Add asset allocation and returns
        client_data['asset_allocation'] = [
            generate_asset_allocation(risk)
            for risk in client_data['risk_profile']
        ]
        
        returns_data = [
            generate_returns(risk)
            for risk in client_data['risk_profile']
        ]
        
        for key in returns_data[0].keys():
            client_data[key] = [r[key] for r in returns_data]
        
        df = pd.DataFrame(client_data)
        df.to_csv('financial_data/client_portfolios.csv', index=False)
        return df
    
    def generate_investment_products(self):
        """Generate investment product data"""
        asset_classes = ['Equity', 'Fixed Income', 'Balanced', 'Alternative', 'Money Market']
        strategies = ['Growth', 'Value', 'Index', 'Active', 'Passive', 'ESG', 'Quantitative']
        
        product_data = {
            'fund_id': [f'FND{i:03d}' for i in range(self.num_products)],
            'fund_name': [f"{fake.company()} {random.choice(strategies)} {random.choice(asset_classes)} Fund" 
                         for _ in range(self.num_products)],
            'asset_class': np.random.choice(asset_classes, size=self.num_products),
            'strategy': np.random.choice(strategies, size=self.num_products),
            'expense_ratio': np.random.uniform(0.0005, 0.025, size=self.num_products),
            'aum': np.random.lognormal(mean=15, sigma=1, size=self.num_products)
        }
        
        # Generate risk metrics
        def generate_risk_metrics(asset_class):
            if asset_class == 'Equity':
                return {
                    'sharpe_ratio': np.random.normal(1.2, 0.3),
                    'volatility': np.random.normal(0.15, 0.02),
                    'beta': np.random.normal(1.1, 0.1),
                    'alpha': np.random.normal(0.02, 0.01)
                }
            elif asset_class == 'Fixed Income':
                return {
                    'sharpe_ratio': np.random.normal(0.8, 0.2),
                    'volatility': np.random.normal(0.06, 0.01),
                    'beta': np.random.normal(0.4, 0.1),
                    'alpha': np.random.normal(0.01, 0.005)
                }
            else:
                return {
                    'sharpe_ratio': np.random.normal(1.0, 0.25),
                    'volatility': np.random.normal(0.10, 0.015),
                    'beta': np.random.normal(0.8, 0.1),
                    'alpha': np.random.normal(0.015, 0.008)
                }
        
        # Add risk metrics
        risk_metrics = [
            generate_risk_metrics(asset_class)
            for asset_class in product_data['asset_class']
        ]
        
        for key in risk_metrics[0].keys():
            product_data[key] = [m[key] for m in risk_metrics]
        
        # Generate historical returns
        def generate_historical_returns(asset_class):
            base_returns = {
                'one_month': np.random.normal(0.01, 0.02),
                'three_month': np.random.normal(0.03, 0.03),
                'six_month': np.random.normal(0.06, 0.04),
                'one_year': np.random.normal(0.12, 0.05),
                'three_year': np.random.normal(0.36, 0.08),
                'five_year': np.random.normal(0.60, 0.10),
                'ten_year': np.random.normal(1.20, 0.15)
            }
            
            # Adjust returns based on asset class
            if asset_class == 'Fixed Income':
                return {k: v * 0.6 for k, v in base_returns.items()}
            elif asset_class == 'Money Market':
                return {k: v * 0.3 for k, v in base_returns.items()}
            else:
                return base_returns
        
        historical_returns = [
            generate_historical_returns(asset_class)
            for asset_class in product_data['asset_class']
        ]
        
        for key in historical_returns[0].keys():
            product_data[key] = [r[key] for r in historical_returns]
        
        df = pd.DataFrame(product_data)
        df.to_csv('financial_data/investment_products.csv', index=False)
        return df
    
    def generate_market_data(self):
        """Generate market data using yfinance"""
        indices = ['^GSPC', '^IXIC', '^DJI', '^RUT']  # S&P 500, NASDAQ, Dow Jones, Russell 2000
        
        # Generate synthetic market data
        dates = pd.date_range(start=self.start_date, end=self.end_date, freq='D')
        market_data = pd.DataFrame(index=dates)
        
        # Generate synthetic index values with realistic correlations
        base_values = {
            '^GSPC': 4000,  # S&P 500
            '^IXIC': 15000,  # NASDAQ
            '^DJI': 35000,  # Dow Jones
            '^RUT': 2000   # Russell 2000
        }
        
        for index in indices:
            # Generate daily returns with realistic volatility
            daily_returns = np.random.normal(0.0002, 0.01, size=len(dates))
            
            # Add some market trends
            trend = np.linspace(0, 0.5, len(dates))  # Overall upward trend
            correction = np.where(
                (dates >= '2023-08-01') & (dates <= '2023-10-31'),
                -0.1,  # Market correction
                0
            )
            
            # Combine returns with trend and correction
            cumulative_returns = np.cumsum(daily_returns + trend + correction)
            
            # Calculate index values
            market_data[index] = base_values[index] * (1 + cumulative_returns)
        
        # Create sector performance data
        sectors = ['Technology', 'Healthcare', 'Financials', 'Consumer', 'Industrial', 
                  'Energy', 'Materials', 'Utilities', 'Real Estate', 'Communication']
        
        # Create a DataFrame with all combinations of dates and sectors
        sector_data = pd.DataFrame({
            'date': np.repeat(dates, len(sectors)),
            'sector': np.tile(sectors, len(dates)),
            'performance': np.random.normal(0, 0.02, size=len(dates) * len(sectors))
        })
        
        # Add sector-specific trends
        sector_trends = {
            'Technology': 0.0003,
            'Healthcare': 0.0002,
            'Financials': 0.0001,
            'Consumer': 0.00015,
            'Industrial': 0.0001,
            'Energy': 0.0002,
            'Materials': 0.0001,
            'Utilities': 0.00005,
            'Real Estate': 0.0001,
            'Communication': 0.00015
        }
        
        for sector in sectors:
            mask = sector_data['sector'] == sector
            sector_data.loc[mask, 'performance'] += np.linspace(0, sector_trends[sector] * len(dates), len(dates))
        
        # Create interest rates data
        interest_rates = pd.DataFrame({
            'date': dates,
            'fed_funds_rate': np.random.normal(4.5, 0.5, size=len(dates)),
            'treasury_10y': np.random.normal(3.8, 0.4, size=len(dates))
        })
        
        # Add rising interest rate trend
        interest_rates['fed_funds_rate'] += np.linspace(0, 2, len(dates))
        interest_rates['treasury_10y'] += np.linspace(0, 1.5, len(dates))
        
        # Save market data
        market_data.to_csv('financial_data/market_indices.csv')
        sector_data.to_csv('financial_data/sector_performance.csv')
        interest_rates.to_csv('financial_data/interest_rates.csv')
        
        return market_data, sector_data, interest_rates
    
    def generate_trading_activity(self, client_portfolios, investment_products):
        """Generate trading activity data"""
        num_transactions = 10000
        
        trading_data = {
            'transaction_id': [f'TXN{i:06d}' for i in range(num_transactions)],
            'date': [fake.date_time_between(start_date='-1y', end_date='now') 
                    for _ in range(num_transactions)],
            'client_id': np.random.choice(client_portfolios['client_id'], size=num_transactions),
            'product_id': np.random.choice(investment_products['fund_id'], size=num_transactions),
            'transaction_type': np.random.choice(['buy', 'sell'], size=num_transactions),
            'share_quantity': np.random.lognormal(mean=3, sigma=1, size=num_transactions),
            'price_per_share': np.random.lognormal(mean=2, sigma=0.5, size=num_transactions),
        }
        
        # Calculate total value and fees
        trading_data['total_value'] = [
            qty * price
            for qty, price in zip(trading_data['share_quantity'], trading_data['price_per_share'])
        ]
        
        trading_data['fee_amount'] = [
            value * np.random.uniform(0.0001, 0.01)  # 0.01% to 1% fee
            for value in trading_data['total_value']
        ]
        
        df = pd.DataFrame(trading_data)
        df.to_csv('financial_data/trading_activity.csv', index=False)
        return df
    
    def generate_advisor_data(self, client_portfolios):
        """Generate financial advisor data"""
        advisor_data = {
            'advisor_id': [f'ADV{i:03d}' for i in range(self.num_advisors)],
            'name': [fake.name() for _ in range(self.num_advisors)],
            'client_count': np.random.randint(10, 100, size=self.num_advisors),
            'total_aum': np.random.lognormal(mean=14, sigma=1, size=self.num_advisors),
            'start_date': [fake.date_between(start_date='-15y', end_date='-1y') 
                          for _ in range(self.num_advisors)]
        }
        
        # Calculate performance metrics
        advisor_data['client_retention_rate'] = np.random.uniform(0.85, 0.98, size=self.num_advisors)
        advisor_data['client_satisfaction_score'] = np.random.uniform(4.0, 5.0, size=self.num_advisors)
        advisor_data['new_client_acquisition'] = np.random.randint(5, 30, size=self.num_advisors)
        
        df = pd.DataFrame(advisor_data)
        df.to_csv('financial_data/advisor_data.csv', index=False)
        return df
    
    def generate_all_data(self):
        """Generate all financial data"""
        print("Generating client portfolio data...")
        client_portfolios = self.generate_client_portfolio_data()
        
        print("Generating investment products...")
        investment_products = self.generate_investment_products()
        
        print("Generating market data...")
        market_data, sector_data, interest_rates = self.generate_market_data()
        
        print("Generating trading activity...")
        trading_activity = self.generate_trading_activity(client_portfolios, investment_products)
        
        print("Generating advisor data...")
        advisor_data = self.generate_advisor_data(client_portfolios)
        
        print("Data generation complete! Files saved in 'financial_data' directory.")
        return {
            'client_portfolios': client_portfolios,
            'investment_products': investment_products,
            'market_data': market_data,
            'sector_data': sector_data,
            'interest_rates': interest_rates,
            'trading_activity': trading_activity,
            'advisor_data': advisor_data
        }

if __name__ == "__main__":
    generator = FinancialDataGenerator()
    data = generator.generate_all_data() 