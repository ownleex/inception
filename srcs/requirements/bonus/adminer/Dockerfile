FROM debian:bullseye

# Installation des paquets nécessaires
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y wget php php-mysql

# Créer le répertoire de travail
RUN mkdir -p /var/www

# Télécharger Adminer PENDANT le build (plus efficace et stable)
RUN wget -O /var/www/index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

# Copier le script de démarrage
COPY ./tools/start_adminer.sh /usr/local/bin/start_adminer.sh
RUN chmod +x /usr/local/bin/start_adminer.sh

# Définir le répertoire de travail
WORKDIR /var/www

# Exposer le port
EXPOSE 8080

# Point d'entrée
ENTRYPOINT ["/usr/local/bin/start_adminer.sh"]