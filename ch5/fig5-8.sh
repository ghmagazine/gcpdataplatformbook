# Cloud Storage上に作成したユーザ行動ログのファイルの一覧を確認します。
gsutil ls gs://$(gcloud config get-value project)-gcpbook-ch5/data/events/20181001/
