#!/bin/bash
set -euo pipefail

>&2 echo 'multiple-databases-backup is starting, backup first.'
sh /app/backup.sh
if [ -z "${SCHEDULE:-}" ];
then
  >&2 echo "There is not SCHEDULE variable, backup once.";
  >&2 echo 'multiple-databases-backup is finished, exiting.'
  exit 0
elif [ "${SCHEDULE:-}" =~ "[^ ] [^ ] [^ ] [^ ] [^ ]" ];
  >&2 echo "There is the SCHEDULE variable: '${SCHEDULE}', backup periodically.";
  sh /app/crontab.sh
else
  >&2 echo "The SCHEDULE variable should contain five fields exactly.";
fi
