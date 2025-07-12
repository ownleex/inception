#!/bin/bash

set -e

# Attendre que le dossier WordPress soit prêt
while [ ! -d "/var/www/wordpress" ]; do
    echo "En attente du dossier WordPress..."
    sleep 2
done

# Créer l'utilisateur FTP
if ! id "$FTP_USER" &>/dev/null; then
    echo "Création de l'utilisateur FTP: $FTP_USER"
    useradd -m -d /var/www/wordpress -s /bin/bash "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
else
    echo "L'utilisateur $FTP_USER existe déjà"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    usermod -d /var/www/wordpress "$FTP_USER"
fi

# Ajouter aux groupes nécessaires
usermod -a -G www-data "$FTP_USER"

# Configuration des permissions
chown -R "$FTP_USER:$FTP_USER" /var/www/wordpress
chmod -R 755 /var/www/wordpress

# Permissions spéciales pour wp-content
if [ -d "/var/www/wordpress/wp-content" ]; then
    chmod -R 777 /var/www/wordpress/wp-content
    chown -R "$FTP_USER:$FTP_USER" /var/www/wordpress/wp-content
fi

# Créer les répertoires vsftpd
mkdir -p /var/run/vsftpd/empty
mkdir -p /var/log
touch /var/log/vsftpd.log

# Configuration vsftpd supplémentaire
echo "user_sub_token=$FTP_USER" >> /etc/vsftpd.conf
echo "local_root=/var/www/wordpress" >> /etc/vsftpd.conf
echo "hide_ids=NO" >> /etc/vsftpd.conf

echo "Démarrage de vsftpd..."
exec /usr/sbin/vsftpd /etc/vsftpd.conf