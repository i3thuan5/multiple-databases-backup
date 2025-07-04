FROM ubuntu:24.04
# https://github.com/aws/aws-cli/blob/v2/CHANGELOG.rst?plain=1

RUN groupadd --system --gid 138 docker
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

RUN useradd --uid 1001 nonroot --user-group && \
  usermod -aG docker nonroot && \
  touch /etc/environment && \
  chown nonroot:nonroot /etc/environment && \
  chmod u+s /usr/sbin/cron

WORKDIR /app/
COPY scripts/ /app/

USER nonroot
CMD ["bash", "/app/start.sh"]
