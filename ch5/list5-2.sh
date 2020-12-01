# リスト5-2. Cloud Storageのバケットの作成
# USマルチリージョンに、[プロジェクト名]-gcpbook-ch5という名前のバケットを作成します。
gsutil mb -l US gs://$(gcloud config get-value project)-gcpbook-ch5/
