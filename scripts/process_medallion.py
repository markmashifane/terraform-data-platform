import os
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, current_timestamp, to_date

spark = SparkSession.builder \
    .appName("MedallionDataPipeline") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .getOrCreate()

print("--- SPARK SESSION CREATED ---")

if not os.path.exists("./data"):
    os.makedirs("./data")

sample_json = """
[
  {"transaction_id": "TXN1001", "customer_id": "CUS881", "amount": 150.50, "timestamp": "2026-09-01T10:15:30Z"},
  {"transaction_id": "TXN1002", "customer_id": "CUS423", "amount": null, "timestamp": "2026-09-01T10:16:00Z"},
  {"transaction_id": "TXN1003", "customer_id": "CUS881", "amount": 89.99, "timestamp": "2026-09-01T10:20:12Z"}
]
"""
with open("./data/bronze_raw.json", "w") as f:
    f.write(sample_json)

df_bronze = spark.read.option("multiline", "true").json("./data/bronze_raw.json")
print("--- BRONZE LAYER ---")
df_bronze.show()

df_silver = df_bronze.filter(col("amount").isNotNull()) \
    .withColumn("processed_at", current_timestamp()) \
    .withColumn("transaction_date", to_date(col("timestamp")))
print("--- SILVER LAYER ---")
df_silver.show()

df_gold = df_silver.groupBy("customer_id").sum("amount").withColumnRenamed("sum(amount)", "total_spend")
print("--- GOLD LAYER ---")
df_gold.show()

spark.stop()
