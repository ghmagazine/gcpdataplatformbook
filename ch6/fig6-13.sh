# DAG実行日を2018-10-01に指定して、
# DAG count_usersを実行します。
gcloud composer environments run gcpbook-ch6 \
  --location us-central1 \
  backfill \
  -- \
  -s 2018-10-01 \
  -e 2018-10-01 \
  count_users
