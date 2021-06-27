# 「日別の、課金ユーザと無課金ユーザそれぞれのユニークユーザ数」を
# 保管するテーブルgcpbook_ch5.dauのスキーマ定義を確認します。
bq show \
  --schema \
  --format=prettyjson \
  gcpbook_ch5.dau
