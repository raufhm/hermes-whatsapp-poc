#!/bin/bash

# WhatsApp Pairing Script for Hermes Agent
# This script runs the hermes whatsapp command to pair with WhatsApp

set -e

# Default environment to dev if not set
ENV="${ENV:-dev}"
ENV_FILE=".env.${ENV}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "Hermes Agent - WhatsApp Pairing ($ENV)"
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

# Check if OPENROUTER_API_KEY is set
if ! grep -q "^OPENROUTER_API_KEY=" "$PROJECT_DIR/$ENV_FILE"; then
    echo "❌ Error: OPENROUTER_API_KEY not set in $ENV_FILE file!"
    echo ""
    echo "Please edit $PROJECT_DIR/$ENV_FILE and set your OpenRouter API key."
    echo ""
    exit 1
fi

echo "Starting WhatsApp pairing process..."
echo ""
echo "Instructions:"
echo "1. Press [Enter] when asked about 'Update allowed users'"
echo "2. A QR code will appear below"
echo "3. Open WhatsApp on your phone"
echo "4. Go to Settings → Linked Devices"
echo "5. Tap 'Link a Device'"
echo "6. Point your camera at the QR code"
echo ""
echo "If the QR code doesn't appear or expires, the command will refresh it."
echo ""
echo "-----------------------------------------"
echo ""

# Run the WhatsApp pairing command inside a temporary container
# We use --env-file to ensure the correct environment variables are loaded
docker compose -p "hermes-$ENV" --env-file "$PROJECT_DIR/$ENV_FILE" -f "$PROJECT_DIR/docker-compose.yml" run --rm hermes --yolo whatsapp

echo ""
echo "-----------------------------------------"
echo ""
echo "✅ Pairing complete!"
echo ""
echo "You can now start the gateway with:"
echo "  make start ENV=$ENV"
echo ""
echo "Or check the status with:"
echo "  make status ENV=$ENV"
echo ""
