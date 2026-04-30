FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	nginx \
	openssl \
	gettext-base \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/C=DE/ST=BW/L=Heilbronn/O=42/OU=42/CN=omizin.42.fr"

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf.template

CMD ["sh", "-c", "envsubst '${DOMAIN_NAME} ${CERT_PATH} ${KEY_PATH} ${WORDPRESS_FPM_PORT} ${ADMINER_PORT} ${PORTAINER_PORT} ${STATIC_SITE_PORT}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]