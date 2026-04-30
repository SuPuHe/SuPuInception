FROM debian:bookworm

ARG PORTAINER_VERSION=2.21.4
ARG PORTAINER_PORT
ENV PORTAINER_PORT=${PORTAINER_PORT}

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    apache2-utils \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL \
    "https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-linux-amd64.tar.gz" \
    | tar -xz -C /

COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

RUN mkdir -p /data

EXPOSE ${PORTAINER_PORT}

ENTRYPOINT ["/setup.sh"]