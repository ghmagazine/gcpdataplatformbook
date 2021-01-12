/*リスト3.3 exampleテーブルにid,userからなるデータを投入するDML*/
INSERT timetravel_test.example (id, user)
SELECT *
FROM UNNEST([(1, 'Mukai'),
      (2, 'Tabuchi'),
      (3, 'Nakao'),
      (4, 'Inazawa')]);