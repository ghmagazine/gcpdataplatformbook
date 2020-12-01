SELECT
  -- 確認しやすさのため日本時間で表示
  DATETIME(timestamp,
    'Asia/Tokyo') AS datetime,
  ride_status,
  count
FROM
  -- your-project-id]の部分は自身のプロジェクトIDに置き換え
  `[your-project-id].nyc_taxi_trip.rides_1m`
ORDER BY
  timestamp DESC
LIMIT
  10