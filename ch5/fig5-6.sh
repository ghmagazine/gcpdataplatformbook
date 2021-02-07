# 「課金ユーザであるか否か」を表すユーザ情報を保管するテーブル
# gcpbook_ch5.usersを作成します。
# 便宜的に、user_pseudo_idの先頭の値が0または1であるユーザを、
# 課金ユーザ(is_paid_user = true)としています。
bq --location=us query \
  --nouse_legacy_sql \
  'create table gcpbook_ch5.users as
   select distinct
    user_pseudo_id
  , substr(user_pseudo_id, 0, 1) in ("0", "1") as is_paid_user
  from
    `firebase-public-project.analytics_153293282.events_*`'
