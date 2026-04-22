#!/bin/bash
set -e

parse_creds() {
    local file=$1
    local line=$(head -n 1 "$file")
    echo "$line"
}

ADMIN_DATA=$(parse_creds /run/secrets/credentials)
USER_DATA=$(parse_creds /run/secrets/user_credentials)

USERS=("$ADMIN_DATA" "$USER_DATA")

for CREDS in "${USERS[@]}"; do
    LOGIN=${CREDS%%:*}
    PASS=${CREDS#*:}

    if [ -n "$LOGIN" ] && ! id "$LOGIN" &>/dev/null; then
        echo "Creating FTP user: $LOGIN"
        useradd -m -s /bin/bash "$LOGIN"
        echo "$LOGIN:$PASS" | chpasswd
        usermod -aG www-data "$LOGIN"
    fi
done

chown -R www-data:www-data /var/www/wordpress
chmod -R 775 /var/www/wordpress

echo "FTP Server is starting. Multiple users enabled."
exec vsftpd /etc/vsftpd.conf