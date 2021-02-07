-- 学習済みのモデルの評価
SELECT
  *
FROM
  -- ML.EVALUATE関数でリスト10-4で作成したモデルの評価
  ML.EVALUATE(MODEL `bqml.model`, (
-- 評価に利用するデータの抽出
-- 学習に利用した目的変数、説明変数と同一カラム名とする
SELECT
  IF(totals.transactions IS NULL, 0, 1) AS label,
  IFNULL(totals.newVisits, 0) AS new_visits,
  IFNULL(totals.pageviews, 0) AS page_views,
  IFNULL(device.browser, "") AS browser,
  IFNULL(device.operatingSystem, "") AS os,
  device.isMobile AS is_mobile,
  IFNULL(geoNetwork.continent, "") AS continent
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
-- 学習データとは異なる期間である点に注意
WHERE
  _TABLE_SUFFIX BETWEEN '20170601' AND '20170630'))