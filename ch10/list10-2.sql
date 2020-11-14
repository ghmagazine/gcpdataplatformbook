-- ニューヨーク州とニュージャージー州の郵便番号エリアのデータのみ抽出するクエリ
SELECT
  zip_code, -- 郵便番号コード
  zip_code_geom -- 郵便番号に該当するエリアのポリゴン情報(GEOGRAPHY型)
FROM
  -- 一般公開データセットの郵便番号エリア情報が格納されたテーブル
  `bigquery-public-data.geo_us_boundaries.zip_codes`
WHERE
  -- サービス対象地域が含まれるニューヨーク州とニュージャージー州に限定
  -- 36: ニューヨーク州
  -- 34: ニュージャージー州
  state_fips_code IN ('36',
    '34')

