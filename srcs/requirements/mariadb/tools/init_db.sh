#!/bin/bash

# Script d'initialisation MariaDB - Version finale et robuste
set -eo pipefail

echo "=== DÉMARRAGE INITIALISATION MARIADB ==="

# Vérification des variables d'environnement obligatoires
if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ]; then
    echo "ERREUR: Variables d'environnement manquantes"
    echo "Requis: MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD"
    exit 1
fi

echo "Variables d'environnement OK:"
echo "- Base de données: $MYSQL_DATABASE"
echo "- Utilisateur: $MYSQL_USER"
echo "- UID actuel: $(id)"

# Vérifier si MariaDB est déjà initialisée
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "=== PREMIÈRE INITIALISATION ==="
    
    # Initialiser la base de données MariaDB
    echo "Initialisation de la structure de base..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm --auth-root-authentication-method=normal
    
    # Créer un fichier temporaire pour les commandes SQL
    tfile=$(mktemp)
    if [ ! -f "$tfile" ]; then
        echo "ERREUR: Impossible de créer le fichier temporaire"
        exit 1
    fi
    
    # Générer les commandes SQL d'initialisation
    cat << EOF > "$tfile"
USE mysql;
FLUSH PRIVILEGES;

-- Supprimer les utilisateurs anonymes et de test
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Configurer le mot de passe root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Créer l'utilisateur root pour les connexions externes
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Créer la base de données WordPress
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Créer l'utilisateur WordPress
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- Appliquer les changements
FLUSH PRIVILEGES;
EOF

    echo "=== CONFIGURATION INITIALE ==="
    
    # Démarrer MariaDB en mode bootstrap et appliquer la configuration
    mysqld --user=mysql --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < "$tfile"
    
    # Nettoyer le fichier temporaire
    rm -f "$tfile"
    
    echo "=== INITIALISATION TERMINÉE ==="
else
    echo "=== MARIADB DÉJÀ INITIALISÉE ==="
fi

echo "=== DÉMARRAGE DE MARIADB ==="
echo "Commande finale: $@"

# Corriger les permissions avant démarrage
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/log/mysql

# Démarrer MariaDB avec les paramètres fournis
echo "Démarrage du serveur MariaDB..."
exec "$@"