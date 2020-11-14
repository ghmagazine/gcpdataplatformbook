# -*- coding: utf-8 -*-

# 単語毎に数をカウントするストリーミングジョブ

import argparse
import logging
import re

from past.builtins import unicode

import apache_beam as beam
import apache_beam.transforms.window as window
from apache_beam.io import ReadFromText
from apache_beam.io import WriteToText
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions


def run(argv=None, save_main_session=True):
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_topic', required=True)
    parser.add_argument('--output', required=True)
    known_args, pipeline_args = parser.parse_known_args(argv)

    pipeline_options = PipelineOptions(pipeline_args)
    pipeline_options.view_as(SetupOptions).save_main_session = save_main_session

    with beam.Pipeline(options=pipeline_options) as p:

        lines = p | beam.io.ReadFromPubSub(known_args.input_topic)

        counts = (
            lines
            | 'Split' >> (
                beam.FlatMap(lambda x: re.findall(r'[A-Za-z\']+', x)).
                with_output_types(unicode))
            # beam.WindowInto()で60秒のタンブリングウィンドウを生成
            | beam.WindowInto(window.FixedWindows(60, 0))
            | 'PairWithOne' >> beam.Map(lambda x: (x, 1))
            | 'GroupAndSum' >> beam.CombinePerKey(sum))

        counts | WriteToText(known_args.output)


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    run()