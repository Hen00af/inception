# ======================
#   attachment
# ======================
GREEN		=	\033[32m
RED			=	\033[31m
CYAN		=	\033[36m
YELLOW		=	\033[33m
RESET		=	\033[0m

# ======================
#	variables
# ======================

DATA_PATH		=	$(HOME)/data
COMPOSE_DIR		=	./
COMPOSE_FILE	=	$(COMPOSE_DIR)/docker-compose.yml

export DATA_PATH

# ======================
#	global　rules
# ======================

all: up

up: 
	@mkdir	-p	$(DATA_PATH)/mariadb
	@mkdir	-p	$(DATA_PATH)/wordpress
	@cd $(COMPOSE_DIR) && docker compose -f $(COMPOSE_FILE) up -d --build
	@printf	"$(GREEN)Container is successfully up!$(RESET) \n"

# Stop Container
down:
	@cd $(COMPOSE_DIR) && docker compose -f $(COMPOSE_FILE) down
	@printf "$(YELLOW)Container is stopped.$(RESET)\n"

# delete containers and network.
clean:
	@cd $(COMPOSE_DIR) && docker compose -f $(COMPOSE_FILE) down --remove-orphans
	@printf "$(CYAN)Containers and network are cleaned.$(RESET)\n"

fclean:	clean
	@cd $(COMPOSE_DIR) && docker compose -f $(COMPOSE_FILE) down -v --rmi all --remove-orphans
	@rm -rf $(DATA_PATH)/mariadb
	@rm -rf $(DATA_PATH)/wordpress
	@printf "$(RED)Project containers, images, volumes, and data are removed.$(RESET)\n"

re: fclean all

# ======================
#	local rules
# ======================

mariadb-up:
	@mkdir -p $(DATA_PATH)/mariadb
	@cd $(COMPOSE_DIR) && docker compose -f $(COMPOSE_FILE) up -d --build mariadb
	@printf "$(GREEN)MariaDB container is up.$(RESET)\n"

nginx-up:
	@cd $(COMPOSE_DIR) && docker compose -f $(COMPOSE_FILE) up -d --build nginx
	@printf "$(GREEN)Nginx container is up.$(RESET)\n"

wordpress-up:
	@mkdir -p $(DATA_PATH)/wordpress
	@cd $(COMPOSE_DIR) && docker compose -f $(COMPOSE_FILE) up -d --build wordpress
	@printf "$(GREEN)WordPress container is up.$(RESET)\n"


.PHONY:	all up down clean fclean re mariadb-up nginx-up wordpress-up
