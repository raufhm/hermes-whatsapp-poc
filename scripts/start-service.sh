#!/bin/bash

# Start Service Script for Hermes Agent
# This script starts the Hermes Agent service with WhatsApp integration

set -e

# Default environment to dev if not set
ENV="${ENV:-dev}"
ENV_FILE=".env.${ENV}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "Hermes Agent - Starting Service ($ENV)"
echo "========================================="
echo ""

# Check if .env file exists
if [ ! -f "$PROJECT_DIR/$ENV_FILE" ]; then
    echo "❌ Error: $ENV_FILE not found!"
    echo ""
    echo "Please run: make setup ENV=$ENV"
    echo ""
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Error: Docker is not running or not accessible"
    exit 1
fi

echo "Starting Hermes Agent ($ENV)..."
echo ""

# Build and start the container
docker compose -p "hermes-$ENV" --env-file "$PROJECT_DIR/$ENV_FILE" -f "$PROJECT_DIR/docker-compose.yml" up -d

echo ""
echo "========================================="
echo "✅ Service started successfully!"
echo "========================================="
echo ""
echo "To view logs, run:"
echo "  make logs ENV=$ENV"
echo ""
echo "To check status, run:"
echo "  make status ENV=$ENV"
echo ""
