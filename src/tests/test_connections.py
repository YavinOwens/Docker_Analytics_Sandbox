
import os
import cx_Oracle
from minio import Minio
import sys

def test_oracle_connection():
    try:
        # Get Oracle connection details from environment variables
        host = os.environ.get('ORACLE_HOST', 'oracle')
        port = os.environ.get('ORACLE_PORT', '1521')
        service = os.environ.get('ORACLE_SERVICE', 'ORCLPDB1')
        user = os.environ.get('ORACLE_USER', 'system')
        password = os.environ.get('ORACLE_PASSWORD', 'oracle')

        # Create connection string
        dsn = cx_Oracle.makedsn(host, port, service_name=service)

        # Connect to Oracle
        connection = cx_Oracle.connect(user, password, dsn)
        print("✅ Oracle connection successful!")

        # Test a simple query
        cursor = connection.cursor()
        cursor.execute("SELECT SYSDATE FROM DUAL")
        result = cursor.fetchone()
        print(f"Oracle server time: {result[0]}")

        cursor.close()
        connection.close()
        return True
    except Exception as e:
        print(f"❌ Oracle connection failed: {str(e)}")
        return False

def test_minio_connection():
    try:
        # Get MinIO connection details from environment variables
        endpoint = os.environ.get('MINIO_ENDPOINT', 'minio:9000')
        access_key = os.environ.get('MINIO_ACCESS_KEY', 'minioadmin')
        secret_key = os.environ.get('MINIO_SECRET_KEY', 'minioadmin')

        # Create MinIO client
        client = Minio(
            endpoint,
            access_key=access_key,
            secret_key=secret_key,
            secure=False  # Set to True if using HTTPS
        )

        # Test bucket operations
        bucket_name = "sql-scripts"

        # Check if bucket exists, create if not
        if not client.bucket_exists(bucket_name):
            client.make_bucket(bucket_name)
            print(f"✅ Created MinIO bucket: {bucket_name}")
        else:
            print(f"✅ MinIO bucket exists: {bucket_name}")

        # List buckets to verify connection
        buckets = client.list_buckets()
        print("Available MinIO buckets:")
        for bucket in buckets:
            print(f"  - {bucket.name}")

        return True
    except Exception as e:
        print(f"❌ MinIO connection failed: {str(e)}")
        return False

if __name__ == "__main__":
    print("Testing connections...")
    oracle_success = test_oracle_connection()
    minio_success = test_minio_connection()

    if oracle_success and minio_success:
        print("\n✅ All connections successful!")
        sys.exit(0)
    else:
        print("\n❌ Some connections failed!")
        sys.exit(1)
=======
import cx_Oracle
from qdrant_client import QdrantClient
import requests
import time
import subprocess
import os

def test_oracle_connection():
    print("Testing Oracle connection...")
    try:
        # Get connection details from environment variables
        user = os.getenv('ORACLE_USER', 'app_user')
        password = os.getenv('ORACLE_PASSWORD', 'app_password')
        host = os.getenv('ORACLE_HOST', 'sql_stuff-oracle-1')
        port = os.getenv('ORACLE_PORT', '1521')
        service = os.getenv('ORACLE_SERVICE', 'FREEPDB1')

        # Construct connection string
        dsn = cx_Oracle.makedsn(host, port, service_name=service)

        conn = cx_Oracle.connect(user=user, password=password, dsn=dsn)
        cursor = conn.cursor()
        cursor.execute("SELECT table_name FROM user_tables")
        tables = cursor.fetchall()
        print("Successfully connected to Oracle!")
        print("Available tables:")
        for table in tables:
            print(f"- {table[0]}")
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Error connecting to Oracle: {e}")

def test_qdrant_connection():
    print("\nTesting Qdrant connection...")
    try:
        # Wait for Qdrant to be ready
        time.sleep(5)

        # Test REST API health endpoint
        health_response = requests.get("http://sql_stuff-qdrant-1:6333/healthz")
        if health_response.status_code == 200:
            print("Qdrant health check passed")
        else:
            print(f"Qdrant health check failed with status code: {health_response.status_code}")

        # Test Qdrant client
        client = QdrantClient("sql_stuff-qdrant-1", port=6333)
        collections = client.get_collections()
        print("Successfully connected to Qdrant!")
        print("Available collections:")
        for collection in collections.collections:
            print(f"- {collection.name}")
    except Exception as e:
        print(f"Error connecting to Qdrant: {e}")

def test_ollama_service():
    print("\nTesting Ollama service...")
    try:
        # Test Ollama API with retries
        max_retries = 3
        retry_delay = 5

        for attempt in range(max_retries):
            try:
                response = requests.get("http://localhost:11434/api/tags", timeout=10)
                if response.status_code == 200:
                    models = response.json().get("models", [])
                    print("Successfully connected to Ollama!")
                    print("Available models:")
                    for model in models:
                        print(f"- {model['name']}")
                    return
                else:
                    print(f"Ollama API check failed with status code: {response.status_code}")
            except requests.exceptions.RequestException as e:
                if attempt < max_retries - 1:
                    print(f"Attempt {attempt + 1} failed, retrying in {retry_delay} seconds...")
                    time.sleep(retry_delay)
                else:
                    raise e
    except Exception as e:
        print(f"Error connecting to Ollama: {e}")

if __name__ == "__main__":
    # Add a delay to ensure services are ready
    time.sleep(10)
    test_oracle_connection()
    test_qdrant_connection()
    test_ollama_service()

