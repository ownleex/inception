#!/bin/bash

# Créer l'utilisateur FTP
echo "Création de l'utilisateur FTP: $FTP_USER"
useradd -m -d /var/www/wordpress -G www-data "$FTP_USER"
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

# Permissions spéciales pour wp-content
chmod -R 775 /var/www/wordpress
chown -R "$FTP_USER:$FTP_USER" /var/www/wordpress

# Créer le répertoire vsftpd
mkdir -p /var/run/vsftpd/empty

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