all:
	mkdir -p ~/data/wordpress
	mkdir -p ~/data/mariadb
	docker compose -f srcs/docker-compose.yml up --build

clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	docker system prune -af --volumes
	sudo rm -rf /home/sdiouane/data/mariadb
	sudo rm -rf /home/sdiouane/data/wordpress

re: fclean all

