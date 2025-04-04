# Infrastructure Credentials and Connection Information

## Oracle Database Credentials

### Default Admin Access
- **Username**: `sys`
- **Password**: `Welcome123`
- **Role**: `SYSDBA`
- **Connection String**: `//localhost:1521/FREEPDB1`

### Application User
- **Username**: `app_user`
- **Password**: `app_password`
- **Connection String**: `//localhost:1521/FREEPDB1`

### Docker Container Information
- **Container Name**: `sql_stuff-oracle-1`
- **Port**: 1521
- **Database Name**: FREEPDB1
- **Health Check**: Enabled

### Connection Examples

#### SQLPlus
```bash
# Connect as sys admin
sqlplus sys/Welcome123@//localhost:1521/FREEPDB1 as sysdba

# Connect as app user
sqlplus app_user/app_password@//localhost:1521/FREEPDB1
```

#### Python (using cx_Oracle)
```python
import cx_Oracle

# Connect as sys admin
conn = cx_Oracle.connect('sys/Welcome123@localhost:1521/FREEPDB1', mode=cx_Oracle.SYSDBA)

# Connect as app user
conn = cx_Oracle.connect('app_user/app_password@localhost:1521/FREEPDB1')
```

## Qdrant Vector Database

### Connection Details
- **Host**: localhost
- **REST API Port**: 6333
- **GRPC API Port**: 6334
- **Health Check Endpoint**: http://localhost:6333/health

### Docker Container Information
- **Container Name**: qdrant
- **Image**: qdrant/qdrant:latest
- **Volumes**: qdrant_storage:/qdrant/storage
- **Health Check**: Enabled

### Connection Examples

#### Python (using qdrant-client)
```python
from qdrant_client import QdrantClient

client = QdrantClient("localhost", port=6333)
```

#### REST API Example
```bash
# Check cluster health
curl -X GET 'http://localhost:6333/health'

# List collections
curl -X GET 'http://localhost:6333/collections'
```

## Minio Credentials

### Web Interface Access
- **URL**: http://localhost:9000
- **Default Admin Credentials**:
  - Username: `minioadmin`
  - Password: `minioadmin`

### API Endpoints
- **S3 API Endpoint**: http://localhost:9000
- **Console Endpoint**: http://localhost:9001

### Connection Details
- **Host**: localhost
- **Port**: 9000
- **Region**: us-east-1 (default)
- **SSL/TLS**: Disabled (HTTP)

### Access Keys
#### Default Admin Access
- **Access Key**: `minioadmin`
- **Secret Key**: `minioadmin`

### Environment Variables
```bash
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
```

### Docker Container Information
- **Container Name**: minio
- **Ports**:
  - 9000 (API)
  - 9001 (Console)
- **Health Check**: Enabled

### SDK Connection Examples

#### AWS CLI
```bash
aws --endpoint-url http://localhost:9000 s3 ls
```

#### Python (using boto3)
```python
import boto3

s3_client = boto3.client(
    's3',
    endpoint_url='http://localhost:9000',
    aws_access_key_id='minioadmin',
    aws_secret_access_key='minioadmin'
)
```

#### Node.js
```javascript
const Minio = require('minio')

const minioClient = new Minio.Client({
    endPoint: 'localhost',
    port: 9000,
    useSSL: false,
    accessKey: 'minioadmin',
    secretKey: 'minioadmin'
})
```

## Security Notes
1. These are default credentials and should be changed in production
2. Access is currently configured without SSL/TLS
3. The services are exposed on localhost only
4. Recommended to change credentials after initial setup
5. Store sensitive credentials in environment variables or secure vaults in production

## Troubleshooting

### Oracle Database
1. Check if the Oracle container is running:
   ```bash
   docker ps | grep oracle
   ```
2. Verify Oracle container logs:
   ```bash
   docker logs sql_stuff-oracle-1
   ```
3. Test connection:
   ```bash
   docker exec -it sql_stuff-oracle-1 sqlplus app_user/app_password@//localhost:1521/FREEPDB1
   ```

### Qdrant
1. Check if the Qdrant container is running:
   ```bash
   docker ps | grep qdrant
   ```
2. Verify Qdrant container logs:
   ```bash
   docker logs qdrant
   ```
3. Test connection:
   ```bash
   curl http://localhost:6333/health
   ```

### Minio
1. Ensure ports 9000 and 9001 are not used by other services
2. Check if the Minio container is running:
   ```bash
   docker ps | grep minio
   ```
3. Verify Minio container logs:
   ```bash
   docker logs minio
   ```

## Additional Resources
- [Oracle Database Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/index.html)
- [Qdrant Documentation](https://qdrant.tech/documentation/)
- [Minio Documentation](https://min.io/docs/minio/container/index.html)
- [Minio Docker Hub](https://hub.docker.com/r/minio/minio/)
- [S3 API Reference](https://docs.min.io/docs/minio-client-complete-guide.html)
