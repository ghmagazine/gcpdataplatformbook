python3 etl.py \
  --region us-central1 \
  --dt 20181001 \
  --runner DataflowRunner \
  --project $(gcloud config get-value project) \
  --temp_location gs://$(gcloud config get-value project)-gcpbook-ch5/tmp/ \
  --experiments shuffle_mode=service
