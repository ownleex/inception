#!/bin/bash

# Préparer un script SQL à injecter lors du démarrage
# @'%' permet à l'utilisateur de se connecter depuis les autres containers
# flush privileges pour appliquer les changements
cat << EOF > /tmp/init.sql
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS \`${DB_USER}\`@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Démarrer MariaDB avec le script d'init
echo "Lancement de MariaDB avec injection SQL..."
exec mysqld --init-file=/tmp/init.sql --datadir=/var/lib/mysql
