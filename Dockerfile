FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && \
  apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release && \
  mkdir -m 0755 -p /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  apt-get update && \
  apt install -y docker-ce-cli

RUN   apt install -y unzip
RUN mkdir /aws_build/ && \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/aws_build/awscliv2.zip"
RUN \
  unzip -q /aws_build/awscliv2.zip -d /aws_build/ && \
  /aws_build//aws/install && \
  rm -rf /aws_build/
RUN   apt install -y jq

COPY scripts/ /app/

CMD bash /app/start.sh
