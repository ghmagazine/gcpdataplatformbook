# リスト5-11. DAGフォルダへのファイルのアップロード
# ファイルcount_users.pyを、Cloud Composerの環境のDAGのフォルダへアップロードします。
gcloud composer environments storage dags import \
  --environment gcpbook-ch5 --location us-central1 \
  --source count_users.py
