-- バイクステーションの位置情報をGEOGRAPHY型に変換するクエリ
SELECT
  -- 数値型である緯度/経度の情報をST_GEOPOINT()に渡して、GEOGRAPHY型カラムgeometryを生成
  -- ST_GEOGPOINTは、BigQuery GISで標準提供された地理関数の一つ
  ST_GEOGPOINT(longitude,
    latitude) AS geometry,
  -- 分析に必要な情報としてcapacityを取得
  capacity
FROM
  -- 一般公開データセットのバイクステーションの情報が格納されたテーブル
  `bigquery-public-data.new_york_citibike.citibike_stations`
