#!/bin/bash

echo "📊 Lancement de cAdvisor sur le port 8080..."
exec /usr/local/bin/cadvisor \
    --logtostderr \
    --port=8080
