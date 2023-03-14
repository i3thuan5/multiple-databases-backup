#!/bin/bash
set -euo pipefail

echo "${SCHEDULE} sh /app/backup.sh" | crontab -
crond -f
