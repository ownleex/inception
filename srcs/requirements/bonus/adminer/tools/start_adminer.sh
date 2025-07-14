#!/bin/bash

echo "⏳ Attente de MariaDB..."

until ! nc -z mariadb 3306 2>/dev/null; do
    echo "   MariaDB pas encore prêt, attente..."
    sleep 2
done

echo "🚀 Démarrage du serveur PHP pour Adminer sur 0.0.0.0:8080..."
echo "🌐 Adminer sera accessible via http://localhost:8080"

# Démarrer le serveur PHP intégré
exec php -S 0.0.0.0:8080