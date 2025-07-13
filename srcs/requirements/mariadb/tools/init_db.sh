#!/bin/bash

# Vérifier les permissions
chown -R mysql:mysql /var/lib/mysql

# Initialisation manuelle de la base si nécessaire
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de la base de données..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Préparer un script SQL à injecter lors du démarrage
cat << EOF > /tmp/init.sql
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS \`${DB_USER}\`@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Démarrer MariaDB en tant que PID 1 avec le script d'init
echo "Lancement de MariaDB avec injection SQL..."
exec mysqld --init-file=/tmp/init.sql --datadir=/var/lib/mysql
