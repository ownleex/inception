FROM debian:bullseye

RUN apt-get update -y && apt-get upgrade -y && apt-get install php7.4 php7.4-fpm php7.4-mysql wget mariadb-client bash gettext-base -y

RUN	mkdir -p /etc/conf/ && mkdir -p /run/php && chown www-data:www-data /run/php && \
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv -f wp-cli.phar /usr/local/bin/wp

RUN	wget https://wordpress.org/latest.tar.gz -P /var/www && \
	cd /var/www && tar -xzf latest.tar.gz && rm latest.tar.gz && \
	chown -R www-data:www-data /var/www/wordpress

COPY /tools/wp.sh /etc/conf/
COPY /conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

RUN chmod +x /etc/conf/wp.sh

CMD ["sh", "/etc/conf/wp.sh"]