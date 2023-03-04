FROM alpine:3

RUN apk update && apk add --no-cache docker-cli aws-cli

COPY scripts/backup.sh /app/
CMD sh -x /app/backup.sh
