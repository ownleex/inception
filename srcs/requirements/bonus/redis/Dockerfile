FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y redis-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY tools/start_redis.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start_redis.sh

ENTRYPOINT ["start_redis.sh"]
