from pathlib import Path
import logging
import os
import sys
import urllib.request

# ==========================================
# 1. STRUCTURED LOGGING CONFIGURATION
# ==========================================
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)
logger = logging.getLogger("AzureETLPipeline")


# ==========================================
# 2. DYNAMIC ENVIRONMENT BOOTSTRAPPER
# ==========================================
def setup_windows_hadoop_env():
    """Dynamically download and set up Hadoop dependencies for local Windows execution."""
    try:
        hadoop_dir = Path("C:/hadoop")
        hadoop_bin = hadoop_dir / "bin"
        hadoop_bin.mkdir(parents=True, exist_ok=True)

        winutils_path = hadoop_bin / "winutils.exe"
        hadoop_dll_path = hadoop_bin / "hadoop.dll"
        base_url = "https://raw.githubusercontent.com/cdarlint/winutils/master/hadoop-3.3.4/bin"

        if not winutils_path.exists():
            logger.info("Downloading winutils.exe for Windows Spark compatibility...")
            urllib.request.urlretrieve(f"{base_url}/winutils.exe", winutils_path)

        if not hadoop_dll_path.exists():
            logger.info("Downloading hadoop.dll for Windows Spark compatibility...")
            urllib.request.urlretrieve(f"{base_url}/hadoop.dll", hadoop_dll_path)

        os.environ["HADOOP_HOME"] = str(hadoop_dir)
        os.environ["PATH"] += os.pathsep + str(hadoop_bin)
        logger.info("HADOOP_HOME dynamically configured successfully.")

    except Exception as e:
        logger.error(
            f"Failed to initialize Windows Hadoop binaries: {str(e)}",
            exc_info=True,
        )
        raise RuntimeError("Environment bootstrap failed.") from e


# Execute bootstrap prior to PySpark imports
setup_windows_hadoop_env()

from pyspark.sql import DataFrame, SparkSession
from pyspark.sql import functions as F
from pyspark.sql.utils import AnalysisException


# ==========================================
# 3. ISOLATED ETL TRANSFORMATIONS (TESTABLE)
# ==========================================
def transform_user_data(df: DataFrame) -> DataFrame:
    """Filters active users and calculates a normalized full_name column."""
    return (
        df.filter(F.col("status") == "ACTIVE")
        .withColumn(
            "full_name", F.concat_ws(" ", F.col("first_name"), F.col("last_name"))
        )
        .select("user_id", "full_name", "status")
    )


# ==========================================
# 4. SPARK SESSION MANAGEMENT
# ==========================================
def create_spark_session(app_name: str = "AzureETLPipeline") -> SparkSession:
    """Initialize PySpark session with optimized Azure Storage configurations."""
    logger.info("Initializing SparkSession with Hadoop-Azure packages...")
    try:
        spark = (
            SparkSession.builder.appName(app_name)
            .config(
                "spark.jars.packages",
                "org.apache.hadoop:hadoop-azure:3.3.4,com.microsoft.azure:azure-storage:8.6.6",
            )
            .config("mapreduce.fileoutputcommitter.algorithm.version", "2")
            .config("spark.sql.parquet.compression.codec", "snappy")
            .getOrCreate()
        )

        # Retrieve storage environment variables dynamically
        account_name = os.getenv("AZURE_STORAGE_ACCOUNT_NAME")
        account_key = os.getenv("AZURE_STORAGE_ACCOUNT_KEY")

        if account_name and account_key:
            spark.conf.set(
                f"fs.azure.account.key.{account_name}.dfs.core.windows.net",
                account_key,
            )
            logger.info(
                f"Successfully configured Azure credentials for storage account: {account_name}"
            )
        else:
            logger.warning(
                "Azure storage environment variables not fully set. Running in local fallback mode."
            )

        return spark
    except Exception as e:
        logger.critical(
            f"Failed to instantiate SparkSession: {str(e)}", exc_info=True
        )
        sys.exit(1)


# ==========================================
# 5. MAIN ETL PIPELINE EXECUTION
# ==========================================
def run_pipeline():
    spark = None
    try:
        spark = create_spark_session()

        logger.info("Starting ETL Pipeline processing job...")

        account_name = os.getenv("AZURE_STORAGE_ACCOUNT_NAME")
        if not account_name:
            logger.warning("AZURE_STORAGE_ACCOUNT_NAME not set. Exiting execution.")
            return

        # Target Azure ADLS Gen2 path
        container_name = "data"
        base_path = f"abfss://{container_name}@{account_name}.dfs.core.windows.net"

        # Example mock data processing flow for local execution/testing
        logger.info("Creating sample raw data DataFrame...")
        raw_data = [
            (1, "Mark", "Mashifane", "ACTIVE"),
            (2, "Jane", "Doe", "INACTIVE"),
            (3, "John", "Smith", "ACTIVE"),
        ]
        schema = ["user_id", "first_name", "last_name", "status"]
        df_raw = spark.createDataFrame(raw_data, schema)

        logger.info("Applying business transformation logic...")
        df_transformed = transform_user_data(df_raw)

        logger.info(f"Writing transformed parquet data to Azure Storage: {base_path}/processed/users")
        (
            df_transformed.coalesce(1)
            .write.mode("overwrite")
            .parquet(f"{base_path}/processed/users")
        )

        logger.info("ETL Pipeline job completed successfully.")

    except AnalysisException as ae:
        logger.error(f"PySpark SQL/Analysis error encountered: {str(ae)}")
        sys.exit(1)
    except Exception as e:
        logger.error(
            f"Unexpected runtime failure during ETL execution: {str(e)}",
            exc_info=True,
        )
        sys.exit(1)
    finally:
        if spark:
            logger.info("Stopping active SparkSession and releasing resources...")
            spark.stop()


if __name__ == "__main__":
    run_pipeline()