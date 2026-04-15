#!/bin/bash
set -e

echo "Waiting for MariaDB (host: mariadb)..."
until mariadb-admin ping -h"mariadb" --silent; do
    echo "MariaDB is unavailable - sleeping"
    sleep 3
done
echo "MariaDB is UP!"

if [ ! -f "wp-load.php" ]; then
    echo "Downloading WordPress core..."
    wp core download --allow-root
fi

if [ ! -f "wp-config.php" ]; then
    ADMIN_PASSWORD=$(awk -F: 'NF>1 {print $2; exit} NF==1 {print $1; exit}' /run/secrets/credentials)
    if [ -z "$ADMIN_PASSWORD" ]; then
        echo "Error: /run/secrets/credentials is empty. Set admin password secret."
        exit 1
    fi

    echo "Creating wp-config.php..."
    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$(cat /run/secrets/db_password) \
        --dbhost=mariadb:3306 \
        --allow-root

    echo "Installing WordPress site..."
    wp core install \
        --url=$DOMAIN_NAME \
        --title="Inception" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password="$ADMIN_PASSWORD" \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root
fi

echo "WordPress is ready. Starting PHP-FPM..."
exec php-fpm7.4 -F