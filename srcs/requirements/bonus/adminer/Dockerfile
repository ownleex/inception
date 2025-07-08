FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y

RUN apt-get install wget php php-mysql -y

COPY ./script.sh /script.sh

RUN chmod +x /script.sh

ENTRYPOINT ["./script.sh"]
