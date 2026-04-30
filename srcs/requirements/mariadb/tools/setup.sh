#!/bin/bash
set -e


DB_PWD=$(cat /run/secrets/db_password)
ROOT_PWD=$(cat /run/secrets/db_root_password)

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "First start: initializing database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    mysqld_safe --skip-networking &
    pid=$!

    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done

    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PWD}';"
    mysql -u root -p"${ROOT_PWD}" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -u root -p"${ROOT_PWD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PWD}';"
    mysql -u root -p"${ROOT_PWD}" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
    mysql -u root -p"${ROOT_PWD}" -e "FLUSH PRIVILEGES;"

    mysqladmin -u root -p"${ROOT_PWD}" shutdown
    wait $pid
else
    echo "Existing database detected: ensuring user and grants..."

    mysqld_safe --skip-networking &
    pid=$!

    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done

    mysql -u root -p"${ROOT_PWD}" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -u root -p"${ROOT_PWD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PWD}';"
    mysql -u root -p"${ROOT_PWD}" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
    mysql -u root -p"${ROOT_PWD}" -e "FLUSH PRIVILEGES;"

    mysqladmin -u root -p"${ROOT_PWD}" shutdown
    wait $pid
fi

echo "MariaDB is ready. Starting normally..."
exec mariadbd --user=mysql