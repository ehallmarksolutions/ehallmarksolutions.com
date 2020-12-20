gcloud auth login evan@ehallmarksolutions.com
gcloud config set project ehallmarksolutions
#gcloud auth application-default login

cd terraform

terraform init
terraform apply