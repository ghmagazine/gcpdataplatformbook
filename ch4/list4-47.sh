# リスト4-47. Cloud Storageへのetl_spark.pyのアップロード
# ファイルetl_spark.pyをCloud Storageへアップロードします。
gsutil cp etl_spark.py gs://$(gcloud config get-value project)-gcpbook-ch4/etl/etl_spark.py