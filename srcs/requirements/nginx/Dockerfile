FROM debian:bullseye

RUN apt update -y && apt upgrade -y && apt install -y nginx openssl

RUN mkdir -p /etc/nginx/ssl && mkdir -p /var/run/nginx
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=PACA/L=Nice/O=42/OU=42/CN=ayarmaya.42.fr/UID=ayarmaya"

COPY conf/nginx.conf /etc/nginx/nginx.conf

# -g pour passer une directive globale à Nginx
ENTRYPOINT ["nginx", "-g", "daemon off;"]