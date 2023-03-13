FROM amazon/aws-cli:latest AS builder

RUN yum install -y nerdctl jq

RUN mkdir -p /run/containerd/ && \
  ln -s /var/run/docker.sock /run/containerd/containerd.sock
RUN ln -s /opt/aws-cli/bin/aws /bin/aws

COPY scripts/ /app/
CMD bash /app/start.sh
