FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    vim \
    wget \
    unzip \
    ca-certificates

VOLUME [ "/workspace" ]

WORKDIR /workspace

CMD ["/bin/bash"]