FROM debian:bullseye

RUN apt update -y && apt-get upgrade -y vsftpd

RUN apt-get install ftp -y 

RUN apt-get install vsftpd -y 

COPY /tools/script.sh /script.sh

ENTRYPOINT [ "bash", "./script.sh" ]
