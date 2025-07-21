FROM debian:bullseye

# 1. Installer les dépendances
RUN apt-get update && \
    apt-get install -y wget ca-certificates unzip libcap2-bin curl

# 2. Télécharger cAdvisor et lui donner les bonnes capacités
RUN wget https://github.com/google/cadvisor/releases/download/v0.47.2/cadvisor-v0.47.2-linux-amd64 \
     -O /usr/local/bin/cadvisor && \
    chmod +x /usr/local/bin/cadvisor && \
    setcap cap_sys_admin+ep /usr/local/bin/cadvisor

# 3. Exposer le port d’écoute
EXPOSE 8080

# 4. Démarrer cAdvisor directement
ENTRYPOINT ["/usr/local/bin/cadvisor", "--logtostderr", "--port=8080"]
