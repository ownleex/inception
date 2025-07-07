# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::   #
#    Makefile                                           :+:      :+:    :+:   #
#                                                     +:+ +:+         +:+     #
#    By: login <login@student.42.fr>                +#+  +:+       +#+        #
#                                                 +#+#+#+#+#+   +#+           #
#    Created: 2024/07/07 00:00:00 by login             #+#    #+#             #
#    Updated: 2024/07/07 00:00:00 by login            ###   ########.fr       #
#                                                                              #
# **************************************************************************** #

# Variables
COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = /home/$(USER)/data

# Couleurs pour l'affichage
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

# Cibles principales
.PHONY: all build up down clean fclean re logs help

all: build up

# Construction des images
build:
	@echo "$(YELLOW)🔨 Construction des images Docker...$(NC)"
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@chmod +x srcs/requirements/mariadb/tools/init_db.sh
	docker-compose -f $(COMPOSE_FILE) build

# Lancement des containers
up:
	@echo "$(GREEN)🚀 Lancement des containers...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d

# Lancement avec logs en temps réel
up-logs:
	@echo "$(GREEN)🚀 Lancement des containers avec logs...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up

# Arrêt des containers
down:
	@echo "$(RED)🛑 Arrêt des containers...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down

# Arrêt et suppression des volumes
down-v:
	@echo "$(RED)🛑 Arrêt des containers et suppression des volumes...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down -v

# Affichage des logs
logs:
	docker-compose -f $(COMPOSE_FILE) logs -f

# Logs d'un service spécifique
logs-mariadb:
	docker-compose -f $(COMPOSE_FILE) logs -f mariadb

# Status des containers
status:
	@echo "$(YELLOW)📊 Status des containers:$(NC)"
	docker-compose -f $(COMPOSE_FILE) ps

# Connexion aux containers
shell-mariadb:
	docker exec -it mariadb /bin/bash

mysql:
	docker exec -it mariadb mysql -u root -p

# Nettoyage léger (containers et images non utilisées)
clean:
	@echo "$(YELLOW)🧹 Nettoyage des containers et images non utilisées...$(NC)"
	docker system prune -f

# Nettoyage complet (containers, images, volumes, réseaux)
fclean: down
	@echo "$(RED)🗑️  Nettoyage complet...$(NC)"
	@docker system prune -af --volumes
	@docker volume prune -f
	@sudo rm -rf $(DATA_PATH)
	@echo "$(RED)⚠️  Toutes les données ont été supprimées !$(NC)"

# Reconstruction complète
re: fclean all

# Test de connexion MariaDB
test-db:
	@echo "$(GREEN)🔍 Test de connexion à MariaDB...$(NC)"
	@docker exec mariadb mysql -u root -p$(shell grep MYSQL_ROOT_PASSWORD srcs/.env | cut -d '=' -f2) -e "SHOW DATABASES;"

# Aide
help:
	@echo "$(GREEN)Commandes disponibles:$(NC)"
	@echo "  $(YELLOW)make$(NC) ou $(YELLOW)make all$(NC)     - Construction et lancement"
	@echo "  $(YELLOW)make build$(NC)           - Construction des images uniquement"
	@echo "  $(YELLOW)make up$(NC)              - Lancement des containers en arrière-plan"
	@echo "  $(YELLOW)make up-logs$(NC)         - Lancement avec affichage des logs"
	@echo "  $(YELLOW)make down$(NC)            - Arrêt des containers"
	@echo "  $(YELLOW)make down-v$(NC)          - Arrêt + suppression des volumes"
	@echo "  $(YELLOW)make logs$(NC)            - Affichage des logs"
	@echo "  $(YELLOW)make logs-mariadb$(NC)    - Logs MariaDB uniquement"
	@echo "  $(YELLOW)make status$(NC)          - Status des containers"
	@echo "  $(YELLOW)make shell-mariadb$(NC)   - Shell dans le container MariaDB"
	@echo "  $(YELLOW)make mysql$(NC)           - Connexion MySQL en tant que root"
	@echo "  $(YELLOW)make test-db$(NC)         - Test de connexion à la base"
	@echo "  $(YELLOW)make clean$(NC)           - Nettoyage léger"
	@echo "  $(YELLOW)make fclean$(NC)          - Nettoyage complet (⚠️  supprime tout)"
	@echo "  $(YELLOW)make re$(NC)              - Reconstruction complète"