FROM debian:bullseye

# Installation de NGINX et OpenSSL
RUN apt update -y && apt upgrade -y && \
    apt install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Création du répertoire pour les certificats SSL
RUN mkdir -p /etc/nginx/ssl

# Génération des certificats SSL auto-signés
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=PACA/L=Nice/O=42/OU=42/CN=ayarmaya.42.fr"

# Copie de la configuration NGINX
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/init_nginx.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_nginx.sh

# Exposition du port HTTPS
EXPOSE 443

# Point d'entrée
ENTRYPOINT ["sh", "/usr/local/bin/init_nginx.sh"]