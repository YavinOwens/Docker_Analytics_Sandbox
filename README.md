# Docker Analytics Sandbox

A comprehensive data analytics platform that integrates various data tools and services in Docker containers.

## Overview

This platform provides a unified interface for data analysis, machine learning, and data visualization, featuring:

- React-based UI with Databricks-inspired design
- Oracle database integration
- Apache Spark integration
- MinIO object storage
- FastAPI backend services
- Qdrant vector database
- Langflow and Ollama for AI/ML workflows

## Architecture

The platform consists of multiple containerized services:

- **React App UI**: Modern web interface for data analysis and visualization
- **Integration Service**: FastAPI backend that connects to various data sources
- **Oracle Database**: For relational data storage and SQL queries
- **Apache Spark**: For distributed data processing
- **MinIO**: For object storage (S3-compatible)
- **Qdrant**: Vector database for similarity search
- **Langflow**: Visual AI/ML workflow builder
- **Ollama**: AI model serving

## UI Components

The UI is built using React with Tailwind CSS for styling. The main components include:

- `App.js`: Main application entry point
- `DatabricksUI.js`: The primary UI component with a Databricks-inspired interface
- `DataComponent.js`: Component for data exploration and SQL queries
- `ReposComponent.js`: Component for repository and file management

## File Structure

```
Docker_Analytics_Sandbox/
├── docker-compose.yml              # Docker services configuration
├── integration/                    # Backend integration service
│   ├── Dockerfile                  # Docker build for integration service
│   ├── oracle_client.py            # Oracle database client
│   └── standalone_api.py           # FastAPI application
├── src/                            # Frontend source code
│   └── react-app/                  # React application
│       ├── Dockerfile              # Docker build for React app
│       ├── package.json            # Node.js dependencies
│       └── src/                    # React source files
│           ├── App.js              # Main App component
│           ├── components/         # UI components
│           │   ├── DataComponent.js   # Data exploration component
│           │   └── ReposComponent.js  # Repository management
│           ├── services/           # API client services
│           │   ├── minioClient.js  # MinIO integration
│           │   └── oracleClient.js # Oracle DB integration
│           └── index.js            # React entry point
```

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Git

### Installation and Setup

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/Docker_Analytics_Sandbox.git
   cd Docker_Analytics_Sandbox
   ```

2. Start the containers:
   ```
   docker compose up -d
   ```

3. Access the platform:
   - React App UI: http://localhost:3001
   - Integration API: http://localhost:8000
   - MinIO Console: http://localhost:9001
   - Langflow: http://localhost:7860

## Available Services

| Service | URL | Description |
|---------|-----|-------------|
| React App | http://localhost:3001 | Main user interface |
| RDS UI | http://localhost:3000 | Alternative UI |
| Integration API | http://localhost:8000 | Backend API |
| SQL IDE | http://localhost:8080 | SQL development environment |
| MinIO | http://localhost:9001 | Object storage UI |
| Langflow | http://localhost:7860 | Workflow builder |
| Spark Master UI | http://localhost:8081 | Spark cluster management |

## Development

The UI is built using:
- React 18
- Tailwind CSS for styling
- Service integration components

The backend uses:
- FastAPI for the REST API
- cx_Oracle for Oracle database connections
- Various connectors for different services

## Note on Oracle Integration

The Oracle integration uses ARM64-compatible libraries for Apple Silicon machines (M1/M2/M3). Mock data is provided when the Oracle service is unavailable.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Services

*   **IDE:** VS Code (code-server) based environment with Python and necessary clients.
*   **Spark Cluster:** Apache Spark master and worker nodes.
*   **Database:** Oracle Free database.
*   **Object Storage:** Minio (S3 compatible).
*   **AI - Vector DB:** Qdrant.
*   **AI - LLM Runner:** Ollama.
*   **AI - Flow Builder:** Langflow.
*   **Integration Service:** Custom Python service (details in `Dockerfile.integration`).

## Python Requirements

The following Python packages are used across the different services (primarily IDE and Integration):

```
# From requirements.txt (Integration Service & potentially IDE)
pandas>=1.5.0
SQLAlchemy>=2.0.31
cx_Oracle==8.3.0
minio>=7.2.0
faker>=18.0.0
pyyaml>=6.0.0
python-dateutil>=2.8.2
numpy>=1.21.0
scipy>=1.12.0
geopy>=2.4.1
yfinance>=0.2.36
requests==2.31.0
qdrant-client==1.7.3
pyspark==3.5.1
python-dotenv==1.0.1
jupyter==1.0.0
notebook==7.0.7

# From requirements-ide.txt (Specifically for IDE)
# pyspark==3.5.1 (already listed)
findspark
# cx_Oracle (already listed)
# minio (already listed)
# python-dotenv (already listed)

