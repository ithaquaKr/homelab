# Variables
SHELL := /bin/bash
DOCKER_COMPOSE := docker compose
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)
CURRENT_USER := ithaquaKr
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

.PHONY: help build up down start stop restart status logs clean backup restore scale-replica \
        enable-service disable-service monitoring-enable monitoring-disable \
        logging-enable logging-disable test lint

help: ## Display this help message
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

## Monitoring and Status
status: ## Show status of all services
	@echo "${YELLOW}Service Status:${NC}"
	$(DOCKER_COMPOSE) ps
	@echo "\n${YELLOW}Redis Master Status:${NC}"
	@$(DOCKER_COMPOSE) exec -T redis-master redis-cli info replication || true
	@echo "\n${YELLOW}Sentinel Status:${NC}"
	@$(DOCKER_COMPOSE) exec -T sentinel redis-cli -p 26379 sentinel master mymaster || true

logs: ## View logs of all services
	$(DOCKER_COMPOSE) logs -f

logs-%: ## View logs of a specific service (usage: make logs-redis-master)
	$(DOCKER_COMPOSE) logs -f $*

## Scaling Operations
scale-replica: ## Scale Redis replicas (usage: make scale-replica REPLICAS=3)
	@echo "${GREEN}Scaling Redis replicas to ${REPLICAS}...${NC}"
	$(DOCKER_COMPOSE) up -d --scale redis-replica=$(REPLICAS)

## Service Management
enable-service: ## Enable a service (usage: make enable-service SERVICE=redis-exporter)
	@echo "${GREEN}Enabling $(SERVICE)...${NC}"
	@sed -i "s/ENABLE_$(SERVICE)=.*/ENABLE_$(SERVICE)=true/" $(ENV_FILE)
	@echo "Don't forget to restart services with: make restart"

disable-service: ## Disable a service (usage: make disable-service SERVICE=redis-exporter)
	@echo "${RED}Disabling $(SERVICE)...${NC}"
	@sed -i "s/ENABLE_$(SERVICE)=.*/ENABLE_$(SERVICE)=false/" $(ENV_FILE)
	@echo "Don't forget to restart services with: make restart"

monitoring-enable: ## Enable all monitoring services
	@echo "${GREEN}Enabling monitoring services...${NC}"
	@sed -i "s/ENABLE_REDIS_EXPORTER=.*/ENABLE_REDIS_EXPORTER=true/" $(ENV_FILE)
	@sed -i "s/ENABLE_SENTINEL_EXPORTER=.*/ENABLE_SENTINEL_EXPORTER=true/" $(ENV_FILE)
	@echo "Don't forget to restart services with: make restart"

monitoring-disable: ## Disable all monitoring services
	@echo "${RED}Disabling monitoring services...${NC}"
	@sed -i "s/ENABLE_REDIS_EXPORTER=.*/ENABLE_REDIS_EXPORTER=false/" $(ENV_FILE)
	@sed -i "s/ENABLE_SENTINEL_EXPORTER=.*/ENABLE_SENTINEL_EXPORTER=false/" $(ENV_FILE)
	@echo "Don't forget to restart services with: make restart"

logging-enable: ## Enable all logging services
	@echo "${GREEN}Enabling logging services...${NC}"
	@sed -i "s/ENABLE_FLUENTD=.*/ENABLE_FLUENTD=true/" $(ENV_FILE)
	@sed -i "s/ENABLE_LOGROTATE=.*/ENABLE_LOGROTATE=true/" $(ENV_FILE)
	@echo "Don't forget to restart services with: make restart"

logging-disable: ## Disable all logging services
	@echo "${RED}Disabling logging services...${NC}"
	@sed -i "s/ENABLE_FLUENTD=.*/ENABLE_FLUENTD=false/" $(ENV_FILE)
	@sed -i "s/ENABLE_LOGROTATE=.*/ENABLE_LOGROTATE=false/" $(ENV_FILE)
	@echo "Don't forget to restart services with: make restart"

## Maintenance
clean: down ## Stop services and clean up data volumes
	@echo "${RED}Cleaning up volumes...${NC}"
	$(DOCKER_COMPOSE) down -v
	@echo "${GREEN}Cleanup complete${NC}"

backup: ## Create a backup of Redis data
	@mkdir -p $(BACKUP_DIR)
	@echo "${GREEN}Creating backup...${NC}"
	@$(DOCKER_COMPOSE) exec -T redis-master redis-cli SAVE
	@$(DOCKER_COMPOSE) cp redis-master:/data/dump.rdb $(BACKUP_DIR)/dump.rdb.$(TIMESTAMP)
	@echo "${GREEN}Backup created at $(BACKUP_DIR)/dump.rdb.$(TIMESTAMP)${NC}"

restore: ## Restore Redis data from backup (usage: make restore FILE=backups/dump.rdb.20250207)
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

## Development and Testing
test: ## Run tests
	@echo "${GREEN}Running tests...${NC}"
	$(DOCKER_COMPOSE) exec -T redis-master redis-cli ping
	$(DOCKER_COMPOSE) exec -T sentinel redis-cli -p 26379 ping
	@echo "${GREEN}Tests completed${NC}"

lint: ## Lint docker-compose files
	@echo "${GREEN}Linting docker-compose files...${NC}"
	docker compose config -q
	@echo "${GREEN}Lint completed${NC}"

.DEFAULT_GOAL := help
