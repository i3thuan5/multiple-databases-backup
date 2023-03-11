#!/bin/bash
set -euo pipefail

>&2 echo 'multiple-databases-backup is starting, backup first.'
export GPG_KEY_PATH=/app/gpg_key.rev
>&2 echo ${GPG_KEY} | base64 -d  > ${GPG_KEY_PATH}
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
