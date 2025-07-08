VOLPATH		= /home/ayarmaya/data
DOCKPATH	= ./srcs/docker-compose.yml

all :
	@sudo mkdir -p $(VOLPATH)/mariadb
	@sudo mkdir -p $(VOLPATH)/wordpress
	@sudo chmod 777 $(VOLPATH)/mariadb
	@sudo chmod 777 $(VOLPATH)/wordpress
	@sudo docker compose -f $(DOCKPATH) up -d

clean :
	@sudo docker compose -f ./srcs/docker-compose.yml down -v
	@sudo rm -rf $(VOLPATH)/mariadb
	@sudo rm -rf $(VOLPATH)/wordpress

fclean : clean
	@sudo docker system prune -a -f --volumes
	@sudo docker network prune -f

re : fclean all
