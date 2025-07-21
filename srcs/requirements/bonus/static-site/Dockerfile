FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y nginx

COPY html/ /var/www/html/

ENTRYPOINT ["nginx", "-g", "daemon off;"]
