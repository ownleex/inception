#!/bin/bash

# Créer l'utilisateur FTP
echo "Création de l'utilisateur FTP: $FTP_USER"
useradd -m -d /var/www/wordpress -s /bin/bash "$FTP_USER"
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

# Ajouter aux groupes nécessaires
usermod -a -G www-data "$FTP_USER"

# Permissions spéciales pour wp-content
chmod -R 775 /var/www/wordpress
chown -R "$FTP_USER:$FTP_USER" /var/www/wordpress

# Créer les répertoires vsftpd
mkdir -p /var/run/vsftpd/empty
mkdir -p /var/log
touch /var/log/vsftpd.log

cat > /etc/vsftpd.conf << EOF
listen=YES
listen_ipv6=NO
background=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
pasv_enable=YES
pasv_min_port=21000
pasv_max_port=21010
user_sub_token=$FTP_USER
local_root=/var/www/wordpress
hide_ids=NO
EOF

echo "Démarrage de vsftpd..."
exec vsftpd /etc/vsftpd.conf