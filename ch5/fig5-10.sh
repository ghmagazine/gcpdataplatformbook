# 「課金ユーザであるか否か」を表すユーザ情報を保管するテーブルgcpbook_ch5.usersのデータを確認します。
bq --location=us query \
  --nouse_legacy_sql \
  'select
    user_pseudo_id
  , is_paid_user
  from
    gcpbook_ch5.users
  order by
    user_pseudo_id
  limit 5'
