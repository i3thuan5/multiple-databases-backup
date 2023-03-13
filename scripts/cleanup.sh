#!/bin/bash
set -euo pipefail

KEEP_EVERY_BACKUP_IN_HOURS=${KEEP_EVERY_BACKUP_IN_HOURS:-72}

CONTAINER_NAME=$1

DATE=`date "+%Y-%m-%d" --date "${KEEP_EVERY_BACKUP_IN_HOURS} hours ago"`
TIME=`date "+%Y%m%dT%H%M" --date "${KEEP_EVERY_BACKUP_IN_HOURS} hours ago"`
FILE_PATH="${DATE}/${CONTAINER_NAME}_${TIME}"

PRESERVE_FILES=/preserves.list
ALL_FILES=/all.list

aws s3api list-objects-v2 \
    --endpoint-url http://localstack:4566 \
    --bucket "${S3_BUCKET}" \
    --prefix "${CONTAINER_NAME}" \
    --start-after "${FILE_PATH}" \
  | jq .Contents[].Key
  > "${PRESERVE_FILES}"
aws s3api list-objects-v2 \
    --endpoint-url http://localstack:4566 \
    --bucket "${S3_BUCKET}" \
    --prefix "${CONTAINER_NAME}" \
  | jq .Contents[].Key
  > "${ALL_FILES}"

for filename in `cat "${ALL_FILES}" | grep -v --file "${PRESERVE_FILES}"`
do
  aws s3api delete-object \
    --endpoint-url http://localstack:4566 \
    --bucket "${S3_BUCKET}" \
    --key filename
done
