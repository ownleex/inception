FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y wget libcap2-bin

RUN wget -O /usr/local/bin/cadvisor https://github.com/google/cadvisor/releases/download/v0.47.2/cadvisor-v0.47.2-linux-amd64 && \
    chmod +x /usr/local/bin/cadvisor && \
    setcap cap_sys_admin+ep /usr/local/bin/cadvisor

ENTRYPOINT ["cadvisor", "--port=8080"]
