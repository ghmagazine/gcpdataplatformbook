# gcpbook_ch5という名前のBigQueryのデータセットを、
# US マルチリージョンに作成します。
bq --location=us mk \
  -d \
  $(gcloud config get-value project):gcpbook_ch5
