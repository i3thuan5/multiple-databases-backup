FROM alpine:3

RUN apk update && apk add --no-cache docker-cli aws-cli bash gnupg

COPY scripts/ /app/
CMD bash /app/start.sh
