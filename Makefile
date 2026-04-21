# Hermes WhatsApp POC - Makefile

# Default environment
ENV ?= dev
ENV_FILE = .env.$(ENV)
CONFIG_FILE = config-$(ENV).yaml

# Export variables for Docker Compose and scripts
export ENV
export HERMES_CONFIG_FILE = $(CONFIG_FILE)

# Docker Compose command with environment file and unique project name
DOCKER_COMPOSE = docker compose -p hermes-$(ENV) --env-file $(ENV_FILE)

.PHONY: help setup pair start stop restart status logs clean

help: ## Show this help message
	@echo 'Usage: make [target] [ENV=dev|stg|prd]'
	@echo ''
	@echo 'Targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

setup: ## Initial setup: create environment-specific .env (e.g., make setup ENV=dev)
	@if [ ! -f $(ENV_FILE) ]; then \
		cp .env.example $(ENV_FILE); \
		echo "✅ Created $(ENV_FILE) from .env.example"; \
		echo "👉 Please edit $(ENV_FILE) and add your OPENROUTER_API_KEY"; \
	else \
		echo "⚠️  $(ENV_FILE) already exists"; \
	fi
	@if [ ! -f $(CONFIG_FILE) ] && [ -f config-dev.yaml ]; then \
		cp config-dev.yaml $(CONFIG_FILE); \
		echo "✅ Created $(CONFIG_FILE) from config-dev.yaml"; \
	fi

pair: ## Run the WhatsApp pairing process for the current ENV
	@./scripts/pair-whatsapp.sh

up: start ## Alias for start

start: ## Start the Hermes service for the current ENV
	@$(DOCKER_COMPOSE) up -d

stop: ## Stop the Hermes service for the current ENV
	@$(DOCKER_COMPOSE) down

restart: stop start ## Restart the Hermes service

status: ## Check the status of the container and WhatsApp session
	@./scripts/check-status.sh

logs: ## View real-time container logs
	@$(DOCKER_COMPOSE) logs -f hermes

clean: ## Remove data directories and stop containers for ALL environments
	@docker compose down -v 2>/dev/null || true
	@rm -rf data/hermes-*
	@echo "✅ Cleaned up containers and all environment-specific data"
