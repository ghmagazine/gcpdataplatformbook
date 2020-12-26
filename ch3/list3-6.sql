/*リスト3.6 CTASで新規テーブルexample_restoreにデータをリストアする*/
CREATE TABLE timetravel_test.example_restore AS
SELECT * FROM timetravel_test.example
/*FOR SYSTEM TIME AS OF でタイムトラベルの基準となる時間を指定するとPITR(Point In Time Recovery)的に動作する*/
FOR SYSTEM TIME AS OF
'2020-11-01 10:00:01+09:00'