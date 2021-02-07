# スキーマ定義の文字列
SCHEMA="ride_id:string,\
pickup_datetime:datetime,\
dropoff_datetime:datetime,\
pickup_location:geography,\
dropoff_location:geography,\
meter_reading:float,\
time_sec:integer,\
passenger_count:integer"

# 出力用テーブルの作成
bq mk nyc_taxi_trip.trips_od ${SCHEMA}