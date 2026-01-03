# AURA Devnet (aura-testnet-1)

Development network for the AURA blockchain.

## Access

This devnet is currently limited to approved developers and contributors. To request access:

1. Review the [AURA documentation](https://github.com/aura-blockchain/aura)
2. Contact the AURA team to request devnet tokens

Artifacts (genesis, binaries, configs) are publicly available. Token distribution requires approval.

## Chain Information

| Property | Value |
|----------|-------|
| Chain ID | `aura-testnet-1` |
| Genesis Time | 2025-01-01T00:00:00Z |
| Native Denom | `uaura` |
| Binary | `aurad` |

## Public Resources

| Resource | URL |
|----------|-----|
| Explorer | https://explorer.aurablockchain.org |
| Artifacts | https://artifacts.aurablockchain.org |

## Endpoints

| Service | URL |
|---------|-----|
| RPC | http://158.69.119.76:10657 |
| REST/LCD | http://158.69.119.76:10317 |
| gRPC | 158.69.119.76:10090 |
| P2P | 158.69.119.76:26656 |

## Peers

```
575fa6d80a2740df7e1ef4111c1a9d394f23b73f@158.69.119.76:26656
```

## Quick Start

### 1. Download genesis

```bash
curl -o ~/.aura/config/genesis.json https://raw.githubusercontent.com/aura-blockchain/testnets/main/aura-testnet-1/genesis.json
```

### 2. Set peers

Add to `~/.aura/config/config.toml`:

```toml
persistent_peers = "575fa6d80a2740df7e1ef4111c1a9d394f23b73f@158.69.119.76:26656"
```

### 3. Start node

```bash
aurad start --home ~/.aura
```

### 4. Request tokens

Contact the AURA team after your node is synced to receive devnet tokens.
