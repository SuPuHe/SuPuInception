FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php-mysql \
    php-redis \
    netcat-openbsd \
    mariadb-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

ARG WORDPRESS_FPM_PORT=9000
ENV WORDPRESS_FPM_PORT=${WORDPRESS_FPM_PORT}
RUN sed -i "s|listen = /run/php/php8.2-fpm.sock|listen = ${WORDPRESS_FPM_PORT}|g" /etc/php/8.2/fpm/pool.d/www.conf

EXPOSE ${WORDPRESS_FPM_PORT}

WORKDIR /var/www/wordpress

ENTRYPOINT ["/usr/local/bin/setup.sh"]