FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y redis-server

ENTRYPOINT ["redis-server", "--protected-mode", "no", "--bind", "0.0.0.0"]
