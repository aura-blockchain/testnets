# AURA Devnet (aura-testnet-1)

Development network for the AURA blockchain.

## Become a Contributor

This devnet is for developers interested in long-term contribution to the AURA project. We're building a team of committed contributors to help develop, test, and improve the network before public launch.

### How to Apply

Choose any of the following methods:

1. **GitHub** - [Submit a Devnet Access Request](https://github.com/aura-blockchain/testnets/issues/new?template=devnet-access.yml)
2. **Email** - Contact dev@aurablockchain.org with your background and interest
3. **Discord** - Join [discord.gg/aura](https://discord.gg/aura) and introduce yourself in #devnet-applications

### What We're Looking For

- Developers with blockchain, Cosmos SDK, or smart contract experience
- Contributors interested in identity, compliance, and privacy modules
- Long-term commitment to the project
- Validators, node operators, and SDK developers

## Chain Information

| Property | Value |
|----------|-------|
| Chain ID | `aura-testnet-1` |
| Genesis Time | 2025-01-01T00:00:00Z |
| Native Denom | `uaura` |
| Binary | `aurad` |

## Public Resources

These resources are publicly accessible:

| Resource | URL |
|----------|-----|
| Explorer | https://explorer.aurablockchain.org |
| Artifacts | https://artifacts.aurablockchain.org |
| Documentation | https://github.com/aura-blockchain/aura |

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

## Quick Start (After Approval)

Once your access request is approved:

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

### 4. Receive tokens

After approval, you'll receive devnet tokens to your provided wallet address.
