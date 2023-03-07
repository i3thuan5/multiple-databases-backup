#!/bin/bash

>&2 echo 'multiple-databases-backup is starting, backup first.'
sh /app/backup.sh
if [ -z "${SCHEDULE}" ];
then
  echo "var is blank";
else
  echo "var is set to '${SCHEDULE}'";
  sh /app/crontab.sh
fi
>&2 echo 'multiple-databases-backup is finished, exiting.'
