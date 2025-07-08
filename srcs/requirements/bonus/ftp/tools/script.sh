#!/bin/bash

echo " Start vsftpd service temporarily to initialize : "
service vsftpd start


echo " Add a new FTP use r: "
adduser --disabled-password --gecos "" "$USERFTP"

echo " Set the user's password securely : "
echo -e "$PASSFTP\n$PASSFTP" | passwd "$USERFTP"

echo "Create the user's home directory : /home/'${$USERFTP}'/ftp "
mkdir -p /home/$USERFTP/ftp
chown -R "$USERFTP:$USERFTP" /home/$USERFTP/ftp

echo " Append the user '${USERFTP}'to the vsftpd user list :"
echo "$USERFTP" >> /etc/vsftpd.userlist

echo " Update vsftpd configuration : "
cat << EOF >> /etc/vsftpd.conf
anonymous_enable=NO
local_enable=YES
write_enable=YES
user_sub_token=$USERFTP
local_root=/home/$USERFTP/ftp
pasv_min_port=60000
pasv_max_port=60005
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
EOF

echo " Stop vsftpd service before restarting it with new configuration : "
service vsftpd stop

echo " Start vsftpd  : "
exec vsftpd