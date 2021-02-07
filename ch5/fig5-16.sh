# 作業用テーブルgcpbook_ch5.work_eventsが正常に作成されて、
# データがロードされたことを確認します。
bq --location=us query \
  --nouse_legacy_sql \
  'select
    count(1)
  from
    gcpbook_ch5.work_events'
