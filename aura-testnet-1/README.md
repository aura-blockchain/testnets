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

## Public Artifacts

All artifacts available at: **https://artifacts.aurablockchain.org**

| File | URL | Description |
|------|-----|-------------|
| genesis.json | [Download](https://artifacts.aurablockchain.org/genesis.json) | Genesis file (required) |
| peers.txt | [Download](https://artifacts.aurablockchain.org/peers.txt) | Persistent peer list |
| seeds.txt | [Download](https://artifacts.aurablockchain.org/seeds.txt) | Seed nodes |
| addrbook.json | [Download](https://artifacts.aurablockchain.org/addrbook.json) | Address book |
| chain.json | [Download](https://artifacts.aurablockchain.org/chain.json) | Chain registry metadata |

## Public Endpoints

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.aurablockchain.org |
| REST API | https://testnet-api.aurablockchain.org |
| gRPC | testnet-grpc.aurablockchain.org:443 |
| WebSocket | wss://testnet-ws.aurablockchain.org |
| Explorer | https://testnet-explorer.aurablockchain.org |
| Faucet | https://testnet-faucet.aurablockchain.org |

## Peers

```
575fa6d80a2740df7e1ef4111c1a9d394f23b73f@158.69.119.76:26656
4f3f81bcbdf15ec836b899c1a0982f02a2603f5d@139.99.149.160:26656
```

## Quick Start

### 1. Install Binary

```bash
git clone https://github.com/aura-blockchain/aura.git
cd aura
make install
```

### 2. Initialize Node

```bash
aurad init <your-moniker> --chain-id aura-testnet-1
```

### 3. Download Genesis

```bash
curl -o ~/.aura/config/genesis.json https://artifacts.aurablockchain.org/genesis.json
```

### 4. Configure Peers

```bash
PEERS="575fa6d80a2740df7e1ef4111c1a9d394f23b73f@158.69.119.76:26656,4f3f81bcbdf15ec836b899c1a0982f02a2603f5d@139.99.149.160:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.aura/config/config.toml
```

### 5. Start Node

```bash
aurad start
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

## Become a Contributor

For validator access or development contribution:

1. **GitHub** - [Submit a Devnet Access Request](https://github.com/aura-blockchain/testnets/issues/new?template=devnet-access.yml)
2. **Email** - dev@aurablockchain.org
3. **Discord** - [discord.gg/aura](https://discord.gg/aura)

## Resources

- [AURA Core Repository](https://github.com/aura-blockchain/aura)
- [Documentation](https://testnet-docs.aurablockchain.org)
- [Block Explorer](https://testnet-explorer.aurablockchain.org)
