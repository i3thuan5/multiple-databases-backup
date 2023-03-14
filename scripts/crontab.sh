#!/bin/bash
set -euo pipefail

echo "PATH=${PATH}
${SCHEDULE} bash /app/backup.sh >> cron.log 2>> cron.error.log" \
  | crontab -

cron -f -L 15
