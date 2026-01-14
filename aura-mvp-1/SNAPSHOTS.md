# AURA Testnet Snapshots

> **Auto-updated**: 2026-01-14T01:00:01Z
> **Chain ID**: aura-mvp-1
> **Latest Height**: unknown

## Quick Start

### Download Latest Snapshot

```bash
# Download
curl -L https://artifacts.aurablockchain.org/aura-mvp-1/snapshots/latest.tar.lz4 -o snapshot.tar.lz4

# Extract (stop node first!)
lz4 -d snapshot.tar.lz4 | tar -xf - -C ~/.aura/data/
```

### Using wget with aria2 (faster)

```bash
aria2c -x 16 -s 16 https://artifacts.aurablockchain.org/aura-mvp-1/snapshots/latest.tar.lz4
```

## Snapshot Schedule

| Frequency | Time (UTC) | Retention |
|-----------|------------|-----------|
| Daily | 00:00 | 7 days |
| Weekly | Sunday 00:00 | 30 days |

## Available Snapshots

Check latest at: https://artifacts.aurablockchain.org/aura-mvp-1/snapshots/

## State Sync Alternative

For faster sync without downloading snapshots:

```bash
# Get state-sync info
curl -s https://artifacts.aurablockchain.org/aura-mvp-1/state-sync.json
```

See [state_sync.md](state_sync.md) for configuration details.

---
*This file is automatically updated by CI/CD. Do not edit manually.*
