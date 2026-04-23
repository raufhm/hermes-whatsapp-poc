---
name: ec2-whatsapp
version: 1.1.0
author: Rauf
license: MIT
description: View and manage WhatsApp bot instances running on remote EC2 servers via SSH.
required_environment_variables:
  - name: EC2_HOST
    prompt: EC2 instance hostname or IP address
    help: The public IP or DNS name of your EC2 instance.
  - name: EC2_USER
    prompt: EC2 SSH username
    help: SSH username for EC2 (e.g., ec2-user, ubuntu).
  - name: EC2_KEY_FILE
    prompt: EC2 PEM key filename
    help: The name of the key file in the /opt/keys directory (e.g., ec2-whatsapp.pem).
---

# EC2 WhatsApp Bot Management

## When to Use
Use this skill when you need to manage WhatsApp bot processes running on a remote EC2 instance. 
- **Trigger**: "Check the status of the bots on EC2", "Update the bot for number 6587654321", "Restart the production bot".
- **Anti-patterns**: Do not use for local WhatsApp processes or general EC2 infrastructure management.

## Quick Reference
| Task | Command / Tool | Notes |
| :--- | :--- | :--- |
| List Processes | `ssh-ec2 "cd scripts && ./view.sh"` | Shows all running bots |
| Update/Restart | `ssh-ec2 "cd scripts && ./update.sh ..."` | Requires -env, -mobile, -email |
| Health Check | `ssh-ec2 "cd scripts && ./view.sh <env>"` | Filters by stg or prd |

## Procedure

### 1. Verification of Current State
Always start by listing the current processes to identify the target bot's status.
```bash
ssh-ec2 "cd scripts && ./view.sh"
```

### 2. Updating a Bot Instance
To deploy a new version or restart an existing bot, use the `update.sh` script.
```bash
ssh-ec2 "cd scripts && ./update.sh -env=<stg|prd> -mobile=<number> -email=<email>"
```
*Note: The mobile number should NOT include the '+' prefix.*

### 3. Final Validation
Verify the process is running and stable.
```bash
ssh-ec2 "cd scripts && ./view.sh <env>"
```

## Pitfalls
- **SSH Timeout**: Large updates might take time; ensure the SSH connection is stable.
- **Incorrect Key Path**: Ensure the PEM key is correctly mounted in `/opt/keys/`.
- **Mobile Format**: Using `+65...` instead of `65...` will cause the script to fail.

## Verification
The task is successful if:
1. The `view.sh` output contains the target mobile number and environment.
2. The process status is active (not defunct).
3. The remote script output confirms "Bot started successfully".
