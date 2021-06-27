/*リスト3.4 exampleテーブルのid=2を'Yoshikane'に、id=3を'Hinata'に変更するDML*/
UPDATE timetravel_test.example
SET user = CASE
WHEN id = 2 THEN 'Yoshikane'
WHEN id = 3 THEN 'Hinata'
END
WHERE id IN (2,3);