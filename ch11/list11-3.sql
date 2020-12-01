-- WITH句でJOINするためのテーブルの準備
WITH
　-- 2017/1/1の欠損データを除いたデータを抽出したトリップデータ trips
  `trips` AS (
  SELECT
    -- 出発ステーションの地理情報(GEOGRAPHY型)
    ST_GEOGPOINT(start_station_longitude,
      start_station_latitude) AS start_geog_point
  FROM
    `bigquery-public-data.new_york_citibike.citibike_trips`
  WHERE
    -- 情報が欠損しているデータを排除
    bikeid IS NOT NULL
    AND DATETIME_TRUNC(starttime,
      year) = '2017-01-01' ),

  -- ニューヨーク州とニュージャージー州に絞った郵便番号エリアデータ zip_codes
  `zip_codes` AS (
  SELECT
    zip_code,
    zip_code_geom
  FROM
    `bigquery-public-data.geo_us_boundaries.zip_codes`
  WHERE
    state_fips_code IN ('36',
      '34'))

-- メインSQLクエリ
SELECT
  -- 郵便番号文字列とそのポリゴン情報および当該エリアに出発地が含まれる利用回数の総数を取得
  zip_code,
  zip_code_geom,
  total_trips
FROM (
  -- trip と zip_codes を内部結合し、結合条件で出発ステーションの位置情報が含まれる郵便番号情報を持つレコードのみに指定
  SELECT
    zip_code,
    -- トリップ件数をカウントして、利用総数を集計
    COUNT(1) AS total_trips
  FROM
    `trips`
  JOIN
    `zip_codes`
  ON
    -- 結合条件にST_WITHIN()を利用して、出発地点が含まれる郵便コードのエリアを判定
    -- 出発ステーション位置 start_geog_point がある郵便番号エリア zip_code_geom に含まれているたら真を返す
    ST_WITHIN( start_geog_point,
      zip_code_geom)
  -- 結合後に郵便番号コードで集計
  -- ちなみに、GEOGRAPHY型のカラムは集計カラムに指定できない
  GROUP BY
    zip_code)
-- 可視化のために郵便番号エリアのポリゴンを取得するため最後に再度 zip_codes と結合
JOIN
  `zip_codes`
USING
  (zip_code)

