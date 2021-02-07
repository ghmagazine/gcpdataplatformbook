# ETL処理を実施するBeamパイプラインが定義されたソースコード、etl.py

# リスト5-1. 各種Pythonモジュールのインポート
import argparse
import json
import logging

import apache_beam as beam
from apache_beam.io import ReadFromText
from apache_beam.options.pipeline_options import GoogleCloudOptions
from apache_beam.options.pipeline_options import PipelineOptions


# リスト5-2. 変数_DAU_TABLE_SCHEMAの定義
# 書き込み先のBigQueryのテーブルgcpbook_ch5.dauのスキーマ定義
_DAU_TABLE_SCHEMA = {
    'fields': [
        {'name': 'dt', 'type': 'date', 'mode': 'required'},
        {'name': 'paid_users', 'type': 'int64', 'mode': 'required'},
        {'name': 'free_to_play_users', 'type': 'int64', 'mode': 'required'}
    ]
}


# リスト5-3. クラスCountUsersFnの定義
class CountUsersFn(beam.CombineFn):
    """課金ユーザと無課金ユーザの人数を集計する。"""
    def create_accumulator(self):
        """課金ユーザと無課金ユーザの人数を保持するaccumulatorを作成して返却する。

        Returns:
          課金ユーザと無課金ユーザの人数を表すタプル(0, 0)
        """
        return 0, 0

    def add_input(self, accumulator, is_paid_user):
        """課金ユーザまたは無課金ユーザの人数を加算する。

        Args:
          accumulator: 課金ユーザと無課金ユーザの人数を表すタプル（現在の中間結果）
          is_paid_user: 課金ユーザであるか否かを表すフラグ

        Returns:
          加算後の課金ユーザと無課金ユーザの人数を表すタプル
        """
        (paid, free) = accumulator
        if is_paid_user:
            return paid + 1, free
        else:
            return paid, free + 1

    def merge_accumulators(self, accumulators):
        """複数のaccumulatorを単一のaccumulatorにマージした結果を返却する。

        Args:
          accumulators: マージ対象の複数のaccumulator

        Returns:
          マージ後のaccumulator
        """
        paid, free = zip(*accumulators)
        return sum(paid), sum(free)

    def extract_output(self, accumulator):
        """集計後の課金ユーザと無課金ユーザの人数を返却する。

        Args:
          accumulator: 課金ユーザと無課金ユーザの人数を表すタプル

        Returns:
          集計後の課金ユーザと無課金ユーザの人数を表すタプル
        """
        return accumulator


def run():
    """メイン処理のエントリポイント。パイプラインを定義して実行する。"""
    # リスト5-4. コマンドライン引数のパースと変数の設定
    # コマンドライン引数をパースして、パイプライン実行用のオプションを生成する。
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--dt',
        dest='dt',
        help='event date')
    known_args, pipeline_args = parser.parse_known_args()
    pipeline_options = PipelineOptions(pipeline_args)

    # ファイル読み取り対象のCloud Storageのパスを組み立てる。
    event_file_path = 'gs://{}-gcpbook-ch5/data/events/{}/*.json.gz'.format(
        pipeline_options.view_as(GoogleCloudOptions).project, known_args.dt)
    # 処理対象のイベント日付を"YYYY-MM-DD"形式で組み立てる。
    dt = '{}-{}-{}'.format(known_args.dt[0:4], known_args.dt[4:6],
                           known_args.dt[6:8])

    # パイプラインを定義して実行する。
    with beam.Pipeline(options=pipeline_options) as p:
        # リスト5-5. user_pseudo_idの一覧の抽出
        # Cloud Storage からユーザ行動ログを読み取り、user_pseudo_idの一覧を
        # 抽出する。
        user_pseudo_ids = (
            p
            # Cloud Storage からユーザ行動ログを読み取る。
            | 'Read Events' >> ReadFromText(event_file_path)
            # JSON 形式のデータをパースしてuser_pseudo_idを抽出する。
            | 'Parse Events' >> beam.Map(
                lambda event: json.loads(event).get('user_pseudo_id'))
            # 重複しているuser_pseudo_idを排除する。
            | 'Deduplicate User Pseudo Ids' >> beam.Distinct()
            # 後続の結合処理で必要となるため、キー・バリュー形式にデータを変換する。
            # user_pseudo_idをキーとし、値は使用しないためNoneとする。
            | 'Transform to KV' >> beam.Map(
                lambda user_pseudo_id: (user_pseudo_id, None))
        )

        # リスト5-6. ユーザ情報の一覧の取得
        # BigQueryのユーザ情報を保管するテーブルgcpbook_ch5.usersからユーザ情報の
        # 一覧を取得する。
        users = (
            p
            # BigQueryのユーザ情報を保管するテーブルgcpbook_ch5.usersからデータを
            # 読み取る。
            | 'Read Users' >> beam.io.Read(
                beam.io.BigQuerySource('gcpbook_ch5.users'))
            # 後続の結合処理で必要となるため、キー・バリュー形式にデータを変換する。
            # user_pseudo_idをキーとし、「課金ユーザであるか否か」を表す
            # is_paid_userを値とする。
            | 'Transform Users' >> beam.Map(
                lambda user: (user['user_pseudo_id'], user['is_paid_user']))
        )

        # リスト5-7. データの結合結果のテーブルへの書き込み
        # 前工程で作成した2つのPCollection user_pseudo_idsとusersを結合し、
        # 集計して、課金ユーザと無課金ユーザそれぞれの人数を算出して、その結果をBigQuery
        # のテーブルgcpbook_ch5.dauへ書き込む。
        (
            {'user_pseudo_ids': user_pseudo_ids, 'users': users}
            # user_pseudo_idsとusersを結合する。
            | 'Join' >> beam.CoGroupByKey()
            # ユーザ行動ログが存在するユーザ情報のみを抽出する。
            | 'Filter Users with Events' >> beam.Filter(
                lambda row: len(row[1]['user_pseudo_ids']) > 0)
            # 「課金ユーザであるか否か」を表すフラグ値を抽出する。
            | 'Transform to Is Paid User' >> beam.Map(
                lambda row: row[1]['users'][0])
            # 課金ユーザと無課金ユーザそれぞれの人数を算出する。
            | 'Count Users' >> beam.CombineGlobally(CountUsersFn())
            # BigQueryのテーブルへ書き込むためのデータを組み立てる。
            | 'Create a Row to BigQuery' >> beam.Map(
                lambda user_nums: {
                    'dt': dt,
                    'paid_users': user_nums[0],
                    'free_to_play_users': user_nums[1]
                })
            # BigQueryのテーブルgcpbook_ch5.dauへ算出結果を書き込む。
            | 'Write a Row to BigQuery' >> beam.io.WriteToBigQuery(
                'gcpbook_ch5.dau',
                schema=_DAU_TABLE_SCHEMA,
                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED)
        )


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    run()
