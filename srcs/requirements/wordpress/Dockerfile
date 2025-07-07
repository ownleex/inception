FROM debian:bullseye

# Installation de PHP et WordPress
RUN apt update -y && apt upgrade -y && \
    apt install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-xml \
    php7.4-mbstring \
    php7.4-zip \
    curl && \
    rm -rf /var/lib/apt/lists/*

# Téléchargement et installation de WordPress
WORKDIR /var/www/html
RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz && \
    chown -R www-data:www-data /var/www/html

# Copie des fichiers de configuration
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/
COPY tools/init_wordpress.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_wordpress.sh

# Création du répertoire pour le socket PHP-FPM
RUN mkdir -p /run/php

# Exposition du port PHP-FPM
EXPOSE 9000

# Point d'entrée
ENTRYPOINT ["sh", "/usr/local/bin/init_wordpress.sh"]