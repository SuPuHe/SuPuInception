#!/bin/sh
set -eu

ADMIN_PASS=$(head -n 1 /run/secrets/portainer_pass | cut -d: -f2)

if [ ${#ADMIN_PASS} -lt 12 ]; then
    echo "ERROR: Password in portainer_pass.txt is too short (min 12 chars)."
    exit 1
fi

HASH=$(htpasswd -B -n -b admin "$ADMIN_PASS" | cut -d: -f2)

exec /portainer/portainer \
    --data /data \
    --assets /portainer \
    --admin-password "$HASH" \
    --bind :${PORTAINER_PORT} \
    --no-analytics