#!/bin/bash

# Supprimer la page par défaut d'Apache
rm -f /var/www/html/index.html

# Configuration d'Apache pour le port 8080
sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf
sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf

# Configurer DirectoryIndex pour prioriser index.php
echo "DirectoryIndex index.php index.html" >> /etc/apache2/apache2.conf

# Activer le module PHP
a2enmod php7.4

# S'assurer que les permissions sont correctes
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "Démarrage d'Adminer sur le port 8080..."
echo "Adminer devrait être accessible via http://localhost:8080"

# Démarrer Apache en premier plan
exec apache2ctl -D FOREGROUND