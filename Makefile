# Hermes WhatsApp Agent - Makefile
# Handles multi-environment management (dev, stg, prd)

# Defaults
ENV ?= dev
ENV_FILE := .env.$(ENV)
PROJECT_NAME := hermes-$(ENV)

# Load environment variables for the shell commands if the file exists
ifneq ("$(wildcard $(ENV_FILE))","")
    include $(ENV_FILE)
    export $(shell sed 's/=.*//' $(ENV_FILE))
endif

.PHONY: help up down restart logs ps setup clean

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Initialize environment file from example (e.g., make setup ENV=stg)
	@if [ ! -f $(ENV_FILE) ]; then \
		cp .env.example $(ENV_FILE); \
		echo "✅ Created $(ENV_FILE). Please edit it with your secrets."; \
	else \
		echo "⚠️  $(ENV_FILE) already exists."; \
	fi

up: ## Start the agent for the specified environment
	@echo "🚀 Starting Hermes Agent ($(ENV))..."
	ENV=$(ENV) docker compose -p $(PROJECT_NAME) --env-file $(ENV_FILE) up -d --build

down: ## Stop the agent for the specified environment
	@echo "🛑 Stopping Hermes Agent ($(ENV))..."
	ENV=$(ENV) docker compose -p $(PROJECT_NAME) --env-file $(ENV_FILE) down

restart: ## Restart the hermes service
	@echo "🔄 Restarting Hermes Agent ($(ENV))..."
	ENV=$(ENV) docker compose -p $(PROJECT_NAME) --env-file $(ENV_FILE) restart hermes

logs: ## Follow logs for the specified environment
	ENV=$(ENV) docker compose -p $(PROJECT_NAME) --env-file $(ENV_FILE) logs -f hermes

ps: ## Check status of the agent
	ENV=$(ENV) docker compose -p $(PROJECT_NAME) --env-file $(ENV_FILE) ps

pair: ## View the WhatsApp pairing QR code (reliable)
	@echo "🔍 Waiting for QR code in bridge log..."
	@tail -n 50 -f data/hermes-$(ENV)/platforms/whatsapp/bridge.log

clean: ## Remove redundant artifacts from data folder (use with caution)
	@echo "🧹 Cleaning up redundant artifacts in data/hermes-$(ENV)..."
	rm -rf data/hermes-$(ENV)/skills data/hermes-$(ENV)/SOUL.md
