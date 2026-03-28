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

LOGIN			=	shattori

UNAME			:=	$(shell uname)
ifeq ($(UNAME), Darwin)
	DATA_PATH	=	$(HOME)/data
else
	DATA_PATH	=	/home/$(LOGIN)/data
endif
COMPOSE_DIR		=	./
COMPOSE_FILE	=	$(COMPOSE_DIR)/docker-compose.yml

export DATA_PATH

# ======================
#	rules
# ======================

all: up

up: 
	@mkdir	-p	$(DATA_PATH)/mariadb
	@mkdir	-p	$(DATA_PATH)/wordpress
	@cd $(COMPOSE_DIR) && docker compose -f $(COMPOSE_FILE) up -d --build
	@printf	"$(GREEN)Container is successfully up!$(RESET) \n"

# Stop Container
down:
	@docker compose -f $(COMPOSE_FILE) down
	@printf "$(YELLOW)🛑 Container is Downed$(RESET)\n"

# delete container, network, image, volume.
clean:
	@docker compose -f $(COMPOSE_FILE) down -v --rmi all --remove-orphans
	@printf "$(CYAN)🧹 container, network, image, volume is cleaned.$(RESET)\n"

fclean:	clean
	@sudo rm -rf $(DATA_PATH)/mariadb
	@sudo rm -rf $(DATA_PATH)/wordpress
	@docker system prune -af --volumes
	@printf "$(RED)💥 All data and docker cache are completely removed!$(RESET)\n"

re: fclean all

.PHONY:	all up	down clean fclean re