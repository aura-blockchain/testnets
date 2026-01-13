# AURA MVP Testnet (aura-mvp-1)

MVP release testnet with 12 essential modules for credential verification.

## Network Architecture

The MVP testnet uses a **sentry node architecture** for DDoS protection. External nodes connect to public sentry nodes, not directly to validators.

```
[Your Node] → [Sentry Nodes] → [Validators]
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

# Configure peers (connect to sentry nodes)
PEERS="f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531@158.69.119.76:26681,35fdadb8b017fc95023a384c7769b946f363294e@139.99.149.160:26681"
sed -i "s/^persistent_peers = .*/persistent_peers = \"$PEERS\"/" ~/.aura/config/config.toml

# Start node
./aurad start
```

## Sentry Nodes

Connect your node to these public sentry nodes:

| Sentry | Address | Node ID |
|--------|---------|---------|
| sentry-1 | 158.69.119.76:26681 | f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531 |
| sentry-2 | 139.99.149.160:26681 | 35fdadb8b017fc95023a384c7769b946f363294e |

**Persistent peers string:**
```
f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531@158.69.119.76:26681,35fdadb8b017fc95023a384c7769b946f363294e@139.99.149.160:26681
```

## Public Endpoints

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.aurablockchain.org |
| REST | https://testnet-api.aurablockchain.org |
| gRPC | testnet-grpc.aurablockchain.org:443 |
| Explorer | https://testnet-explorer.aurablockchain.org |
| Faucet | https://testnet-faucet.aurablockchain.org |

## Faucet

Request testnet tokens:
```bash
curl -X POST https://testnet-faucet.aurablockchain.org/api/v1/faucet/request \
  -H "Content-Type: application/json" \
  -d '{"address": "aura1..."}'
```

## MVP Modules

**Cosmos SDK Standard**: auth, bank, staking, slashing, distribution, consensus, upgrade, params, genutil

**CosmWasm**: wasm

**AURA Custom**: identity, vcregistry, dataregistry, compliance, governance, prevalidation

## State Sync (Coming Soon)

State sync configuration will be available after the network stabilizes.

## Resources

- [MVP Modules Documentation](https://docs.aurablockchain.org/mvp)
- [Transition Plan](../MVP_TESTNET_TRANSITION_PLAN.md)
