# AURA MVP Testnet (aura-mvp-1)

MVP release testnet with credential verification modules.

## Network Architecture

The MVP testnet uses a **sentry node architecture** for DDoS protection.

```
[Your Node] → [Sentry Nodes] → [Validators (Private)]
                    ↓
             [Public Services]
```

## Quick Start

```bash
# Download binary
curl -LO https://artifacts.aurablockchain.org/mvp/v1.0.0-mvp/aurad-v1.0.0-mvp-linux-amd64
chmod +x aurad-v1.0.0-mvp-linux-amd64
mv aurad-v1.0.0-mvp-linux-amd64 aurad

# Initialize node
./aurad init my-node --chain-id aura-mvp-1

# Download genesis
curl -LO https://artifacts.aurablockchain.org/mvp/genesis.json
mv genesis.json ~/.aura/config/genesis.json

# Configure peers (connect to sentry nodes only)
PEERS="f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531@158.69.119.76:26681,35fdadb8b017fc95023a384c7769b946f363294e@139.99.149.160:26681"
sed -i "s/^persistent_peers = .*/persistent_peers = \"$PEERS\"/" ~/.aura/config/config.toml

# Start node
./aurad start
```

## Sentry Nodes

Connect your node to these public sentry nodes (NOT validators):

| Sentry | Server | P2P Address | Node ID |
|--------|--------|-------------|---------|
| sentry-1 | aura-testnet | 158.69.119.76:26681 | f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531 |
| sentry-2 | services-testnet | 139.99.149.160:26681 | 35fdadb8b017fc95023a384c7769b946f363294e |

**Persistent peers string:**
```
f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531@158.69.119.76:26681,35fdadb8b017fc95023a384c7769b946f363294e@139.99.149.160:26681
```

## Validators (Private Network)

Validators are protected behind sentries and NOT directly accessible.

| Validator | Server | Status |
|-----------|--------|--------|
| val1 | aura-testnet | Active |
| val2 | aura-testnet | Active |
| val3 | services-testnet | Active |
| val4 | services-testnet | Active |

## Public Endpoints

### Primary Endpoints (aura-testnet / sentry1)

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.aurablockchain.org |
| REST API | https://testnet-api.aurablockchain.org |
| gRPC | testnet-grpc.aurablockchain.org:443 |

### Secondary Endpoints (services-testnet / sentry2)

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc-2.aurablockchain.org |
| REST API | https://testnet-api-2.aurablockchain.org |

### Services

| Service | URL |
|---------|-----|
| Explorer (Ping.pub) | https://explorer.aurablockchain.org/aura |
| Legacy Explorer | https://testnet-explorer.aurablockchain.org |
| Faucet | https://testnet-faucet.aurablockchain.org |
| Artifacts | https://artifacts.aurablockchain.org |

## Faucet

Request testnet tokens:
```bash
curl -X POST https://testnet-faucet.aurablockchain.org/api/v1/faucet/request \
  -H "Content-Type: application/json" \
  -d '{"address": "aura1..."}'
```

## State Sync

Fast-sync to the network using state sync:

```bash
RPC="https://testnet-rpc.aurablockchain.org"
LATEST=$(curl -s "$RPC/block" | jq -r '.result.block.header.height')
TRUST_HEIGHT=$((LATEST - 2000))
TRUST_HASH=$(curl -s "$RPC/block?height=$TRUST_HEIGHT" | jq -r '.result.block_id.hash')

# Update config.toml
sed -i "s/enable = false/enable = true/" ~/.aura/config/config.toml
sed -i "s|rpc_servers = \"\"|rpc_servers = \"$RPC,$RPC\"|" ~/.aura/config/config.toml
sed -i "s/trust_height = 0/trust_height = $TRUST_HEIGHT/" ~/.aura/config/config.toml
sed -i "s/trust_hash = \"\"/trust_hash = \"$TRUST_HASH\"/" ~/.aura/config/config.toml
```

See [state_sync.md](state_sync.md) for auto-generated values.

## MVP Modules

**Cosmos SDK Standard**: auth, bank, staking, slashing, distribution, consensus, upgrade, params, genutil

**CosmWasm**: wasm

**AURA Custom**: identity, vcregistry, dataregistry, compliance, governance, prevalidation

## Chain Parameters

| Parameter | Value |
|-----------|-------|
| Chain ID | aura-mvp-1 |
| Denom | uaura |
| Block Time | ~5s |
| Validators | 4 |

## Resources

- [State Sync](state_sync.md)
- [Snapshots](SNAPSHOTS.md)
- [Public Endpoints](../docs/public-endpoints.md)
- [MVP Documentation](https://docs.aurablockchain.org/mvp)
