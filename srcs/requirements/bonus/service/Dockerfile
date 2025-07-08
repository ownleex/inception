FROM debian:bullseye

RUN apt-get update && apt-get install -y curl tar && apt-get clean

RUN curl -L "https://github.com/portainer/portainer/releases/download/2.16.2/portainer-2.16.2-linux-amd64.tar.gz" -o "/tmp/portainer.tar.gz" \
    && tar -xzf "/tmp/portainer.tar.gz" -C /opt \
    && rm /tmp/portainer.tar.gz

EXPOSE 9000

ENTRYPOINT ["/opt/portainer/portainer", "-H", "unix:///var/run/docker.sock"]

