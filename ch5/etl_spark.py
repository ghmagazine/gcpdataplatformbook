# ETL処理を実施するSparkアプリケーションが定義されたソースコード、etl_spark.py

# リスト5-8. 各種Pythonモジュールのインポート
import argparse

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, count, lit, to_date, when


def run():
    """メイン処理のエントリポイント。"""
    # リスト5-9. コマンドライン引数のパース
    # コマンドライン引数をパースする。
    parser = argparse.ArgumentParser()
    parser.add_argument('--bucket', dest='bucket', help='Cloud Storage bucket')
    parser.add_argument('--dt', dest='dt', help='event date')
    args = parser.parse_args()

    # リスト5-10. SparkSessionの作成と実行時オプションの設定
    # SparkSessionを作成する。
    spark = SparkSession.builder.appName('CountUsers').getOrCreate()
    # BigQueryのテーブルへのロード時に使用されるCloud Storageのバケットを設定する。
    spark.conf.set('temporaryGcsBucket', args.bucket)

    # リスト5-11. 変数の設定
    # ファイル読み取り対象のCloud Storageのパスを組み立てる。
    event_file_path = 'gs://{}/data/events/{}/*.json.gz'\
        .format(args.bucket, args.dt)
    # 処理対象のイベント日付を"YYYY-MM-DD"形式で組み立てる。
    dt = '{}-{}-{}'.format(args.dt[0:4], args.dt[4:6], args.dt[6:8])

    # リスト5-12. user_pseudo_idの一覧の抽出
    # Cloud Storageからユーザ行動ログを読み取り、user_pseudo_idの一覧を抽出する。
    user_pseudo_ids = spark.read.json(event_file_path)\
        .select('user_pseudo_id').distinct()

    # リスト5-13.usersテーブルデータの読み取り
    # BigQueryのユーザ情報を保管するテーブルgcpbook_ch5.usersからデータを読み取る。
    users = spark.read.format('bigquery').load('gcpbook_ch5.users')

    # リスト5-14. データの結合とdauテーブルへの結合結果の書き込み
    # 前工程で抽出したuser_pseudo_idsとusersを結合し、集計して、
    # 課金ユーザと無課金ユーザそれぞれの人数を算出し、その結果をBigQueryの
    # テーブルgcpbook_ch5.dauへ書き込む。
    user_pseudo_ids.join(users, 'user_pseudo_id')\
        .agg(count(when(col('is_paid_user'), 1)).alias('paid_users'),
             count(when(~col('is_paid_user'), 1)).alias('free_to_play_users'))\
        .withColumn('dt', to_date(lit(dt)))\
        .select('dt', 'paid_users', 'free_to_play_users')\
        .write.format('bigquery').option('table', 'gcpbook_ch5.dau')\
        .mode('append').save()

    # リスト5-15. SparkContextの停止
    # SparkSessionに紐づくSparkContextを停止させる。
    spark.stop()


if __name__ == "__main__":
    run()
