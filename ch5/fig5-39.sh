# 前工程で作成したcount-users.yamlをインポートし、
# Dataprocのワークフローテンプレートを作成します。
gcloud dataproc workflow-templates import count-users \
  --source=count-users.yaml \
  --region=us-central1
