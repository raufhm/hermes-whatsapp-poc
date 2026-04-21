#!/bin/bash

# Stop Service Script for Hermes Agent
# This script stops the Hermes Agent service

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "Hermes Agent - Stopping Service"
echo "========================================="
echo ""

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Error: Docker is not running or not accessible"
    exit 1
fi

echo "Stopping Hermes Agent..."
echo ""

# Stop the container
docker compose -f "$PROJECT_DIR/docker-compose.yml" down

echo ""
echo "========================================="
echo "✅ Service stopped successfully!"
echo "========================================="
echo ""
echo "Note: Your WhatsApp session and configuration are preserved."
echo "To start again, run:"
echo "  $SCRIPT_DIR/start-service.sh"
echo ""
