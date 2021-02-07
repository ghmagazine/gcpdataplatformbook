CREATE VIEW `automl.gaview`
AS
SELECT
  -- total.transactionsを目的変数とする
  -- AutoML Tablesはデータ取り込み後に目的変数を明示的に設定するため、カラム名自体に仕様上の意味はない
  -- IF関数を利用してNULLなら0, それ以外は1に変換する
  IF(totals.transactions IS NULL, 0, 1) AS label,
  -- その他のカラムを説明変数として扱う
  IFNULL(totals.newVisits, 0) AS new_visits,
  IFNULL(totals.pageviews, 0) AS page_views,
  IFNULL(device.browser, "") AS browser,
  IFNULL(device.operatingSystem, "") AS os,
  device.isMobile AS is_mobile,
  IFNULL(geoNetwork.continent, "") AS continent
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20160801' AND '20170630'