# Utilisation de Debian 11 (avant-dernière version stable)
FROM debian:11

# Installation de MariaDB et des outils nécessaires
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Création des répertoires nécessaires avec les bonnes permissions
RUN mkdir -p /var/run/mysqld \
    && mkdir -p /var/log/mysql \
    && chown -R mysql:mysql /var/run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql \
    && chown -R mysql:mysql /var/log/mysql \
    && chmod 755 /var/run/mysqld

# Copie de la configuration MariaDB
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copie du script d'initialisation
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

# Exposition du port MariaDB
EXPOSE 3306

# Point d'entrée avec script d'initialisation (en tant que root pour les permissions)
ENTRYPOINT ["/usr/local/bin/init_db.sh"]

# Commande par défaut pour démarrer MariaDB
CMD ["mysqld", "--user=mysql", "--console", "--log-error=/var/log/mysql/error.log"]