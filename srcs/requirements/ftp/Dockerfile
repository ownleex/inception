FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y vsftpd

# Créer le répertoire de configuration et les scripts
RUN mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/ftp_setup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/ftp_setup.sh

EXPOSE 21 20 21000-21010

CMD ["bash", "/usr/local/bin/ftp_setup.sh"]