# EC2 WhatsApp MCP Server

This directory contains a custom MCP (Model Context Protocol) server for managing WhatsApp bot instances running on an EC2 remote server.

## Overview

The `ec2-whatsapp-mcp` server provides two tools:

1. **`view_whatsapp_bots`** - View running WhatsApp bot processes on EC2
2. **`update_whatsapp_bot`** - Update/restart a WhatsApp bot instance

## Architecture

```
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│  Hermes Agent   │────▶│  ec2-whatsapp-mcp    │────▶│   EC2 Instance  │
│  (WhatsApp Bot) │     │  (Docker Container)  │ SSH │  (Remote Host)  │
└─────────────────┘     └──────────────────────┘     └─────────────────┘
```

## Files

- `index.js` - Main MCP server implementation
- `package.json` - Node.js dependencies
- `Dockerfile` - Docker container configuration

## Configuration

The server requires the following environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `EC2_HOST` | EC2 instance hostname or IP | **Required** |
| `EC2_USER` | SSH username | `ec2-user` |
| `EC2_KEY_FILE` | Path to PEM key file inside container | `/opt/keys/ec2-whatsapp.pem` |

## Tools

### view_whatsapp_bots

View running WhatsApp bot processes on the EC2 instance.

**Parameters:**
- `environment` (optional): Filter by environment (`stg` or `prd`). If not specified, shows all environments.

**Example:**
```json
{
  "name": "view_whatsapp_bots",
  "arguments": {
    "environment": "prd"
  }
}
```

### update_whatsapp_bot

Update/restart a WhatsApp bot instance. This removes the old script, deploys the new version, and starts the bot.

**Parameters:**
- `environment` (required): Target environment (`stg` or `prd`)
- `mobile` (required): Phone number with country code, no `+` prefix (e.g., `6587654321`)
- `email` (required): Email associated with the bot account

**Example:**
```json
{
  "name": "update_whatsapp_bot",
  "arguments": {
    "environment": "stg",
    "mobile": "6587654321",
    "email": "bot@example.com"
  }
}
```

## Remote Scripts

The server executes the following scripts on the EC2 instance at `/home/ec2-user/scripts/`:

- `view.sh [env]` - List running WhatsApp bot processes
- `update.sh -env=<env> -mobile=<number> -email=<email>` - Update and restart a bot

## Usage in Hermes

Once configured in your `config-*.yaml` file, enable the tools for WhatsApp:

```bash
docker compose run --rm hermes tools enable whatsapp ec2-whatsapp:*
```

Then you can use natural language commands like:

- "Show me all running WhatsApp bots"
- "Check production WhatsApp bots"
- "Update the staging bot for mobile 6587654321 with email bot@example.com"

## Security Notes

- The PEM key file is mounted as read-only in the container
- SSH uses `StrictHostKeyChecking=no` and `BatchMode=yes` for automated connections
- Ensure your EC2 security group allows SSH access from the Docker network

## Development

To test locally:

```bash
export EC2_HOST=your-ec2-host
export EC2_USER=ec2-user
export EC2_KEY_FILE=/path/to/key.pem

npm install
node index.js
```
