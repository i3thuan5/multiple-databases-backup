# multiple-databases-backup
Backup postgres, mariadb at the same time by docker one container.

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
      S3_ACCESS_KEY_ID: key
      S3_SECRET_ACCESS_KEY: secret
      S3_BUCKET: my-bucket
      SCHEDULE: "0 * * * *"  # Optional
      GPG_PUBLIC_KEY: ${GPG_PUBLIC_KEY:-}  # Optional
      BACKUP_KEEP_MINS: 1440  # Optional, not implemented yet
      BACKUP_KEEP_DAYS: 7  # Optional, not implemented yet
      BACKUP_KEEP_WEEKS: 4  # Optional, not implemented yet
      BACKUP_KEEP_MONTHS: 6  # Optional, not implemented yet
```

## Reference

`GPG_PUBLIC_KEY`: base64 format of GPG public key for asymmetric encryptions

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

The decryption command is `gpg --decrypt <postgres15.sql.gz.gpg> | zcat`.
  