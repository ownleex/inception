#!/bin/bash

# Créer les dossiers nécessaires
mkdir -p /run/php
chown -R www-data:www-data /run/php
chown -R www-data:www-data /var/www/wordpress

# Créer wp-config.php depuis le sample s'il n'existe pas
if [ ! -f /var/www/wordpress/wp-config.php ]; then
    cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
fi

# Configuration de la base de données dans wp-config.php
if [ -n "$DB_NAME" ]; then
	sed -i "s/database_name_here/$DB_NAME/g" /var/www/wordpress/wp-config.php
	if [ -n "$DB_USER" ]; then
		sed -i "s/username_here/$DB_USER/g" /var/www/wordpress/wp-config.php
		if [ -n "$DB_PASSWORD" ]; then
    		sed -i "s/password_here/$DB_PASSWORD/g" /var/www/wordpress/wp-config.php
		fi
	fi
fi

sed -i "s/localhost/mariadb/g" /var/www/wordpress/wp-config.php

# Attendre que MariaDB soit prête
echo "Attente de la base de données..."
until wp db check --allow-root --path=/var/www/wordpress; do
    sleep 5
    echo "Retry database connection..."
done

# Installation de WordPress si pas déjà fait
if ! wp core is-installed --allow-root --path=/var/www/wordpress; then
    echo "Installation de WordPress..."
    wp core install --allow-root \
                    --path=$WP_PATHWORDPRESS \
                    --url=https://$DOMAIN \
                    --title="$WP_TITLE" \
                    --admin_user=$WP_ADMINUSER \
                    --admin_password=$WP_ADMINPASSWORD \
                    --admin_email=$WP_ADMINEMAIL

    wp user create --allow-root $WP_USER $WP_USEREMAIL \
                   --path=$WP_PATHWORDPRESS \
                   --role=$WP_ROLE \
                   --user_pass=$WP_USERPASSWORD \
                   --display_name="$WP_DISPLAYNAME"
    
    echo "WordPress installé avec succès !"
else
    echo "WordPress est déjà installé."
fi



# Mise à jour des URLs
wp option update home "https://$DOMAIN" --path=/var/www/wordpress --allow-root
wp option update siteurl "https://$DOMAIN" --path=/var/www/wordpress --allow-root

# Démarrer PHP-FPM en premier plan
echo "Démarrage de PHP-FPM..."
/usr/sbin/php-fpm7.4 -F -R