# Unique packages consolidated:
pandas>=1.5.0
SQLAlchemy>=2.0.31
cx_Oracle==8.3.0
minio>=7.2.0
faker>=18.0.0
pyyaml>=6.0.0
python-dateutil>=2.8.2
numpy>=1.21.0
scipy>=1.12.0
geopy>=2.4.1
yfinance>=0.2.36
requests==2.31.0
qdrant-client==1.7.3
pyspark==3.5.1
python-dotenv==1.0.1
jupyter==1.0.0
notebook==7.0.7
findspark
```

**Note:** The `Dockerfile.ide` uses `requirements-ide.txt` for installation, and `Dockerfile.integration` uses `requirements.txt`.

## Setup

1.  Ensure Docker and Docker Compose are installed.
2.  Place necessary files (e.g., `Dockerfile.integration`, `requirements.txt`) in the root directory.
3.  Run `docker-compose up -d --build`.

## Accessing Services

*   IDE (code-server): http://localhost:8080
*   Spark Master UI: http://localhost:8081
*   Spark Worker UI: http://localhost:8082
*   Oracle DB: Connect via client on port 1521 (service name: FREE)
*   Minio Console: http://localhost:9001 (Login: minioadmin/minioadmin)
*   Langflow: http://localhost:7860
*   Ollama API: http://localhost:11434
*   Qdrant API: http://localhost:6333
*   Integration Service: (No direct UI unless built)

## 🎓 Free for Education
This project is completely free for:
- University Students
- College Students
- Educational Institutions
- Self-Learners
- Anyone without access to paid subscription services

We believe in making enterprise-grade development tools accessible to everyone, especially students and learners who may not have access to expensive commercial solutions.

![Docker Environment Screenshot](./docs/images/docker_desktop.png)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Project Structure

```
.
├── config/
│   └── docker/
│       ├── dev/         # Development environment configs
│       └── prod/        # Production environment configs
├── docker/
│   ├── vscode/         # VS Code Server configuration
│   ├── oracle/         # Oracle DB initialization
│   ├── minio/          # MinIO configuration
│   └── ollama/         # Ollama AI models
├── src/
│   ├── python/         # Python source code
│   ├── sql/           # SQL scripts
│   └── tests/         # Test files
└── docs/              # Documentation
```

## Component Licenses

This project integrates several components, each with its own license:
- Oracle Database XE: [OTN License Agreement](https://www.oracle.com/downloads/licenses/database-11g-express-edition-license.html)
- Docker: [Apache License 2.0](https://www.docker.com/legal/components-licenses)
- MinIO: [GNU AGPL v3](https://github.com/minio/minio/blob/master/LICENSE)
- VS Code Server: [MIT License](https://github.com/microsoft/vscode/blob/main/LICENSE.txt)

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for detailed licensing information.

## Overview

This sandbox environment combines powerful data tools into a cohesive development platform:

- **Oracle Database**: Enterprise-grade relational database for learning SQL and database management
- **MinIO**: S3-compatible object storage for understanding modern data lake architectures
- **VS Code Server**: Browser-based IDE with full development capabilities
- **Ollama**: Local AI model integration for learning AI/ML workflows

### Educational Benefits
- **No Subscription Costs**: Complete development environment at zero cost
- **Industry-Standard Tools**: Learn the same tools used in enterprise environments
- **Hands-On Experience**: Practical experience with real-world technologies
- **Local Development**: No cloud costs or credit card required
- **Comprehensive Learning**: From basic SQL to advanced data engineering

Current Resource Usage (as of April 2024):
- CPU Usage: 7.08% of 800% (8 CPUs available)
- Memory Usage: 1.04GB / 4.69GB
- Storage: Efficient container sizes with minimal overhead

## Prerequisites

- Docker Desktop installed
- Minimum 8GB RAM recommended (4GB required)
- 20GB free disk space
- Git for version control

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/YavinOwens/Docker_Analytics_Sandbox.git
   cd Docker_Analytics_Sandbox
   ```

2. Development Setup:
   ```bash
   cd config/docker/dev
   cp .env.example .env  # Configure your environment variables
   docker-compose up -d
   ```

3. Access the development environment:
   - VS Code Server: http://localhost:8080
   - MinIO Console: http://localhost:9001
   - Oracle Database: localhost:1521
   - Ollama AI: http://localhost:11434

## Connection Details

### Oracle Database Connections

#### VS Code Database Client Connection (Inside code-server)
```sql
Host: SQL_PY_Sandbox-oracle
Port: 1521
Service Name: FREE
Username: system
Password: oracle
Connection String: system/oracle@//SQL_PY_Sandbox-oracle:1521/FREE
```

#### External Connection (From your local machine)
```sql
Host: localhost
Port: 1521
Service Name: FREE
Username: system
Password: oracle
Connection String: system/oracle@//localhost:1521/FREE
```

### MinIO Object Storage
```
Internal API Endpoint: http://SQL_PY_Sandbox-minio:9000
External API Endpoint: http://localhost:9000
Web Console: http://localhost:9001
Access Key: minioadmin
Secret Key: minioadmin
Default Bucket: sql-scripts
```

### Development Environment
- VS Code Server with pre-configured extensions
- Oracle Database XE
- MinIO Object Storage
- Ollama AI Integration
- Persistent volumes for all data
- Shared network for inter-container communication



Development volumes:
- sql_py_sandbox_minio_data
- sql_py_sandbox_oracle_data
- sql_py_sandbox_ollama_data
- sql_py_sandbox_vscode_extensions
- sql_py_sandbox_vscode_user_data


### Network Configuration
- Development: sql_py_sandbox_network
- Production: sql_py_sandbox_network_prod

## Troubleshooting


   ```bash
   docker-compose exec vscode python -m pytest /home/coder/project/src/tests
   ```

