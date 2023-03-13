FROM amazon/aws-cli:latest AS builder

RUN yum update -y && \
  amazon-linux-extras install docker && \
  yum install -y jq

COPY scripts/ /app/

ENTRYPOINT
CMD bash /app/start.sh
