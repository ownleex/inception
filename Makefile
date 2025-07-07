# Variables
COMPOSE_FILE = ./srcs/docker-compose.yml
DATA_PATH = /home/$(USER)/data

# Couleurs
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m

.PHONY: all up down clean fclean re logs

# Construction et lancement
all:
	@echo "$(YELLOW)📁 Création des répertoires...$(NC)"
	@sudo mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress
	@sudo chown -R $(USER):$(USER) $(DATA_PATH)
	@echo "$(GREEN)🚀 Lancement des services...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) up -d --build

# Nettoyage des containers
clean:
	@echo "$(YELLOW)🧹 Nettoyage...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) down -v --remove-orphans

# Nettoyage complet
fclean: clean
	@echo "$(RED)🗑️ Nettoyage complet...$(NC)"
	@docker system prune -a -f --volumes
	@sudo rm -rf $(DATA_PATH)

# Reconstruction
re: fclean all

# Logs
logs:
	@docker-compose -f $(COMPOSE_FILE) logs -f

# Connexion MySQL
mysql:
	@docker exec -it mariadb mysql -u root -p