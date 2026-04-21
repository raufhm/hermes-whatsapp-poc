# Hermes WhatsApp Agent

A lightweight, Docker-native setup for running the [Hermes Agent](https://hermes-agent.nousresearch.com/) with WhatsApp integration using OpenRouter LLMs and EC2 bot management via SSH.

## Quick Start

### 1. Initial Setup
Create your environment file:
```bash
cp .env.example .env
```
Edit `.env` and add your `OPENROUTER_API_KEY` and EC2 configuration (see Configuration section).

### 2. Place EC2 SSH Key
Copy your EC2 PEM key to the keys directory:
```bash
mkdir -p keys
cp /path/to/your/key.pem keys/ec2-whatsapp.pem
chmod 600 keys/ec2-whatsapp.pem
```

### 3. Pair WhatsApp
Start the service and follow pairing instructions:
```bash
docker compose up -d
docker compose logs -f hermes
```
*Note: Press [Enter] once when prompted to "Update allowed users".*

### 4. Enable EC2 WhatsApp Skill
Enable the skill for managing WhatsApp bots on EC2:
```bash
docker compose run --rm hermes tools enable whatsapp ec2-whatsapp:*
```

## Environment Support

You can manage multiple isolated environments (e.g., `dev`, `stg`, `prd`) using different config files:

- **Isolated Config**: Uses `config-<name>.yaml`
- **Isolated Secrets**: Uses `.env.<name>`
- **Isolated Data**: Stores sessions in `data/hermes-<name>/`

Set `ENV` variable in docker-compose command:
```bash
ENV=prd docker compose up -d
```

## Management Commands

| Command | Description |
| :--- | :--- |
| `docker compose up -d` | Start the agent in background |
| `docker compose logs -f` | View real-time agent activity |
| `docker compose down` | Stop the service |
| `docker compose restart` | Restart after config changes |
| `docker compose ps` | Check if agent is running |

## Configuration

### Environment (`.env`)
| Variable | Description | Default |
| :--- | :--- | :--- |
| `OPENROUTER_API_KEY` | Your OpenRouter API key | **Required** |
| `WHATSAPP_MODE` | `bot` (separate number) or `self-chat` | `bot` |
| `HERMES_MODEL` | The LLM to use via OpenRouter | `hermes-3-llama-3.1-70b` |
| `EC2_HOST` | EC2 instance IP/DNS for WhatsApp bots | **Required for EC2 features** |
| `EC2_USER` | SSH username for EC2 | `ec2-user` |
| `EC2_KEY_FILE` | Path to EC2 PEM key | `ec2-whatsapp.pem` |

### Customizing Behavior (`config.yaml`)
Edit `config.yaml` to change the agent's personality, reasoning levels, or to add **MCP Tools**. Examples for adding Google Maps, GitHub, or SQLite tools are included as comments at the bottom of the file.

## EC2 WhatsApp Integration

This project includes integration to manage WhatsApp bots on remote EC2 instances via SSH. The agent uses the `ec2-whatsapp` skill to execute remote scripts securely. See the [EC2 Integration Guide](README-EC2.md) for setup instructions.

## Project Structure

- `CONSTITUTION.md`: Project governance and development standards
- `skills/`: Skill specifications defining agent capabilities
- `config-*.yaml`: Environment-specific configurations
- `scripts/`: Helper scripts for common operations
- `data/`: (**Ignored by Git**) Stores your encrypted WhatsApp session and logs
- `keys/`: (**Ignored by Git**) SSH keys for EC2 access

## Security

- Your `.env` and `data/` folder contain sensitive session keys; they are automatically ignored by git.
- WhatsApp sessions are stored locally in the `data/` volume.
- Use `WHATSAPP_ALLOWED_USERS` in `.env` to restrict who can talk to your bot.
- SSH keys for EC2 integration are stored in `keys/` (gitignored) and mounted read-only to containers.

## Documentation

- **[CONSTITUTION.md](CONSTITUTION.md)**: Development standards and project governance
- **[README-EC2.md](README-EC2.md)**: EC2 WhatsApp integration guide via SSH
- **[skills/ec2-whatsapp/SKILL.md](skills/ec2-whatsapp/SKILL.md)**: EC2 WhatsApp capability specification
