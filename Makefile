VOLPATH		= $(HOME)/data
DOCKPATH	= ./srcs/docker-compose.yml
DOMAIN		= ayarmaya.42.fr

all : add-host
	@echo "Création des dossiers dans: $(VOLPATH)"
	@sudo mkdir -p $(VOLPATH)/mariadb
	@sudo mkdir -p $(VOLPATH)/wordpress
	@sudo chmod 777 $(VOLPATH)/mariadb
	@sudo chmod 777 $(VOLPATH)/wordpress
	@HOME=$(HOME) sudo -E docker-compose -f $(DOCKPATH) up -d

clean : remove-host
	@HOME=$(HOME) sudo -E docker-compose -f ./srcs/docker-compose.yml down -v
	@sudo rm -rf $(VOLPATH)

fclean : clean
	@sudo docker system prune -a -f --volumes
	@sudo docker network prune -f

re : fclean all

add-host :
	@echo "Ajout de $(DOMAIN) au fichier hosts..."
	@if ! grep -q "$(DOMAIN)" /etc/hosts; then \
		echo "127.0.0.1	$(DOMAIN)" | sudo tee -a /etc/hosts > /dev/null; \
		echo "$(DOMAIN) ajouté à /etc/hosts"; \
	else \
		echo "$(DOMAIN) existe déjà dans /etc/hosts"; \
	fi

remove-host :
	@echo "Suppression de $(DOMAIN) du fichier hosts..."
	@if grep -q "$(DOMAIN)" /etc/hosts; then \
		sudo sed -i '/$(DOMAIN)/d' /etc/hosts; \
		echo "$(DOMAIN) supprimé de /etc/hosts"; \
	else \
		echo "$(DOMAIN) n'existe pas dans /etc/hosts"; \
	fi

show-hosts :
	@echo "Contenu actuel de /etc/hosts concernant $(DOMAIN):"
	@grep "$(DOMAIN)" /etc/hosts || echo "Aucune entrée trouvée pour $(DOMAIN)"

show-path :
	@echo "Chemin des données actuel: $(VOLPATH)"

mysql:
	@echo "🔐 Connexion MySQL (mot de passe requis)..."
	@docker exec -it mariadb mysql -u root -p

logs:
	@docker-compose -f $(DOCKPATH) logs -f

.PHONY: all clean fclean re add-host remove-host show-hosts show-path mysql ftp-test logs logs-ftp