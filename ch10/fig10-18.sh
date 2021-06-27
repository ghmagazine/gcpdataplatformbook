# virtualenvを使ってPython仮想環境を作成し、
# その仮想環境を有効化するコマンド
virtualenv .env
source .env/bin/activate
python --version

# Apache Beam SDKのライブラリをインストールするコマンド
pip install --upgrade apache-beam[gcp]