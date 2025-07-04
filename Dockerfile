FROM ubuntu:24.04
# https://github.com/aws/aws-cli/blob/v2/CHANGELOG.rst?plain=1

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && \
  apt install --no-install-recommends -y \
    docker.io cron gnupg jq \
    curl ca-certificates unzip && \
  apt-get clean && \
  mkdir /aws_build/ && \
  update-ca-certificates && \
  curl -sSf "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.22.35.zip" -o "/aws_build/awscliv2.zip" && \
  unzip -q /aws_build/awscliv2.zip -d /aws_build/ && \
  /aws_build/aws/install && \
  rm -rf /aws_build/

WORKDIR /app/
COPY scripts/ /app/

CMD ["bash", "/app/start.sh"]
