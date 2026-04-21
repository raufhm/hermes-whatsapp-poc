# EC2 WhatsApp Integration Guide

This guide details the setup and usage of the EC2 WhatsApp Bot Management integration for the Hermes Agent.

## Overview

This integration enables the Hermes Agent to manage WhatsApp bot instances running on a remote EC2 server via SSH. It uses a dedicated MCP (Model Context Protocol) server to execute remote scripts securely.

## Architecture Components

1. **Hermes Core**: Main AI agent that receives user requests.
2. **EC2 MCP Server**: Intermediate service that handles SSH connections and script execution.
3. **Remote EC2 Instance**: Hosts the WhatsApp bot scripts (`view.sh`, `update.sh`).

## Prerequisites

- AWS EC2 instance with SSH access enabled
- PEM key file for authentication
- Remote scripts deployed at `/home/ec2-user/scripts/`:
  - `view.sh`: Lists running bot processes
  - `update.sh`: Deploys and restarts bots
- Docker and Docker Compose installed locally

## Setup Instructions

### Step 1: Environment Configuration

Create or update your `.env` file:

```bash
cp .env.example .env
```

Required variables:
```ini
EC2_HOST=<your-ec2-public-ip-or-dns>
EC2_USER=<ssh-username>  # Typically 'ec2-user' or 'ubuntu'
EC2_KEY_FILE=ec2-whatsapp.pem
```

### Step 2: SSH Key Setup

Place your PEM file in the `keys/` directory:

```bash
mkdir -p keys
cp /path/to/your/key.pem keys/ec2-whatsapp.pem
chmod 600 keys/ec2-whatsapp.pem
```

**Security Note**: The `keys/` directory is:
- Mounted read-only to containers
- Excluded from version control (`.gitignore`)
- Only accessible by the Docker daemon

### Step 3: Verify Remote Scripts

Ensure the following scripts exist on your EC2 instance at `/home/ec2-user/scripts/`:

```bash
# Test connectivity manually
ssh -i keys/ec2-whatsapp.pem ec2-user@<EC2_HOST> "ls -la /home/ec2-user/scripts/"
```

Expected output should include `view.sh` and `update.sh` with execute permissions.

### Step 4: Start Services

```bash
docker compose up -d
```

This starts both the Hermes agent and the `ec2-whatsapp-mcp` service.

### Step 5: Enable Skills

Enable the EC2 tools for your WhatsApp persona:

```bash
docker compose run --rm hermes tools enable whatsapp ec2-whatsapp:*
```

Verify enabled tools:
```bash
docker compose run --rm hermes tools list whatsapp
```

## Usage Examples

Once configured, interact naturally with the agent:

### View Running Bots
```
User: Show me all running WhatsApp bots
User: Check production bot status
User: List staging environment processes
```

### Update/Restart Bots
```
User: Update the staging bot for mobile 6587654321 with email bot@example.com
User: Restart production bot for +1234567890
```

The agent will:
1. Prompt for missing required arguments (mobile, email)
2. Default to `prd` environment unless specified
3. Execute the remote `update.sh` script via SSH
4. Verify the bot started successfully

## Available Tools

| Tool | Description | Required Arguments |
|------|-------------|-------------------|
| `view_whatsapp_bots` | Lists running WhatsApp processes | None (optional: env) |
| `update_whatsapp_bot` | Deploys and restarts a bot | env, mobile, email |

## Troubleshooting

### Connection Issues
- **Error**: `Connection refused`
  - Verify EC2 Security Group allows inbound SSH (port 22)
  - Confirm `EC2_HOST` is correct and reachable

- **Error**: `Permission denied (publickey)`
  - Check PEM file permissions: `chmod 600 keys/*.pem`
  - Verify `EC2_USER` matches your EC2 AMI default user

### Script Execution Errors
- **Error**: `script not found`
  - Confirm scripts exist at `/home/ec2-user/scripts/` on EC2
  - Ensure scripts have execute permissions: `chmod +x *.sh`

- **Error**: `update.sh failed`
  - Check remote script logs on EC2
  - Verify bot dependencies are installed on the server

### Testing Manually

Test SSH connectivity and script execution manually:

```bash
# Test view.sh
ssh -i keys/ec2-whatsapp.pem ec2-user@<EC2_HOST> \
  "cd /home/ec2-user/scripts && ./view.sh prd"

# Test update.sh (dry-run if supported)
ssh -i keys/ec2-whatsapp.pem ec2-user@<EC2_HOST> \
  "cd /home/ec2-user/scripts && ./update.sh -env=stg -mobile=6587654321 -email=test@example.com"
```

## Security Best Practices

1. **Key Management**: Never commit PEM files to version control
2. **Least Privilege**: EC2 user should only have permissions to run specific scripts
3. **Network Security**: Restrict SSH access to known IPs via Security Groups
4. **Audit Logs**: Monitor SSH access and script execution on the EC2 instance
5. **Environment Isolation**: Use separate environments (dev/stg/prd) for testing

## Maintenance

### Updating Scripts on EC2

When bot scripts are updated:

```bash
scp -i keys/ec2-whatsapp.pem new-view.sh ec2-user@<EC2_HOST>:/home/ec2-user/scripts/view.sh
ssh -i keys/ec2-whatsapp.pem ec2-user@<EC2_HOST> "chmod +x /home/ec2-user/scripts/*.sh"
```

### Rotating Keys

1. Generate new key pair in AWS Console
2. Update `.env` with new key filename
3. Place new PEM in `keys/` directory
4. Remove old PEM file
5. Restart services: `docker compose restart`

## Support

For issues related to:
- **Hermes Agent**: Refer to main [README.md](README.md)
- **EC2 Scripts**: Contact your infrastructure team
- **AWS Connectivity**: Check AWS documentation on EC2 SSH access
