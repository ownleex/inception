FROM debian:bullseye

RUN apt update -y && apt upgrade -y && apt install mariadb-server -y

RUN sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld

COPY tools/init_db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_db.sh

ENTRYPOINT ["init_db.sh"]