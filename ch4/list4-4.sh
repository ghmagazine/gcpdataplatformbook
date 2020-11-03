# リスト4-4. BigQueryのデータセットの作成
# gcpbook_ch4という名前のBigQueryのデータセットを、
# US マルチリージョンに作成します。
bq --location=us mk \
  -d \
  $(gcloud config get-value project):gcpbook_ch4
