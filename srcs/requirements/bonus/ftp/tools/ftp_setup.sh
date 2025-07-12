#!/bin/bash

set -e

echo "=== Configuration du serveur FTP ==="

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

# S'assurer que l'utilisateur a accès au répertoire WordPress
echo "Configuration des permissions..."
chown -R "$FTP_USER:www-data" /var/www/wordpress
chmod -R 755 /var/www/wordpress

# Ajouter l'utilisateur FTP au groupe www-data
usermod -a -G www-data "$FTP_USER"

echo "Permissions configurées:"
ls -la /var/www/wordpress/wp-content/

# Démarrer vsftpd en mode foreground
exec /usr/sbin/vsftpd /etc/vsftpd.conf