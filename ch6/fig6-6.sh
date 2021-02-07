# DAGの実行時に必要となる環境変数PROJECT_IDを、作成した
# Cloud Composerの環境gcpbook-ch6に設定します。
gcloud composer environments update gcpbook-ch6 \
  --location us-central1 \
  --update-env-variables=PROJECT_ID=$(gcloud config get-value project)
