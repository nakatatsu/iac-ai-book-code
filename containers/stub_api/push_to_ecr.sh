#! /bin/bash

# DO NOT use in production.

if [ -z "$ENV" ]; then
  export ENV=experimental
fi

export AWS_ACCOUNT=$(aws sts get-caller-identity --query "Account" --output text)
export CONTAINER_TAG=$(date +"%Y%m%d%H%M%S")
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.ap-northeast-1.amazonaws.com
docker build -t ${ENV}-practitioner-api .
docker tag ${ENV}-practitioner-api:latest ${AWS_ACCOUNT}.dkr.ecr.ap-northeast-1.amazonaws.com/${ENV}-practitioner-api:${CONTAINER_TAG}
docker push ${AWS_ACCOUNT}.dkr.ecr.ap-northeast-1.amazonaws.com/${ENV}-practitioner-api:${CONTAINER_TAG}