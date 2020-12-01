view: monthly_complaint_type_rank {
  derived_table: {
    sql:
    SELECT
      created_date,
      complaint_type,
      DENSE_RANK() OVER (PARTITION BY created_date ORDER BY cnt DESC) AS monthly_rank
    FROM (
      SELECT
        TIMESTAMP_TRUNC( created_date,MONTH) AS created_date,
        complaint_type,
        COUNT(1) AS cnt
      FROM
        `looker_demo.new_york_311_service_requests`
      GROUP BY
        created_date,
        complaint_type);;
  }

  dimension_group: created_month {
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

  dimension: complaint_type {
    type: string
    hidden: yes
    sql:  ${TABLE}.complaint_type ;;
  }

  dimension: monthly_complaint_rank {
    type: number
    sql: ${TABLE}.monthly_rank ;;
  }

}

