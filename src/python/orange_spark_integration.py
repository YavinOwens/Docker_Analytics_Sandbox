#!/usr/bin/env python3
"""
Orange-Spark Integration

This script provides integration between Orange Data Mining and Apache Spark
for big data analysis and machine learning workflows.

Features:
- Connect to Spark cluster
- Load data from Spark into Orange-compatible formats
- Save Orange analysis results back to Spark
- Create bridge workflows between the two systems
"""

import os
import pandas as pd
import numpy as np
import json
import logging
from datetime import datetime
from pathlib import Path

# Spark imports
import findspark
findspark.init()
from pyspark.sql import SparkSession
from pyspark.ml import Pipeline
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.classification import RandomForestClassifier
from pyspark.ml.evaluation import MulticlassClassificationEvaluator

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
)

# Constants for workspace paths
ORANGE_WORKSPACE = "/workspace/orange"
SPARK_DATA_DIR = "/workspace/spark_data"

class OrangeSparkIntegration:
    """Class for integrating Orange Data Mining with Apache Spark"""
    
    def __init__(self, app_name="OrangeSparkIntegration"):
        """Initialize the integration with Spark session"""
        self.spark = self._create_spark_session(app_name)
        
        # Create workspace directories
        self.orange_dir = Path(ORANGE_WORKSPACE)
        self.spark_dir = Path(SPARK_DATA_DIR)
        self.orange_dir.mkdir(exist_ok=True)
        self.spark_dir.mkdir(exist_ok=True)
    
    def _create_spark_session(self, app_name):
        """Create and return a Spark session"""
        try:
            spark = SparkSession.builder \
                .appName(app_name) \
                .master("spark://spark-master:7077") \
                .config("spark.ui.port", "4040") \
                .getOrCreate()
            
            logging.info("Successfully connected to Spark")
            return spark
        except Exception as e:
            logging.error(f"Error connecting to Spark: {e}")
            raise
    
    def spark_to_orange(self, spark_df, name, sample_size=None, file_format="csv"):
        """
        Convert Spark DataFrame to Orange-compatible format and save it
        
        Args:
            spark_df: Spark DataFrame
            name: Base name for the saved file
            sample_size: Optional limit on number of rows to process (for large datasets)
            file_format: Format to save data (csv, tab, xlsx)
            
        Returns:
            Path to the saved file
        """
        logging.info(f"Converting Spark DataFrame to Orange format ({file_format})")
        
        # Sample if needed (for large datasets)
        if sample_size and spark_df.count() > sample_size:
            logging.info(f"Sampling {sample_size} rows from {spark_df.count()} total rows")
            spark_df = spark_df.sample(False, sample_size / spark_df.count())
        
        # Convert to Pandas for easier saving in Orange format
        pandas_df = spark_df.toPandas()
        
        # Save in specified format
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{name}_{timestamp}.{file_format}"
        filepath = self.orange_dir / filename
        
        try:
            if file_format.lower() == "csv":
                pandas_df.to_csv(filepath, index=False)
            elif file_format.lower() == "tab":
                # Orange prefers tab-delimited files
                pandas_df.to_csv(filepath, sep='\t', index=False)
            elif file_format.lower() == "xlsx":
                pandas_df.to_excel(filepath, index=False)
            else:
                raise ValueError(f"Unsupported format: {file_format}")
            
            # Also create metadata for Orange
            self._create_orange_metadata(pandas_df, name, timestamp)
            
            logging.info(f"Saved Spark data to {filepath} for Orange Data Mining")
            return filepath
        except Exception as e:
            logging.error(f"Error saving data for Orange: {e}")
            return None
    
    def _create_orange_metadata(self, df, name, timestamp):
        """Create metadata file for Orange Data Mining"""
        filename = f"{name}_{timestamp}.metadata"
        filepath = self.orange_dir / filename
        
        # Create metadata for Orange
        metadata = {
            "name": name,
            "description": f"Data converted from Spark on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "columns": []
        }
        
        # Add column metadata
        for col in df.columns:
            col_type = "categorical" if pd.api.types.is_categorical_dtype(df[col]) else \
                      "numeric" if pd.api.types.is_numeric_dtype(df[col]) else \
                      "datetime" if pd.api.types.is_datetime64_dtype(df[col]) else \
                      "string"
            
            metadata["columns"].append({
                "name": col,
                "type": col_type,
                "missing_values": int(df[col].isna().sum())
            })
        
        try:
            with open(filepath, 'w') as f:
                json.dump(metadata, f, indent=2)
            
            logging.info(f"Created metadata file at {filepath}")
            return filepath
        except Exception as e:
            logging.error(f"Error creating metadata for Orange: {e}")
            return None
    
    def orange_to_spark(self, file_path, name=None):
        """
        Load data from an Orange-compatible file into a Spark DataFrame
        
        Args:
            file_path: Path to the Orange data file
            name: Optional name for the registered temp view
            
        Returns:
            Spark DataFrame
        """
        file_path = Path(file_path)
        if not file_path.exists():
            logging.error(f"File not found: {file_path}")
            return None
        
        logging.info(f"Loading Orange data from {file_path} into Spark")
        
        try:
            # Determine file format and load accordingly
            if file_path.suffix.lower() == '.csv':
                spark_df = self.spark.read.csv(str(file_path), header=True, inferSchema=True)
            elif file_path.suffix.lower() == '.tab':
                spark_df = self.spark.read.csv(str(file_path), header=True, inferSchema=True, sep='\t')
            elif file_path.suffix.lower() in ['.xlsx', '.xls']:
                # For Excel files, we need to use pandas as an intermediary
                pandas_df = pd.read_excel(file_path)
                spark_df = self.spark.createDataFrame(pandas_df)
            else:
                logging.error(f"Unsupported file format: {file_path.suffix}")
                return None
            
            # Register as a temporary view if name is provided
            if name:
                spark_df.createOrReplaceTempView(name)
                logging.info(f"Registered Spark DataFrame as temporary view: {name}")
            
            return spark_df
        except Exception as e:
            logging.error(f"Error loading Orange data into Spark: {e}")
            return None
    
    def run_spark_ml_pipeline(self, spark_df, feature_cols, label_col, test_fraction=0.2):
        """
        Run a simple ML pipeline in Spark
        
        Args:
            spark_df: Input Spark DataFrame
            feature_cols: List of feature column names
            label_col: Label column name
            test_fraction: Fraction of data to use for testing
            
        Returns:
            Dict with model metrics
        """
        logging.info("Running Spark ML pipeline")
        
        try:
            # Prepare feature vector
            assembler = VectorAssembler(inputCols=feature_cols, outputCol="features")
            
            # Split data into training and test sets
            train_df, test_df = spark_df.randomSplit([1-test_fraction, test_fraction], seed=42)
            
            # Create and train model (Random Forest as an example)
            rf = RandomForestClassifier(labelCol=label_col, featuresCol="features")
            
            # Build the pipeline
            pipeline = Pipeline(stages=[assembler, rf])
            
            # Train the model
            model = pipeline.fit(train_df)
            
            # Make predictions
            predictions = model.transform(test_df)
            
            # Evaluate the model
            evaluator = MulticlassClassificationEvaluator(
                labelCol=label_col, predictionCol="prediction", metricName="accuracy")
            accuracy = evaluator.evaluate(predictions)
            
            # Return metrics
            metrics = {
                "accuracy": accuracy,
                "feature_importance": model.stages[-1].featureImportances.toArray().tolist(),
                "num_trees": model.stages[-1].getNumTrees,
                "features": feature_cols
            }
            
            logging.info(f"ML pipeline complete. Accuracy: {accuracy:.4f}")
            return metrics
        except Exception as e:
            logging.error(f"Error running Spark ML pipeline: {e}")
            return {"error": str(e)}
    
    def create_example_workflow(self):
        """Create an example Orange-Spark workflow file"""
        # This is a simplified version - real workflows would be created using Orange
        workflow = {
            "version": 1,
            "widgets": [
                {
                    "name": "Python Script",
                    "id": "spark-load-widget",
                    "parameters": {
                        "script": """
import findspark
findspark.init()
from pyspark.sql import SparkSession

# Create Spark session
spark = SparkSession.builder.appName("OrangeSparkExample").getOrCreate()

# Load data from Spark
data = spark.sql("SELECT * FROM example_data").toPandas()

# Make it available to Orange
in_data = Orange.data.Table.from_pandas(data)
                        """
                    },
                    "position": [100, 100]
                },
                {
                    "name": "Data Table",
                    "id": "data-table-widget",
                    "parameters": {},
                    "position": [300, 100]
                },
                {
                    "name": "Scatter Plot",
                    "id": "scatter-plot-widget",
                    "parameters": {},
                    "position": [300, 250]
                }
            ],
            "connections": [
                {"from": "spark-load-widget", "to": "data-table-widget"},
                {"from": "data-table-widget", "to": "scatter-plot-widget"}
            ]
        }
        
        workflow_path = self.orange_dir / f"spark_orange_workflow_{datetime.now().strftime('%Y%m%d_%H%M%S')}.ows"
        try:
            with open(workflow_path, 'w') as f:
                json.dump(workflow, f, indent=2)
            logging.info(f"Created Orange-Spark workflow at {workflow_path}")
            return workflow_path
        except Exception as e:
            logging.error(f"Error creating Orange-Spark workflow: {e}")
            return None
    
    def demo_integration(self):
        """Run a demonstration of Orange-Spark integration"""
        logging.info("Starting Orange-Spark integration demo")
        
        # Create sample data in Spark
        logging.info("Creating sample data in Spark")
        data = [(i, f"person_{i}", i * 10, "Group A" if i % 3 == 0 else "Group B" if i % 3 == 1 else "Group C") 
                for i in range(1, 101)]
        spark_df = self.spark.createDataFrame(data, ["id", "name", "age", "group"])
        
        # Register as a view for SQL queries
        spark_df.createOrReplaceTempView("demo_data")
        
        # Run a SQL query in Spark
        result_df = self.spark.sql("""
            SELECT 
                group, 
                COUNT(*) as count, 
                AVG(age) as avg_age, 
                MIN(age) as min_age, 
                MAX(age) as max_age 
            FROM demo_data 
            GROUP BY group
        """)
        
        print("Spark SQL result:")
        result_df.show()
        
        # Convert to Orange format
        orange_file = self.spark_to_orange(spark_df, "spark_demo_data", file_format="tab")
        
        # Run a simple ML model in Spark
        metrics = self.run_spark_ml_pipeline(
            spark_df, 
            feature_cols=["id", "age"], 
            label_col="group"
        )
        
        # Create an example workflow
        workflow_path = self.create_example_workflow()
        
        # Output instructions
        instructions = f"""
        Orange-Spark Integration Demo Complete
        -------------------------------------
        
        1. Your Spark data has been converted to Orange format:
           {orange_file}
           
        2. To use this data in Orange:
           - Open Orange Data Mining
           - Use the File widget to load the TAB file
           
        3. ML model metrics from Spark:
           Accuracy: {metrics.get('accuracy', 'N/A')}
           
        4. Example workflow created:
           {workflow_path}
           
        5. To run Spark queries directly:
           spark_df = spark.sql("SELECT * FROM demo_data")
           
        The integration is now set up and ready to use!
        """
        
        print(instructions)
        logging.info("Demo completed")
        
        return {
            "orange_file": str(orange_file),
            "workflow": str(workflow_path),
            "metrics": metrics
        }
    
    def close(self):
        """Close the Spark session"""
        if self.spark:
            self.spark.stop()
            logging.info("Spark session closed")

if __name__ == "__main__":
    integration = OrangeSparkIntegration()
    try:
        integration.demo_integration()
    finally:
        integration.close() 