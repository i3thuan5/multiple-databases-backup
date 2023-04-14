# multiple-databases-backup

Backup databases from dockerized PostgresSQL to any S3-compatible storage with a single backup container. Supporting periodic backup schedule, S3 storage API and encrypted backups.

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
      - backup.postgres=true  # Add this label on database containers you wish to backup
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
      MAX_PERIOD_IN_HOURS_TO_KEEP_EVERY_BACKUPS: 72  # Optional
      MAX_PERIOD_IN_DAYS_TO_KEEP_DAILY_BACKUPS: 90  # Optional
      MAX_PERIOD_IN_MONTHS_TO_KEEP_MONTHLY_BACKUPS: 36  # Optional
```

## Features

### Backup Multiple Databases at Once

Simply add the `backup.postgres=true` label on database containers that needs backup. The backup script will automatically discover containers with `backup.postgres=true` label and run the backup command against all of them.


### Easy Configuration

All custom settings including backup schedule, S3 storage and encryption key can be configured in the `environment` of backup container. See the [docker-compose](#docker-compose) part for example configuration.

### Supports Any S3-compatiable Storages

Using the S3 CLI, it is possible to upload backup files to S3-compatible storage services offered by various vendors. The S3 connection settings can be customized through the "environment" configuration. See [S3 Storage Configurations](#S3_Storage_Configurations) for details.

### Manual Backup

To perform an instant manual backup, simply launch a new backup container with the [`SCHEDULE`](#SCHEDULE) variable left empty. See [Backup Schedule](#Backup_Schedule) for details.

### Retention Strategy to Remove Old Backup Files

Retention strategy can be established to remove backups older than a designated time period and retain the earliest backup of every day or month for a set duration. See: [Retention Policy](#Retention_Policy) for details.

### Confidentiality and Integrity

GPG-encrypted backup is supported. See [GPG key](#GPG_KEY) for details on how to configure encrypted backups. Data is transferred on shell pipeline without leaving any unencrypted intermediate data on the disk, in order to preserve confidentiality and integrity of the backup files.

### Automated Test and Build

Our codebase undergoes automatic testing using Travis CI, which covers backup scripts and docker configurations. Furthermore, an automated build on dockerhub is also in place. These automated processes minimize the possibility of introducing bugs or vulnerabilities into our codebase.

## Configuration

### S3 Storage Configurations
- `S3_ENDPOINT_URL` (required): The S3 endpoint URL in the form of `http://<hostname>/` or `https://<hostname>/
`. Note that the scheme should be included.
- `S3_REGION`: The name of the S3 region (eg. `eu-west-1`). This may be optional depending on your storage vendor.
- `S3_BUCKET` (required): The bucket name.
- `S3_ACCESS_KEY_ID` (required): The S3 Access Key ID.
- `S3_SECRET_ACCESS_KEY` (required): The S3 Secret Access Key.

### Backup Schedule

- `SCHEDULE`: The backup schedule specified in a string following [crontab syntax](https://www.man7.org/linux/man-pages/man5/crontab.5.html) where the five fields are minute, hour, day of month, month and day of week. If set to a blank string, the script will perform a manual backup and exit. The default value is a blank string.


### GPG key

- `GPG_PUBLIC_KEY`: Base64-encoded GPG public key used in the encryption process. If not set, backup files will be uploaded and saved un-encrypted.

#### Generate and encode a GPG public key

1. [Generate a new GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key) if there is not any existing GPG key.
2. Encode GPG public key in base64 format and write it into the `.env` file.
```bash
GPG_PUBLIC_KEY=`gpg --armor --export <GPG key ID> | base64 --wrap 0`
echo "GPG_PUBLIC_KEY=${GPG_PUBLIC_KEY}" > .env
```
3. Export the private key and store it securely. The private key is needed when decrypting a backup file.
```bash
gpg --export-secret-keys --armor <GPG key ID> > <gpg-private-key.asc>
```

#### Decrypt a backup file

1. Import the gpg private key if it hasn't been imported yet.
```bash
gpg --import <gpg-private-key.asc>
```
2. Decrypt the backup file to get the original SQL.
```bash
gpg --decrypt <postgres15.sql.gz.gpg> | zcat
```

### Retention Policy

There are 3 variables available for users to setup their retention policy. Backup files that are older than a specified period will be deleted, while a daily/monthly backup, which is the earliest backup file of the day/month, will be kept for a specified period.

- `MAX_PERIOD_IN_HOURS_TO_KEEP_EVERY_BACKUPS`: The time period in **hours** to keep all the recent backups. Backup files that are older than this period will be deleted, except for the daily and monthly backups that are to be kept. The value should be any positive integer. The default value is `72` hours.
- `MAX_PERIOD_IN_DAYS_TO_KEEP_DAILY_BACKUPS`: The time period in **days** to keep all the daily backups. Set the value to any positive integer to keep daily backups, or set it to `0` to disable this behavior. The default value is `90` days.
- `MAX_PERIOD_IN_MONTHS_TO_KEEP_MONTHLY_BACKUPS`: The time period in **months** to keep all the monthly backups. Set the value to any positive integer to keep monthly backups, or set it to `0` to disable this behavior. The default value is `36` months.
