# AURA Testnet (aura-testnet-1)

Development network for the AURA blockchain - a Cosmos SDK chain focused on identity verification and compliance.

## Chain Information

| Property | Value |
|----------|-------|
| Chain ID | `aura-testnet-1` |
| Genesis Time | 2025-01-01T00:00:00Z |
| Native Denom | `uaura` |
| Binary | `aurad` |
| Bech32 Prefix | `aura` |
| Cosmos SDK | v0.50.x |
| Go Version | 1.22+ |

## Hardware Requirements

| Specification | Minimum | Recommended |
|---------------|---------|-------------|
| CPU | 4 cores | 8 cores |
| RAM | 8 GB | 16 GB |
| Disk | 100 GB SSD | 500 GB NVMe |
| Network | 100 Mbps | 1 Gbps |

## Software Requirements

| Software | Version |
|----------|---------|
| Go | 1.22 or higher |
| Make | 4.0+ |
| Git | 2.0+ |
| jq | 1.6+ (for scripts) |

## Pre-built Binaries

Download pre-compiled binaries (recommended for quick setup):

| Platform | Architecture | Download | Checksum |
|----------|--------------|----------|----------|
| Linux | amd64 | [aurad-linux-amd64](https://artifacts.aurablockchain.org/bin/aurad-linux-amd64) | [SHA256](https://artifacts.aurablockchain.org/bin/SHA256SUMS) |
| Linux | arm64 | [aurad-linux-arm64](https://artifacts.aurablockchain.org/bin/aurad-linux-arm64) | [SHA256](https://artifacts.aurablockchain.org/bin/SHA256SUMS) |
| macOS | amd64 | [aurad-darwin-amd64](https://artifacts.aurablockchain.org/bin/aurad-darwin-amd64) | [SHA256](https://artifacts.aurablockchain.org/bin/SHA256SUMS) |
| macOS | arm64 | [aurad-darwin-arm64](https://artifacts.aurablockchain.org/bin/aurad-darwin-arm64) | [SHA256](https://artifacts.aurablockchain.org/bin/SHA256SUMS) |

```bash
# Example: Download and install on Linux amd64
curl -L https://artifacts.aurablockchain.org/bin/aurad-linux-amd64 -o aurad
chmod +x aurad
sudo mv aurad /usr/local/bin/
aurad version
```

## Public Artifacts

All artifacts available at: **https://artifacts.aurablockchain.org**

| File | URL | Description |
|------|-----|-------------|
| genesis.json | [Download](https://artifacts.aurablockchain.org/genesis.json) | Genesis file (required) |
| peers.txt | [Download](https://artifacts.aurablockchain.org/peers.txt) | Persistent peer list |
| seeds.txt | [Download](https://artifacts.aurablockchain.org/seeds.txt) | Seed nodes |
| addrbook.json | [Download](https://artifacts.aurablockchain.org/addrbook.json) | Address book |
| chain.json | [Download](https://artifacts.aurablockchain.org/chain.json) | Chain registry metadata |
| assetlist.json | [Download](https://artifacts.aurablockchain.org/assetlist.json) | Asset metadata |
| app.toml | [Download](https://artifacts.aurablockchain.org/config/app.toml) | Example app config |
| config.toml | [Download](https://artifacts.aurablockchain.org/config/config.toml) | Example node config |

## Snapshots

For faster sync, download a recent snapshot:

| Type | Size | Block Height | Download |
|------|------|--------------|----------|
| Pruned | ~5 GB | Updated daily | [Download](https://artifacts.aurablockchain.org/snapshots/aura-testnet-1-pruned-latest.tar.lz4) |
| Archive | ~20 GB | Updated weekly | [Download](https://artifacts.aurablockchain.org/snapshots/aura-testnet-1-archive-latest.tar.lz4) |

```bash
# Download and extract snapshot
curl -L https://artifacts.aurablockchain.org/snapshots/aura-testnet-1-pruned-latest.tar.lz4 | lz4 -dc - | tar -xf - -C ~/.aura
```

## Public Endpoints

| Service | URL | Status |
|---------|-----|--------|
| RPC | https://testnet-rpc.aurablockchain.org | [Status](https://status.aurablockchain.org) |
| REST API | https://testnet-api.aurablockchain.org | [Swagger](https://testnet-api.aurablockchain.org/swagger/) |
| gRPC | testnet-grpc.aurablockchain.org:443 | - |
| WebSocket | wss://testnet-ws.aurablockchain.org | - |
| Explorer | https://testnet-explorer.aurablockchain.org | - |
| Faucet | https://testnet-faucet.aurablockchain.org | - |
| Status Page | https://status.aurablockchain.org | - |

## API Documentation

- **REST API (Swagger)**: https://testnet-api.aurablockchain.org/swagger/
- **gRPC Reflection**: Enabled on testnet-grpc.aurablockchain.org:443
- **Cosmos SDK API Docs**: https://docs.cosmos.network/api

## Peers

```
575fa6d80a2740df7e1ef4111c1a9d394f23b73f@158.69.119.76:26656
4f3f81bcbdf15ec836b899c1a0982f02a2603f5d@139.99.149.160:26656
```

## Quick Start

### Option A: Pre-built Binary (Recommended)

```bash
# 1. Download binary
curl -L https://artifacts.aurablockchain.org/bin/aurad-linux-amd64 -o aurad
chmod +x aurad
sudo mv aurad /usr/local/bin/

# 2. Initialize node
aurad init <your-moniker> --chain-id aura-testnet-1

# 3. Download genesis
curl -o ~/.aura/config/genesis.json https://artifacts.aurablockchain.org/genesis.json

# 4. Download recommended config
curl -o ~/.aura/config/app.toml https://artifacts.aurablockchain.org/config/app.toml
curl -o ~/.aura/config/config.toml https://artifacts.aurablockchain.org/config/config.toml

# 5. Start node
aurad start
```

### Option B: Build from Source

```bash
# 1. Install Go 1.22+
# See https://golang.org/doc/install

# 2. Clone and build
git clone https://github.com/aura-blockchain/aura.git
cd aura
git checkout v0.1.0
make install

# 3. Verify installation
aurad version
# Expected: v0.1.0

# 4. Continue from step 2 above
```

### Configure Peers

```bash
PEERS="575fa6d80a2740df7e1ef4111c1a9d394f23b73f@158.69.119.76:26656,4f3f81bcbdf15ec836b899c1a0982f02a2603f5d@139.99.149.160:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.aura/config/config.toml
```

## State Sync (Fast Sync)

State sync allows rapid bootstrapping:

```bash
SNAP_RPC="https://testnet-rpc.aurablockchain.org:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true|" ~/.aura/config/config.toml
sed -i.bak -E "s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"|" ~/.aura/config/config.toml
sed -i.bak -E "s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT|" ~/.aura/config/config.toml
sed -i.bak -E "s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.aura/config/config.toml

aurad tendermint unsafe-reset-all --home ~/.aura --keep-addr-book
aurad start
```

## Get Testnet Tokens

Visit the faucet: https://testnet-faucet.aurablockchain.org

## Network Status

Check current network status:

- **Status Page**: https://status.aurablockchain.org
- **Current Block Height**: `curl -s https://testnet-rpc.aurablockchain.org/status | jq -r .result.sync_info.latest_block_height`
- **Network Info**: `curl -s https://testnet-rpc.aurablockchain.org/net_info | jq .result.n_peers`

## Become a Contributor

For validator access or development contribution:

1. **GitHub** - [Submit a Devnet Access Request](https://github.com/aura-blockchain/testnets/issues/new?template=devnet-access.yml)
2. **Email** - dev@aurablockchain.org
3. **Discord** - [discord.gg/RwQ8pma6](https://discord.gg/RwQ8pma6)

## Resources

- [AURA Core Repository](https://github.com/aura-blockchain/aura)
- [Documentation](https://testnet-docs.aurablockchain.org)
- [Block Explorer](https://testnet-explorer.aurablockchain.org)
- [API Swagger](https://testnet-api.aurablockchain.org/swagger/)
- [Status Page](https://status.aurablockchain.org)
