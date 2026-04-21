#!/bin/bash

# Status Check Script for Hermes Agent
# This script checks the status of the Hermes Agent service

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "Hermes Agent - Status Check"
echo "========================================="
echo ""

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Error: Docker is not running or not accessible"
    exit 1
fi

# Check if container exists and is running
CONTAINER_STATUS=$(docker inspect -f '{{.State.Status}}' hermes-agent 2>/dev/null || echo "not_found")

echo "Container Status: $CONTAINER_STATUS"
echo ""

if [ "$CONTAINER_STATUS" = "running" ]; then
    echo "✅ Hermes Agent is running!"
    echo ""
    
    # Show recent logs
    echo "Recent logs (last 20 lines):"
    echo "-----------------------------------------"
    docker logs --tail 20 hermes-agent 2>&1
    echo "-----------------------------------------"
    echo ""
    
    # Check if WhatsApp is enabled
    echo "Checking WhatsApp configuration..."
    docker exec hermes-agent bash -c "hermes config show 2>/dev/null || echo 'Config command not available'" 2>/dev/null || true
    echo ""
    
    # Show how to view full logs
    echo "To view full logs, run:"
    echo "  docker compose logs -f hermes"
    echo ""
    
    # Show how to stop
    echo "To stop the service, run:"
    echo "  docker compose down"
    echo ""
    
elif [ "$CONTAINER_STATUS" = "exited" ]; then
    echo "⚠️  Hermes Agent container exists but is not running"
    echo ""
    echo "Last exit code: $(docker inspect -f '{{.State.ExitCode}}' hermes-agent 2>/dev/null)"
    echo ""
    echo "Recent logs:"
    echo "-----------------------------------------"
    docker logs --tail 30 hermes-agent 2>&1
    echo "-----------------------------------------"
    echo ""
    echo "To restart the service, run:"
    echo "  docker compose up -d"
    echo ""
    
elif [ "$CONTAINER_STATUS" = "not_found" ]; then
    echo "⚠️  Hermes Agent container not found"
    echo ""
    echo "To start the service for the first time, run:"
    echo "  docker compose up -d --build"
    echo ""
fi

# Check if .env file exists
if [ -f "$PROJECT_DIR/.env" ]; then
    echo "✅ Configuration file (.env) found"
else
    echo "⚠️  Configuration file (.env) not found"
    echo "   Please copy .env.example to .env and configure it"
fi

# Check if WhatsApp session exists
if [ -d "$PROJECT_DIR/data/hermes/platforms/whatsapp/session" ]; then
    echo "✅ WhatsApp session found"
else
    echo "⚠️  WhatsApp session not found - pairing required"
    echo "   Run: $SCRIPT_DIR/pair-whatsapp.sh"
fi

echo ""
echo "========================================="
