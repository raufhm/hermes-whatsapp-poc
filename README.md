# Hermes WhatsApp Agent

A lightweight, Docker-native setup for running the [Hermes Agent](https://hermes-agent.nousresearch.com/) with WhatsApp integration using OpenRouter LLMs.

## 🚀 Quick Start

### 1. Initial Setup
Initialize your environment file (defaults to `dev`):
```bash
make setup ENV=dev
```
Edit the newly created `.env.dev` file and add your `OPENROUTER_API_KEY`.

### 2. Pair WhatsApp
Run the pairing script for your environment:
```bash
make pair ENV=dev
```
*Note: Press [Enter] once when prompted to "Update allowed users".*

### 3. Start Service
Launch the agent in the background:
```bash
make start ENV=dev
```

## 🌍 Environment Support

You can manage multiple isolated environments (e.g., `dev`, `stg`, `prd`) by appending `ENV=<name>` to any `make` command.

- **Isolated Config**: Uses `config-<name>.yaml`
- **Isolated Secrets**: Uses `.env.<name>`
- **Isolated Data**: Stores sessions in `data/hermes-<name>/`

**Examples:**
- `make start ENV=prd`: Start the production agent.
- `make logs ENV=stg`: View logs for the staging agent.
- `make status ENV=dev`: Check status of the development agent.

## 🛠️ Management Commands

Use the provided `Makefile` for easy management:

| Command | Description |
| :--- | :--- |
| `make status` | Check if the agent is running and paired |
| `make logs` | View real-time agent activity and chat logs |
| `make stop` | Stop the background service |
| `make restart`| Restart the service after config changes |
| `make clean` | **Reset everything**: Deletes ALL environment data and stops containers |

## ⚙️ Configuration

### Environment (`.env`)
| Variable | Description | Default |
| :--- | :--- | :--- |
| `OPENROUTER_API_KEY` | Your OpenRouter API key | **Required** |
| `WHATSAPP_MODE` | `bot` (separate number) or `self-chat` | `bot` |
| `HERMES_MODEL` | The LLM to use via OpenRouter | `hermes-3-llama-3.1-70b` |

### Customizing Behavior (`config.yaml`)
Edit `config.yaml` to change the agent's personality, reasoning levels, or to add **MCP Tools**. Examples for adding Google Maps, GitHub, or SQLite tools are included as comments at the bottom of the file.

## 📂 Project Structure
- `config.yaml`: Core agent behavior and MCP tool settings.
- `Makefile`: Standard interface for all operations.
- `scripts/`: Internal automation for Docker operations.
- `data/`: (**Ignored by Git**) Stores your encrypted WhatsApp session and logs.

## 🛡️ Security
- Your `.env` and `data/` folder contain sensitive session keys; they are automatically ignored by git.
- WhatsApp sessions are stored locally in the `data/` volume.
- Use `WHATSAPP_ALLOWED_USERS` in `.env` to restrict who can talk to your bot.
