#!/bin/bash

echo "Starting MariaDB service..."
service mariadb start

echo "Waiting for 5 seconds to allow MariaDB to initialize..."
sleep 5

echo "Setting the root password for MariaDB..."
mysqladmin -u root password "${MYSQLROOTPASSWORD}"

echo "Creating the database '${MYSQLDB}' if it does not exist..."
mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQLDB}\`;"

echo "Creating the user '${MSQLUSER}' if it does not exist..."
mysql -e "CREATE USER IF NOT EXISTS \`${MSQLUSER}\`@'%' IDENTIFIED BY '${MYSQLPASSWORD}';"

echo "Granting privileges to user '${MSQLUSER}' on the database '${MYSQLDB}'..."
mysql -e "GRANT ALL PRIVILEGES ON ${MYSQLDB}.* TO \`${MSQLUSER}\`@'%' IDENTIFIED BY '${MYSQLPASSWORD}' ;"

echo "Flushing privileges to apply the changes..."
mysql -e "FLUSH PRIVILEGES;"

echo "Stopping MariaDB service..."
service mariadb stop

echo "Starting MariaDB in safe mode, allowing remote connections..."
exec mysqld_safe --bind-address=0.0.0.0
