#!/bin/bash
set -euo pipefail

echo "PATH=${PATH}
${SCHEDULE} bash /app/backup.sh >> /var/log/cron.log 2>> /var/log/cron.error.log" \
  | crontab -

cron -f -L 15
