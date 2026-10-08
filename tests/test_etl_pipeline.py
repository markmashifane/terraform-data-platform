import pytest
from pyspark.sql import SparkSession

# 1. Ensure Windows Hadoop environment setup is bootstrapped
from src.etl_pipeline import setup_windows_hadoop_env

setup_windows_hadoop_env()

from src.etl_pipeline import transform_user_data


# 2. Pytest Fixture for Local SparkSession
@pytest.fixture(scope="session")
def spark():
    """Creates a lightweight local SparkSession shared across all unit tests."""
    session = (
        SparkSession.builder.appName("PySparkUnitTestSuite")
        .master("local[2]")  # Run locally with 2 threads
        .config("spark.sql.shuffle.partitions", "1")  # Minimal partitions for fast tests
        .getOrCreate()
    )
    yield session
    session.stop()


# 3. Unit Test Cases
def test_transform_user_data_filters_inactive_users(spark):
    """Verify that transform_user_data filters out INACTIVE users."""
    # Arrange: Create sample input dataset
    input_data = [
        (1, "John", "Doe", "ACTIVE"),
        (2, "Jane", "Smith", "INACTIVE"),
        (3, "Mark", "Mashifane", "ACTIVE"),
    ]
    schema = ["user_id", "first_name", "last_name", "status"]
    input_df = spark.createDataFrame(input_data, schema)

    # Act: Run the transformation
    result_df = transform_user_data(input_df)
    results = result_df.collect()

    # Assert: Verify total active count and status values
    assert len(results) == 2
    assert all(row["status"] == "ACTIVE" for row in results)


def test_transform_user_data_concatenates_full_name(spark):
    """Verify that full_name is correctly formatted and original name columns are dropped."""
    # Arrange
    input_data = [(1, "Mark", "Mashifane", "ACTIVE")]
    schema = ["user_id", "first_name", "last_name", "status"]
    input_df = spark.createDataFrame(input_data, schema)

    # Act
    result_df = transform_user_data(input_df)
    row = result_df.first()

    # Assert
    assert row["full_name"] == "Mark Mashifane"
    assert "first_name" not in result_df.columns
    assert "last_name" not in result_df.columns