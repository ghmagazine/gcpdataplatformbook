# Dataflowのジョブを実行するコマンド
# 実行するプロジェクト、リージョン、実行サービス、
# 入力となるCloud Storageのファイルのパス、
# 出力先ファイルのCloud Storageのパスをオプションに指定しています。
python wordcount.py \
--project $(gcloud config get-value project) \
--region='us-central1' \
--runner DataflowRunner \
--input gs://$(gcloud config get-value project)-gcpbook-ch10/bbc_news_fulltext.csv \
--output gs://$(gcloud config get-value project)-gcpbook-ch10/wordcount_out