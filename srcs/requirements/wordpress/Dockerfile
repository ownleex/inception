FROM debian:bullseye

RUN apt update  &&  apt install -y curl git wget php php-fpm php-mysql 

COPY tools/auto_config.sh /

RUN chmod +x /auto_config.sh

WORKDIR /var/www/wordpress

RUN mkdir -p /run/php

ENTRYPOINT [ "bash", "/auto_config.sh" ]

