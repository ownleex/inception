#!/bin/bash

# Créer l'utilisateur FTP
echo "Création de l'utilisateur FTP: $FTP_USER"
useradd -m -d /var/www/wordpress -s /bin/bash "$FTP_USER"
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

# Ajouter aux groupes nécessaires
usermod -a -G www-data "$FTP_USER"

# Permissions spéciales pour wp-content
chmod -R 777 /var/www/wordpress
chown -R "$FTP_USER:$FTP_USER" /var/www/wordpress

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