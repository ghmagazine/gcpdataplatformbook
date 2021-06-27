SELECT
  *
FROM
  -- ML.PREDICT関数を用いて学習済みモデルに対する推論を実行
  ML.PREDICT(MODEL `bqml.model`, (
-- 推論に用いるデータの抽出
-- 学習、評価と異なり、目的変数は不要
-- 説明変数は学習に用いいたデータと同じカラム名
SELECT
  IFNULL(totals.newVisits, 0) AS new_visits,
  IFNULL(totals.pageviews, 0) AS page_views,
  IFNULL(device.browser, "") AS browser,
  IFNULL(device.operatingSystem, "") AS os,
  device.isMobile AS is_mobile,
  IFNULL(geoNetwork.continent, "") AS continent
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
-- 学習用データ、評価用データとは異なる期間である点に注意
WHERE
  _TABLE_SUFFIX BETWEEN '20170701' AND '20170801'))