# AURA Testnets Repository

## Repository Separation

**This repo (`aura-testnets/`)** → github:aura-blockchain/testnets (network config)
**Main repo (`aura/`)** → github:aura-blockchain/aura (source code)

### Save HERE (aura-testnets/<chain-id>/)
- genesis.json - network genesis file
- chain.json - chain registry metadata
- assetlist.json - token metadata
- versions.json - upgrade history
- peers.txt, seeds.txt - node addresses
- config/app.toml, config/config.toml - reference configs
- SNAPSHOTS.md, state_sync.md - sync guides
- README.md - network-specific docs
- bin/SHA256SUMS - binary checksums

### Save to MAIN REPO (aura/)
- Go source code, modules, CLI
- Protobuf definitions
- Tests, Makefiles, Dockerfiles
- General documentation

## Active Testnet: aura-mvp-1

The MVP testnet uses a **sentry node architecture** for DDoS protection.

### Sentry Architecture

External nodes connect to public sentry nodes, NOT directly to validators.

```
[External Nodes] → [Sentry-1/Sentry-2] → [Validators]
                         ↓
                   [Public Services]
```

### Sentry Nodes (Public P2P)

| Sentry | Server | P2P Address | Node ID |
|--------|--------|-------------|---------|
| sentry-1 | aura-testnet | 158.69.119.76:26681 | f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531 |
| sentry-2 | services-testnet | 139.99.149.160:26681 | 35fdadb8b017fc95023a384c7769b946f363294e |

### Validators (Private - NO direct access)

Validators are protected behind sentries with `pex=false`.

| Validator | Server | VPN Only |
|-----------|--------|----------|
| val1 | aura-testnet | 10.10.0.1:26656 |
| val2 | aura-testnet | 10.10.0.1:26756 |
| val3 | services-testnet | 10.10.0.4:26656 |
| val4 | services-testnet | 10.10.0.4:26756 |

### Public Endpoints

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.aurablockchain.org |
| REST API | https://testnet-api.aurablockchain.org |
| gRPC | testnet-grpc.aurablockchain.org:443 |
| Explorer | https://testnet-explorer.aurablockchain.org |
| Faucet | https://testnet-faucet.aurablockchain.org |

### Service Ports (aura-testnet)

| Service | Port |
|---------|------|
| Sentry RPC | 26680 |
| Sentry P2P | 26681 |
| Sentry API | 1380 |
| Sentry gRPC | 19080 |
| Explorer | 10080 |
| GraphQL | 10400 |
| WS Proxy | 10082 |
| Faucet | 8080 |
| cosmos-exporter | 9300 |

## Health Check

```bash
# On aura-testnet server
~/aura-health.sh

# Or run daemon mode
~/aura-health.sh daemon 60
```

## Connecting External Node

External nodes should connect to sentry nodes only:

```bash
# Set persistent peers to sentry nodes
PEERS="f5ce5e5ce5dd77bdbfd636fb8148756f6df9c531@158.69.119.76:26681,35fdadb8b017fc95023a384c7769b946f363294e@139.99.149.160:26681"
sed -i "s/^persistent_peers = .*/persistent_peers = \"$PEERS\"/" ~/.aura/config/config.toml
```

See `aura-mvp-1/README.md` for full setup instructions.
