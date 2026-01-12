# Testnets Governance

## Overview

This document describes governance for AURA testnet operations, not on-chain governance. For on-chain governance, see the [AURA documentation](https://github.com/aura-blockchain/aura).

## Testnet Operations

### Network Upgrades

1. Core team announces upgrade with 7-day notice minimum
2. Upgrade proposal includes: target height, binary version, changelog
3. Validators coordinate via Discord/GitHub issues

### Validator Participation

**Joining**:
- Submit gentx during genesis ceremony, or
- Request validator slot via [Devnet Access](https://github.com/aura-blockchain/testnets/issues/new?template=devnet-access.yml)

**Requirements**:
- Maintain >90% uptime
- Respond to upgrade notices within 48 hours
- Follow security best practices

**Removal**:
- Extended downtime (>7 days unresponsive)
- Malicious behavior (double-signing, spam)
- Failure to upgrade after grace period

### Configuration Changes

| Change Type | Process |
|-------------|---------|
| Peer/seed updates | PR with node verification |
| Genesis parameters | Core team decision + announcement |
| Endpoint changes | PR with testing confirmation |

## Decision Making

- **Testnet resets**: Core team decision with 48-hour notice
- **Emergency actions**: Core team can act immediately, document after
- **Feature testing**: Coordinated via GitHub issues

## Communication

- **Primary**: GitHub Issues/Discussions
- **Real-time**: Discord #testnet channel
- **Announcements**: GitHub releases
