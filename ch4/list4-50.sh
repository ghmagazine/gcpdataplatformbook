# リスト4-50. Dataprocのワークフローテンプレートの実行
# 作成したDataprocのワークフローテンプレートcount-usersを実行します。
gcloud dataproc workflow-templates instantiate count-users \
  --region=us-central1 \
  --parameters=BUCKET=--bucket=$(gcloud config get-value project)-gcpbook-ch4,DT=--dt=20181001,MAIN_FILE=gs://$(gcloud config get-value project)-gcpbook-ch4/etl/etl_spark.py