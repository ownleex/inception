# Utilisation de Debian (avant-dernière version stable)
FROM debian:11

# Installation de MariaDB et des outils nécessaires
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Création des répertoires nécessaires avec les bonnes permissions
RUN mkdir -p /var/run/mysqld \
    && mkdir -p /var/log/mysql \
    && chown -R mysql:mysql /var/run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql \
    && chown -R mysql:mysql /var/log/mysql \
    && chmod 755 /var/run/mysqld

# Copie du script d'initialisation
COPY tools/init_db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_db.sh

# Copie de la configuration MariaDB dans le bon répertoire
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/

# Exposition du port MariaDB
EXPOSE 3306

# Changement d'utilisateur pour la sécurité
USER mysql

# Point d'entrée
ENTRYPOINT ["init_db.sh"]

# Commande par défaut
CMD ["mysqld", "--user=mysql"]