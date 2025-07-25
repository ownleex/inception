#!/bin/bash

if [ ! -f /var/www/wordpress/wp-config.php ]; then
    cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
fi

if ! grep -q "mariadb" /var/www/wordpress/wp-config.php; then
    if [ -n "$DB_NAME" ] && [ -n "$DB_USER" ] && [ -n "$DB_PASSWORD" ]; then
        echo "✅ Toutes les variables DB sont définies, configuration complète..."
        sed -i "s/database_name_here/$DB_NAME/g" /var/www/wordpress/wp-config.php
        sed -i "s/username_here/$DB_USER/g" /var/www/wordpress/wp-config.php
        sed -i "s/password_here/$DB_PASSWORD/g" /var/www/wordpress/wp-config.php
        sed -i "s/localhost/mariadb/g" /var/www/wordpress/wp-config.php
    else
        echo "⚠️ Une ou plusieurs variables DB manquantes, configuration partielle..."
        exit 1
    fi
fi

echo "Attente de la base de données..."
until wp db check --allow-root --path=/var/www/wordpress; do
    sleep 5
    echo "Retry database connection..."
done

if ! wp core is-installed --allow-root --path=/var/www/wordpress; then

    echo "Configuration Redis dans wp-config.php"
    sed -i "/require_once ABSPATH/i \
    define( 'WP_REDIS_HOST', 'redis' );\n\
    define( 'WP_REDIS_PORT', 6379 );" \
        /var/www/wordpress/wp-config.php

    echo "Installation de WordPress..."
    wp core install --allow-root \
        --path=$WP_PATHWORDPRESS \
        --url=https://$DOMAIN \
        --title="$WP_TITLE" \
        --admin_user=$WP_ADMINUSER \
        --admin_password=$WP_ADMINPASSWORD \
        --admin_email=$WP_ADMINEMAIL

    wp option update timezone_string "Europe/Paris" --allow-root --path=/var/www/wordpress

    wp user create --allow-root $WP_USER $WP_USEREMAIL \
        --path=$WP_PATHWORDPRESS \
        --role=$WP_ROLE \
        --user_pass=$WP_USERPASSWORD

    echo "Installation et activation du plugin Redis Cache..."
    wp plugin install redis-cache --activate --allow-root --path=/var/www/wordpress
    wp redis enable --allow-root --path=/var/www/wordpress

    echo "Installation du thème AnyNews ..."
    wp theme install anynews --allow-root --path=/var/www/wordpress --activate

    echo "WordPress installé avec succès !"
else
    echo "WordPress est déjà installé."
fi

chown -R www-data:www-data /var/www/wordpress
chmod -R 775 /var/www/wordpress/wp-content

echo "Démarrage de PHP-FPM..."
exec php-fpm7.4 -F -R
