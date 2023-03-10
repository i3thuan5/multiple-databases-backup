#!/bin/bash
set -euo pipefail

echo "${SCHEDULE} sh /app/backup.sh" > /etc/crontabs/root
crond -f
