#!/bin/bash

echo "Démarrage de Redis..."
exec redis-server --protected-mode no --bind 0.0.0.0
