# リスト4-23. dauテーブルへのデータの挿入
# 一時テーブルとユーザ情報を保管するテーブルgcpbook_ch4.usersを結合して集計し、
# 課金ユーザと無課金ユーザそれぞれのユーザ数を算出して、結果をテーブルgcpbook_ch4.dauへ挿入します。
bq --location=us query \
  --nouse_legacy_sql \
  --external_table_definition=events::user_pseudo_id:string@NEWLINE_DELIMITED_JSON=gs://$(gcloud config get-value project)-gcpbook-ch4/data/events/20181001/*.json.gz \
  --parameter='dt:date:2018-10-01' \
  'insert gcpbook_ch4.dau
  select
    @dt as dt
  , countif(u.is_paid_user) as paid_users
  , countif(not u.is_paid_user) as free_to_play_users
  from
    (
      select distinct
        user_pseudo_id
      from
        events
    ) e
      inner join
        gcpbook_ch4.users u
      on
        u.user_pseudo_id = e.user_pseudo_id'
