FROM ubuntu:22.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk-headless \
    wget \
    curl \
    python3.10 \
    python3-pip \
    git \
    procps \
    net-tools \
    ca-certificates \
    openssl \
    dnsutils \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# After pip upgrade, update certificates
RUN update-ca-certificates

# Find and set JAVA_HOME dynamically
RUN export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java)))) && \
    echo "export JAVA_HOME=$JAVA_HOME" >> /etc/environment && \
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/environment

# Set Java environment variables (will be overridden by dynamic detection)
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Download and install Spark 3.5.6
RUN wget -q https://downloads.apache.org/spark/spark-3.5.6/spark-3.5.6-bin-hadoop3.tgz && \
    tar xf spark-3.5.6-bin-hadoop3.tgz && \
    mv spark-3.5.6-bin-hadoop3 /opt/spark && \
    rm spark-3.5.6-bin-hadoop3.tgz

# Set Spark environment variables
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH
ENV PYSPARK_PYTHON=python3

# Create tmp directory with proper permissions
RUN mkdir -p /tmp/spark-events /tmp/spark && \
    chmod -R 777 /tmp/spark-events /tmp/spark

# Upgrade pip
RUN pip3 install --upgrade pip setuptools wheel

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Create necessary directories with proper permissions
RUN mkdir -p /workspace/notebooks /workspace/data/raw /workspace/data/processed /workspace/data/outputs /workspace/scripts && \
    chmod -R 777 /workspace

# Copy initialization script
COPY scripts/init-spark.sh /workspace/scripts/
RUN chmod +x /workspace/scripts/init-spark.sh

# Expose Jupyter and Spark UI ports
EXPOSE 8888 4040 4041

# Set default command to start Jupyter
CMD ["bash", "/workspace/scripts/init-spark.sh"]