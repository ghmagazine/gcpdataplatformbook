# ニューヨークタクシーのリアルタイム位置情報の公開データセットトピック
# "projects/pubsub-public-data/topics/taxirides-realtime" から
# データを取得するサブスクリプション "streaming-taxi-rides"
# を生成するコマンド
gcloud pubsub subscriptions create streaming-taxi-rides \
--topic=projects/pubsub-public-data/topics/taxirides-realtime