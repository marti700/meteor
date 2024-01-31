FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-20.04

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
    build-essential \
    gcc-arm-none-eabi \
    binutils-multiarch \
    gdb-multiarch \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /workspaces

WORKDIR /workspaces