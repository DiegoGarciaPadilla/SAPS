#!/bin/bash

echo "🚀 Starting Environment..."
echo "================================"

# Find Java installation dynamically
if [ -z "$JAVA_HOME" ] || [ ! -f "$JAVA_HOME/bin/java" ]; then
    echo "⚠️  JAVA_HOME not valid, detecting Java..."
    export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
    echo "   Detected JAVA_HOME: $JAVA_HOME"
fi

# Verify Java is working
echo "☕ Java Configuration:"
echo "   JAVA_HOME: $JAVA_HOME"
if [ -f "$JAVA_HOME/bin/java" ]; then
    $JAVA_HOME/bin/java -version 2>&1 | head -n 1
    echo "   ✅ Java executable found"
else
    echo "   ❌ Java executable NOT found at $JAVA_HOME/bin/java"
    # Try alternative paths
    for path in /usr/lib/jvm/java-8-openjdk-* /usr/lib/jvm/default-java; do
        if [ -f "$path/bin/java" ]; then
            export JAVA_HOME=$path
            echo "   ✅ Found Java at: $JAVA_HOME"
            break
        fi
    done
fi
echo ""

# Display system information
echo "📊 System Resources:"
echo "   CPU Cores: $(nproc)"
echo "   Memory: $(free -h | awk '/^Mem:/ {print $2}')"
echo ""

# Verify Spark installation
echo "⚡ Spark Configuration:"
echo "   SPARK_HOME: $SPARK_HOME"
echo "   Driver Memory: $SPARK_DRIVER_MEMORY"
echo "   Executor Memory: $SPARK_EXECUTOR_MEMORY"
echo ""

# Create and set permissions for Spark temp directories
mkdir -p /tmp/spark-events /tmp/spark
chmod -R 777 /tmp/spark-events /tmp/spark

# Start Jupyter Notebook
echo "📓 Starting Jupyter Notebook..."
echo "   Access at: http://localhost:8888"
echo "   Spark UI at: http://localhost:4040"
echo "================================"
echo ""

# Start Jupyter with custom configuration
cd /workspace/notebooks
jupyter notebook \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --NotebookApp.token="" \
    --NotebookApp.password="" \
    --notebook-dir=/workspace/notebooks