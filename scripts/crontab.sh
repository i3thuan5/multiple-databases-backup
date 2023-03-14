#!/bin/bash
set -euo pipefail

echo "${SCHEDULE} bash /app/backup.sh" | crontab -
cron -f -L 15
