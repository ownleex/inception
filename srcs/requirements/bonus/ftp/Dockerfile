FROM debian:bullseye

# Installer vsftpd et les outils de debug
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y vsftpd netstat-nat procps && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Créer les répertoires nécessaires
RUN mkdir -p /var/run/vsftpd/empty && \
    mkdir -p /var/log

# Copier les fichiers de configuration
COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/ftp_setup.sh /usr/local/bin/ftp_setup.sh

# Rendre le script exécutable
RUN chmod +x /usr/local/bin/ftp_setup.sh

# Exposer les ports
EXPOSE 21 20 21000-21010

# Démarrer le script de configuration
CMD ["bash", "/usr/local/bin/ftp_setup.sh"]