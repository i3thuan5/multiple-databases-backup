#!/bin/bash
set -euo pipefail

source /app/filepath.sh

CONTAINER_NAME=$1

FILE_PATH=$(filepath ${CONTAINER_NAME} "${MAX_PERIOD_IN_HOURS_TO_KEEP_EVERY_BACKUPS} hours ago")

temp_dir=$(mktemp -d)
ALL_FILES="${temp_dir}/all.list"
PRESERVE_FILES="${temp_dir}/preserves.list"

aws s3api list-objects-v2 \
    --endpoint-url "${S3_ENDPOINT_URL}" \
    --bucket "${S3_BUCKET}" \
    --prefix "${CONTAINER_NAME}" \
  | jq .Contents[].Key \
  > "${ALL_FILES}"

aws s3api list-objects-v2 \
    --endpoint-url "${S3_ENDPOINT_URL}" \
    --bucket "${S3_BUCKET}" \
    --prefix "${CONTAINER_NAME}" \
    --start-after "${FILE_PATH}" \
  | jq .Contents[].Key \
  > "${PRESERVE_FILES}"

for day in $(seq 1 "${MAX_PERIOD_IN_DAYS_TO_KEEP_DAILY_BACKUPS}")
do
  TARGET_DAY=`date "+%Y-%m-%d" --date "${day} days ago"`
  FILE_PATH=$(filepath ${CONTAINER_NAME} "${TARGET_DAY}")
  aws s3api list-objects-v2 \
      --endpoint-url "${S3_ENDPOINT_URL}" \
      --bucket "${S3_BUCKET}" \
      --prefix "${CONTAINER_NAME}" \
      --start-after "${FILE_PATH}" \
      --max-item "1" \
    | jq .Contents[0].Key \
    >> "${PRESERVE_FILES}"
done

for month in $(seq 1 "${MAX_PERIOD_IN_MONTHS_TO_KEEP_MONTHLY_BACKUPS}")
do
  TARGET_DAY=`date "+%Y-%m-01" --date "${month} months ago"`
  FILE_PATH=$(filepath ${CONTAINER_NAME} "${TARGET_DAY}")
  aws s3api list-objects-v2 \
      --endpoint-url "${S3_ENDPOINT_URL}" \
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
    --endpoint-url "${S3_ENDPOINT_URL}" \
    --bucket "${S3_BUCKET}" \
    --key ${filename}
done

rm -rf "${temp_dir}"
