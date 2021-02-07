# 「日別の、課金ユーザと無課金ユーザそれぞれのユニークユーザ数」を
# 保管するテーブルgcpbook_ch5.dau_by_user_typeを作成します。
bq --location=us query \
  --nouse_legacy_sql \
  'create or replace table gcpbook_ch5.dau_by_user_type
  (
    dt string not null
  , is_paid_user bool not null
  , users int64 not null
  )'
