#!/bin/bash

# MinIO configuration
MINIO_ENDPOINT="localhost:9000"
MINIO_ACCESS_KEY="minioadmin"
MINIO_SECRET_KEY="minioadmin"
BUCKET_NAME="sql-scripts"

# Create bucket if it doesn't exist
mc alias set myminio http://$MINIO_ENDPOINT $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
mc mb myminio/$BUCKET_NAME --ignore-existing

# Push procedures
mc cp scripts/sql_files/procedures/leave_and_survey_procedures.sql myminio/$BUCKET_NAME/procedures/
mc cp scripts/sql_files/functions/leave_and_survey_functions.sql myminio/$BUCKET_NAME/functions/
mc cp scripts/sql_files/triggers/leave_and_survey_triggers.sql myminio/$BUCKET_NAME/triggers/
mc cp scripts/sql_files/rollback/rollback_leave_and_survey.sql myminio/$BUCKET_NAME/rollback/
mc cp scripts/sql_files/verify_procedures.sql myminio/$BUCKET_NAME/verification/
mc cp scripts/sql_files/commit_procedures.sql myminio/$BUCKET_NAME/commit/

# Set proper permissions
mc policy set download myminio/$BUCKET_NAME

# Verify uploads
echo "Verifying uploaded files..."
mc ls myminio/$BUCKET_NAME/procedures/
mc ls myminio/$BUCKET_NAME/functions/
mc ls myminio/$BUCKET_NAME/triggers/
mc ls myminio/$BUCKET_NAME/rollback/
mc ls myminio/$BUCKET_NAME/verification/
mc ls myminio/$BUCKET_NAME/commit/

echo "Files successfully pushed to MinIO!" 