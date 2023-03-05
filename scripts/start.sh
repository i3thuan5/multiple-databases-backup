sh /app/backup.sh
if [ -z "${SCHEDULE}" ];
then
  echo "var is blank";
else
  echo "var is set to '${SCHEDULE}'";
  sh /app/crontab.sh
fi