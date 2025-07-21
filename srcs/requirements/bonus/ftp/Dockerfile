FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y vsftpd

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
    echo 'pasv_max_port=21010' >> /etc/vsftpd.conf

COPY tools/ftp_setup.sh /usr/local/bin/setup_ftp.sh
RUN chmod +x /usr/local/bin/setup_ftp.sh

EXPOSE 21 20 21000-21010

ENTRYPOINT ["/usr/local/bin/setup_ftp.sh"]