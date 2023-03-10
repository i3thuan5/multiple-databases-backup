#!/bin/bash
set -euo pipefail

>&2 echo 'multiple-databases-backup is starting, backup first.'
sh /app/backup.sh
if [ -z "${SCHEDULE:-}" ];
then
  >&2 echo "There is not SCHEDULE variable, backup once.";
else
  >&2 echo "There is the SCHEDULE variable: '${SCHEDULE}', backup periodically.";
  sh /app/crontab.sh
fi
>&2 echo 'multiple-databases-backup is finished, exiting.'
