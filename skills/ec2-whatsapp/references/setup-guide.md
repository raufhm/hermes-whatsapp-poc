# EC2 WhatsApp Skill Setup Guide

This guide walks you through setting up EC2 WhatsApp bot management in Hermes via SSH using the `ssh-ec2` tool.

## Prerequisites

- An EC2 instance running WhatsApp bot scripts at `/home/ec2-user/scripts/`
- SSH access to the EC2 instance with a PEM key file
- The following scripts must exist on EC2:
  - `view.sh`
  - `update.sh`
  - `setup.sh` (called internally)
  - `start.sh` (called internally)

## Step 1: Place Your PEM Key File

Copy your EC2 PEM file to the `keys/` directory:

```bash
cp /path/to/your/ec2-whatsapp.pem ./keys/
chmod 600 ./keys/ec2-whatsapp.pem
```

**Important:** Never commit PEM files to Git. The `.gitignore` is configured to exclude them.

## Step 2: Configure Environment Variables

Create or update your `.env` file from the example:

```bash
cp .env.example .env
```

Edit `.env` and fill in your values:

```env
# OpenRouter API Configuration
OPENROUTER_API_KEY=<your-api-key>

# EC2 Configuration for WhatsApp Bots
EC2_HOST=your-ec2-public-ip-or-dns
EC2_USER=ec2-user
EC2_KEY_FILE=ec2-whatsapp.pem
```

| Variable | Description | Example |
|----------|-------------|---------|
| `OPENROUTER_API_KEY` | Your OpenRouter API key | `sk-or-...` |
| `EC2_HOST` | EC2 public IP or DNS name | `54.123.45.67` or `ec2-54-123-45-67.ap-southeast-1.compute.amazonaws.com` |
| `EC2_USER` | SSH username | `ec2-user` (Amazon Linux) or `ubuntu` (Ubuntu) |
| `EC2_KEY_FILE` | PEM filename in keys/ directory | `ec2-whatsapp.pem` |

## Step 3: Start Docker Services

```bash
docker compose up -d
```

Verify the services are running:

```bash
docker compose ps
```

## Step 4: Use SSH-EC2 Tool

The `ssh-ec2` tool is built into Hermes and ready to use. No additional skill enablement required.

Test connectivity:
```bash
docker compose run --rm hermes ssh-ec2 "cd /home/ec2-user/scripts && ./view.sh"
```

Or use directly in chat with Hermes - the agent will automatically use SSH commands when you ask about WhatsApp bots.

## Step 5: Test with SSH-EC2

### Check Running Bots

Ask Hermes:

```
Show me all running WhatsApp bots
```

Or filter by environment:

```
Show production WhatsApp bots
Show staging WhatsApp bots
```

### Update a Bot

Provide the required information when prompted:

```
Update the WhatsApp bot for mobile 6587654321 with email bot@example.com in staging
```

The skill will:
1. Ask you to confirm the parameters (env, mobile, email)
2. Execute `update.sh` on EC2 via SSH using the ssh-ec2 tool
3. Verify the bot started successfully

## Usage Examples

### View All Bots
```
What WhatsApp bots are currently running?
```

### View Production Only
```
Show production WhatsApp bots
```

### Update Staging Bot
```
Update staging bot for 6587654321 with email test@example.com
```

### Update Production Bot (default env)
```
Restart bot 6587654321 using email prod@example.com
```

## Troubleshooting

### SSH Connection Failed

**Error:** `Permission denied (publickey)` or `Connection refused`

**Solutions:**
1. Verify the PEM file path is correct in `EC2_KEY_FILE`
2. Check file permissions: `chmod 600 ./keys/ec2-whatsapp.pem`
3. Ensure EC2 security group allows SSH (port 22) from your IP
4. Confirm EC2 instance is running

### Script Not Found

**Error:** `./view.sh: No such file or directory`

**Solution:** Verify scripts exist on EC2:
```bash
ssh -i ./keys/ec2-whatsapp.pem ec2-user@<EC2_HOST> "ls -la /home/ec2-user/scripts/"
```

### Permission Denied on Scripts

**Error:** `Permission denied`

**Solution:** Fix permissions on EC2:
```bash
ssh -i ./keys/ec2-whatsapp.pem ec2-user@<EC2_HOST> \
  "chmod +x /home/ec2-user/scripts/*.sh"
```

### Environment Variables Not Loaded

If Hermes prompts for environment variables every time:

1. Verify `.env` file exists in the project root
2. Restart Docker Compose: `docker compose down && docker compose up -d`
3. Check variable names match exactly (case-sensitive)

## Security Notes

- **Never share your PEM file** — it provides full SSH access to your EC2 instance
- **Restrict SSH access** — Configure EC2 security group to allow only necessary IPs
- **Use IAM roles** — For production, consider using IAM instance profiles instead of key-based auth
- **Rotate keys regularly** — Follow your organization's key rotation policy

## Next Steps

- Review the main [SKILL.md](../SKILL.md) for detailed procedures (reference only, use ssh-ec2 directly)
- Check [references/scripts.md](./references/scripts.md) for script documentation
- Monitor bot health regularly using the `view.sh` command via ssh-ec2 tool
