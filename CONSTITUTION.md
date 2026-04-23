# Project Constitution

## Purpose

This repository extends the Hermes Agent framework to provide secure, AI-driven management of WhatsApp bot instances running on remote EC2 infrastructure. We strictly adhere to **Spec-Driven Development** using the official Hermes Skill specification.

## Spec-Driven Development Framework

### Specification-First Principle
Every capability MUST be defined in a `SKILL.md` file before any code is written or tools are configured. The `SKILL.md` is the "source of truth" for both the developer and the Agent.

### Core Artifacts

#### 1. Skill Specifications (`artifacts/skills/*/SKILL.md`)
All skills must follow the official directory structure and schema.
- **Canonical Path**: `artifacts/skills/<name>/SKILL.md`
- **Automation**: Bind-mounted from `artifacts/skills/` to `/opt/artifacts/skills` in the container.
- **Loading**: Merged with any existing skills in the persistent data volume via the `external_dirs` configuration in the agent's config.

#### 2. Agent Identity (`artifacts/soul/SOUL.md`)
The agent's "voice" and personality are defined in the central `artifacts/soul/SOUL.md`.
- **Purpose**: Defines durable personality traits, tone, and behavioral logic.
- **Management**: Mounted from `artifacts/soul/SOUL.md` to `/opt/data/SOUL.md` in the container.
- **Guidelines**: Follow the [official Personality Documentation](https://hermes-agent.nousresearch.com/docs/user-guide/features/personality).

#### 3. Environment Configuration (`artifacts/config/config-<env>.yaml`)
Environment-specific agent settings are stored in the central `artifacts/config/` directory.
- **Purpose**: Controls agent behavior, enabled platforms, and MCP server settings for different environments (`dev`, `stg`, `prd`).
- **Management**: Mounted from `artifacts/config/config-<env>.yaml` to `/opt/data/config.yaml` in the container.

## Technical Standards

### Code Organization
```
/workspace
├── CONSTITUTION.md          # This document
├── README.md                # Quick start and high-level overview
├── Makefile                 # Primary automation interface
├── artifacts/               # Core agent assets (Bind-mounted)
│   ├── config/              # Environment-specific settings
│   ├── skills/              # Operational capabilities
│   └── soul/                # Durable identity (SOUL.md)
├── docker-compose.yml       # Service configuration
├── .env.example             # Environment template
└── data/                    # Persistent storage (Gitignored)
```

### Automation Standards
- **Makefile**: Use for all lifecycle operations (`up`, `down`, `restart`, `logs`, `ps`, `pair`).
- **Environment Targeting**: Use the `ENV` variable to target environments (e.g., `ENV=prd make up`).
- **Development Sync**: Bind mounts ensure changes to artifacts are instantly available to the agent upon restart.
- **Credentials**: Securely provided via local absolute paths in `.env` files (e.g., `EC2_KEY_PATH`).

## Revision History
- **v3.0.0**: Major restructuring and automation overhaul.
  - Aligned with official Hermes Agent Skill documentation and schema.
  - Centralized all agent assets (config, skills, soul) into the `artifacts/` directory.
  - Implemented a parameterized `Makefile` for multi-environment lifecycle management.
  - Automated artifact synchronization via Docker bind mounts (merging without shadowing).
- **v2.0.0**: Simplified architecture - SSH-based implementation via MCP.
- **v1.0.0**: Initial constitution.
