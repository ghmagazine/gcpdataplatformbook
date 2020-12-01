# mv_demoというデータセットを作成
bq mk --dataset $(gcloud config get-value project):mv_demo

# 一般公開データセットのテーブル311_service_requestsを上のデータセットへコピー
bq cp bigquery-public-data:new_york_311.311_service_requests \
$(gcloud config get-value project):mv_demo.311_service_requests

