# USマルチリージョンに、[プロジェクト名]-gcpbook-ch10という名前のバケットを作成
gsutil mb -l US gs://$(gcloud config get-value project)-gcpbook-ch10/

# BigQueryの一般公開データセット「bbc_news」の「fulltext」テーブルの
# データをCloud Storageの指定バケットに出力
bq extract bigquery-public-data:bbc_news.fulltext \
gs://$(gcloud config get-value project)-gcpbook-ch10/bbc_news_fulltext.csv

# 出力ファイルの存在確認
# gs://[プロジェクト名]-gcpbook-ch10/bbc_news_fulltext.csv と表示されたら正常
gsutil ls gs://$(gcloud config get-value project)-gcpbook-ch10/bbc_news_fulltext.csv