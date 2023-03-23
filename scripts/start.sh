#!/bin/bash
set -euo pipefail

export S3_ENDPOINT_URL="${S3_ENDPOINT_URL}"
export S3_REGION="${S3_REGION:-}"
export S3_ACCESS_KEY_ID="${S3_ACCESS_KEY_ID}"
export S3_SECRET_ACCESS_KEY="${S3_SECRET_ACCESS_KEY}"
export S3_BUCKET="${S3_BUCKET}"
export SCHEDULE="${SCHEDULE:-}"
export MAX_PERIOD_IN_HOURS_TO_KEEP_EVERY_BACKUPS="${MAX_PERIOD_IN_HOURS_TO_KEEP_EVERY_BACKUPS:-72}"
export MAX_PERIOD_IN_DAYS_TO_KEEP_DAILY_BACKUPS="${MAX_PERIOD_IN_DAYS_TO_KEEP_DAILY_BACKUPS:-90}"
export MAX_PERIOD_IN_MONTHS_TO_KEEP_MONTHLY_BACKUPS="${MAX_PERIOD_IN_MONTHS_TO_KEEP_MONTHLY_BACKUPS:-36}"
export GPG_PUBLIC_KEY="${GPG_PUBLIC_KEY:-}"
export GPG_PUBLIC_KEY_PATH=/app/GPG_PUBLIC_KEY.rev

echo "# Environment variables for cron.
S3_ENDPOINT_URL=\"${S3_ENDPOINT_URL}\"
S3_REGION=\"${S3_REGION}\"
S3_ACCESS_KEY_ID=\"${S3_ACCESS_KEY_ID}\"
S3_SECRET_ACCESS_KEY=\"${S3_SECRET_ACCESS_KEY}\"
S3_BUCKET=\"${S3_BUCKET}\"
SCHEDULE=\"${SCHEDULE}\"
MAX_PERIOD_IN_HOURS_TO_KEEP_EVERY_BACKUPS=\"${MAX_PERIOD_IN_HOURS_TO_KEEP_EVERY_BACKUPS}\"
MAX_PERIOD_IN_DAYS_TO_KEEP_DAILY_BACKUPS=\"${MAX_PERIOD_IN_DAYS_TO_KEEP_DAILY_BACKUPS}\"
MAX_PERIOD_IN_MONTHS_TO_KEEP_MONTHLY_BACKUPS=\"${MAX_PERIOD_IN_MONTHS_TO_KEEP_MONTHLY_BACKUPS}\"
GPG_PUBLIC_KEY=\"${GPG_PUBLIC_KEY}\"
GPG_PUBLIC_KEY_PATH=\"${GPG_PUBLIC_KEY_PATH}\"
" >> /etc/environment

if [ -z "${GPG_PUBLIC_KEY}" ]; then
  >&2 echo 'There is not a GPG_PUBLIC_KEY, all backup files will not be encrypted.'
else
  >&2 echo 'There is the GPG_PUBLIC_KEY, all backup files will be encrypted.'
  echo ${GPG_PUBLIC_KEY} | base64 -d  > ${GPG_PUBLIC_KEY_PATH}
fi
if [ -z "${SCHEDULE}" ]; then
  >&2 echo "multiple-databases-backup is starting."
  >&2 echo "There is not SCHEDULE variable, backup once."
  bash /app/backup.sh
  >&2 echo 'multiple-databases-backup is finished, exiting.'
  exit 0
elif [[ "${SCHEDULE}" =~ ^([^[:blank:]]*[[:blank:]]){4}([^[:blank:]])*$ ]]; then
  >&2 echo 'multiple-databases-backup is starting.'
  >&2 echo "There is the SCHEDULE variable: '${SCHEDULE}', backup periodically."
  >&2 echo "And backup right now at the same time."
  bash /app/backup.sh &
  bash /app/crontab.sh
else
  >&2 echo "The SCHEDULE variable should contain five fields exactly."
  exit 1
fi
