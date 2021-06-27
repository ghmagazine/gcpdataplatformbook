-- リスト9-7. マテリアライズドビューを作成するクエリ
-- マテリアライズドビューを作成する際のDDLステートメント
CREATE MATERIALIZED VIEW
  `[your-project-id].mv_demo.daily` AS
SELECT
  -- created_dateの値を日に切り詰め
  TIMESTAMP_TRUNC(created_date, DAY) AS created_date,
  agency,
  complaint_type,
  descriptor,
  borough,
  status,
  COUNT(1) AS count
-- 元テーブル参照
FROM
  `[your-project-id].mv_demo.311_service_requests`
-- 時間毎かつ利用想定の分析軸で集計
GROUP BY
  created_date,
  agency,
  complaint_type,
  descriptor,
  borough,
  status
