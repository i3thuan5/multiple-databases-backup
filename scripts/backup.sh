#!/bin/bash
set -euo pipefail

for postgres_container_name in `docker container list \
    --format "{{.Names}}" \
    --filter label=backup.postgres=true`
do
    docker exec "${postgres_container_name}" pg_dump -U postgres \
      | gzip \
      | AWS_ACCESS_KEY_ID="${S3_ACCESS_KEY_ID}" AWS_SECRET_ACCESS_KEY="${S3_SECRET_ACCESS_KEY}" \
        aws s3 cp --endpoint-url "${S3_ENDPOINT_URL}" \
        - "s3://${S3_BUCKET}/${postgres_container_name}/${postgres_container_name}_`date "+%Y%m%dT%H%M"`.sql.gz"
done
