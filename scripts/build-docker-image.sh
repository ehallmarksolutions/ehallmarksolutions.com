PROJECT_NAME="ehallmarksolutions"
IMAGE_NAME="gcr.io/$PROJECT_NAME/$PROJECT_NAME:latest"

gcloud auth login evan@ehallmarksolutions.com
gcloud config set project ehallmarksolutions
gcloud container clusters get-credentials ehallmarksolutions --region us-west2-c

echo "Building image"
docker build -t $IMAGE_NAME .

docker push $IMAGE_NAME
