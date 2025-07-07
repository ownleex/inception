FROM debian:bullseye

# Installation des paquets nécessaires
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copie de la configuration
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copie et préparation du script d'initialisation
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

# Exposition du port
EXPOSE 3306

# Point d'entrée
ENTRYPOINT ["/usr/local/bin/init_db.sh"]