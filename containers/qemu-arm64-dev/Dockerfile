FROM ubuntu:24.04

LABEL version="1.0-1"
LABEL id="qemu-arm64-dev"

ENV DEBIAN_FRONTEND=noninteractive

# Toolchain completo dentro del container
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    git \
    curl

VOLUME [ "/workspace" ]

WORKDIR /workspace

COPY ./container-init /container-init
RUN chmod -R +x /container-init

ENTRYPOINT [ "/container-init/entrypoint.sh" ]
CMD [ "/bin/bash" ]