# リスト4-7. ファイル一覧の確認
# Cloud Storage上に作成したユーザ行動ログのファイルの一覧を確認します。
gsutil ls gs://$(gcloud config get-value project)-gcpbook-ch4/data/events/20181001/
