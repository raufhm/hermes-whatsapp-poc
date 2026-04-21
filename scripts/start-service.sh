#!/bin/bash

# Start Service Script for Hermes Agent
# This script starts the Hermes Agent service with WhatsApp integration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "Hermes Agent - Starting Service"
echo "========================================="
echo ""

# Check if .env file exists
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo "❌ Error: .env file not found!"
    echo ""
    echo "Please copy .env.example to .env and configure it:"
    echo "  cp $PROJECT_DIR/.env.example $PROJECT_DIR/.env"
    echo ""
    exit 1
fi

# Check if OPENROUTER_API_KEY is set
if ! grep -q "^OPENROUTER_API_KEY=" "$PROJECT_DIR/.env"; then
    echo "❌ Error: OPENROUTER_API_KEY not set in .env file!"
    echo ""
    echo "Please edit $PROJECT_DIR/.env and set your OpenRouter API key."
    echo ""
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Error: Docker is not running or not accessible"
    exit 1
fi

echo "Building and starting Hermes Agent..."
echo ""

# Build and start the container
docker compose -f "$PROJECT_DIR/docker-compose.yml" up -d --build

echo ""
echo "========================================="
echo "✅ Service started successfully!"
echo "========================================="
echo ""
echo "To view logs, run:"
echo "  docker compose logs -f hermes"
echo ""
echo "To check status, run:"
echo "  $SCRIPT_DIR/check-status.sh"
echo ""
echo "If this is your first time, you need to pair WhatsApp:"
echo "  $SCRIPT_DIR/pair-whatsapp.sh"
echo ""
