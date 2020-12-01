# -*- coding: utf-8 -*-

# 次のデータパイプライン処理を行うDataflowジョブのコード、nyc_taxi_streaming2.py
# 1. Pub/Subからタクシーの位置情報をストリーミングに取得
# 2. タンブリングウィンドウで5分ごとの乗車数と降車数を
#    BigQueryのテーブルにデータ追加
# 3. セッションウィンドウで乗車ごとに乗降車データを一つの
#    レコードにまとめてBigQueryのテーブルにデータ追加

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

# 乗車と降車のデータを整形して一つのレコードに乗降者データを格納する処理を備えたクラス
class CompileTripOD(beam.DoFn):
    # PCollectionの各要素へ実施する処理
    def process(self, element):
        (ride_id, rides) = element

        # 最終的につくるレコードを初期化
        trip_od = {"ride_id": ride_id,
                   "pickup_datetime": None,
                   "pickup_location": None,
                   "dropoff_datetime": None,
                   "dropoff_location": None,
                   "meter_reading": None,
                   "time_sec": None,
                   "passenger_count": None}

        pickup_dt = None
        dropoff_dt = None
        # 乗車データと降車データを取り出してそれぞれの情報をtrip_odに反映
        for ride in rides:
            if ride['ride_status'] == 'pickup':
                trip_od['pickup_datetime'] = ride['timestamp'][0:19]
                trip_od['pickup_location'] = 'POINT({} {})'.format(ride['longitude'],ride['latitude'])
                trip_od['passenger_count'] = ride['passenger_count']
                pickup_dt = datetime.strptime(trip_od['pickup_datetime'], '%Y-%m-%dT%H:%M:%S')
            elif ride['ride_status'] == 'dropoff':
                trip_od['dropoff_datetime'] = ride['timestamp'][0:19]
                trip_od['dropoff_location'] = 'POINT({} {})'.format(ride['longitude'],ride['latitude'])
                trip_od['meter_reading'] = ride['meter_reading']
                dropoff_dt = datetime.strptime(trip_od['dropoff_datetime'], '%Y-%m-%dT%H:%M:%S')

        # 乗車と降車の両方が揃っていた場合、乗車時間を計算して追加
        if pickup_dt and dropoff_dt:
            trip_od['time_sec'] = (dropoff_dt - pickup_dt).total_seconds()

        yield trip_od


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

        trips_od = (
            # 乗降車に絞ったデータPCollection
            rides_onoff
            # セッションウィンドウで利用するためのセッションIDとなるride_idをキーに設定
            | 'Key-value pair with Ride_id' >> beam.Map(lambda x: (x['ride_id'],x))
            # セッションウィンドウ設定。ギャップ期間を5分に設定。
            # もし同じ乗車データの位置情報が5分より大きな間隔をあけて到着した場合、
            # 別のセッションとして集計される
            | 'Into SessionWindows' >> beam.WindowInto(window.Sessions(5*60))
            | 'Group by ride_id' >> beam.GroupByKey()
            # セッション内でまとめた乗車および降車データを一つの要素に結合する
            # 処理は、CompileTripODクラスで実装
            | 'Compile trip OD' >> beam.ParDo(CompileTripOD())
        )

        trips_od | 'Write od trips to BigQuery' >> WriteToBigQuery('trips_od',
                                                                   dataset=dataset,
                                                                   project=bigquery_project,
                                                                   create_disposition=BigQueryDisposition.CREATE_NEVER)


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    run()
