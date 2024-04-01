FROM docker.io/library/node:20.11-slim as base

FROM base as downloader.podman-remote-static
ADD https://github.com/containers/podman/releases/download/v5.0.0/podman-remote-static-linux_amd64.tar.gz podman-remote-static-linux_amd64.tar.gz
RUN tar zxf podman-remote-static-linux_amd64.tar.gz

FROM scratch as files
COPY --from=downloader.podman-remote-static bin/podman-remote-static-linux_amd64 podman-remote


FROM base as common
RUN apt update \
    && apt dist-upgrade -y
ENV LC_ALL=C
COPY --from=files podman-remote /usr/local/bin/podman
ENV CONTAINER_HOST=unix:///var/run/docker.sock
WORKDIR /workspace


FROM common as dev
RUN apt update \
    && apt install -y ca-certificates curl gnupg bash-completion git
RUN podman completion -f /etc/bash_completion.d/podman bash
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
    && apt update \
    && apt install -y docker-compose-plugin docker-ce-cli
ENV DOCKER_HOST=${CONTAINER_HOST}

FROM common as build
COPY . .
RUN yarn install

FROM common as dist
WORKDIR /app 

FROM dev