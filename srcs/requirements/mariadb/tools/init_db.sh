#!/bin/bash

# Script d'initialisation pour MariaDB - Version avec diagnostic
set -e

echo "=== DÉMARRAGE INITIALISATION MARIADB ==="

# Vérification des variables d'environnement
if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ]; then
    echo "ERREUR: Variables d'environnement manquantes"
    exit 1
fi

echo "Variables d'environnement OK:"
echo "- Base de données: $MYSQL_DATABASE"
echo "- Utilisateur: $MYSQL_USER"
echo "- UID actuel: $(id)"

# Vérifier les permissions des répertoires
echo "=== VÉRIFICATION PERMISSIONS ==="
echo "Contenu /var/lib/mysql:"
ls -la /var/lib/mysql/ || echo "Répertoire vide ou inexistant"

echo "Permissions /var/run/mysqld:"
ls -la /var/run/mysqld/ || echo "Répertoire vide"

# Vérifier si l'initialisation est nécessaire
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "=== PREMIÈRE INITIALISATION ==="
    
    # Initialiser la base de données
    echo "Initialisation de la base de données MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --force
    
    echo "Contenu après mysql_install_db:"
    ls -la /var/lib/mysql/
    
    # Démarrer MariaDB temporairement pour configuration
    echo "=== DÉMARRAGE TEMPORAIRE POUR CONFIGURATION ==="
    mysqld --user=mysql --datadir=/var/lib/mysql --pid-file=/var/run/mysqld/mysqld.pid --socket=/var/run/mysqld/mysqld.sock --skip-networking &
    MYSQL_PID=$!
    
    echo "MariaDB PID: $MYSQL_PID"
    
    # Attendre que MariaDB soit prêt
    echo "Attente de MariaDB..."
    for i in {1..30}; do
        if mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent 2>/dev/null; then
            echo "MariaDB est prêt après $i secondes!"
            break
        fi
        echo "Tentative $i/30..."
        sleep 2
    done
    
    # Vérifier si MariaDB répond
    if ! mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent 2>/dev/null; then
        echo "ERREUR: MariaDB ne répond pas"
        echo "Logs de MariaDB:"
        cat /var/log/mysql/error.log 2>/dev/null || echo "Pas de logs d'erreur"
        kill $MYSQL_PID 2>/dev/null || true
        exit 1
    fi
    
    echo "=== CONFIGURATION DE LA BASE ==="
    
    # Configuration SQL
    mysql --socket=/var/run/mysqld/mysqld.sock <<EOF
-- Configurer le mot de passe root
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');

-- Créer l'utilisateur root pour les connexions externes
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Nettoyer les utilisateurs par défaut
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1', '%');

-- Supprimer la base test
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Créer la base WordPress
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Créer l'utilisateur WordPress
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- Appliquer les changements
FLUSH PRIVILEGES;

-- Vérification
SELECT 'Configuration réussie' as Status;
SHOW DATABASES;
SELECT User, Host FROM mysql.user WHERE User IN ('root', '${MYSQL_USER}');
EOF

    if [ $? -eq 0 ]; then
        echo "=== CONFIGURATION RÉUSSIE ==="
    else
        echo "ERREUR lors de la configuration SQL"
        kill $MYSQL_PID 2>/dev/null || true
        exit 1
    fi
    
    # Arrêter MariaDB temporaire
    echo "Arrêt de MariaDB temporaire..."
    mysqladmin shutdown --socket=/var/run/mysqld/mysqld.sock
    wait $MYSQL_PID
    
else
    echo "=== MARIADB DÉJÀ INITIALISÉE ==="
    echo "Contenu existant:"
    ls -la /var/lib/mysql/
fi

echo "=== DÉMARRAGE FINAL DE MARIADB ==="
echo "Commande finale: $@"
echo "Test de configuration avant démarrage:"
mysqld --help --verbose | head -20

# Démarrer MariaDB en mode normal
echo "Lancement de: $@"
exec "$@"