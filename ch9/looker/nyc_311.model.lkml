# リスト9-1. モデルファイルの接続設定部分
# ①接続するデータベースのコネクションを記述
connection: "gcp-book"

# リスト9-2. モデルファイルの他ファイルの取り込み部分
# ②モデルに含めるviewファイルを相対パスで指定
include: "*.view"

# リスト9-3. モデルファイルのexplore定義部分
# ③exploreを記述。
# ここでは、requests とmonthly_complaint_type_rankの2 つのviewを結合
explore: requests {
  label: "New York 311 service requests"

  join: monthly_complaint_type_rank {
    type: left_outer
    sql_on: TIMESTAMP_TRUNC(${requests.created_raw},MONTH) =
              ${monthly_complaint_type_rank.created_month_raw}
            AND ${requests.complaint_type} =
              ${monthly_complaint_type_rank.complaint_type};;
    relationship: many_to_one
  }
}

