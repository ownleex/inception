#!/bin/bash

set -e

echo "Configuration du serveur FTP..."

# Créer l'utilisateur FTP s'il n'existe pas
if ! id "$FTP_USER" &>/dev/null; then
    echo "Création de l'utilisateur FTP: $FTP_USER"
    useradd -m -d /var/www/wordpress -s /bin/bash "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
else
    echo "L'utilisateur $FTP_USER existe déjà"
fi

# S'assurer que l'utilisateur a accès au répertoire WordPress
chown -R "$FTP_USER:$FTP_USER" /var/www/wordpress
chmod -R 755 /var/www/wordpress

# Créer le répertoire de log s'il n'existe pas
mkdir -p /var/log
touch /var/log/vsftpd.log

# Créer le répertoire secure_chroot_dir s'il n'existe pas
mkdir -p /var/run/vsftpd/empty

echo "Démarrage du serveur FTP..."
exec /usr/sbin/vsftpd /etc/vsftpd.conf