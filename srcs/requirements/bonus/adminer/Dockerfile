FROM debian:bullseye

# Installer Apache, PHP et les extensions nécessaires
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    apache2 \
    php7.4 \
    php7.4-mysql \
    libapache2-mod-php7.4 \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Créer le répertoire web et télécharger Adminer
RUN mkdir -p /var/www/html && \
    wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O /var/www/html/index.php

# Configuration d'Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Exposer le port 8080
EXPOSE 8080

# Copier le script de démarrage
COPY tools/start_adminer.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start_adminer.sh

# Démarrer Apache en premier plan
CMD ["/usr/local/bin/start_adminer.sh"]