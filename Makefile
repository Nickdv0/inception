USER = $(shell whoami)

DOCKER_COMPOSE=docker compose

DOCKER_COMPOSE_FILE = ./srcs/docker-compose.yml

.PHONY: kill build down clean restart

up:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) up -d

build:
	mkdir -p /home/$(USER)/data/mysql
	mkdir -p /home/$(USER)/data/wordpress
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) up --build -d

kill:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) kill

down:
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) down

clean: down
	@echo "Cleaning volumes..."
	@docker run --rm -v /home/$(USER)/data:/data debian:11 sh -c "rm -rf /data/mysql /data/wordpress && mkdir -p /data/mysql /data/wordpress"

fclean: clean
	@echo "Removing Docker images and system cleanup..."
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) down -v
	docker system prune -a -f

re: clean build