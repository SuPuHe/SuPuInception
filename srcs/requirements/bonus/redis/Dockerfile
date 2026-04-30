FROM debian:bookworm

RUN apt-get update && apt-get install -y redis-server && rm -rf /var/lib/apt/lists/*

RUN sed -i "s/bind 127.0.0.1/bind 0.0.0.0/" /etc/redis/redis.conf

ARG REDIS_PORT=6379
ENV REDIS_PORT=${REDIS_PORT}

EXPOSE ${REDIS_PORT}

CMD ["sh", "-c", "exec redis-server --port ${REDIS_PORT} --protected-mode no"]