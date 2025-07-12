#!/bin/bash

set -e

echo "=== Configuration du serveur FTP ==="

# Attendre que le dossier WordPress soit prêt
while [ ! -d "/var/www/wordpress" ]; do
    echo "En attente du dossier WordPress..."
    sleep 2
done

echo "Utilisation de l'utilisateur: $FTP_USER"

# Créer l'utilisateur FTP s'il n'existe pas
if ! id "$FTP_USER" &>/dev/null; then
    echo "Création de l'utilisateur FTP: $FTP_USER"
    useradd -m -d /var/www/wordpress -s /bin/bash "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    echo "Utilisateur $FTP_USER créé avec succès"
else
    echo "L'utilisateur $FTP_USER existe déjà"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
fi

# Créer les répertoires nécessaires
mkdir -p /var/run/vsftpd/empty
mkdir -p /var/log
touch /var/log/vsftpd.log

# Ajouter l'utilisateur FTP au groupe www-data
usermod -a -G www-data "$FTP_USER"

# Configuration des permissions - CRITIQUE
echo "Configuration des permissions..."

# Changer le propriétaire principal pour permettre l'écriture FTP
chown -R "$FTP_USER:www-data" /var/www/wordpress

# Définir les bonnes permissions
find /var/www/wordpress -type d -exec chmod 755 {} \;
find /var/www/wordpress -type f -exec chmod 644 {} \;

# Permissions spéciales pour les dossiers d'upload WordPress
if [ -d "/var/www/wordpress/wp-content" ]; then
    chmod -R 775 /var/www/wordpress/wp-content
    chown -R "$FTP_USER:www-data" /var/www/wordpress/wp-content
fi

if [ -d "/var/www/wordpress/wp-content/uploads" ]; then
    chmod -R 775 /var/www/wordpress/wp-content/uploads
    chown -R "$FTP_USER:www-data" /var/www/wordpress/wp-content/uploads
fi

echo "Permissions configurées:"
ls -la /var/www/wordpress/

echo "Démarrage de vsftpd..."

# Démarrer vsftpd en mode foreground
exec /usr/sbin/vsftpd /etc/vsftpd.conf