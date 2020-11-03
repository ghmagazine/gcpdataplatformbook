# リスト4-14. ユーザ行動ログのデータのロードの確認
# 作業用テーブルgcpbook_ch4.work_eventsが正常に作成されて、
# データがロードされたことを確認します。
bq --location=us query \
  --nouse_legacy_sql \
  'select
    count(1)
  from
    gcpbook_ch4.work_events'
