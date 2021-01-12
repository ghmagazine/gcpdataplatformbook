# リスト3.9 タイムトラベルによる`example`テーブルリストアの実行
# bq CLIツールを用いてコマンドラインから削除済みテーブルのタイムトラベルを行う
bq cp timetravel_test.example@-600000 timetravel_test.example