/*リスト3.7 MERGEステートメントを利用して`example`テーブルと`example_restore`テーブルで差分を統合する*/
/*`example`テーブルと`example_restore`テーブルで差分がある場合
MERGE ステートメントの対象テーブルは変更したいテーブルを指定、この場合リストアをかける`example`を指定*/
MERGE timetravel_test.example O
/*USING ではデータの抽出元を指定する*/
USING timetravel_test.example_restore R
/*MERGE の条件を指定。FALSEの場合は抽出先である`example`に DELETE を実行するとともに、抽出元の INSERT を実行する場合*/
ON FALSE
/*データが`example_restore`にあるが`example`にないものは`example_restore`からINSERT*/
WHEN NOT MATCHED THEN
  INSERT (id, user) VALUES(id, user)
/*データが`example`にあるが、`example_restore`にないものは`example`からDELETE*/
WHEN NOT MATCHED BY SOURCE THEN
  DELETE