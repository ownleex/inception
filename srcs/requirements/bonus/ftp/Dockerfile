FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y vsftpd && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Configuration vsftpd plus permissive pour debug
RUN echo 'listen=YES' >> /etc/vsftpd.conf && \
    echo 'listen_ipv6=NO' >> /etc/vsftpd.conf && \
    echo 'background=NO' >> /etc/vsftpd.conf && \
    echo 'anonymous_enable=NO' >> /etc/vsftpd.conf && \
    echo 'local_enable=YES' >> /etc/vsftpd.conf && \
    echo 'write_enable=YES' >> /etc/vsftpd.conf && \
    echo 'chroot_local_user=YES' >> /etc/vsftpd.conf && \
    echo 'allow_writeable_chroot=YES' >> /etc/vsftpd.conf && \
    echo 'pasv_enable=YES' >> /etc/vsftpd.conf && \
    echo 'pasv_min_port=21000' >> /etc/vsftpd.conf && \
    echo 'pasv_max_port=21010' >> /etc/vsftpd.conf && \
    echo 'local_umask=000' >> /etc/vsftpd.conf && \
    echo 'file_open_mode=0777' >> /etc/vsftpd.conf && \
    echo 'dirmessage_enable=YES' >> /etc/vsftpd.conf && \
    echo 'use_localtime=YES' >> /etc/vsftpd.conf && \
    echo 'xferlog_enable=YES' >> /etc/vsftpd.conf && \
    echo 'connect_from_port_20=YES' >> /etc/vsftpd.conf

# Créer les répertoires nécessaires
RUN mkdir -p /var/run/vsftpd/empty

COPY tools/ftp_setup.sh /usr/local/bin/setup_ftp.sh
RUN chmod +x /usr/local/bin/setup_ftp.sh

EXPOSE 21 20 21000-21010

ENTRYPOINT ["/usr/local/bin/setup_ftp.sh"]