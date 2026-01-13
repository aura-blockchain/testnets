# AURA MVP Testnet (aura-mvp-1)

MVP release testnet with 12 essential modules for credential verification.

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

# Set seeds
sed -i 's/seeds = ""/seeds = "TBD@testnet-rpc.aurablockchain.org:10656"/' ~/.aura/config/config.toml

# Start node
./aurad start
```

## Endpoints

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
curl -X POST https://testnet-faucet.aurablockchain.org/request \
  -H "Content-Type: application/json" \
  -d '{"address": "aura1..."}'
```

## MVP Modules

**Cosmos SDK Standard**: auth, bank, staking, slashing, distribution, consensus, upgrade, params, genutil

**CosmWasm**: wasm

**AURA Custom**: identity, vcregistry, dataregistry, compliance, governance, prevalidation

## Resources

- [MVP Modules Documentation](https://docs.aurablockchain.org/mvp)
- [Transition Plan](../MVP_TESTNET_TRANSITION_PLAN.md)
- [Pre-Launch Checklist](../../aura-dev-team/MVP_PRELAUNCH_CHECKLIST.md)
