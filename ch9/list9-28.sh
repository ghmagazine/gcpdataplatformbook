python nyc_taxi_streaming_analytics2.py \
--update \
--project $(gcloud config get-value project) \
--job_name=taxirides-realtime \
--region='us-central1' \
--runner DataflowRunner \
--input_subscription "projects/$(gcloud config get-value project)/subscriptions/streaming-taxi-rides" \
--output_dataset "$(gcloud config get-value project).nyc_taxi_trip"

