#!/bin/bash
set -e

FTP_USER=$(head -n 1 /run/secrets/user_credentials | cut -d: -f1)
FTP_PASS=$(head -n 1 /run/secrets/user_credentials | cut -d: -f2)

if ! id "$FTP_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$FTP_USER"
    echo "$FTP_USER:$FTP_PASS" | chpasswd
    usermod -aG www-data "$FTP_USER"
fi

echo "FTP Server is starting for user: $FTP_USER"
exec vsftpd /etc/vsftpd.conf