# リスト4-13. ユーザ行動ログのデータのロード
# BigQueryの作業用テーブルgcpbook_ch4.work_eventsを作成し、
# そのテーブルへCloud Storage上のユーザ行動ログのデータをロードします。
bq --location=us load \
  --autodetect \
  --source_format=NEWLINE_DELIMITED_JSON \
  gcpbook_ch4.work_events \
  gs://$(gcloud config get-value project)-gcpbook-ch4/data/events/20181001/*.json.gz
