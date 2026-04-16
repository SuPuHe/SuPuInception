LOGIN = omizin
DATA_PATH = /home/$(LOGIN)/data
DOCKER_COMPOSE = docker compose -f srcs/docker-compose.yml

GREEN = \033[0;32m
RED = \033[0;31m
RESET = \033[0m

all: setup
	$(DOCKER_COMPOSE) up --build -d

setup:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@if [ ! -f ./secrets/db_password.txt ]; then echo "Error: Create ./secrets/db_password.txt"; exit 1; fi

stop:
	$(DOCKER_COMPOSE) stop

down:
	$(DOCKER_COMPOSE) down

clean: down
	@docker system prune -a --force

fclean: clean
	@sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all setup stop down clean fclean re
