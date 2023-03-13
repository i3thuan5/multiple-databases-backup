FROM amazon/aws-cli:latest AS builder

RUN yum update -y && \
  amazon-linux-extras install docker && \
  yum install -y jq

COPY scripts/ /app/
ENTRYPOINT ["/bin/bash"]

CMD bash /app/start.sh
