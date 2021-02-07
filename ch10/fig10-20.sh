# Dataflowのジョブを実行するコマンド
# 実行するプロジェクト、ジョブ名、リージョン、実行サービス、
# 入力となるサブスクリプション、出力のBigQueryデータセット名
# をオプションに指定しています。
python nyc_taxi_streaming_analytics1.py \
--project $(gcloud config get-value project) \
--job_name=taxirides-realtime \
--region='us-central1' \
--runner DataflowRunner \
--input_subscription "projects/$(gcloud config get-value project)/subscriptions/streaming-taxi-rides" \
--output_dataset "$(gcloud config get-value project).nyc_taxi_trip"