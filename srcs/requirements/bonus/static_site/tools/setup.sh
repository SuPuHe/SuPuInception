#!/bin/sh
set -e

sed -i "s/listen 80;/listen ${STATIC_SITE_PORT};/g" /etc/nginx/sites-available/default || true
sed -i "s/listen 80 default_server;/listen ${STATIC_SITE_PORT} default_server;/g" /etc/nginx/sites-available/default || true
sed -i "s/listen \[::\]:80 default_server;/listen [::]:${STATIC_SITE_PORT} default_server;/g" /etc/nginx/sites-available/default || true

exec nginx -g 'daemon off;'
