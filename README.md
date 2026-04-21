# Hermes Agent Docker Setup with WhatsApp Integration

This Docker setup allows you to run Hermes Agent with WhatsApp integration using OpenRouter as the LLM provider.

## Prerequisites

1. Docker and Docker Compose installed
2. An OpenRouter API key (get one at https://openrouter.ai)
3. A phone number for WhatsApp (can use Google Voice, prepaid SIM, or VoIP service)
4. Node.js v18+ on your host machine (required for WhatsApp QR code pairing)

## Quick Start

### 1. Configure Environment Variables

Copy the example environment file and edit it:

```bash
cp .env.example .env
```

Edit `.env` and set:
- `OPENROUTER_API_KEY=your_api_key_here`
- `WHATSAPP_ENABLED=true`
- `WHATSAPP_MODE=bot` (or `self-chat`)
- `WHATSAPP_ALLOWED_USERS=*` (or specific phone numbers)

### 2. Build and Start the Container

```bash
docker compose up -d --build
```

### 3. Pair WhatsApp (First Time Setup)

Run the WhatsApp pairing command:

```bash
./scripts/pair-whatsapp.sh
```

This will display a QR code in your terminal. Scan it with WhatsApp:
1. Open WhatsApp on your phone
2. Go to Settings → Linked Devices
3. Tap "Link a Device"
4. Point your camera at the terminal QR code

### 4. Verify the Service

Check the logs:

```bash
docker compose logs -f hermes
```

## Usage

Once paired, the gateway will automatically start and handle WhatsApp messages.

### Sending Messages

Simply send a message to your configured WhatsApp number, and Hermes will respond.

### Stopping the Service

```bash
docker compose down
```

### Restarting the Service

```bash
docker compose restart
```

## File Structure

```
.
├── docker-compose.yml          # Docker Compose configuration
├── .env.example                # Example environment variables
├── config.yaml                 # Hermes configuration
├── scripts/
│   ├── pair-whatsapp.sh        # WhatsApp pairing script
│   └── check-status.sh         # Status check script
└── data/                       # Persistent data directory (created automatically)
    └── hermes/                 # Hermes session and config data
```

## Configuration

### Environment Variables (.env)

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENROUTER_API_KEY` | Your OpenRouter API key | Required |
| `WHATSAPP_ENABLED` | Enable WhatsApp integration | `true` |
| `WHATSAPP_MODE` | `bot` or `self-chat` | `bot` |
| `WHATSAPP_ALLOWED_USERS` | Allowed phone numbers (comma-separated) or `*` for all | `*` |
| `HERMES_MODEL` | Model to use via OpenRouter | `nousresearch/hermes-3-llama-3.1-70b` |

### Hermes Configuration (config.yaml)

You can customize agent behavior in `config.yaml`. See the [Hermes documentation](https://hermes-agent.nousresearch.com/docs/) for details.

## Troubleshooting

### QR Code Not Showing

Make sure your terminal supports Unicode and is at least 60 columns wide.

### Session Lost

If the session is lost, re-run the pairing script:

```bash
./scripts/pair-whatsapp.sh
```

### Check Logs

```bash
docker compose logs -f hermes
```

### View Gateway Status

```bash
./scripts/check-status.sh
```

## Security Notes

- Keep your `.env` file secure and never commit it to version control
- The WhatsApp session credentials are stored in `data/hermes/platforms/whatsapp/session`
- Use a dedicated phone number for the bot to isolate risk
- Set appropriate access controls with `WHATSAPP_ALLOWED_USERS`

## Updating

To update to the latest Hermes version:

```bash
docker compose pull
docker compose up -d
```

## License

MIT License - See LICENSE file for details
