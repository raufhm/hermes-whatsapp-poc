#!/bin/bash

# Stop Service Script for Hermes Agent
# This script stops the Hermes Agent service

set -e

# Default environment to dev if not set
ENV="${ENV:-dev}"
ENV_FILE=".env.${ENV}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "Hermes Agent - Stopping Service ($ENV)"
echo "========================================="
echo ""

# Check if .env file exists
if [ ! -f "$PROJECT_DIR/$ENV_FILE" ]; then
    echo "❌ Error: $ENV_FILE not found!"
    exit 1
fi

echo "Stopping Hermes Agent ($ENV)..."
echo ""

# Stop and remove the container
docker compose -p "hermes-$ENV" --env-file "$PROJECT_DIR/$ENV_FILE" -f "$PROJECT_DIR/docker-compose.yml" down

echo ""
echo "========================================="
echo "✅ Service stopped!"
echo "========================================="
echo ""
