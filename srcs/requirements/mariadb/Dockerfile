FROM debian:bullseye

# Installation de MariaDB
RUN apt update -y && apt upgrade -y && \
    apt install mariadb-server -y && \
    rm -rf /var/lib/apt/lists/*

# Copie de la configuration et du script
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY tools/init_db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_db.sh

# Exposition du port
EXPOSE 3306

# Point d'entrée
ENTRYPOINT ["sh", "/usr/local/bin/init_db.sh"]