# ファイルcount_users.pyを、Cloud Composerの環境のDAGのフォルダへアップロードします。
gcloud composer environments storage dags import \
  --environment gcpbook-ch6 --location us-central1 \
  --source count_users.py
