#!/bin/bash
set -euo pipefail

export AWS_DEFAULT_REGION="${S3_REGION}"
export AWS_ACCESS_KEY_ID="${S3_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${S3_SECRET_ACCESS_KEY}"

source /app/filepath.sh

if [ -z "${GPG_PUBLIC_KEY}" ]; then
  ENCRYPT_COMMAND="cat"
  FILE_TYPE="sql.gz"
else
  ENCRYPT_COMMAND="gpg --encrypt --recipient-file ${GPG_PUBLIC_KEY_PATH} -o - -"
  FILE_TYPE="sql.gz.gpg"
fi

all_containers=`docker container list \
    --format "{{.Names}}" \
    --filter label=backup.postgres=true \
  | sort`

for postgres_container_name in $all_containers
do
  >&2 echo "Backuping ${postgres_container_name} is starting."
  FILE_PATH=$(filepath ${postgres_container_name} 'now')
  docker exec "${postgres_container_name}" pg_dump -U postgres \
    | gzip \
    | ${ENCRYPT_COMMAND} \
    | aws s3 cp --endpoint-url "${S3_ENDPOINT_URL}" \
      - "s3://${S3_BUCKET}/${FILE_PATH}.${FILE_TYPE}"
  >&2 echo "Backuping ${postgres_container_name} is finished."
done

for postgres_container_name in $all_containers
do
  >&2 echo "Cleaning the ${postgres_container_name} old backup is starting."
  bash /app/cleanup.sh "${postgres_container_name}"
  >&2 echo "Cleaning the ${postgres_container_name} old backup is finished."
done
