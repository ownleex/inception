# Variables
COMPOSE_FILE	= ./srcs/docker-compose.yml
DOCKER_COMPOSE	= docker compose
DATA_PATH		= /home/$(USER)/data

# Couleurs
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m

.PHONY: all build up down clean fclean re logs status help test-mariadb

# Construction et lancement de MariaDB
all: build

# Création des répertoires et construction
build:
	@echo "$(YELLOW)📁 Création du répertoire MariaDB...$(NC)"
	@mkdir -p $(DATA_PATH)/mariadb
	@echo "$(YELLOW)🔨 Construction et lancement de MariaDB...$(NC)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up --build -d mariadb
	@echo "$(GREEN)✅ MariaDB lancé avec succès !$(NC)"
	@echo "$(YELLOW)⏳ Attente du démarrage de MariaDB...$(NC)"
	@sleep 10
	@make test-mariadb

# Lancement simple de MariaDB (sans rebuild)
up:
	@echo "$(GREEN)🚀 Lancement de MariaDB...$(NC)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d mariadb

# Arrêt de MariaDB
down:
	@echo "$(RED)🛑 Arrêt de MariaDB...$(NC)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down

# Arrêt forcé de MariaDB
kill:
	@echo "$(RED)💀 Arrêt forcé de MariaDB...$(NC)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) kill mariadb

# Nettoyage des containers et volumes Docker
clean:
	@echo "$(YELLOW)🧹 Nettoyage de MariaDB...$(NC)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down -v

# Nettoyage complet (containers + données locales)
fclean: clean
	@echo "$(RED)🗑️  Suppression des données MariaDB...$(NC)"
	@rm -rf $(DATA_PATH)/mariadb
	@echo "$(RED)🧽 Nettoyage complet du système Docker...$(NC)"
	@docker system prune -a -f --volumes
	@docker network prune -f
	@echo "$(RED)⚠️  Nettoyage complet terminé !$(NC)"

# Reconstruction complète
re: fclean all

# Affichage des logs de MariaDB
logs:
	@echo "$(YELLOW)📋 Logs de MariaDB:$(NC)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f mariadb

# Status de MariaDB
status:
	@echo "$(YELLOW)📊 Status de MariaDB:$(NC)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) ps mariadb

# Shell dans MariaDB
shell:
	@echo "$(GREEN)🔧 Ouverture du shell MariaDB...$(NC)"
	@docker exec -it mariadb /bin/bash

# Connexion MySQL directe
mysql:
	@echo "$(GREEN)🔐 Connexion MySQL (mot de passe requis)...$(NC)"
	@docker exec -it mariadb mysql -u root -p

# Connexion MySQL avec utilisateur WordPress
mysql-wp:
	@echo "$(GREEN)🔐 Connexion MySQL avec utilisateur WordPress...$(NC)"
	@docker exec -it mariadb mysql -u $(shell grep MYSQL_USER srcs/.env | cut -d '=' -f2) -p$(shell grep MYSQL_PASSWORD srcs/.env | cut -d '=' -f2)

# Test complet de MariaDB
test-mariadb:
	@echo "$(GREEN)🔍 === TEST DE MARIADB ===$(NC)"
	@echo "$(YELLOW)📊 Status du container:$(NC)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) ps mariadb
	@echo ""
	@echo "$(YELLOW)🔌 Test de connexion avec root:$(NC)"
	@docker exec mariadb mysql -u root -p$(shell grep MYSQL_ROOT_PASSWORD srcs/.env | cut -d '=' -f2) -e "SELECT 'Connexion root OK' as Status;" 2>/dev/null && echo "$(GREEN)✅ Connexion root réussie$(NC)" || echo "$(RED)❌ Échec connexion root$(NC)"
	@echo ""
	@echo "$(YELLOW)🔌 Test de connexion utilisateur WordPress:$(NC)"
	@docker exec mariadb mysql -u $(shell grep MYSQL_USER srcs/.env | cut -d '=' -f2) -p$(shell grep MYSQL_PASSWORD srcs/.env | cut -d '=' -f2) -e "SELECT 'Connexion WordPress OK' as Status;" 2>/dev/null && echo "$(GREEN)✅ Connexion WordPress réussie$(NC)" || echo "$(RED)❌ Échec connexion WordPress$(NC)"
	@echo ""
	@echo "$(YELLOW)🗄️  Bases de données disponibles:$(NC)"
	@docker exec mariadb mysql -u root -p$(shell grep MYSQL_ROOT_PASSWORD srcs/.env | cut -d '=' -f2) -e "SHOW DATABASES;" 2>/dev/null || echo "$(RED)❌ Impossible d'afficher les bases$(NC)"
	@echo ""
	@echo "$(YELLOW)👥 Utilisateurs MySQL:$(NC)"
	@docker exec mariadb mysql -u root -p$(shell grep MYSQL_ROOT_PASSWORD srcs/.env | cut -d '=' -f2) -e "SELECT User, Host FROM mysql.user;" 2>/dev/null || echo "$(RED)❌ Impossible d'afficher les utilisateurs$(NC)"

# Test de performance MariaDB
test-perf:
	@echo "$(GREEN)⚡ Test de performance MariaDB...$(NC)"
	@docker exec mariadb mysql -u root -p$(shell grep MYSQL_ROOT_PASSWORD srcs/.env | cut -d '=' -f2) -e "SELECT BENCHMARK(1000000, MD5('test'));" 2>/dev/null && echo "$(GREEN)✅ Test de performance OK$(NC)" || echo "$(RED)❌ Échec test de performance$(NC)"

# Redémarrage rapide
restart: down up

# Aide spécifique MariaDB
help:
	@echo "$(GREEN)=== COMMANDES MARIADB ===$(NC)"
	@echo "$(YELLOW)make$(NC) ou $(YELLOW)make all$(NC)        - Construction et lancement MariaDB"
	@echo "$(YELLOW)make build$(NC)              - Construction avec test automatique"
	@echo "$(YELLOW)make up$(NC)                 - Lancement MariaDB"
	@echo "$(YELLOW)make down$(NC)               - Arrêt MariaDB"
	@echo "$(YELLOW)make kill$(NC)               - Arrêt forcé MariaDB"
	@echo "$(YELLOW)make restart$(NC)            - Redémarrage MariaDB"
	@echo "$(YELLOW)make logs$(NC)               - Logs de MariaDB"
	@echo "$(YELLOW)make status$(NC)             - Status de MariaDB"
	@echo "$(YELLOW)make shell$(NC)              - Shell dans le container MariaDB"
	@echo "$(YELLOW)make mysql$(NC)              - Connexion MySQL root (interactive)"
	@echo "$(YELLOW)make mysql-wp$(NC)           - Connexion MySQL utilisateur WordPress"
	@echo "$(YELLOW)make test-mariadb$(NC)       - Test complet de MariaDB"
	@echo "$(YELLOW)make test-perf$(NC)          - Test de performance"
	@echo "$(YELLOW)make clean$(NC)              - Nettoyage containers et volumes"
	@echo "$(YELLOW)make fclean$(NC)             - Nettoyage complet (⚠️  supprime tout)"
	@echo "$(YELLOW)make re$(NC)                 - Reconstruction complète"