# BigQueryデータセットの作成
bq mk --dataset $(gcloud config get-value project):nyc_taxi_trip

# テーブルの作成
bq mk --time_partitioning_type=HOUR \
--time_partitioning_field=timestamp \
nyc_taxi_trip.rides_1m "timestamp:timestamp,ride_status:string,count:integer"