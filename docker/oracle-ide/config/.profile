# ~/.profile: executed by the command interpreter for login shells

# include .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

# Activate Python virtual environment
if [ -f "$HOME/venv/bin/activate" ]; then
    . "$HOME/venv/bin/activate"
fi

# Set environment variables for Spark and Oracle
export SPARK_HOME=/opt/spark
export PYTHONPATH=$PYTHONPATH:$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip
export PYSPARK_PYTHON=$HOME/venv/bin/python
export PYSPARK_DRIVER_PYTHON=$HOME/venv/bin/python
export ORACLE_HOME=/opt/oracle/instantclient_21_9
export LD_LIBRARY_PATH=$ORACLE_HOME:$LD_LIBRARY_PATH
export PATH=$PATH:$ORACLE_HOME
