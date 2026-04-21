#!/bin/bash

# WhatsApp Pairing Script for Hermes Agent
# This script runs the hermes whatsapp command to pair with WhatsApp

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "Hermes Agent - WhatsApp Pairing"
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

echo "Starting WhatsApp pairing process..."
echo ""
echo "Instructions:"
echo "1. A QR code will appear below"
echo "2. Open WhatsApp on your phone"
echo "3. Go to Settings → Linked Devices"
echo "4. Tap 'Link a Device'"
echo "5. Point your camera at the QR code"
echo ""
echo "If the QR code doesn't appear or expires, the command will refresh it."
echo ""
echo "-----------------------------------------"
echo ""

# Run the WhatsApp pairing command inside the container
docker compose -f "$PROJECT_DIR/docker-compose.yml" exec -T hermes hermes whatsapp

echo ""
echo "-----------------------------------------"
echo ""
echo "✅ Pairing complete!"
echo ""
echo "You can now start the gateway with:"
echo "  docker compose up -d"
echo ""
echo "Or check the status with:"
echo "  $SCRIPT_DIR/check-status.sh"
echo ""
