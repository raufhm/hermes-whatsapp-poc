# Hermes WhatsApp Agent

A Docker-native setup for the [Hermes Agent](https://hermes-agent.nousresearch.com/) with WhatsApp integration and remote EC2 bot management.

## 🚀 Quick Start (5 Minutes)

### 1. Configure Environment
Initialize your environment file (default is `dev`):
```bash
make setup
# Edit .env.dev and add your OPENROUTER_API_KEY and EC2 details
```

### 2. Prepare SSH Keys
Place your EC2 PEM key in the `keys/` directory:
```bash
mkdir -p keys
# cp /path/to/key.pem keys/ec2-whatsapp.pem
chmod 600 keys/ec2-whatsapp.pem
```

### 3. Launch & Pair
```bash
make up
make logs
```
*Scan the QR code in the logs with your WhatsApp app.*

## 🛠 Management Commands

The project uses a **parameterized Makefile**. Default environment is `dev`.

| Command | Description |
| :--- | :--- |
| `make up` | Start dev agent |
| `ENV=prd make up` | Start production agent |
| `make restart` | Restart the agent |
| `make logs` | View real-time activity |
| `make pair` | View WhatsApp pairing QR code |
| `make ps` | Check service status |
| `make setup ENV=stg` | Prepare staging env file |

## 📂 Project Structure

- `artifacts/config/`: Environment-specific agent settings.
- `artifacts/skills/`: Operational capabilities (Bind-mounted).
- `artifacts/soul/`: Agent's durable personality (Bind-mounted).
- `CONSTITUTION.md`: Project standards and Spec-Driven principles.

## 📖 Documentation

- **[CONSTITUTION.md](CONSTITUTION.md)**: Development and automation standards.
- **[artifacts/skills/ec2-whatsapp/SKILL.md](artifacts/skills/ec2-whatsapp/SKILL.md)**: Guide for remote bot management.

---
*Built with Hermes Agent Framework*
