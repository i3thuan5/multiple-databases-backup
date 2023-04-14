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

To perform an instant manual backup, simply launch a new backup container with the [`SCHEDULE`](#SCHEDULE) variable left empty. Related: [SCHEDULE](#SCHEDULE).

### Retention Strategy to Remove Old Backup Files

Retention strategy can be established to remove backups older than a designated timeframe and retain the earliest backup of every day or month for a set duration. Related: [MAX_PERIOD_IN_HOURS_TO_KEEP_EVERY_BACKUPS](#MAX_PERIOD_IN_HOURS_TO_KEEP_EVERY_BACKUPS), [MAX_PERIOD_IN_DAYS_TO_KEEP_DAILY_BACKUPS](#MAX_PERIOD_IN_DAYS_TO_KEEP_DAILY_BACKUPS), [MAX_PERIOD_IN_MONTHS_TO_KEEP_MONTHLY_BACKUPS](#MAX_PERIOD_IN_MONTHS_TO_KEEP_MONTHLY_BACKUPS).

### Security

Preserves the confientiality and intgerity of backup process and backup files. The backup process is built by shell pipeline, without leaving any temporary file in the disk. It also supports encrypting the backup files. Related: [GPG_PUBLIC_KEY](#GPG_PUBLIC_KEY).

### Robustness

Introducing to Continuous integration (CI) and dockerhub auto build to keep the backup script workable.

## Environment Variables

### S3 Storage Configurations
- `S3_ENDPOINT_URL` (required): The S3 endpoint URL in the form of `http://<hostname>/` or `https://<hostname>/
`. Note that the scheme should be included.
- `S3_REGION`: The name of the S3 region (eg. `eu-west-1`). This may be optional depending on your storage vendor.
- `S3_BUCKET` (required): The bucket name.
- `S3_ACCESS_KEY_ID` (required): The S3 Access Key ID.
- `S3_SECRET_ACCESS_KEY` (required): The S3 Secret Access Key.

### Backup Schedule

- `SCHEDULE`: The backup schedule specified in a crontab syntax string. Where the expressions minute, hour, day of the month, month of the year and day of the week. If set to a blank string, the script will perform a manual backup and exit. The default value is a blank string.


### GPG key

- `GPG_PUBLIC_KEY`: base64-encoded GPG public key used in the encryption process. If not set, backup files will be uploaded and saved un-encrypted.

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

### MAX_PERIOD_IN_HOURS_TO_KEEP_EVERY_BACKUPS

This optional environment variable is how old backups kept. Every backup recently in this period will be kept. The default value is `72`. It means 72 hours, 3 days.

### MAX_PERIOD_IN_DAYS_TO_KEEP_DAILY_BACKUPS

This optional environment variable is how many daily backups kept. The daily backup is the first backup in one day. The default value is `90`. It means 90 days, 3 months.

### MAX_PERIOD_IN_MONTHS_TO_KEEP_MONTHLY_BACKUPS

This optional environment variable is how many monthly backups kept. The monthly backup is the first backup in one month. The default value is `36`. It means 36 months, 3 years.

## Examples

### docker-compose

Keep `docker-compose.yml` simple and set the variables in `.env`.

#### docker-compose.yml

```
version: '3'
services:
  backup:
    image: ithuan/multiple-databases-backup
    volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    environment:
      S3_ENDPOINT_URL:
      S3_REGION:
      S3_BUCKET:
      S3_ACCESS_KEY_ID:
      S3_SECRET_ACCESS_KEY:
      SCHEDULE:
      GPG_PUBLIC_KEY:
      MAX_PERIOD_IN_HOURS_TO_KEEP_EVERY_BACKUPS:
      MAX_PERIOD_IN_DAYS_TO_KEEP_DAILY_BACKUPS:
      MAX_PERIOD_IN_MONTHS_TO_KEEP_MONTHLY_BACKUPS:
    restart: always
```

#### .env

The variables below are configurable. [GPG_PUBLIC_KEY](#GPG_PUBLIC_KEY) variables should be set by manually.

```
S3_ENDPOINT_URL=
S3_REGION=
S3_BUCKET=
S3_ACCESS_KEY_ID=
S3_SECRET_ACCESS_KEY=
SCHEDULE='0 * * * *'  # Backuping every hour
GPG_PUBLIC_KEY=
MAX_PERIOD_IN_HOURS_TO_KEEP_EVERY_BACKUPS=72  # 72 hours, 3 days
MAX_PERIOD_IN_DAYS_TO_KEEP_DAILY_BACKUPS=90  # 90 days, 3 months.
MAX_PERIOD_IN_MONTHS_TO_KEEP_MONTHLY_BACKUPS=36  # 36 months, 3 years
```
