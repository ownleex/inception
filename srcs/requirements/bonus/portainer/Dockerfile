# srcs/requirements/bonus/portainer/Dockerfile

FROM debian:bullseye

# 1. Installer les dépendances nécessaires
RUN apt-get update && \
    apt-get install -y \
      ca-certificates \
      curl \
      tar && \
    rm -rf /var/lib/apt/lists/*

# 2. Récupérer Portainer CE et n’extraire que le binaire
ARG PORTAINER_VER=2.31.2
RUN curl -fsSL \
    https://github.com/portainer/portainer/releases/download/${PORTAINER_VER}/portainer-${PORTAINER_VER}-linux-amd64.tar.gz \
  | tar --strip-components=1 -xz -C /usr/local/bin && \
    chmod +x /usr/local/bin/portainer

# 3. Créer et préparer le dossier de données pour la persistance
RUN mkdir -p /data && chmod 777 /data

# 4. Exposer les ports de l’interface Portainer
EXPOSE 9000 9443

# 5. Lancer Portainer
ENTRYPOINT ["/usr/local/bin/portainer"]
CMD ["--bind", "0.0.0.0:9000", "--data", "/data"]
