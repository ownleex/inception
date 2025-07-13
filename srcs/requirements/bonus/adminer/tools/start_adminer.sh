#!/bin/bash

echo "=== Démarrage d'Adminer ==="

# Vérification que le fichier Adminer existe
if [ ! -f index.php ]; then
    echo "❌ Erreur: Fichier Adminer non trouvé !"
    exit 1
fi

echo "✅ Fichier Adminer trouvé"

# Optionnel : Attendre que MariaDB soit prêt
echo "⏳ Attente de MariaDB..."
timeout=30
while ! nc -z mariadb 3306 2>/dev/null && [ $timeout -gt 0 ]; do
    echo "   MariaDB pas encore prêt, attente... ($timeout)"
    sleep 2
    timeout=$((timeout-2))
done

if [ $timeout -le 0 ]; then
    echo "⚠️  Attention: MariaDB ne répond pas, mais démarrage d'Adminer quand même"
else
    echo "✅ MariaDB est prêt !"
fi

echo "🚀 Démarrage du serveur PHP pour Adminer sur 0.0.0.0:8080..."
echo "🌐 Adminer sera accessible via http://localhost:8080"

# Démarrer le serveur PHP intégré
exec php -S 0.0.0.0:8080