import os
import sys
import pytest
from pyspark.sql import SparkSession

# Automatically bind PySpark to the running Python executable
os.environ["PYSPARK_PYTHON"] = sys.executable
os.environ["PYSPARK_DRIVER_PYTHON"] = sys.executable

@pytest.fixture(scope="session")
def spark():
    spark_session = (
        SparkSession.builder
        .appName("ETL_Unit_Tests")
        .master("local[1]")  # Keep local execution single-threaded for speed
        .getOrCreate()
    )
    yield spark_session
    spark_session.stop()