FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

COPY html/ /var/www/html/

ARG STATIC_SITE_PORT
ENV STATIC_SITE_PORT=${STATIC_SITE_PORT}

EXPOSE ${STATIC_SITE_PORT}

COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]