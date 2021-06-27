# 後続の処理で使用する変数を設定します。
PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects list --filter=$PROJECT_ID --format="value(PROJECT_NUMBER)")
SERVICE_ACCOUNT=service-$PROJECT_NUMBER@gcp-sa-datafusion.iam.gserviceaccount.com

# Cloud Data Fusionで使用されるサービスアカウントにサービスアカウントユーザーのロールを付与します。
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$SERVICE_ACCOUNT \
  --role=roles/iam.serviceAccountUser
