from blob_storage import BlobStorage
import pandas as pd
import os
from datetime import datetime, timedelta

def test_blob_storage():
    try:
        # Initialize storage
        storage = BlobStorage()
        print("Successfully connected to MinIO storage")

        # Create test directories
        storage.create_staging_directory("raw_data")
        storage.create_staging_directory("processed_data")
        storage.create_dumps_directory("archived_data")
        print("Created test directories")

        # Create a test CSV file
        df = pd.DataFrame({
            'date': [datetime.now() + timedelta(days=i) for i in range(5)],
            'value': [i * 100 for i in range(5)]
        })
        test_file = "test_data.csv"
        df.to_csv(test_file, index=False)
        print("Created test CSV file")

        # Upload to staging
        storage.upload_to_staging(test_file, "raw_data/test_data.csv")
        print("Uploaded file to staging")

        # List files in staging
        staging_files = storage.list_staging_files()
        print("Files in staging:", staging_files)

        # Get file info
        file_info = storage.get_file_info("staging", "raw_data/test_data.csv")
        print("File info:", file_info)

        # Download the file
        downloaded_file = "downloaded_test_data.csv"
        storage.download_from_staging("raw_data/test_data.csv", downloaded_file)
        print("Downloaded file from staging")

        # Archive to dumps
        archived_path = storage.archive_to_dumps("raw_data/test_data.csv")
        print("Archived file to dumps:", archived_path)

        # List files in dumps
        dumps_files = storage.list_dumps_files()
        print("Files in dumps:", dumps_files)

        # Clean up local files
        os.remove(test_file)
        os.remove(downloaded_file)
        print("Cleaned up local files")

    except Exception as e:
        print("Error during test:", str(e))
        raise

if __name__ == "__main__":
    test_blob_storage() 