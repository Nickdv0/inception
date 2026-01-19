USER = $(shell whoami)

DOCKER_COMPOSE=docker compose

DOCKER_COMPOSE_FILE = ./srcs/docker-compose.yml

.PHONY: kill build down clean restart

build:
	mkdir -p /home/$(USER)/data/mysql
	mkdir -p /home/$(USER)/data/wordpress
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) up --build -d

kill:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) kill

down:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) down

clean:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) down -v

fclean: clean
	docker run --rm -v /home/$(USER)/data:/data debian rm -rf /data/mysql /data/wordpress
	docker system prune -a -f

re: clean build