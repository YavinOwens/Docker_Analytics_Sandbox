# Docker Analytics Sandbox (Containerized Version)

A fully containerized development environment for data analysts and data engineers, providing enterprise-grade tools at minimal cost.

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

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/YavinOwens/Docker_Analytics_Sandbox.git
   cd Docker_Analytics_Sandbox
   ```

2. Set up development environment:
   ```bash
   cd config/docker/dev
   cp .env.example .env  # Configure your environment variables
   docker-compose up -d
   ```

3. Access development tools:
   - VS Code Server: http://localhost:8080
   - MinIO Console: http://localhost:9001
   - Oracle Database: localhost:1521
   - Ollama AI: http://localhost:11434

## Production Deployment

1. Configure production environment:
   ```bash
   cd config/docker/prod
   cp .env.example .env  # Configure secure credentials
   ```

2. Start production services:
   ```bash
   docker-compose up -d
   ```

## Container Details

### Development Environment
- VS Code Server with pre-configured extensions
- Oracle Database XE
- MinIO Object Storage
- Ollama AI Integration
- Persistent volumes for all data
- Shared network for inter-container communication

### Production Environment
- Hardened security configurations
- Separate volume namespaces
- Environment variable-based configuration
- Health checks for all services

## Volume Management

Development volumes:
- sql_py_sandbox_minio_data
- sql_py_sandbox_oracle_data
- sql_py_sandbox_ollama_data
- sql_py_sandbox_vscode_extensions
- sql_py_sandbox_vscode_user_data

Production volumes:
- sql_py_sandbox_minio_data_prod
- sql_py_sandbox_oracle_data_prod

## Network Configuration

- Development: sql_py_sandbox_network
- Production: sql_py_sandbox_network_prod

## Contributing

1. Development workflow:
   - All development happens inside VS Code Server container
   - Source code is mounted from ./src
   - Tests run in containerized environment

2. Testing:
   ```bash
   docker-compose exec vscode python -m pytest /home/coder/project/src/tests
   ```

## License

MIT License - see LICENSE file for details.

## Third-Party Components

See THIRD_PARTY_NOTICES.md for detailed licensing information of included components.
