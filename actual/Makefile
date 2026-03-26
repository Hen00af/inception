# ======================
#	variables
# ======================

LOGIN			=	shattori
DATA_PATH		=	/home/$(LOGIN)/data
COMPOSE_DIR		=	./srcs
COMPOSE_FILE	=	$(COMPOSE_DIR)/docker-compose.yml

# ======================
#	rules
# ======================

all: up

up: 
	@mkdir	-p	$(DATA_PATH)/mariadb
	@mkdir	-p	$(DATA_PATH)/wordpress
	@docker compose -f $(COMPOSE_FILE) up -d --build

	@echo	"Container is successfully up!"

# Stop Container
down:
	@docker compose -f $(COMPOSE_FILE) down
	@echo	"Container is Downed"

# delete container, network, image, volume.
clean:
	@docker compose -f &$(COMPOSE_FILE) down -v --rmi all --remove-orphans
	@echo "container, network, image, volume is cleaned."

fclean:	clean
	@sudo rm -rf $(DATA_PATH)/mariadb
	@sudo rm -rf $(DATA_PATH)/wordpress
	@docker system prune -af --volumes

re: fclean all

.PHONY:	all up	down clean fclean re