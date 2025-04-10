FROM codercom/code-server:latest

USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \
  python3-pip \
  python3-venv \
  libaio1 \
  wget \
  unzip \
  curl \
  libicu-dev \
  icu-devtools \
  && rm -rf /var/lib/apt/lists/*

# Install Oracle Instant Client
RUN mkdir -p /opt/oracle && \
  cd /opt/oracle && \
  wget https://download.oracle.com/otn_software/linux/instantclient/219000/instantclient-basic-linux.x64-21.9.0.0.0dbru.zip && \
  unzip instantclient-basic-linux.x64-21.9.0.0.0dbru.zip && \
  rm instantclient-basic-linux.x64-21.9.0.0.0dbru.zip && \
  cd instantclient_21_9 && \
  ln -s libclntsh.so.21.1 libclntsh.so && \
  ln -s libocci.so.21.1 libocci.so && \
  echo /opt/oracle/instantclient_21_9 > /etc/ld.so.conf.d/oracle-instantclient.conf && \
  ldconfig

# Create Oracle network configuration directories
RUN mkdir -p /home/coder/Oracle/network/admin

# Set environment variables for Oracle
ENV ORACLE_HOME=/opt/oracle/instantclient_21_9
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_21_9:$LD_LIBRARY_PATH
ENV TNS_ADMIN=/opt/oracle/instantclient_21_9/network/admin
ENV PATH=/opt/oracle/instantclient_21_9:$PATH

# Create tnsnames.ora file
RUN echo "FREE = \n\
  (DESCRIPTION = \n\
  (ADDRESS = (PROTOCOL = TCP)(HOST = SQL_PY_Sandbox-oracle)(PORT = 1521)) \n\
  (CONNECT_DATA = \n\
  (SERVER = DEDICATED) \n\
  (SERVICE_NAME = FREE) \n\
  ) \n\
  )" > /home/coder/Oracle/network/admin/tnsnames.ora

# Set environment variable for .NET Globalization
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Set proper ownership
RUN chown -R coder:coder /home/coder/Oracle

# Create and switch to non-root user
USER coder

# Set up Python environment
RUN python3 -m venv /home/coder/venv
ENV PATH="/home/coder/venv/bin:$PATH"

# Install Python packages
RUN pip install --no-cache-dir \
  pandas \
  numpy \
  cx_Oracle \
  minio \
  sqlalchemy \
  python-dotenv \
  pytest

WORKDIR /home/coder/project

# Install VSCode Python extension
RUN code-server --install-extension ms-python.python

# Create workspace directory
RUN mkdir -p /home/coder/project

# Expose code-server port
EXPOSE 8080

# Start code-server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none"]
