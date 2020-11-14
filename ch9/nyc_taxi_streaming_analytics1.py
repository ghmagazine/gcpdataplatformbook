# -*- coding: utf-8 -*-

# 次のデータパイプライン処理を行うDataflowジョブのコード、nyc_taxi_streaming2.py
# 1. Pub/Subからタクシーの位置情報をストリーミングに取得
# 2. タンブリングウィンドウで5分ごとの乗車数と降車数を
#    BigQueryのテーブルにデータ追加

import argparse
import logging
import json
from datetime import datetime

import apache_beam as beam
import apache_beam.transforms.window as window

from apache_beam.io.gcp.pubsub import ReadFromPubSub
from apache_beam.io.gcp.bigquery import WriteToBigQuery, BigQueryDisposition
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions


# ウィンドウの開始イベント時間を取得してPCollectionの要素に付加する処理を備えたクラス
class AttachWindowTimestamp(beam.DoFn):
    # PCollectionの各要素へ実施する処理
    # window=beam.DoFn.WindowParam を加えることで、ウィンドウに関する情報が取得できる
    def process(self, element, window=beam.DoFn.WindowParam):
        (status, count) = element
        # 当該ウィンドウの開始イベント時間を取得
        window_start_dt = window.start.to_utc_datetime()

        # PCollectionに含まれた要素にウィンドウのイベント開始時間を足して返却
        status_count = {"timestamp": window_start_dt.strftime('%Y-%m-%d %H:%M:%S'),
                        "ride_status": status,
                        "count": count}
        yield status_count


# ジョブ実行時のメイン処理部分
def run(argv=None, save_main_session=True):

    # 実行時のコマンドで受け付けるオプションの設定
    parser = argparse.ArgumentParser()
    # 入力のサブスクリプション受付のためのオプション
    parser.add_argument(
      '--input_subscription',
      required=True,
      help=(
          'Input PubSub subscription '
          '"projects/<PROJECT>/subscriptions/<SUBSCRIPTION>".'))
    # 出力のBigQueryデータセット受付のためのオプション
    parser.add_argument(
      '--output_dataset',
      required=True,
      help=(
          'Output BigQuery dataset '
          '"<PROJECT>.<DATASET>"'))
    known_args, pipeline_args = parser.parse_known_args(argv)

    # パイプラインに渡すオプションインスタンスを生成します。
    # streaming=True でストリーミングジョブを有効にするオプションを明示的に渡します。
    pipeline_options = PipelineOptions(pipeline_args, streaming=True)
    pipeline_options.view_as(SetupOptions).save_main_session = save_main_session

    # パイプラインの生成
    with beam.Pipeline(options=pipeline_options) as p:

        subscription = known_args.input_subscription
        (bigquery_project, dataset) = known_args.output_dataset.split('.')

        rides = (
            p
            # ReadFromPubSub()で指定されたPub/Sub スブスクリプションからメッセージを取得
            | 'Read From PubSub' >> ReadFromPubSub(subscription=subscription).with_output_types(bytes)
            # メッセージ文字列をPythonのディクショナリに変換します。
            | 'ToDict' >> beam.Map(json.loads)
        )

        # PCollectionの要素が乗車および降車のデータのみ返却する関数
        def is_pickup_or_dropoff(element):
            return element['ride_status'] in ('pickup', 'dropoff')

        rides_onoff = (
            rides
            # 乗降車データのみ抽出。走行中 enroute データを除外
            | 'Filter pickup/dropoff' >> beam.Filter(is_pickup_or_dropoff)
        )

        rides_onoff_1m = (
            rides_onoff
            # タンブリングウィンドウ生成
            | 'Into 1m FixedWindow' >> beam.WindowInto(window.FixedWindows(60))
            # 乗車ステータスごとに件数を集計
            | 'Group status by rides' >> beam.Map(lambda x: (x['ride_status'],1))
            | 'Count unique elements' >> beam.combiners.Count.PerKey()
            # ウィンドウの開始イベント時刻をデータに付与
            | 'Attach window start timestamp' >> beam.ParDo(AttachWindowTimestamp())
        )

        # WriteToBigQueryを使って、BigQueryへストリーミング挿入で結果を出力
        rides_onoff_1m | 'Write 1m rides to BigQuery' >> WriteToBigQuery('rides_1m',
                                                            dataset=dataset,
                                                            project=bigquery_project,
                                                            create_disposition=BigQueryDisposition.CREATE_NEVER)


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    run()
