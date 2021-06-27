# Dataflow APIの有効化
gcloud services enable dataflow.googleapis.com

# virtualenvを使ってPython仮想環境を作成し、
# その仮想環境を有効化するコマンド
virtualenv .env
source .env/bin/activate

# Apache Beam SDKのライブラリをインストールするコマンド
pip install apache-beam[gcp]