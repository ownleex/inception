#!/bin/bash

echo "=== INITIALISATION MARIADB SIMPLIFIÉE ==="

# Configuration des permissions de base
chown -R mysql:mysql /var/lib/mysql
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

# Initialiser la base de données si nécessaire
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de la base de données..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Démarrer MySQL en arrière-plan
echo "Démarrage de MySQL..."
mysqld_safe --user=mysql --datadir=/var/lib/mysql &

# Attendre que MySQL soit prêt
echo "Attente de la disponibilité de MySQL..."
while ! mysqladmin ping --silent; do
    echo "MySQL n'est pas encore prêt, attente..."
    sleep 1
done

echo "MySQL est en ligne !"

# Configuration de la base de données et des utilisateurs
if [ -n "$MYSQL_DATABASE" ]; then
    echo "Création de la base de données: $MYSQL_DATABASE"
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    
    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
        echo "Création de l'utilisateur: $MYSQL_USER"
        mysql -u root -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
        mysql -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
        mysql -u root -e "FLUSH PRIVILEGES;"
        echo "Utilisateur $MYSQL_USER créé avec succès"
    fi
fi

# Définir le mot de passe root si spécifié
if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
    echo "Configuration du mot de passe root..."
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -u root -e "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;"
    mysql -u root -e "FLUSH PRIVILEGES;"
fi

echo "=== MARIADB PRÊT ==="

# Maintenir le processus actif
wait