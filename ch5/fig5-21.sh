# 作業用テーブルgcpbook_ch5.work_eventsを削除
bq --location=us query \
  --nouse_legacy_sql \
  'drop table gcpbook_ch5.work_events'
