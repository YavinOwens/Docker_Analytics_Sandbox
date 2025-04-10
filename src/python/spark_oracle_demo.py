from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType
import os

# Initialize Spark Session
spark = SparkSession.builder \
    .appName("OracleSparkIntegration") \
    .config("spark.jars.packages", "com.oracle.database.jdbc:ojdbc8:19.3.0.0") \
    .getOrCreate()

# Oracle connection details
oracle_host = os.getenv("ORACLE_HOST", "oracle")
oracle_port = os.getenv("ORACLE_PORT", "1521")
oracle_service = os.getenv("ORACLE_SERVICE", "FREE")
oracle_user = os.getenv("ORACLE_USER", "system")
oracle_password = os.getenv("ORACLE_PASSWORD", "oracle")

# JDBC URL for Oracle
jdbc_url = f"jdbc:oracle:thin:@{oracle_host}:{oracle_port}/{oracle_service}"

# Example 1: Read data from Oracle
def read_from_oracle():
    try:
        # Read data from Oracle
        df = spark.read \
            .format("jdbc") \
            .option("url", jdbc_url) \
            .option("user", oracle_user) \
            .option("password", oracle_password) \
            .option("driver", "oracle.jdbc.driver.OracleDriver") \
            .option("query", "SELECT * FROM v$version") \
            .load()
        
        print("Oracle Version:")
        df.show(truncate=False)
        
    except Exception as e:
        print(f"Error reading from Oracle: {str(e)}")

# Example 2: Create a sample DataFrame and write to Oracle
def write_to_oracle():
    try:
        # Create sample data
        data = [("John", 25), ("Jane", 30), ("Bob", 35)]
        schema = StructType([
            StructField("name", StringType(), True),
            StructField("age", IntegerType(), True)
        ])
        
        df = spark.createDataFrame(data, schema)
        
        # Write to Oracle
        df.write \
            .format("jdbc") \
            .option("url", jdbc_url) \
            .option("user", oracle_user) \
            .option("password", oracle_password) \
            .option("driver", "oracle.jdbc.driver.OracleDriver") \
            .option("dbtable", "sample_people") \
            .mode("overwrite") \
            .save()
        
        print("Data written to Oracle successfully!")
        
    except Exception as e:
        print(f"Error writing to Oracle: {str(e)}")

# Example 3: Perform a complex operation
def complex_operation():
    try:
        # Read data from Oracle
        df = spark.read \
            .format("jdbc") \
            .option("url", jdbc_url) \
            .option("user", oracle_user) \
            .option("password", oracle_password) \
            .option("driver", "oracle.jdbc.driver.OracleDriver") \
            .option("query", "SELECT * FROM sample_people") \
            .load()
        
        # Perform some transformations
        result = df.groupBy("age").count()
        
        print("Age distribution:")
        result.show()
        
    except Exception as e:
        print(f"Error in complex operation: {str(e)}")

if __name__ == "__main__":
    print("Starting PySpark Oracle Demo...")
    
    # Run examples
    read_from_oracle()
    write_to_oracle()
    complex_operation()
    
    # Stop Spark session
    spark.stop() 