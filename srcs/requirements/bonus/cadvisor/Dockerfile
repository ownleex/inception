FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y wget ca-certificates unzip libcap2-bin curl

RUN wget https://github.com/google/cadvisor/releases/download/v0.47.2/cadvisor-v0.47.2-linux-amd64 \
     -O /usr/local/bin/cadvisor && \
    chmod +x /usr/local/bin/cadvisor && \
    setcap cap_sys_admin+ep /usr/local/bin/cadvisor

ENTRYPOINT ["/usr/local/bin/cadvisor", "--logtostderr", "--port=8080"]
