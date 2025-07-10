#!/bin/bash

# Fonction pour arrêter proprement MySQL
shutdown_mysql() {
    echo "Arrêt de MySQL..."
    mysqladmin -u root shutdown
    exit 0
}

# Capturer les signaux pour arrêt propre
trap shutdown_mysql SIGTERM SIGINT

chown -R mysql:mysql /var/lib/mysql

# Vérifier si MySQL est déjà initialisé
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de la base de données..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql >> /dev/null
fi

# Démarrer MySQL et récupérer son PID
echo "Démarrage de MySQL..."
/usr/bin/mysqld_safe --datadir=/var/lib/mysql &
MYSQL_PID=$!

# Attendre que MySQL soit prêt
until /usr/bin/mysqladmin ping --silent; do
    sleep 1
done
echo "MySQL is online"

# Configuration de la base de données
if [ -n "$DB_NAME" ]; then
    echo "Checking if $DB_NAME already exists"
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
    if [ -n "$DB_USER" ] && [ -n "$DB_PASSWORD" ]; then
        echo "Checking if $DB_USER already exists..."
        mysql -u root -e "CREATE USER IF NOT EXISTS \`${DB_USER}\`@'%' IDENTIFIED BY '${DB_PASSWORD}';"
        echo "Granting privileges to $DB_USER on $DB_NAME"
        mysql -u root -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
        echo "Flushing privileges..."
        mysql -u root -e "FLUSH PRIVILEGES;"
    fi
fi

echo "MariaDB est prête !"

# Attendre le processus MySQL spécifique
wait $MYSQL_PID