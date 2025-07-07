#!/bin/bash

# Attendre que MariaDB soit prêt (méthode TCP qui fonctionne)
echo "Attente de MariaDB..."
while ! timeout 1 bash -c '</dev/tcp/mariadb/3306'; do
    echo "En attente de la base de données..."
    sleep 2
done
echo "MariaDB est accessible"

# Configuration de WordPress si pas déjà fait
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Configuration de WordPress..."
    
    # Copie du fichier de configuration
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    
    # Configuration de la base de données
    sed -i "s/database_name_here/$WORDPRESS_DB_NAME/g" /var/www/html/wp-config.php
    sed -i "s/username_here/$WORDPRESS_DB_USER/g" /var/www/html/wp-config.php
    sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/g" /var/www/html/wp-config.php
    sed -i "s/localhost/$WORDPRESS_DB_HOST/g" /var/www/html/wp-config.php
    
    echo "WordPress configuré avec succès"
fi

# Démarrage de PHP-FPM
echo "Démarrage de PHP-FPM..."
php-fpm7.4 -F