FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gcc \
    g++ \
    make \
    supervisor \
    iputils-ping \
    libaio1 \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Oracle Instant Client for ARM64
WORKDIR /opt/oracle

RUN curl -o instantclient-basic-linux.arm64.zip https://download.oracle.com/otn_software/linux/instantclient/191000/instantclient-basic-linux.arm64-19.10.0.0.0dbru.zip \
    && unzip instantclient-basic-linux.arm64.zip \
    && rm instantclient-basic-linux.arm64.zip \
    && cd /opt/oracle/instantclient_19_10 \
    && rm -f libclntsh.so \
    && ln -s libclntsh.so.19.1 libclntsh.so \
    && rm -f libocci.so \
    && ln -s libocci.so.19.1 libocci.so \
    && echo /opt/oracle/instantclient_19_10 > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig

# Set Oracle environment variables
ENV ORACLE_HOME=/opt/oracle/instantclient_19_10
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_19_10
ENV PATH=$PATH:/opt/oracle/instantclient_19_10

# Setup application directory
WORKDIR /app

# Copy requirements and install packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Set environment variables for Oracle
ENV ORACLE_SERVICE=FREEPDB1
ENV ORACLE_USER=analytics
ENV ORACLE_PASSWORD=analytics
ENV ORACLE_HOST=oracle
ENV ORACLE_PORT=1521

# Run the application
CMD ["uvicorn", "standalone_api:app", "--host", "0.0.0.0", "--port", "8000", "--reload"] 