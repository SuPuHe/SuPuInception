#!/bin/bash
set -e

parse_credentials() {
    local secret_file="$1"
    local line login password

    line=$(head -n 1 "$secret_file" | tr -d '\r')
    login=${line%%:*}
    password=${line#*:}

    if [ -z "$line" ] || [ "$line" = "$login" ] || [ -z "$login" ] || [ -z "$password" ]; then
        echo "Error: $secret_file must be in login:password format."
        return 1
    fi

    printf '%s:%s' "$login" "$password"
}

ADMIN_CREDENTIALS=$(parse_credentials /run/secrets/credentials)
USER_CREDENTIALS=$(parse_credentials /run/secrets/user_credentials)

ADMIN_LOGIN=${ADMIN_CREDENTIALS%%:*}
ADMIN_PASSWORD=${ADMIN_CREDENTIALS#*:}
WP_USER=${USER_CREDENTIALS%%:*}
WP_USER_PASSWORD=${USER_CREDENTIALS#*:}

WP_USER_EMAIL=${WP_USER_EMAIL:-$WP_USER@$DOMAIN_NAME}
WP_USER_ROLE=${WP_USER_ROLE:-author}

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
        --admin_user=$ADMIN_LOGIN \
        --admin_password="$ADMIN_PASSWORD" \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root
fi

if ! wp user get "$WP_USER" --field=ID --allow-root >/dev/null 2>&1; then
    echo "Creating second user: $WP_USER"
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --role="$WP_USER_ROLE" \
        --user_pass="$WP_USER_PASSWORD" \
        --allow-root
fi

echo "WordPress is ready. Starting PHP-FPM..."
exec php-fpm7.4 -F