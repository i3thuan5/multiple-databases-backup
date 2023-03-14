#!/bin/bash
set -euo pipefail

export S3_ENDPOINT_URL="${S3_ENDPOINT_URL}"
export S3_REGION="${S3_REGION:-}"
export S3_ACCESS_KEY_ID="${S3_ACCESS_KEY_ID}"
export S3_SECRET_ACCESS_KEY="${S3_SECRET_ACCESS_KEY}"
export S3_BUCKET="${S3_BUCKET}"
export SCHEDULE="${SCHEDULE:-}"
export KEEP_EVERY_BACKUP_IN_HOURS="${KEEP_EVERY_BACKUP_IN_HOURS:-72}"
export KEEP_DAY_BACKUP_IN_DAYS="${KEEP_DAY_BACKUP_IN_DAYS:-90}"
export KEEP_MONTH_BACKUP_IN_MONTHS="${KEEP_MONTH_BACKUP_IN_MONTHS:-36}"
export GPG_PUBLIC_KEY="${GPG_PUBLIC_KEY:-}"

>&2 echo 'multiple-databases-backup is starting, backup first.'
export GPG_PUBLIC_KEY_PATH=/app/GPG_PUBLIC_KEY.rev
if [ -z "${GPG_PUBLIC_KEY}" ]; then
  >&2 echo 'There is not a GPG_PUBLIC_KEY, all backup files will not be encrypted.'
else
  >&2 echo 'There is the GPG_PUBLIC_KEY, all backup files will be encrypted.'
  echo ${GPG_PUBLIC_KEY} | base64 -d  > ${GPG_PUBLIC_KEY_PATH}
fi
bash /app/backup.sh
if [ -z "${SCHEDULE}" ]; then
  >&2 echo "There is not SCHEDULE variable, backup once.";
  >&2 echo 'multiple-databases-backup is finished, exiting.'
  exit 0
elif [[ "${SCHEDULE}" =~ ^([^[:blank:]]*[[:blank:]]){4}([^[:blank:]])*$ ]]; then
  >&2 echo "There is the SCHEDULE variable: '${SCHEDULE}', backup periodically.";
  bash /app/crontab.sh
else
  >&2 echo "The SCHEDULE variable should contain five fields exactly.";
  exit 1
fi
