FROM debian:bullseye

RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y mariadb-server

COPY ./tools/script.sh /script.sh

RUN chmod +x /script.sh

ENTRYPOINT [ "./script.sh" ]