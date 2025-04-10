import findspark
findspark.init()

from pyspark.sql import SparkSession

def get_spark_session(app_name="OracleSparkApp"):
    """Create and return a Spark session configured to connect to the spark-master service."""
    spark = SparkSession.builder         .appName(app_name)         .config("spark.master", "spark://spark-master:7077")         .getOrCreate()
    
    return spark

if __name__ == "__main__":
    # Test the connection
    spark = get_spark_session("TestConnection")
    
    # Create some test data
    data = [(1, "John"), (2, "Jane"), (3, "Bob")]
    df = spark.createDataFrame(data, ["id", "name"])
    
    # Show the data
    print("Successfully connected to Spark!")
    print("Sample data:")
    df.show()
    
    # Stop the session
    spark.stop()
