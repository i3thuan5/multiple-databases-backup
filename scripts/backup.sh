#!/bin/bash
set -euo pipefail

for postgres_container_name in `docker container list \
    --format "{{.Names}}" \
    --filter label=backup.postgres=true`
do
    FILE_PATH="`date "+%Y-%m-%d"`/${postgres_container_name}_`date "+%Y%m%dT%H%M"`"
    if [ -z "${GPG_PUBLIC_KEY:-}" ]; then
      ENCRYPT_COMMAND="cat"
      OUTPUT_FILE_PATH="${FILE_PATH}.sql.gz"
    else
      ENCRYPT_COMMAND="gpg --encrypt --recipient-file ${GPG_PUBLIC_KEY_PATH} -o - -"
      OUTPUT_FILE_PATH="${FILE_PATH}.sql.gz.gpg"
    fi
    docker exec "${postgres_container_name}" pg_dump -U postgres \
      | gzip \
      | ${ENCRYPT_COMMAND} \
      | AWS_DEFAULT_REGION="${S3_REGION}" \
        AWS_ACCESS_KEY_ID="${S3_ACCESS_KEY_ID}" \
        AWS_SECRET_ACCESS_KEY="${S3_SECRET_ACCESS_KEY}" \
        aws s3 cp --endpoint-url "${S3_ENDPOINT_URL}" \
        - "s3://${S3_BUCKET}/${postgres_container_name}/${OUTPUT_FILE_PATH}"
    bash -x cleanup.sh "${postgres_container_name}" "${FILE_PATH}"
done
