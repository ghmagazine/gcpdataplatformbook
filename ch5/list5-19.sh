# リスト5-19. work_eventsテーブルの削除
# 作業用テーブルgcpbook_ch5.work_eventsを削除します。
bq --location=us query \
  --nouse_legacy_sql \
  'drop table gcpbook_ch5.work_events'
