-- リスト9-8. 元テーブルを参照して集計するクエリ
SELECT
  TIMESTAMP_TRUNC(created_date, DAY) AS created_date,
  borough,
  COUNT(1) AS count
-- マテリアライズドビュー`mv_demo.daily`の元テーブル
FROM
  `[your-project-id].mv_demo.311_service_requests`
GROUP BY
  created_date,
  borough
