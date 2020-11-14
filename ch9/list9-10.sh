# 出力先のファイルの冒頭を抜粋して参照
gsutil cat gs://$(gcloud config get-value project)-gcpbook-ch9/wordcount_out* | head

