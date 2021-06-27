CREATE VIEW `automl.gaview_test`
AS
-- 推論のため目的変数は不要
-- 説明変数は学習用データと同一のカラムにする
SELECT
  IFNULL(totals.newVisits, 0) AS new_visits,
  IFNULL(totals.pageviews, 0) AS page_views,
  IFNULL(device.browser, "") AS browser,
  IFNULL(device.operatingSystem, "") AS os,
  device.isMobile AS is_mobile,
  IFNULL(geoNetwork.continent, "") AS continent
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
-- 学習用データとは異なる期間である点に注意
WHERE
  _TABLE_SUFFIX BETWEEN '20170701' AND '20170801'