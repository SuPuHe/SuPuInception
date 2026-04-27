FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    php \
    php-fpm \
    php-mysql \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    wget "https://www.adminer.org/latest.php" -O /var/www/html/index.php

RUN chown -R www-data:www-data /var/www/html

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9001|g' /etc/php/8.2/fpm/pool.d/www.conf && \
    sed -i 's|listen.allowed_clients = 127.0.0.1||g' /etc/php/8.2/fpm/pool.d/www.conf

RUN mkdir -p /run/php

EXPOSE 9001

CMD ["php-fpm8.2", "-F"]