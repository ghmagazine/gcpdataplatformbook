-- ロジスティック回帰のモデル構築
CREATE MODEL `bqml.model` -- CREATE MODELステートメントによるモデル名の宣言
OPTIONS(model_type='logistic_reg') AS -- モデルとしてロジスティック回帰を選択
SELECT
  -- total.transactionsを目的変数とする(labelという名前のカラムは目的変数として扱われる)
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
  -- 一般公開データに含まれるGoogleアナリティクスのデータ
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20160801' AND '20170531'