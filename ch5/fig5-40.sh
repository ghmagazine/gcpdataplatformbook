# 作成したDataprocのワークフローテンプレートcount-usersを実行します。
gcloud dataproc workflow-templates instantiate count-users \
  --region=us-central1 \
  --parameters=BUCKET=--bucket=$(gcloud config get-value project)-gcpbook-ch5,DT=--dt=20181001,MAIN_FILE=gs://$(gcloud config get-value project)-gcpbook-ch5/etl/etl_spark.py
