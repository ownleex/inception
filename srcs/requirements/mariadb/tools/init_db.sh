#!/bin/bash

echo "=== INITIALISATION MARIADB ==="

# Configuration des permissions de base
chown -R mysql:mysql /var/lib/mysql
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

# Initialiser la base de données si nécessaire
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de la base de données..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Fonction pour arrêter MySQL proprement
shutdown_mysql() {
    echo "Arrêt de MySQL..."
    mysqladmin shutdown -u root -p"${MYSQL_ROOT_PASSWORD}" 2>/dev/null || true
    exit 0
}

# Capturer les signaux pour arrêt propre
trap shutdown_mysql SIGTERM SIGINT

# Démarrer MySQL en arrière-plan avec supervision
echo "Démarrage de MySQL..."
mysqld_safe --user=mysql --datadir=/var/lib/mysql &
MYSQL_PID=$!

# Attendre que MySQL soit prêt
echo "Attente de la disponibilité de MySQL..."
while ! mysqladmin ping --silent; do
    echo "MySQL n'est pas encore prêt, attente..."
    sleep 1
done

echo "MySQL est en ligne !"

# Configuration de la base de données et des utilisateurs (uniquement au premier démarrage)
if [ ! -f "/var/lib/mysql/.configured" ]; then
    echo "Configuration initiale de MySQL..."
    
    # Définir le mot de passe root si spécifié
    if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
        echo "Configuration du mot de passe root..."
        mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
        mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;"
        mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"
    fi

    # Configuration de la base de données et des utilisateurs
    if [ -n "$MYSQL_DATABASE" ]; then
        echo "Création de la base de données: $MYSQL_DATABASE"
        mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
        
        if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
            echo "Création de l'utilisateur: $MYSQL_USER"
            mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
            mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
            mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"
            echo "Utilisateur $MYSQL_USER créé avec succès"
        fi
    fi
    
    # Marquer comme configuré
    touch /var/lib/mysql/.configured
    echo "Configuration terminée"
fi

echo "=== MARIADB PRÊT ==="

# Attendre le processus MySQL (gestion propre du PID 1)
wait $MYSQL_PID