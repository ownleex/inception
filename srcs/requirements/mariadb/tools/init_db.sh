#!/bin/bash

# Script d'initialisation MariaDB corrigé
set -e

echo "=== INITIALISATION MARIADB ==="

# Vérification des variables d'environnement requises
if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ]; then
    echo "ERREUR: Variables d'environnement manquantes"
    exit 1
fi

# Permissions de base
echo "Configuration des permissions..."
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /var/log/mysql
chmod 755 /var/run/mysqld

# Vérifier si la base est déjà initialisée
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Première initialisation de la base MySQL..."
    
    # Initialiser la base de données
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm --auth-root-authentication-method=normal
    
    # Créer un fichier temporaire pour l'initialisation
    tfile=`mktemp`
    if [ ! -f "$tfile" ]; then
        return 1
    fi

    cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    # Appliquer la configuration d'initialisation
    echo "Application de la configuration initiale..."
    mysqld --user=mysql --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < $tfile
    rm -f $tfile
    
    echo "Initialisation terminée avec succès."
else
    echo "Base de données déjà initialisée, démarrage direct..."
fi

echo "=== MARIADB PRÊT À DÉMARRER ==="

# Démarrer MariaDB en premier plan avec la configuration finale
exec mysqld --user=mysql --console --log-error=/var/log/mysql/error.log