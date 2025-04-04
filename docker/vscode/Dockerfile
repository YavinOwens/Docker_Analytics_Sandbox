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
    && rm -rf /var/lib/apt/lists/*

# Install Oracle Instant Client
RUN mkdir -p /opt/oracle \
    && cd /opt/oracle \
    && wget https://download.oracle.com/otn_software/linux/instantclient/219000/instantclient-basic-linux.x64-21.9.0.0.0dbru.zip \
    && unzip instantclient-basic-linux.x64-21.9.0.0.0dbru.zip \
    && rm instantclient-basic-linux.x64-21.9.0.0.0dbru.zip \
    && cd instantclient_21_9 \
    && rm -f libclntsh.so libocci.so \
    && ln -s libclntsh.so.21.1 libclntsh.so \
    && ln -s libocci.so.21.1 libocci.so

# Set environment variables for Oracle
ENV ORACLE_HOME=/opt/oracle/instantclient_21_9
ENV LD_LIBRARY_PATH=$ORACLE_HOME
ENV PATH=$PATH:$ORACLE_HOME

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

# Create workspace directory and set permissions
RUN mkdir -p /home/coder/project && \
    chown -R coder:coder /home/coder

# Expose code-server port
EXPOSE 8080

# Start code-server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none"]
