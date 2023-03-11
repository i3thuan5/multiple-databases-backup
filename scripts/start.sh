#!/bin/bash
set -euo pipefail

>&2 echo 'multiple-databases-backup is starting, backup first.'
export GPG_KEY_PATH=/app/gpg_key.rev
if [ -z "${GPG_KEY:-}" ]; then
  >&2 echo 'There is not a GPG_KEY, all backup files will not be encrypted.'
else
  >&2 echo 'There is the GPG_KEY, all backup files will be encrypted.'
  echo ${GPG_KEY} | base64 -d  > ${GPG_KEY_PATH}
fi
bash /app/backup.sh
if [ -z "${SCHEDULE:-}" ]; then
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
