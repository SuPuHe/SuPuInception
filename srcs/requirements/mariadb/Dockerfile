FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 777 /var/run/mysqld

COPY conf/50-server.conf /etc/mysql/mariadb.conf.d/50-server.cnf

ARG MARIADB_PORT=3306
ENV MARIADB_PORT=${MARIADB_PORT}
RUN sed -i "s/^port = 3306/port = ${MARIADB_PORT}/" /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE ${MARIADB_PORT}

ENTRYPOINT ["/usr/local/bin/setup.sh"]