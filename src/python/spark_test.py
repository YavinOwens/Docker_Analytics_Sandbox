import findspark
findspark.init()

from pyspark.sql import SparkSession
import time
import os
import socket

def get_spark_session(app_name="SparkUITest"):
    """Create a Spark session configured for the Docker environment"""
    spark = SparkSession.builder \
        .appName(app_name) \
        .master("spark://spark-master:7077") \
        .config("spark.ui.port", "4040") \
        .getOrCreate()

    return spark

if __name__ == "__main__":
    # Print environment info
    print(f"Hostname: {socket.gethostname()}")
    print(f"Testing connection to Spark master...")

    try:
        # Create Spark session
        spark = get_spark_session()
        print("Successfully connected to Spark!")

        # Create and process sample data
        print("Creating sample data...")
        data = [(i, f"person_{i}", i * 10) for i in range(1, 101)]
        df = spark.createDataFrame(data, ["id", "name", "age"])

        # Perform some operations
        print("Performing operations...")
        df.createOrReplaceTempView("people")
        result = spark.sql("SELECT * FROM people WHERE age > 50")

        print("Sample result:")
        result.show(5)

        # Get Spark UI URL
        spark_ui_url = spark.sparkContext.uiWebUrl
        print(f"Spark UI available at: {spark_ui_url}")

        # Keep application running to keep UI available
        print("Keeping application alive for 10 minutes so you can access the Spark UI...")
        print("Access the Spark UI in your browser.")
        time.sleep(600)

    except Exception as e:
        print(f"Error connecting to Spark: {e}")
        raise
