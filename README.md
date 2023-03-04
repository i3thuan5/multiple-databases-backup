# multiple-databases-backup
Backup postgres, mariadb at the same time by docker one container.

## Quick Start

```
version: '3'
services:
  mariadb:
    image: mariadb:10.6
    labels:
      - backup.mariadb=true
  postgres:
    image: postgres
    labels:
      - backup.postgres=true
  backup:
    image: ithuan/multiple-databases-backup
    volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    environment:
      S3_ENDPOINT_URL: https://domain.tw
      S3_REGION: region
      S3_ACCESS_KEY_ID: key
      S3_SECRET_ACCESS_KEY: secret
      S3_BUCKET: my-bucket
      SCHEDULE: @daily # Optional
      BACKUP_KEEP_MINS: 1440 # Optional
      BACKUP_KEEP_DAYS: 7 # Optional
      BACKUP_KEEP_WEEKS: 4 # Optional
      BACKUP_KEEP_MONTHS: 6 # Optional
```
