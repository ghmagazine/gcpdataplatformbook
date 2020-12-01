# リスト5-36. dauテーブルへのデータ挿入の確認
# テーブルgcpbook_ch5.dauに正常にデータが挿入されたことを確認します。
bq --location=us query \
  --nouse_legacy_sql \
  --parameter='dt:date:2018-10-01' \
  'select
    dt
  , paid_users
  , free_to_play_users
  from
    gcpbook_ch5.dau
  where
    dt = @dt'
