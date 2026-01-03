# AURA Devnet (aura-testnet-1)

Development network for the AURA blockchain. Access is limited to approved developers and contributors.

## Chain Information

| Property | Value |
|----------|-------|
| Chain ID | `aura-testnet-1` |
| Genesis Time | 2025-01-01T00:00:00Z |
| Native Denom | `uaura` |
| Binary | `aurad` |

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

## Artifacts

Genesis and configuration files are also available at:
https://artifacts.aurablockchain.org

## Faucet

Contact the AURA team for devnet tokens.
