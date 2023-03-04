#!/bin/bash
set -euo pipefail

docker container list --filter label=backup.postgres=true
