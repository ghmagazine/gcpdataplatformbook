/*このクエリを実行すると、22.9 GB が処理されます。
BigQueryの無料枠は10GB/月です。
BigQuery サンドボックスを利用している場合は1TB/月まで利用できます。
スキャン量としては大きいので、必ずサンドボックス環境でのみ試してください。*/
SELECT
  subject,
  COUNT(subject)
FROM
  `bigquery-public-data.github_repos.commits`
WHERE
  author.email LIKE "%@gmail%"
GROUP BY
  subject
ORDER BY
  COUNT(subject) DESC
LIMIT
  10