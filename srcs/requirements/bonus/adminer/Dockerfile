FROM debian:bookworm-slim

ARG ADMINER_PORT
ENV ADMINER_PORT=${ADMINER_PORT}

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    wget "https://www.adminer.org/latest.php" -O /var/www/html/index.php

RUN chown -R www-data:www-data /var/www/html && \
    mkdir -p /run/php

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

EXPOSE ${ADMINER_PORT}

CMD ["sh", "-c", "sed -i \"s/listen = 9001/listen = ${ADMINER_PORT}/g\" /etc/php/8.2/fpm/pool.d/www.conf && php-fpm8.2 -F"]