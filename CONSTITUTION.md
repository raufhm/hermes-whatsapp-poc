# Project Constitution

## Purpose

This repository extends the Hermes Agent framework to provide secure, AI-driven management of WhatsApp bot instances running on remote EC2 infrastructure using Spec-Driven Development principles.

## Spec-Driven Development Framework

### Specification Hierarchy

```
SKILL.md (Capability Spec)
    ↓
MCP Server Implementation
    ↓
Configuration & Environment
    ↓
Verification & Testing
```

### Core Artifacts

#### 1. Skill Specifications (`skills/*/SKILL.md`)

Every capability must be defined by a specification file before implementation:

**Required Sections:**
- **Metadata**: name, version, risk level, description, tags
- **When to Use**: Clear use cases and anti-patterns
- **Procedure**: Step-by-step operational workflow
- **Environment Variables**: Required configuration with prompts
- **Pitfalls**: Known issues and mitigation strategies
- **Verification**: Success criteria and validation steps

**Example Structure:**
```markdown
---
name: skill-name
version: 1.0.0
risk: safe|medium|high
description: Clear capability description
---

# Skill Name

## When to Use
## Overview  
## Prerequisites
## Procedure
## Workflow Summary
## Pitfalls
## Verification
## Environment Variables
```

#### 2. MCP Server Implementations (`mcp-servers/*/`)

Each MCP server implements exactly one skill specification:

**Required Components:**
- `server.py` or `index.js`: Main server implementation
- `tools/`: Individual tool implementations matching spec procedures
- `README.md`: Implementation notes and testing instructions

**Implementation Rules:**
- Tools must map directly to procedures in SKILL.md
- Input validation must match spec requirements
- Error messages must reference spec pitfalls
- No functionality outside spec scope

#### 3. Configuration Files

**Environment-Specific Configs:**
- `config-dev.yaml`: Development environment
- `config-stg.yaml`: Staging environment  
- `config-prd.yaml`: Production environment

**Configuration Standards:**
- All sensitive values parameterized via `${VAR_NAME}`
- MCP servers reference skill names from specs
- Environment variables documented in SKILL.md

#### 4. Environment Variables (`.env*`)

**Variable Management:**
- Template file: `.env.example` (committed)
- Actual files: `.env`, `.env.dev`, `.env.stg`, `.env.prd` (gitignored)
- All variables referenced in SKILL.md must have prompts

## Development Workflow

### Phase 1: Specification

1. **Identify Capability**: Define what the agent should do
2. **Risk Assessment**: Classify as safe/medium/high
3. **Write SKILL.md**: Complete specification following template
4. **Review**: Validate clarity, completeness, and safety

### Phase 2: Implementation

1. **Create MCP Server**: Scaffold `mcp-servers/<skill-name>/`
2. **Implement Tools**: Code each procedure from spec
3. **Add Configuration**: Update config files with MCP server
4. **Document Setup**: Create integration guide if needed

### Phase 3: Verification

1. **Unit Testing**: Test each tool independently
2. **Integration Testing**: Verify end-to-end workflow
3. **Spec Compliance**: Ensure implementation matches spec
4. **Security Review**: Validate secrets handling

### Phase 4: Deployment

1. **Enable Skill**: `hermes tools enable <persona> <skill>:*`
2. **Monitor**: Track usage and errors
3. **Iterate**: Update spec and implementation based on feedback

## Risk Classification System

| Level | Definition | Examples | Approval |
|-------|------------|----------|----------|
| **Safe** | Read-only operations, no state changes | View logs, check status, list processes | Auto-approved |
| **Medium** | Reversible state changes | Restart services, update configs, deploy with rollback | Team lead review |
| **High** | Irreversible operations, production impact | Delete data, modify infrastructure, security changes | Security + team approval |

## Technical Standards

### Code Organization

```
/workspace
├── CONSTITUTION.md          # This document
├── README.md                # Quick start guide
├── README-<FEATURE>.md      # Feature-specific guides
├── skills/                  # Skill specifications
│   └── <skill-name>/
│       ├── SKILL.md         # Canonical specification
│       └── references/      # Supporting documentation
├── mcp-servers/             # MCP implementations
│   └── <skill-name>/
│       ├── server.py        # Server implementation
│       └── tools/           # Tool implementations
├── config-*.yaml            # Environment configs
├── .env.example             # Environment template
├── keys/                    # SSH keys (gitignored)
└── scripts/                 # Utility scripts
```

### Documentation Standards

**README.md**: 
- Quick start only (5-minute setup)
- Link to detailed guides
- No implementation details

**Feature Guides** (`README-*.md`):
- Complete setup instructions
- Architecture overview
- Troubleshooting section
- Security considerations

**SKILL.md**:
- Authoritative specification
- Implementation-agnostic
- User-facing procedures

### Security Requirements

1. **No Hardcoded Secrets**: All credentials via environment variables
2. **Key Isolation**: SSH keys in gitignored directories, read-only mounts
3. **Least Privilege**: MCP servers execute only specified scripts
4. **Audit Trail**: Log all remote operations
5. **Environment Separation**: Isolated configs per environment

## Governance

### Decision Authority

- **Architecture**: Technical lead
- **Security**: Security reviewer + team consensus
- **Specifications**: Author maintains, team reviews
- **Operations**: On-call engineer with team support

### Change Management

**Specification Changes**:
1. Update SKILL.md with new version
2. Document breaking changes
3. Implement migration path if needed
4. Deprecate old version after transition period

**Implementation Changes**:
1. Must remain within spec scope
2. Breaking changes require spec update first
3. Backward compatibility preferred

**Configuration Changes**:
1. Test in dev environment first
2. Document in changelog
3. Update .env.example if adding variables

## Quality Metrics

1. **Spec Coverage**: 100% of capabilities have SKILL.md
2. **Implementation Fidelity**: Tools match spec procedures exactly
3. **Security Compliance**: Zero hardcoded secrets, all keys isolated
4. **Documentation Completeness**: Users can setup in <15 minutes
5. **Operational Reliability**: >99% successful operation rate

## Revision History

- **v1.0.0**: Initial constitution
  - Spec-driven development framework
  - Skill specification template
  - Risk classification system
  - EC2 WhatsApp integration (reference implementation)
