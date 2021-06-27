# 作業用テーブルgcpbook_ch5.work_eventsとユーザ情報を保管するテーブルgcpbook_ch5.usersを結合して集計し、
# 課金ユーザと無課金ユーザそれぞれのユーザ数を算出して、結果をテーブルgcpbook_ch5.dauへ挿入します。
bq --location=us query \
  --nouse_legacy_sql \
  --parameter='dt:date:2018-10-01' \
  'insert gcpbook_ch5.dau
  select
    @dt as dt
  , countif(u.is_paid_user) as paid_users
  , countif(not u.is_paid_user) as free_to_play_users
  from
    (
      select distinct
        user_pseudo_id
      from
        gcpbook_ch5.work_events
    ) e
      inner join
        gcpbook_ch5.users u
      on
        u.user_pseudo_id = e.user_pseudo_id'
