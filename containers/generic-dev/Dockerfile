FROM ubuntu:24.04

LABEL version="1.0-2"
LABEL id="generic-dev"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    vim \
    wget \
    unzip \
    sudo \
    gosu \
    ca-certificates

VOLUME [ "/workspace" ]

WORKDIR /workspace

COPY ./container-init /container-init
RUN chmod -R +x /container-init

ENTRYPOINT [ "/container-init/entrypoint.sh" ]
CMD [ "/bin/bash" ]