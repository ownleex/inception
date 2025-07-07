#!/bin/bash

# Configuration des permissions
chown -R mysql:mysql /var/lib/mysql

# Initialisation de la base de données
mysql_install_db --user=mysql --datadir=/var/lib/mysql >> /dev/null

# Démarrage de MySQL
/usr/bin/mysqld_safe --datadir=/var/lib/mysql &

# Attendre que MySQL soit prêt
while true; do
    if /usr/bin/mysqladmin ping --silent; then
        echo "MySQL is online"
        break
    fi
    sleep 1
done

# Configuration de la base de données (sans mot de passe root)
if [ -n "$MYSQL_DATABASE" ]; then
    echo "Creating database: $MYSQL_DATABASE"
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    
    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
        echo "Creating user: $MYSQL_USER"
        mysql -u root -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
        mysql -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
        mysql -u root -e "FLUSH PRIVILEGES;"
    fi
fi

# Maintenir le processus actif
wait