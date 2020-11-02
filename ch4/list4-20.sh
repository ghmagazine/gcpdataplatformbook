# リスト4-20. work_eventsテーブルの削除の確認
# 作業用テーブルgcpbook_ch4.work_eventsの情報がINFORMATION_SCHEMA.TABLESに存在しないことを確認し、
# このテーブルが削除されたことを確認します。
bq --location=us query \
  --nouse_legacy_sql \
  'select
    count(1)
  from
    gcpbook_ch4.INFORMATION_SCHEMA.TABLES
  where
    table_name = "work_events"'
