#!/bin/bash

# Test de la configuration NGINX
echo "Test de la configuration NGINX..."
nginx -t

if [ $? -eq 0 ]; then
    echo "Configuration NGINX valide"
else
    echo "Erreur dans la configuration NGINX"
    exit 1
fi

# Démarrage de NGINX en mode foreground
echo "Démarrage de NGINX..."
nginx -g "daemon off;"