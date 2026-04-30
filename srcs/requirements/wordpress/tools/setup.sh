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
MARIADB_PORT=${MARIADB_PORT:-3306}
REDIS_PORT=${REDIS_PORT:-6379}

echo "Waiting for MariaDB (host: mariadb)..."
until mariadb-admin ping -h"mariadb" -P"${MARIADB_PORT}" --silent; do
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
		--dbhost=mariadb:${MARIADB_PORT} \
		--allow-root
fi

attempt=0
until wp db check --allow-root >/dev/null 2>&1; do
	attempt=$((attempt+1))
	echo "Waiting for WordPress DB to be accessible (attempt $attempt)..."
	sleep 3
	if [ $attempt -ge 12 ]; then
		echo "Error: WordPress cannot connect to DB after retries."
		exit 1
	fi
done

if ! wp core is-installed --allow-root >/dev/null 2>&1; then
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
	attempt=0
	until wp user create "$WP_USER" "$WP_USER_EMAIL" \
		--role="$WP_USER_ROLE" \
		--user_pass="$WP_USER_PASSWORD" \
		--allow-root >/dev/null 2>&1; do
		attempt=$((attempt+1))
		echo "Retrying user creation (attempt $attempt)..."
		sleep 3
		if [ $attempt -ge 6 ]; then
			echo "Error: failed to create user after retries."
			exit 1
		fi
	done
fi

echo "Configuring Redis cache..."

wp config set WP_REDIS_HOST redis --allow-root
wp config set WP_REDIS_PORT ${REDIS_PORT} --raw --allow-root
wp config set WP_CACHE true --raw --allow-root

if ! wp plugin is-installed redis-cache --allow-root >/dev/null 2>&1; then
	wp plugin install redis-cache --activate --allow-root
else
	wp plugin activate redis-cache --allow-root >/dev/null 2>&1 || true
fi

wp redis enable --allow-root >/dev/null 2>&1 || true

echo "WordPress is ready. Starting PHP-FPM..."
exec php-fpm8.2 -F