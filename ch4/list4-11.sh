# リスト4-11. dauテーブルのスキーマ定義の確認
# 「日別の、課金ユーザと無課金ユーザそれぞれのユニークユーザ数」を
# 保管するテーブルgcpbook_ch4.dauのスキーマ定義を確認します。
bq show \
  --schema \
  --format=prettyjson \
  gcpbook_ch4.dau
