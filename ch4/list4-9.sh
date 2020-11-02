# リスト4-9. usersテーブルデータの確認
# 「課金ユーザであるか否か」を表すユーザ情報を保管するテーブルgcpbook_ch4.usersのデータを確認します。
bq --location=us query \
  --nouse_legacy_sql \
  'select
    user_pseudo_id
  , is_paid_user
  from
    gcpbook_ch4.users
  order by
    user_pseudo_id
  limit 5'
