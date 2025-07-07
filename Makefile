# Variables
COMPOSE_FILE = ./srcs/docker-compose.yml
DATA_PATH = /home/$(USER)/data
DOMAIN = ayarmaya.42.fr

# Couleurs
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m

.PHONY: all up down clean fclean re logs hosts clean-hosts

# Construction et lancement
all: hosts
	@echo "$(YELLOW)📁 Création des répertoires...$(NC)"
	@sudo mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress
	@sudo chown -R $(USER):$(USER) $(DATA_PATH)
	@echo "$(GREEN)🚀 Lancement des services...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) up -d --build

# Configuration du fichier hosts
hosts:
	@echo "$(YELLOW)🌐 Configuration du nom de domaine...$(NC)"
	@if ! grep -q "$(DOMAIN)" /etc/hosts; then \
		echo "127.0.0.1 $(DOMAIN)" | sudo tee -a /etc/hosts; \
		echo "$(GREEN)✅ Domaine $(DOMAIN) ajouté au fichier hosts$(NC)"; \
	else \
		echo "$(GREEN)✅ Domaine $(DOMAIN) déjà configuré$(NC)"; \
	fi

# Lancement simple
up:
	@echo "$(GREEN)🚀 Lancement des services...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) up -d

# Arrêt
down:
	@echo "$(RED)🛑 Arrêt des services...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) down

# Nettoyage des containers
clean:
	@echo "$(YELLOW)🧹 Nettoyage...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) down -v --remove-orphans

# Suppression du domaine des hosts
clean-hosts:
	@echo "$(YELLOW)🌐 Suppression du domaine du fichier hosts...$(NC)"
	@sudo sed -i '/$(DOMAIN)/d' /etc/hosts
	@echo "$(GREEN)✅ Domaine $(DOMAIN) supprimé du fichier hosts$(NC)"

# Nettoyage complet
fclean: clean
	@echo "$(RED)🗑️ Nettoyage complet...$(NC)"
	@docker system prune -a -f --volumes
	@sudo rm -rf $(DATA_PATH)
	@echo "$(YELLOW)🌐 Suppression du domaine du fichier hosts...$(NC)"
	@sudo sed -i '/$(DOMAIN)/d' /etc/hosts
	@echo "$(GREEN)✅ Domaine $(DOMAIN) supprimé du fichier hosts$(NC)"

# Reconstruction
re: fclean all

# Logs
logs:
	@docker-compose -f $(COMPOSE_FILE) logs -f

# Logs spécifiques
logs-nginx:
	@docker-compose -f $(COMPOSE_FILE) logs -f nginx

logs-wordpress:
	@docker-compose -f $(COMPOSE_FILE) logs -f wordpress

logs-mariadb:
	@docker-compose -f $(COMPOSE_FILE) logs -f mariadb

# Connexion MySQL
mysql:
	@docker exec -it mariadb mysql -u root -p

# Test de connectivité
test:
	@echo "$(YELLOW)🧪 Test de connectivité...$(NC)"
	@curl -k https://$(DOMAIN) || echo "$(RED)❌ Site non accessible$(NC)"