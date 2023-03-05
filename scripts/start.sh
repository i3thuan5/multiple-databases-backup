sh ./backup.sh
if [ -z "${SCHEDULE}" ];
then
  echo "var is blank";
else
  echo "var is set to '${SCHEDULE}'";
  sh ./crontab.sh
fi