# Variables
DOCKER_COMPOSE := docker compose
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)
ENV_FILE := .env
BACKUP_DIR := ./backups

# Loading environment variables from .env file
ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif


# Colors for output
YELLOW := \033[1;33m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help status backup restore build up down start stop restart

.DEFAULT_GOAL := help

## Display this help message
help:
	@echo "Redis Sentinel cluster management Tool"
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-20s${NC} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## Build and Setup
build: ## Build or rebuild services
	@echo "${GREEN}Building services...${NC}"
	$(DOCKER_COMPOSE) build

## Up compose
up: ## Start all services
	@echo "${GREEN}Starting services...${NC}"
	$(DOCKER_COMPOSE) up -d

## Down compose
down: ## Stop and remove all services
	@echo "${RED}Stopping and removing services...${NC}"
	$(DOCKER_COMPOSE) down

## Start compose
start: ## Start existing services
	@echo "${GREEN}Starting existing services...${NC}"
	$(DOCKER_COMPOSE) start

## Stop compose
stop: ## Stop services without removing them
	@echo "${RED}Stopping services...${NC}"
	$(DOCKER_COMPOSE) stop

## Restart compose
restart: stop start ## Restart all services
	@echo "${RED}Stopping services...${NC}"
	$(DOCKER_COMPOSE) restart

## Show status of all services
status:
	@echo "${YELLOW}Service Status:${NC}"
	$(DOCKER_COMPOSE) ps
	@echo "\n${YELLOW}Redis Master Status:${NC}"
	@$(DOCKER_COMPOSE) exec -T redis-1 redis-cli -p 6380 info replication || true
	@echo "\n${YELLOW}Sentinel Status:${NC}"
	@$(DOCKER_COMPOSE) exec -T sentinel-1 redis-cli -p 26380 sentinel master mymaster || true

## Create a backup of Redis data
backup:
	@mkdir -p $(BACKUP_DIR)
	@echo "${GREEN}Creating backup...${NC}"
	@$(DOCKER_COMPOSE) exec -T redis-master redis-cli SAVE
	@$(DOCKER_COMPOSE) cp redis-master:/data/dump.rdb $(BACKUP_DIR)/dump.rdb.$(TIMESTAMP)
	@echo "${GREEN}Backup created at $(BACKUP_DIR)/dump.rdb.$(TIMESTAMP)${NC}"

## Restore Redis data from backup (usage: make restore FILE=backups/dump.rdb.20250207)
restore:
	@if [ -z "$(FILE)" ]; then \
		echo "${RED}Error: Please specify the backup file with FILE=path/to/backup${NC}"; \
		exit 1; \
	fi
	@echo "${YELLOW}Stopping Redis services...${NC}"
	@$(DOCKER_COMPOSE) stop redis-master redis-replica
	@echo "${GREEN}Restoring from backup...${NC}"
	@$(DOCKER_COMPOSE) cp $(FILE) redis-master:/data/dump.rdb
	@echo "${GREEN}Starting Redis services...${NC}"
	@$(DOCKER_COMPOSE) start redis-master redis-replica
