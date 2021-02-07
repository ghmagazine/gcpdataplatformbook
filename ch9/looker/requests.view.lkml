# リスト9-4. ビューファイルのビューの名称と参照テーブル設定部分
# ①ビュー名の定義
view: requests {
  sql_table_name: `looker_demo.new_york_311_service_requests`;;

  # リスト9-5. ビューファイルのディメンション設定部分
  # ②ディメンジョンの定義
  dimension: complaint_type {
    type: string
    sql: ${TABLE}.complaint_type ;;
  }

  dimension: has_closed_date {
    type: yesno
    sql: ${closed_raw} IS NOT NULL ;;
  }

  # リスト9-6. ビューファイルのメジャー設定部分
  # ②メジャーの定義
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: agency {
    description: "問い合わ先組織"
    type: string
    sql: ${TABLE}.agency ;;
  }

  dimension: borough {
    description: "区(郡)"
    type: string
    sql: ${TABLE}.borough ;;
  }

  dimension_group: closed {
    type: time
    hidden: yes
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.closed_date ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_date ;;
  }

  dimension: descriptor {
    type: string
    sql: ${TABLE}.descriptor ;;
  }

  dimension_group: due {
    type: time
    hidden: yes
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.due_date ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: location {
    type: location
    sql_latitude: ${TABLE}.latitude;;
    sql_longitude: ${TABLE}.longitude;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: unique_key {
    type: number
    sql: ${TABLE}.unique_key ;;
  }

  measure: percent_of_total {
    type: percent_of_total
    sql: ${count} ;;
  }

  measure: cumulative_count {
    type: running_total
    sql: ${count} ;;
  }

  dimension: monthly_top10_complaint_type {
    type: yesno
    sql: ${monthly_complaint_type_rank.monthly_complaint_rank} < 11 ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      agency,
      complaint_type,
      descriptor,
      status
    ]
  }
}

