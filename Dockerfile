FROM alpine:3

RUN apk update && apk add --no-cache docker-cli aws-cli

COPY scripts/ /app/
CMD sh /app/start.sh
