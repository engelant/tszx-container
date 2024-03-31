FROM docker.io/library/node:slim as base
RUN apt update \
    && apt dist-upgrade -y \
    && npm i -g zx
# WORKDIR /tmp
# ADD https://github.com/containers/podman/releases/download/v5.0.0/podman-remote-static-linux_amd64.tar.gz podman-remote-static-linux_amd64.tar.gz
# RUN tar zxf podman-remote-static-linux_amd64.tar.gz \
#     && mv bin/podman-remote-static-linux_amd64 /usr/local/bin/podman \
#     && rm -rf /tmp/*
ENV CONTAINER_HOST=unix:///run/run/docker.sock


FROM base as dev
RUN apt update \
    && apt install -y ca-certificates curl gnupg bash-completion git \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
    && apt update \
    && apt install -y docker-compose-plugin docker-ce-cli
WORKDIR /workspace
ENV DOCKER_HOST=${CONTAINER_HOST}

FROM base as build
WORKDIR /workspace
COPY . .
RUN yarn install

FROM base as dist
WORKDIR /app 

FROM dev