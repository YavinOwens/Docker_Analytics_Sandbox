FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    libaio1 \
    && rm -rf /var/lib/apt/lists/*

# Install Oracle Instant Client
RUN mkdir -p /usr/lib/oracle/21 && cd /usr/lib/oracle/21 \
    && curl -O https://download.oracle.com/otn_software/linux/instantclient/219000/instantclient-basic-linux.x64-21.9.0.0.0dbru.zip \
    && unzip instantclient-basic-linux.x64-21.9.0.0.0dbru.zip \
    && rm instantclient-basic-linux.x64-21.9.0.0.0dbru.zip \
    && mv instantclient_21_9 client64 \
    && ln -s /usr/lib/oracle/21/client64/libclntsh.so.21.1 /usr/lib/oracle/21/client64/libclntsh.so

# Set environment variables
ENV ORACLE_HOME=/usr/lib/oracle/21/client64
ENV LD_LIBRARY_PATH=/usr/lib/oracle/21/client64/lib
ENV PATH=$ORACLE_HOME/bin:$PATH

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Expose the port
EXPOSE 8000

# Start the FastAPI server
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000"] 