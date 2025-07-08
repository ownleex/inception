#!/bin/bash

# Attendre que MariaDB soit prêt
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
    
    # Ajouter les variables WordPress pour auto-install
    cat >> /var/www/html/wp-config.php << 'EOF'

// Configuration automatique pour l'installation
define('WP_SITEURL', 'https://' . $_SERVER['HTTP_HOST']);
define('WP_HOME', 'https://' . $_SERVER['HTTP_HOST']);

// Désactiver l'éditeur de fichiers pour sécurité
define('DISALLOW_FILE_EDIT', true);
EOF
    
    echo "WordPress configuré avec succès"
fi

# Créer un fichier d'auto-installation
if [ ! -f /var/www/html/auto-install.php ]; then
    cat > /var/www/html/auto-install.php << 'EOF'
<?php
// Script d'auto-installation WordPress
define('WP_USE_THEMES', false);
require_once('./wp-load.php');

if (!is_blog_installed()) {
    require_once(ABSPATH . 'wp-admin/includes/upgrade.php');
    
    $blog_title = getenv('WP_TITLE') ?: 'Mon Site WordPress';
    $user_name = getenv('WP_ADMIN_USER') ?: 'ayarmaya';
    $user_email = getenv('WP_ADMIN_EMAIL') ?: 'admin@ayarmaya.42.fr';
    $user_pass = getenv('WP_ADMIN_PASSWORD') ?: 'adminpass123';
    $public = true;
    
    $result = wp_install($blog_title, $user_name, $user_email, $public, '', $user_pass);
    
    if (!is_wp_error($result)) {
        // Créer un utilisateur supplémentaire
        $user_data = array(
            'user_login' => getenv('WP_USER') ?: 'user',
            'user_pass' => getenv('WP_USER_PASSWORD') ?: 'userpass123',
            'user_email' => getenv('WP_USER_EMAIL') ?: 'user@ayarmaya.42.fr',
            'role' => 'author'
        );
        wp_insert_user($user_data);
        
        // Marquer comme installé
        file_put_contents('/var/www/html/.wp_installed', 'installed');
        echo "WordPress installé avec succès!\n";
    } else {
        echo "Erreur lors de l'installation: " . $result->get_error_message() . "\n";
    }
} else {
    echo "WordPress déjà installé.\n";
}
?>
EOF
    chmod 644 /var/www/html/auto-install.php
fi

# Correction des permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Démarrage de PHP-FPM
echo "Démarrage de PHP-FPM..."
php-fpm7.4 -F