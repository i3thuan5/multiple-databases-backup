# multiple-databases-backup
Backup postgres, mariadb at the same time by docker one container.

[![Build Status](https://app.travis-ci.com/i3thuan5/multiple-databases-backup.svg?branch=main)](https://app.travis-ci.com/i3thuan5/multiple-databases-backup)
[![GitHub](https://img.shields.io/github/license/i3thuan5/multiple-databases-backup)](https://github.com/i3thuan5/multiple-databases-backup/blob/main/LICENSE)
[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/ithuan/multiple-databases-backup)](https://hub.docker.com/r/ithuan/multiple-databases-backup)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/ithuan/multiple-databases-backup/latest)](https://hub.docker.com/r/ithuan/multiple-databases-backup)
[![Docker Stars](https://img.shields.io/docker/stars/ithuan/multiple-databases-backup)](https://hub.docker.com/r/ithuan/multiple-databases-backup)
[![Docker Pulls](https://img.shields.io/docker/pulls/ithuan/multiple-databases-backup)](https://hub.docker.com/r/ithuan/multiple-databases-backup)
![GitHub Repo stars](https://img.shields.io/github/stars/i3thuan5/multiple-databases-backup?style=social)

## Quick Start

```
version: '3'
services:
  postgres:
    image: postgres
    labels:
      - backup.postgres=true  # Add label
    environment:
      POSTGRES_PASSWORD: secret
  mariadb:
    image: mariadb:10.6
    labels:
      - backup.mariadb=true  # Not implemented yet
  backup:
    image: ithuan/multiple-databases-backup
    volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    environment:
      S3_ENDPOINT_URL: https://domain.tw
      S3_REGION: region
      S3_BUCKET: my-bucket
      S3_ACCESS_KEY_ID: key
      S3_SECRET_ACCESS_KEY: secret
      SCHEDULE: "0 * * * *"  # Optional
      GPG_PUBLIC_KEY: ${GPG_PUBLIC_KEY:-}  # Optional
      BACKUP_KEEP_MINS: 1440  # Optional, not implemented yet
      BACKUP_KEEP_DAYS: 7  # Optional, not implemented yet
      BACKUP_KEEP_WEEKS: 4  # Optional, not implemented yet
      BACKUP_KEEP_MONTHS: 6  # Optional, not implemented yet
```

## Features

### Backup Together

Backup the containers containing the labels together.

### Configure Easily

Only configuration is setting labels in database containers and setting storages and encryption variables in the backup container.

### Support Remote Backup natively

All backups are transfered to remote storage to keep availability. Related: [S3_ENDPOINT_URL](#S3_ENDPOINT_URL), [S3_REGION](#S3_REGION), [S3_BUCKET](#S3_BUCKET), [S3_ACCESS_KEY_ID](#S3_ACCESS_KEY_ID), [S3_SECRET_ACCESS_KEY](#S3_SECRET_ACCESS_KEY).

### Support Backup Periodly and Backup once

Using the crontab daemon to backup periodly is for operation daily. For emergency, backup container can backup immediately. Related: [SCHEDULE](#SCHEDULE).

### Production ready

Compatiabily to docker compose, docker-swarm and k8s.

### Security

Preserves the confientiality and intgerity of backup process and backup files.

### Robust

Introducing to Continuous integration (CI) and dockerhub auto build to keep the backup script workable.

## Environment Variables

### S3_ENDPOINT_URL

This environment variable is required for S3 URL when connecting to S3, including scheme.

### S3_REGION

This optional environment variable is the name of the S3 region to use. (eg. eu-west-1)

### S3_BUCKET

This environment variable is required for S3 storage bucket name, as a string.

### S3_ACCESS_KEY_ID

This environment variable is required for S3 access key, as a string.

### S3_SECRET_ACCESS_KEY

This environment variable is required for S3 secret access key, as a string.

### SCHEDULE

This optional environment variable is the backup schedule for backup. The format is crontab syntax containing settings for minute, hour, day of the month, month of the year and day of the week respectively. If this vairable is blank, the script will backup once and exit. The default value is ''.

### GPG_PUBLIC_KEY
This optional environment variable is used for asymmetric encryptions. It is base64 format of GPG public key. The configuration steps are:

1. [Generating a new GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key) if you don't have an existing GPG key.
2. Get base64 format of GPG public key and save to `.env` env-file:
```bash
GPG_PUBLIC_KEY=`gpg --armor --export <GPG key ID> | base64 --wrap 0`
echo "GPG_PUBLIC_KEY=${GPG_PUBLIC_KEY}" > .env
```
3. Run with `docker-compose`, `docker-compose` will [read `.env` automatically](https://docs.docker.com/compose/environment-variables/set-environment-variables/#substitute-with-an-env-file).
Or pass the varivable to `docker`:
```bash
docker run --env-file .env ithuan/multiple-databases-backup
```

The decryption command is `gpg --decrypt <postgres15.sql.gz.gpg> | zcat`, the output is the original SQL.
