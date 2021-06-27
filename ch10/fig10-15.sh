# 作成したサブスクリプションからデータを取得・表示するコマンド
# 見やすさのためにgcloudコマンドの出力をjqコマンドに渡しています
gcloud pubsub subscriptions pull \
projects/$(gcloud config get-value project)/subscriptions/streaming-taxi-rides \
--format="value(message.data)" | jq