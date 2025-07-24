FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y wget php php-mysql

RUN mkdir -p /var/www

RUN wget -O /var/www/index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

WORKDIR /var/www

ENTRYPOINT ["php", "-S", "0.0.0.0:8080"]