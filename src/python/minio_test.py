#!/usr/bin/env python3
import os
import pandas as pd
from minio import Minio
from minio.error import S3Error
import io

# MinIO credentials from environment variables
minio_endpoint = os.environ.get("MINIO_ENDPOINT", "http://minio:9000").replace("http://", "")
minio_access_key = os.environ.get("MINIO_ACCESS_KEY", "minioadmin")
minio_secret_key = os.environ.get("MINIO_SECRET_KEY", "minioadmin")

def test_minio_connection():
    """Test connection to MinIO and create a sample bucket."""
    try:
        # Initialize MinIO client
        client = Minio(
            endpoint=minio_endpoint,
            access_key=minio_access_key,
            secret_key=minio_secret_key,
            secure=False  # Set to True if using HTTPS
        )

        # Make a bucket if it does not exist
        bucket_name = "demo-bucket"
        if not client.bucket_exists(bucket_name):
            client.make_bucket(bucket_name)
            print(f"Bucket {bucket_name} created successfully")
        else:
            print(f"Bucket {bucket_name} already exists")

        # Create sample data
        df = pd.DataFrame({
            "id": range(1, 6),
            "name": ["Alice", "Bob", "Charlie", "David", "Eve"],
            "age": [25, 30, 35, 40, 45]
        })

        # Convert DataFrame to CSV in memory
        csv_buffer = io.StringIO()
        df.to_csv(csv_buffer, index=False)
        csv_content = csv_buffer.getvalue().encode("utf-8")

        # Upload to MinIO
        file_name = "sample_data.csv"
        client.put_object(
            bucket_name=bucket_name,
            object_name=file_name,
            data=io.BytesIO(csv_content),
            length=len(csv_content),
            content_type="application/csv"
        )
        print(f"File {file_name} uploaded to bucket {bucket_name}")

        # List all objects in the bucket
        print("Objects in bucket:")
        objects = client.list_objects(bucket_name)
        for obj in objects:
            print(f" - {obj.object_name} (size: {obj.size} bytes)")

        # Download the file and print its contents
        response = client.get_object(bucket_name, file_name)
        data = response.read().decode("utf-8")
        print(f"\nContents of {file_name}:")
        print(data)

        # Close the response
        response.close()
        response.release_conn()

        print("\nMinIO connection test completed successfully!")
        return True

    except S3Error as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    print("Testing MinIO connection...")
    test_minio_connection()
