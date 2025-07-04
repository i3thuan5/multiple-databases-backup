FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
RUN groupadd --system --gid 138 docker
RUN apt update && \
  apt install -y docker.io cron gnupg jq

# https://github.com/aws/aws-cli/blob/v2/CHANGELOG.rst?plain=1
RUN apt install -y curl unzip && \
  mkdir /aws_build/ && \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.22.35.zip" -o "/aws_build/awscliv2.zip" && \
  unzip -q /aws_build/awscliv2.zip -d /aws_build/ && \
  /aws_build/aws/install && \
  rm -rf /aws_build/

RUN useradd --uid 1001 nonroot --user-group # --groups docker
RUN usermod -aG docker nonroot
RUN touch /etc/environment
RUN chown nonroot:nonroot /etc/environment

WORKDIR /app/
COPY scripts/ /app/

USER nonroot
CMD bash /app/start.sh
