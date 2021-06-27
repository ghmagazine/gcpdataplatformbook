# ファイルetl_spark.pyをCloud Storageへアップロードします。
gsutil cp etl_spark.py gs://$(gcloud config get-value project)-gcpbook-ch5/etl/etl_spark.py
