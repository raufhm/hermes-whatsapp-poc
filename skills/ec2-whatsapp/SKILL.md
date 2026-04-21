---
name: ec2-whatsapp
version: 1.0.0
risk: safe
description: View and manage WhatsApp bot instances running on EC2 remote server
metadata:
  hermes:
    tags: [whatsapp, ec2, ssh, automation]
    category: devops
    requires_toolsets: [terminal]
required_environment_variables:
  - name: EC2_HOST
    prompt: EC2 instance hostname or IP address
    help: The public IP or DNS name of your EC2 instance running WhatsApp bots
    required_for: full functionality
  - name: EC2_USER
    prompt: EC2 SSH username
    help: SSH username for EC2 (e.g., ec2-user, ubuntu)
    default: ec2-user
    required_for: full functionality
  - name: EC2_KEY_FILE
    prompt: Path to EC2 PEM key file
    help: Full path to your EC2 private key file (e.g., /workspace/keys/ec2-whatsapp.pem)
    required_for: full functionality
---

# EC2 WhatsApp Bot Management

## When to Use

Use this skill when you need to:
- Check which WhatsApp bot processes are running on the remote EC2 instance
- Deploy or update a WhatsApp bot instance for a specific phone number
- Restart a bot that has stopped or is malfunctioning
- Verify bot deployment after an update

Do NOT use this skill for:
- Managing local WhatsApp processes (bots run only on EC2)
- Direct SSH access outside the defined scripts
- Modifying EC2 infrastructure or system configuration

## Overview

WhatsApp bot instances run on a remote EC2 instance under `/home/ec2-user/scripts/`. This skill provides safe, scripted access to manage these bots through predefined shell scripts.

## Prerequisites

- Target directory on EC2: `/home/ec2-user/scripts/`
- Required scripts must exist on EC2:
  - `view.sh` — list running WhatsApp bot processes
  - `update.sh` — remove old bot script, update with new, start bot
  - `setup.sh` — configure bot environment (called internally by update.sh)
  - `start.sh` — launch bot instance (called internally by update.sh)

## Procedure

### Step 1: Check Current State

Before making any changes, always check what's currently running:

```bash
ssh -i $EC2_KEY_FILE $EC2_USER@$EC2_HOST "cd /home/ec2-user/scripts && ./view.sh"
```

Filter by environment:

```bash
# Production only
ssh -i $EC2_KEY_FILE $EC2_USER@$EC2_HOST "cd /home/ec2-user/scripts && ./view.sh prd"

# Staging only
ssh -i $EC2_KEY_FILE $EC2_USER@$EC2_HOST "cd /home/ec2-user/scripts && ./view.sh stg"
```

Output shows:
- Process count per environment (prd/stg)
- Full `ps -aux` listing of WhatsApp processes

### Step 2: Gather Required Information

Before updating a bot, collect from the user:
- **Environment** (`env`): `stg` or `prd` (default: `prd`)
- **Mobile number**: Phone number with country code, no `+` prefix (e.g., `6587654321`)
- **Email**: Email associated with the bot account

Always confirm these values with the user before proceeding.

### Step 3: Update/Restart the Bot

Deploy the updated bot using the wrapper script:

```bash
ssh -i $EC2_KEY_FILE $EC2_USER@$EC2_HOST "cd /home/ec2-user/scripts && \
  ./update.sh -env=<stg|prd> -mobile=<country-code+number> -email=<bot-email>"
```

Example:

```bash
ssh -i $EC2_KEY_FILE $EC2_USER@$EC2_HOST "cd /home/ec2-user/scripts && \
  ./update.sh -env=stg -mobile=6587654321 -email=bot@example.com"
```

Required flags:
- `-env` — environment: `stg` or `prd`
- `-mobile` — phone number with country code (no `+` prefix)
- `-email` — email associated with the bot account

### Step 4: Verify Bot Started

After the update completes, verify the new process is running:

```bash
ssh -i $EC2_KEY_FILE $EC2_USER@$EC2_HOST "cd /home/ec2-user/scripts && ./view.sh"
```

Confirm the new process appears in the output with the correct mobile number and environment.

## Workflow Summary

1. **Check current state** → Run `view.sh [stg|prd]` to see existing processes
2. **Gather parameters** → Ask user for env (default: prd), mobile, email
3. **Update/restart bot** → Run `update.sh -env=... -mobile=... -email=...`
4. **Verify running** → Run `view.sh [env]` and confirm new process in output

## Pitfalls

- **Never call `setup.sh` or `start.sh` directly** — always use `update.sh` which handles both in the correct sequence
- **Mobile number format** — Do not include the `+` prefix (use `6587654321`, not `+6587654321`)
- **SSH key permissions** — Ensure the PEM file has restricted permissions (chmod 600)
- **Network connectivity** — Verify SSH access to EC2 before attempting operations
- **Process conflicts** — `update.sh` removes old scripts before deploying new ones; don't interrupt mid-execution

## Verification

After completing an update, confirm success by:

1. Running `view.sh [env]` and checking for the new process
2. Verifying the process shows the correct mobile number
3. Checking that the process is in running state (not zombie or defunct)
4. Optionally, send a test message to the bot to confirm responsiveness

## Environment Variables

The following environment variables must be configured:

| Variable | Description | Example |
|----------|-------------|---------|
| `EC2_HOST` | EC2 instance hostname or IP | `54.123.45.67` or `ec2-54-123-45-67.ap-southeast-1.compute.amazonaws.com` |
| `EC2_USER` | SSH username | `ec2-user` or `ubuntu` |
| `EC2_KEY_FILE` | Path to PEM private key | `/workspace/keys/ec2-whatsapp.pem` |

Set these in `~/.hermes/.env` or via `hermes setup` when prompted.
