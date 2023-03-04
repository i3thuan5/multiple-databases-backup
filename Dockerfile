FROM alpine:3

RUN apk update && apk add --no-cache docker-cli

COPY scripts/backup.sh ./

CMD ./backup.sh
