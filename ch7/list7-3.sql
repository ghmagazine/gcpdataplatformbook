-- リスト7-3. クエリジョブの監査
select
  start_time
, end_time
, user_email
, query
, referenced_tables
, destination_table
from
  `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
where
  date(creation_time) = current_date()
and job_type = 'QUERY'
order by
  start_time
