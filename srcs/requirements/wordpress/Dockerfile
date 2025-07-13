FROM debian:bullseye

RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y \
      php7.4 \
      php7.4-fpm \
      php7.4-mysql \
      php7.4-gd \
      php-redis \
      wget \
      mariadb-client

RUN	mkdir -p /etc/conf/ && mkdir -p /run/php && chown www-data:www-data /run/php && \
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv -f wp-cli.phar /usr/local/bin/wp

RUN	wget https://fr.wordpress.org/latest-fr_FR.tar.gz -P /var/www && \
	cd /var/www && tar -xzf latest-fr_FR.tar.gz && rm latest-fr_FR.tar.gz && \
	chown -R www-data:www-data /var/www/wordpress

COPY /tools/wp.sh /etc/conf/
COPY /conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

RUN chmod +x /etc/conf/wp.sh

CMD ["bash", "/etc/conf/wp.sh"]