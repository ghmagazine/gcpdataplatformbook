# 「日別の、課金ユーザと無課金ユーザそれぞれのユニークユーザ数」を
# 保管するテーブルgcpbook_ch5.dauを再作成します。
bq --location=us query \
  --nouse_legacy_sql \
  'create or replace table gcpbook_ch5.dau
  (
    dt date not null
  , paid_users int64 not null
  , free_to_play_users int64 not null
  )'
