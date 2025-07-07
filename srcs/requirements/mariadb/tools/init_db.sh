#!/bin/bash

# Script d'initialisation MariaDB simplifié
set -e

echo "=== INITIALISATION MARIADB ==="

# Permissions de base
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /var/log/mysql

# Initialiser la base si elle n'existe pas
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de la base MySQL..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Démarrer MySQL en arrière-plan
mysqld --user=mysql &

# Attendre que MySQL soit prêt
echo "Attente du démarrage MySQL..."
while ! mysqladmin ping --silent; do
    sleep 1
done

# Configuration de la base
echo "Configuration de la base de données..."
mysql -u root <<-EOSQL
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

echo "=== MARIADB PRÊT ==="

# Arrêter le processus en arrière-plan et redémarrer en premier plan
mysqladmin shutdown -u root -p${MYSQL_ROOT_PASSWORD}
exec mysqld --user=mysql --console