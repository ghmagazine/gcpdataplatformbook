# -*- coding: utf-8 -*-

# 単語毎に数をカウントするジョブ

import argparse
import logging
import re

from past.builtins import unicode

import apache_beam as beam
from apache_beam.io import ReadFromText
from apache_beam.io import WriteToText
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions


def run(argv=None, save_main_session=True):
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', required=True)
    parser.add_argument('--output', required=True)
    known_args, pipeline_args = parser.parse_known_args(argv)

    pipeline_options = PipelineOptions(pipeline_args)
    pipeline_options.view_as(SetupOptions).save_main_session = save_main_session

    # パイプラインの作成
    with beam.Pipeline(options=pipeline_options) as p:

        # テキストファイルを読み込んでPCollectionとしてlinesを生成
        lines = p | ReadFromText(known_args.input)

        # 文字を単語ごとにカウントするTransform処理
        counts = (
            lines
            # Split : 分を単語ごとに分割
            | 'Split' >> (
                beam.FlatMap(lambda x: re.findall(r'[A-Za-z\']+', x)).
                with_output_types(unicode))
            # PairWithOne : (単語, 1)というマップを生成
            | 'PairWithOne' >> beam.Map(lambda x: (x, 1))
            # GroupAndSum : 単語をキーにして、件数を集計
            | 'GroupAndSum' >> beam.CombinePerKey(sum))

        # PCollectionであるcountsをオブジェクトストレージに出力
        counts | WriteToText(known_args.output)


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    run()