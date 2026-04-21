#!/bin/bash

# Status Check Script for Hermes Agent
# This script checks the status of the Hermes Agent service

# Default environment to dev if not set
ENV="${ENV:-dev}"
ENV_FILE=".env.${ENV}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Define Docker Compose command with env-file
DOCKER_COMPOSE="docker compose --env-file $PROJECT_DIR/$ENV_FILE"

echo "========================================="
echo "Hermes Agent - Status Check ($ENV)"
echo "========================================="
echo ""

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Error: Docker is not running or not accessible"
    exit 1
fi

# Check if container exists and is running
CONTAINER_STATUS=$(docker inspect -f '{{.State.Status}}' hermes-$ENV 2>/dev/null || echo "not_found")

echo "Container Status: $CONTAINER_STATUS"
echo ""

if [ "$CONTAINER_STATUS" = "running" ]; then
    echo "✅ Hermes Agent is running!"
    echo ""
    
    # Show recent logs
    echo "Recent logs (last 20 lines):"
    echo "-----------------------------------------"
    $DOCKER_COMPOSE logs --tail 20 hermes 2>&1
    echo "-----------------------------------------"
    echo ""
    
    # Check if WhatsApp is enabled
    echo "Checking WhatsApp configuration..."
    $DOCKER_COMPOSE exec -T hermes hermes config show 2>/dev/null || echo "Config command not available or container not ready"
    echo ""
    
    # Show how to view full logs
    echo "To view full logs, run:"
    echo "  make logs ENV=$ENV"
    echo ""
    
    # Show how to stop
    echo "To stop the service, run:"
    echo "  make stop ENV=$ENV"
    echo ""
    
elif [ "$CONTAINER_STATUS" = "exited" ]; then
    echo "⚠️  Hermes Agent container exists but is not running"
    echo ""
    echo "Last exit code: $(docker inspect -f '{{.State.ExitCode}}' hermes-agent 2>/dev/null)"
    echo ""
    echo "Recent logs:"
    echo "-----------------------------------------"
    $DOCKER_COMPOSE logs --tail 30 hermes 2>&1
    echo "-----------------------------------------"
    echo ""
    echo "To restart the service, run:"
    echo "  make start ENV=$ENV"
    echo ""
    
elif [ "$CONTAINER_STATUS" = "not_found" ]; then
    echo "⚠️  Hermes Agent container not found"
    echo ""
    echo "To start the service, run:"
    echo "  make start ENV=$ENV"
    echo ""
fi

# Check if .env file exists
if [ -f "$PROJECT_DIR/$ENV_FILE" ]; then
    echo "✅ Configuration file ($ENV_FILE) found"
else
    echo "⚠️  Configuration file ($ENV_FILE) not found"
    echo "   Run: make setup ENV=$ENV"
fi

# Check if WhatsApp session exists
if [ -d "$PROJECT_DIR/data/hermes-$ENV/platforms/whatsapp/session" ]; then
    echo "✅ WhatsApp session found"
else
    echo "⚠️  WhatsApp session not found - pairing required"
    echo "   Run: make pair ENV=$ENV"
fi

echo ""
echo "========================================="
