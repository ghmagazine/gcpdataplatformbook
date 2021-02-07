# テーブルgcpbook_ch5.dau_by_user_typeに正常にデータが挿入されたことを確認します。
bq --location=us query \
  --nouse_legacy_sql \
  --parameter='dt:string:20181001' \
  'select
    dt
  , is_paid_user
  , users
  from
    gcpbook_ch5.dau_by_user_type
  where
    dt = @dt
  order by
    is_paid_user'
