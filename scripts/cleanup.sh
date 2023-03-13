#!/bin/bash
set -euo pipefail

source /app/filepath.sh

KEEP_EVERY_BACKUP_IN_HOURS=${KEEP_EVERY_BACKUP_IN_HOURS:-72}

CONTAINER_NAME=$1

FILE_PATH=$(filepath ${CONTAINER_NAME} "${KEEP_EVERY_BACKUP_IN_HOURS} hours ago")

ALL_FILES=/all.list
PRESERVE_FILES=/preserves.list

aws s3api list-objects-v2 \
    --endpoint-url http://localstack:4566 \
    --bucket "${S3_BUCKET}" \
    --prefix "${CONTAINER_NAME}" \
  | jq .Contents[].Key \
  > "${ALL_FILES}"

aws s3api list-objects-v2 \
    --endpoint-url http://localstack:4566 \
    --bucket "${S3_BUCKET}" \
    --prefix "${CONTAINER_NAME}" \
    --start-after "${FILE_PATH}" \
  | jq .Contents[].Key \
  > "${PRESERVE_FILES}"

for day in $(seq 1 "${KEEP_DAY_BACKUP_IN_DAYS}")
do
  TARGET_DAY=`date "+%Y-%m-%d" --date "${day} days ago"`
  FILE_PATH=$(filepath ${CONTAINER_NAME} "${TARGET_DAY}")
  aws s3api list-objects-v2 \
      --endpoint-url http://localstack:4566 \
      --bucket "${S3_BUCKET}" \
      --prefix "${CONTAINER_NAME}" \
      --start-after "${FILE_PATH}" \
      --max-item "1" \
    | jq .Contents[0].Key \
    >> "${PRESERVE_FILES}"
done

for month in $(seq 1 "${KEEP_MONTH_BACKUP_IN_MONTHS}")
do
  TARGET_DAY=`date "+%Y-%m-01" --date "${month} months ago"`
  FILE_PATH=$(filepath ${CONTAINER_NAME} "${TARGET_DAY}")
  aws s3api list-objects-v2 \
      --endpoint-url http://localstack:4566 \
      --bucket "${S3_BUCKET}" \
      --prefix "${CONTAINER_NAME}" \
      --start-after "${FILE_PATH}" \
      --max-item "1" \
    | jq .Contents[0].Key \
    >> "${PRESERVE_FILES}"
done

for filename in `cat "${ALL_FILES}" \
  | grep --invert-match --line-regexp --file "${PRESERVE_FILES}" \
  | sed 's/^"\(.*\)"$/\1/g'`
do
  aws s3api delete-object \
    --endpoint-url http://localstack:4566 \
    --bucket "${S3_BUCKET}" \
    --key ${filename}
done
