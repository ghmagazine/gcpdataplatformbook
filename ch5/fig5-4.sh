# firebase-public-project:analytics_153293282.events_20181001という
# BigQueryテーブルのデータ（Firebaseデモプロジェクトの公開サンプルデータ）を、
# 前述の手順4.で作成したCloud Storageのバケットに、GZIP圧縮のJSON形式の
# ファイルでエクスポートします。
bq --location=us extract \
  --destination_format NEWLINE_DELIMITED_JSON \
  --compression GZIP \
  firebase-public-project:analytics_153293282.events_20181001 \
  gs://$(gcloud config get-value project)-gcpbook-ch5/data/events/20181001/*.json.gz
