# Project Constitution

## Purpose

This repository extends the Hermes Agent framework to provide secure, AI-driven management of WhatsApp bot instances running on remote EC2 infrastructure using Spec-Driven Development principles.

## Spec-Driven Development Framework

### Specification Hierarchy

```
SKILL.md (Capability Spec)
    ↓
SSH Terminal Tool Configuration
    ↓
Environment Variables & Keys
    ↓
Verification & Testing
```

### Core Artifacts

#### 1. Skill Specifications (`skills/*/SKILL.md`)

Every capability must be defined by a specification file before implementation:

**Required Sections:**
- **Metadata**: name, version, risk level, description, tags
- **When to Use**: Clear use cases and anti-patterns
- **Procedure**: Step-by-step operational workflow via SSH
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

#### 2. SSH-Based Implementation

Skills are executed via the built-in SSH terminal tool, referencing SKILL.md procedures:

**Required Components:**
- `skills/<skill-name>/SKILL.md`: Complete operational specification
- SSH access configured in `.env` and docker-compose.yml
- Remote scripts on EC2 instance (e.g., `/home/ec2-user/scripts/`)

**Implementation Rules:**
- Hermes agent references SKILL.md for context and procedures
- SSH tool executes commands directly on remote EC2 instance
- All operations follow the step-by-step procedures in the spec
- Error handling and validation based on spec pitfalls
- No intermediate MCP server layer needed

#### 3. Configuration Files

**Environment-Specific Configs:**
- `docker-compose.yml`: Single service configuration with SSH settings
- `.env*`: Environment variables for SSH access and WhatsApp bridge

**Configuration Standards:**
- All sensitive values parameterized via environment variables
- SSH credentials isolated in gitignored keys directory
- Skills reference environment variables documented in SKILL.md

#### 4. Environment Variables (`.env*`)

**Variable Management:**
- Template file: `.env.example` (committed)
- Actual files: `.env`, `.env.dev`, `.env.stg`, `.env.prd` (gitignored)
- All variables referenced in SKILL.md must have prompts

## Development Workflow

### Phase 1: Specification

1. **Identify Capability**: Define what the agent should do via SSH
2. **Risk Assessment**: Classify as safe/medium/high
3. **Write SKILL.md**: Complete specification following template with SSH procedures
4. **Review**: Validate clarity, completeness, and safety

### Phase 2: Implementation

1. **Create Skill Directory**: Scaffold `skills/<skill-name>/SKILL.md`
2. **Configure SSH Access**: Add environment variables to `.env` and docker-compose.yml
3. **Deploy Remote Scripts**: Ensure scripts exist on EC2 instance at specified paths
4. **Document Setup**: Update README with skill usage examples

### Phase 3: Verification

1. **Manual Testing**: Execute procedures via SSH terminal tool
2. **Integration Testing**: Verify end-to-end workflow through Hermes agent
3. **Spec Compliance**: Ensure SSH commands match spec procedures
4. **Security Review**: Validate SSH key handling and access controls

### Phase 4: Deployment

1. **Enable Skill**: Agent automatically references SKILL.md when using SSH tool
2. **Monitor**: Track usage and errors via logs
3. **Iterate**: Update spec based on operational feedback

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
├── docker-compose.yml       # Service configuration
├── .env.example             # Environment template
├── keys/                    # SSH keys (gitignored)
└── scripts/                 # Local utility scripts
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
- SSH command procedures
- User-facing operational workflows
- Environment variable requirements

### Security Requirements

1. **No Hardcoded Secrets**: All credentials via environment variables
2. **Key Isolation**: SSH keys in gitignored directories, read-only mounts in container
3. **Least Privilege**: SSH user has minimal permissions on EC2 instance
4. **Audit Trail**: Log all SSH operations and commands executed
5. **Environment Separation**: Isolated configs per environment via .env files

## Governance

### Decision Authority

- **Architecture**: Technical lead
- **Security**: Security reviewer + team consensus
- **Specifications**: Author maintains, team reviews
- **Operations**: On-call engineer with team support

### Change Management

**Specification Changes**:
1. Update SKILL.md with new version
2. Document breaking changes in SSH procedures
3. Implement migration path if needed
4. Deprecate old version after transition period

**Implementation Changes**:
1. Must remain within spec scope
2. Breaking changes require spec update first
3. Backward compatibility preferred
4. SSH command updates tested in dev environment

**Configuration Changes**:
1. Test in dev environment first
2. Document in changelog
3. Update .env.example if adding variables
4. Verify SSH connectivity after changes

## Quality Metrics

1. **Spec Coverage**: 100% of capabilities have SKILL.md with SSH procedures
2. **Implementation Fidelity**: SSH commands match spec procedures exactly
3. **Security Compliance**: Zero hardcoded secrets, all SSH keys isolated
4. **Documentation Completeness**: Users can setup in <15 minutes
5. **Operational Reliability**: >99% successful SSH operation rate
6. **Skill Effectiveness**: Agent correctly references SKILL.md for all operations

## Revision History

- **v2.0.0**: Simplified architecture - SSH-based implementation
  - Removed MCP server layer
  - Direct SSH terminal tool integration
  - Streamlined skill specification workflow
  - Updated security requirements for SSH access

- **v1.0.0**: Initial constitution
  - Spec-driven development framework
  - Skill specification template
  - Risk classification system
  - EC2 WhatsApp integration (reference implementation)
