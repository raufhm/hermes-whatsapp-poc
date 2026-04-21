# EC2 WhatsApp Scripts Reference

This directory contains reference documentation for the shell scripts that run on the EC2 instance.

## Script Locations

All scripts are located at: `/home/ec2-user/scripts/` on the EC2 instance.

## Available Scripts

### view.sh

Lists all running WhatsApp bot processes.

**Usage:**
```bash
./view.sh [env]
```

**Parameters:**
- `env` (optional): Filter by environment (`stg` or `prd`). If omitted, shows all environments.

**Output:**
- Process count per environment
- Full `ps -aux` listing of WhatsApp processes

---

### update.sh

Main deployment script that removes old bot scripts, updates with new version, and starts the bot.

**Usage:**
```bash
./update.sh -env=<stg|prd> -mobile=<number> -email=<email>
```

**Required Parameters:**
- `-env`: Environment (`stg` or `prd`)
- `-mobile`: Phone number with country code, no `+` prefix (e.g., `6587654321`)
- `-email`: Email associated with the bot account

**Internal Flow:**
1. Removes existing bot script for the specified mobile number
2. Calls `setup.sh` to configure the environment
3. Calls `start.sh` twice with 2-second delay for auto-check

**Do NOT call setup.sh or start.sh directly** — always use this wrapper.

---

### setup.sh

Configures the bot environment. Called internally by `update.sh`.

**Do not call directly.**

---

### start.sh

Launches a bot instance. Called internally by `update.sh` (twice).

**Do not call directly.**

---

## Example Session

```bash
# Check what's running
ssh ec2-user@<host> "cd /home/ec2-user/scripts && ./view.sh prd"

# Update a staging bot
ssh ec2-user@<host> "cd /home/ec2-user/scripts && \
  ./update.sh -env=stg -mobile=6587654321 -email=bot@example.com"

# Verify it started
ssh ec2-user@<host> "cd /home/ec2-user/scripts && ./view.sh stg"
```

## Troubleshooting

### Bot not appearing after update
1. Run `view.sh` without filters to see all processes
2. Check SSH command output for errors during `update.sh` execution
3. Verify the mobile number format (no `+` prefix)

### Permission denied errors
Ensure scripts have execute permissions on EC2:
```bash
chmod +x /home/ec2-user/scripts/*.sh
```

### Process starts then stops
Check logs in the bot's working directory on EC2 for error messages.
