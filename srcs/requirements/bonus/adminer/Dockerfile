FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y wget php php-mysql

RUN mkdir -p /var/www

RUN wget -O /var/www/index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

COPY ./tools/start_adminer.sh /usr/local/bin/start_adminer.sh
RUN chmod +x /usr/local/bin/start_adminer.sh

WORKDIR /var/www

# Point d'entrée
ENTRYPOINT ["/usr/local/bin/start_adminer.sh"]