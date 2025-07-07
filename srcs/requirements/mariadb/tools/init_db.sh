#!/bin/bash

# Script d'initialisation pour MariaDB
# Ce script configure la base de données WordPress et les utilisateurs

set -e

echo "=== Démarrage de l'initialisation MariaDB ==="

# Vérifier que les variables d'environnement nécessaires sont définies
if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ]; then
    echo "Erreur: Variables d'environnement manquantes"
    echo "Requis: MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD"
    exit 1
fi

# Vérifier si MariaDB a déjà été initialisée
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "=== Première initialisation de MariaDB ==="
    
    # Initialiser la base de données MariaDB
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Démarrer MariaDB en arrière-plan pour la configuration
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    MYSQL_PID=$!
    
    # Attendre que MariaDB soit prêt
    echo "=== Attente du démarrage de MariaDB ==="
    for i in {1..30}; do
        if mysqladmin ping --silent; then
            echo "MariaDB est prêt !"
            break
        fi
        echo "Tentative $i/30..."
        sleep 2
    done
    
    # Vérifier si MariaDB a démarré
    if ! mysqladmin ping --silent; then
        echo "Erreur: MariaDB n'a pas pu démarrer"
        exit 1
    fi
    
    echo "=== Configuration de la base de données ==="
    
    # Configuration initiale via mysql
    mysql -u root << EOF
-- Sécuriser l'installation
UPDATE mysql.user SET Password=PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Créer la base de données WordPress
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Créer l'utilisateur administrateur WordPress (pas de "admin" dans le nom)
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- Créer un utilisateur normal WordPress
CREATE USER IF NOT EXISTS 'wp_user'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT SELECT, INSERT, UPDATE, DELETE ON \`${MYSQL_DATABASE}\`.* TO 'wp_user'@'%';

-- Appliquer les changements
FLUSH PRIVILEGES;
EOF

    echo "=== Base de données configurée avec succès ==="
    
    # Arrêter MariaDB proprement
    mysqladmin shutdown
    wait $MYSQL_PID
    
else
    echo "=== MariaDB déjà initialisée ==="
fi

echo "=== Démarrage de MariaDB ==="

# Exécuter la commande passée en paramètre (CMD du Dockerfile)
exec "$@"